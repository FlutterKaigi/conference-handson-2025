import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../domain/model/reading_books_domain_model.dart';
import '../../../../fundamental/debug/debug_logger.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../../model/view_model_packages.dart';
import 'components/delete_confirmation_sheet.dart';
import 'components/form_field.dart' as form_field;
import 'components/morphing_button.dart';

/// 読書記録編集ウィジェット
///
/// このウィジェットは以下の機能を提供します：
/// 1. 書籍情報の入力フォーム
/// 2. モーフィングボタンによる保存アニメーション
/// 3. 削除機能（編集モード時のみ）
class ReadingBookWidget
    extends ConsumerStagedWidget<ReadingBookValueObject, ReadingBookState> {
  const ReadingBookWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  ReadingBookState? createWidgetState() {
    return ReadingBookState();
  }

  @override
  void disposeState(ReadingBookState? state) {
    if (state != null) {
      state.nameController.dispose();
      state.totalPagesController.dispose();
      state.readingPageNumController.dispose();
      state.bookReviewController.dispose();
      state.formKey.currentState?.reset();
    }
    super.disposeState(state);
  }

  /// 書籍削除処理
  Future<void> _deleteBook(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBooksViewModel readingBooksViewModel,
  ) async {
    final bool? isConfirmDelete = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => DeleteConfirmationSheet(
        readingBook: readingBook,
        viewModel: readingBooksViewModel,
      ),
    );

    if (isConfirmDelete ?? false) {
      if (context.mounted) {
        debugLog('Deleting book: ${readingBook.name}');
        Navigator.pop(context, readingBook);
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ReadingBookValueObject value,
    ReadingBookState? state,
  ) {
    final ReadingProgressAnimationsViewModel animeVm = ref.read(
      readingProgressAnimationsProvider.notifier,
    );
    final ReadingBooksViewModel vm = ref.read(readingBooksProvider.notifier);
    final ReadingBookState controllers = state!;

    controllers.nameController.text = value.name;
    controllers.totalPagesController.text = value.totalPages.toString();
    controllers.readingPageNumController.text = value.readingPageNum.toString();
    controllers.bookReviewController.text = value.bookReview;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controllers.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ヘッダーセクション
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.1),
                      Theme.of(
                        context,
                      ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.auto_stories,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          vm.currentEditMode == ReadingBookEditMode.create
                              ? '新しい読書記録'
                              : '読書記録を編集',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '読書の進捗を記録して、学習の軌跡を残しましょう',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 書籍タイトル入力
              form_field.FormField(
                controller: controllers.nameController,
                label: '書籍タイトル',
                hint: '例: Flutter実践入門',
                prefixIcon: Icons.book,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return '書籍タイトルを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ページ数入力（総ページ数・読了ページ数）
              Row(
                children: <Widget>[
                  Expanded(
                    child: form_field.FormField(
                      controller: controllers.totalPagesController,
                      label: '総ページ数',
                      hint: '300',
                      prefixIcon: Icons.menu_book,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return '総ページ数を入力してください';
                        }
                        final int? pages = int.tryParse(value);
                        if (pages == null || pages <= 0) {
                          return '有効なページ数を入力してください';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: form_field.FormField(
                      controller: controllers.readingPageNumController,
                      label: '読了ページ数',
                      hint: '150',
                      prefixIcon: Icons.bookmark,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return '読了ページ数を入力してください';
                        }
                        final int? currentPage = int.tryParse(value);
                        if (currentPage == null || currentPage < 0) {
                          return '有効なページ数を入力してください';
                        }
                        final int? totalPages = int.tryParse(
                          controllers.totalPagesController.text,
                        );
                        if (totalPages != null && currentPage > totalPages) {
                          return '総ページ数を超えることはできません';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 書籍感想入力
              form_field.FormField(
                controller: controllers.bookReviewController,
                label: '書籍感想',
                hint: '読書の感想や学んだことを記録しましょう',
                prefixIcon: Icons.rate_review,
                maxLines: 4,
              ),
              const SizedBox(height: 40),

              // モーフィングボタン
              Center(
                child: MorphingButtonStateful(
                  value: value,
                  vm: vm,
                  animeVm: animeVm,
                  state: controllers,
                ),
              ),

              // 削除ボタン（編集モード時のみ）
              if (vm.currentEditMode == ReadingBookEditMode.edit) ...<Widget>[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _deleteBook(context, value, vm),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('この書籍を削除する'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// モーフィングボタンの状態
enum MorphingButtonState { idle, pressed, loading, success }

/// 読書記録フォームの状態管理クラス
///
/// フォームコントローラーとアニメーション状態を管理
class ReadingBookState {
  ReadingBookState();

  // フォーム関連
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
  final TextEditingController readingPageNumController =
      TextEditingController();
  final TextEditingController bookReviewController = TextEditingController();

  // アニメーションコントローラー
  AnimationController? morphingController;
  AnimationController? loadingController;
  AnimationController? pressController;

  // アニメーション
  Animation<double>? morphingAnimation;
  Animation<double>? loadingAnimation;
  Animation<double>? pressAnimation;

  // カレント・モーフィング状態種別（アニメーション描画切替に用います）
  MorphingButtonState currentMorphState = MorphingButtonState.idle;
  double loadingProgress = 0; // ローディング進捗率（0%〜100% ⇒ 0〜1.0）
  bool isPressed = false;
  bool isProcessing = false; // 連打防止フラグ

  /// モーフィングボタンアニメーションの初期化
  ///
  /// 3つのAnimationControllerで複雑なボタン変形を実現：
  /// 1. morphingController: ボタンの形状変化（幅・角丸・色の変化）
  /// 2. loadingController: ローディング中の回転アニメーション
  /// 3. pressController: タップ時のプレス効果（スケール変化）
  void initializeAnimations(TickerProvider vsync) {
    // 重複初期化を防止
    if (morphingController != null) {
      return;
    }

    // 1. モーフィングController（ボタン形状変化）
    morphingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );

    // 2. ローディングController（スピナー回転）
    loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    );

    // 3. プレスController（タップ効果）
    pressController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: vsync,
    );

    // 以下の３つのアニメーション・カーブ（変化曲線）設定は、
    // 「リニアに変化」や「だんだん早く」や「徐々に遅く」など
    // アニメーション変化の緩急指定をコードで扱えるようにするため、
    //
    // アニメーション期間をx、アニメーション変化をyとして、
    // それぞれの値範囲が 0%〜100%の進捗率とした二次関数を使い、
    // 幾つかの緩急パターンの変化曲線関数① が定義されている
    // Curve クラス② を使って設定したものです。
    //
    // ① だんだん早くなら y=x^2 など（ただし y=x ⇒ 0〜1.0）
    // ② Curves class
    // 　 https://api.flutter.dev/flutter/animation/Curves-class.html

    // モーフィング時のアニメーション・カーブ設定
    morphingAnimation = CurvedAnimation(
      parent: morphingController!,
      curve: Curves.easeOutCubic, // 滑らかに減速
    );

    // ローディング時のアニメーション・カーブ設定
    loadingAnimation = CurvedAnimation(
      parent: loadingController!,
      curve: Curves.easeInOut, // 加速→減速
    );

    // タップ時のアニメーション・カーブ設定
    pressAnimation = CurvedAnimation(
      parent: pressController!,
      curve: Curves.easeOut, // 素早いレスポンス
    );

    // ローディング進捗の連動設定
    loadingController!.addListener(() {
      loadingProgress = loadingController!.value;
    });
  }

  /// リソースの解放
  void dispose() {
    // AnimationControllerのdispose
    try {
      morphingController?.dispose();
    } catch (e) {
      // Ignore dispose errors
    }
    try {
      loadingController?.dispose();
    } catch (e) {
      // Ignore dispose errors
    }
    try {
      pressController?.dispose();
    } catch (e) {
      // Ignore dispose errors
    }

    // Animation参照のクリア
    morphingController = null;
    loadingController = null;
    pressController = null;
    morphingAnimation = null;
    loadingAnimation = null;
    pressAnimation = null;

    // TextControllerのdispose
    nameController.dispose();
    totalPagesController.dispose();
    readingPageNumController.dispose();
    bookReviewController.dispose();
  }
}
