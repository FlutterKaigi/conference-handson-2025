import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../domain/model/reading_books_domain_model.dart';
import '../../../../fundamental/debug/debug_logger.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../../model/view_model_packages.dart';

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

  /// フォーム送信処理のメインフロー
  ///
  /// 処理の流れ：
  /// 1. バリデーション実行
  /// 2. データの保存
  /// 3. モーフィングアニメーション実行
  /// 4. 画面遷移
  Future<void> _submitForm(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBooksViewModel readingBooksViewModel,
    SupportAnimationsViewModel supportAnimationsViewModel,
    ReadingBookState state,
  ) async {
    // 連打防止処理
    if (state.isProcessing) {
      return;
    }

    // バリデーションチェック
    if (!state.formKey.currentState!.validate()) {
      return;
    }

    state.formKey.currentState!.save();
    state.isProcessing = true;

    try {
      // Step 1: フォームデータの取得
      final _FormData formData = _getFormData(state);

      // Step 2: 更新前のページ数を保存（元のreadingBookから取得）
      final int prevReadingPageNum = readingBook.readingPageNum;

      // Step 3: データモデルの更新
      final ReadingBookValueObject editedReadingBook = _updateBookData(
        readingBooksViewModel,
        formData,
      );

      // Step 4: 進捗アニメーションの更新
      _updateProgressAnimation(
        supportAnimationsViewModel,
        editedReadingBook,
        prevReadingPageNum,
      );

      // Step 5: ボタンのモーフィングアニメーション実行
      await _performMorphingSequence(state);

      // Step 6: 画面遷移
      if (context.mounted) {
        await _navigateBack(context, editedReadingBook);
      }
    } finally {
      state.isProcessing = false;
    }
  }

  /// フォームデータの取得
  _FormData _getFormData(ReadingBookState state) {
    return _FormData(
      name: state.nameController.text,
      totalPages: int.tryParse(state.totalPagesController.text) ?? 0,
      readingPageNum: int.tryParse(state.readingPageNumController.text) ?? 0,
      bookReview: state.bookReviewController.text,
    );
  }

  /// 読書データの更新と保存
  ReadingBookValueObject _updateBookData(
    ReadingBooksViewModel viewModel,
    _FormData formData,
  ) {
    final ReadingBookValueObject editedBook = viewModel.updateReadingBook(
      name: formData.name,
      totalPages: formData.totalPages,
      readingPageNum: formData.readingPageNum,
      bookReview: formData.bookReview,
    );
    viewModel.commitReadingBook(editedBook);
    return editedBook;
  }

  /// 進捗アニメーションの更新
  void _updateProgressAnimation(
    SupportAnimationsViewModel animationViewModel,
    ReadingBookValueObject updatedBook,
    int previousPageNum,
  ) {
    animationViewModel.updateAnimationTypeIfProgressChange(
      updatedBook: updatedBook,
      prevReadingPageNum: previousPageNum,
    );
  }

  /// 画面遷移処理
  Future<void> _navigateBack(
    BuildContext context,
    ReadingBookValueObject editedBook,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (context.mounted) {
      Navigator.pop(context, editedBook);
    }
  }

  /// モーフィングボタンのアニメーションシーケンス
  ///
  /// 3つのフェーズで構成：
  /// Phase 1: ボタン押下アニメーション
  /// Phase 2: ローディングアニメーション
  /// Phase 3: 成功アニメーション
  Future<void> _performMorphingSequence(ReadingBookState state) async {
    try {
      // Phase 1: ボタン押下アニメーション
      await _animateButtonPress(state);

      // Phase 2: ローディングアニメーション
      await _animateLoading(state);

      // Phase 3: 成功アニメーション
      await _animateSuccess(state);
    } finally {
      _resetAnimationState(state);
    }
  }

  /// Phase 1: ボタン押下アニメーション
  /// ボタンが押されたことを視覚的・触覚的にフィードバック
  Future<void> _animateButtonPress(ReadingBookState state) async {
    state.currentMorphState = MorphingButtonState.pressed;
    unawaited(HapticFeedback.lightImpact()); // 軽い振動フィードバック

    // モーフィング開始
    if (state.morphingController != null) {
      unawaited(state.morphingController!.forward());
    }

    // プレスアニメーション（押す→戻る）
    if (state.pressController != null) {
      await state.pressController!.forward();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await state.pressController!.reverse();
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  /// Phase 2: ローディングアニメーション
  /// データ処理中を表現する回転アニメーション
  Future<void> _animateLoading(ReadingBookState state) async {
    state.currentMorphState = MorphingButtonState.loading;

    // ボタンを円形に変形
    if (state.morphingController != null) {
      await state.morphingController!.forward();
    }

    // ローディングプログレス表示
    await _showLoadingProgress(state);
  }

  /// ローディングプログレスの表示
  Future<void> _showLoadingProgress(ReadingBookState state) async {
    if (state.loadingController != null) {
      state.loadingController!.reset();
      unawaited(state.loadingController!.repeat());
    }

    // プログレスバーのアニメーション（0% → 100%）
    for (int i = 0; i <= 100; i += 10) {
      state.loadingProgress = i / 100.0;
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }

    state.loadingController?.stop();
  }

  /// Phase 3: 成功アニメーション
  /// 処理完了を祝福するアニメーション
  Future<void> _animateSuccess(ReadingBookState state) async {
    state.currentMorphState = MorphingButtonState.success;
    unawaited(HapticFeedback.mediumImpact()); // 中程度の振動フィードバック

    // バウンス効果で成功を表現
    if (state.morphingController != null) {
      await state.morphingController!.reverse();
      await state.morphingController!.forward();
    }

    // 成功状態を維持（視認性のため長めに表示）
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  /// アニメーション状態のリセット
  void _resetAnimationState(ReadingBookState state) {
    state.morphingController?.reset();
    state.loadingController?.reset();
    state.pressController?.reset();
    state.loadingProgress = 0;
    state.currentMorphState = MorphingButtonState.idle;
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
      builder: (BuildContext context) => _buildDeleteConfirmationSheet(
        context,
        readingBook,
        readingBooksViewModel,
      ),
    );

    if (isConfirmDelete ?? false) {
      if (context.mounted) {
        debugLog('Deleting book: ${readingBook.name}');
        Navigator.pop(context, readingBook);
      }
    }
  }

  /// 削除確認ボトムシート
  Widget _buildDeleteConfirmationSheet(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBooksViewModel readingBooksViewModel,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(
            Icons.delete_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '書籍を削除',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '「${readingBook.name}」を削除してもよろしいですか？\nこの操作は取り消せません。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('キャンセル'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    readingBooksViewModel.removeReadingBook();
                    readingBooksViewModel.commitReadingBook(readingBook);
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    '削除する',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// フォームフィールドのビルダー
  /// 共通のテキストフィールドUIを生成
  Widget _buildFormField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
    );
  }

  /// モーフィングボタンのビルド
  Widget _buildSophisticatedMorphingButton(
    BuildContext context,
    ReadingBookValueObject value,
    ReadingBooksViewModel vm,
    SupportAnimationsViewModel animeVm,
    ReadingBookState state,
  ) {
    return _MorphingButtonStateful(
      value: value,
      vm: vm,
      state: state,
      onSubmit:
          (
            BuildContext context,
            ReadingBookValueObject value,
            ReadingBooksViewModel vm,
            ReadingBookState state,
          ) => _submitForm(context, value, vm, animeVm, state),
      getButtonWidth: _getButtonWidth,
      getBorderRadius: _getBorderRadius,
      getButtonGradient: _getButtonGradient,
      getButtonShadowColor: _getButtonShadowColor,
    );
  }

  /// ボタンの幅を状態に応じて決定
  double _getButtonWidth(ReadingBookState state) {
    switch (state.currentMorphState) {
      case MorphingButtonState.idle:
        return 200;
      case MorphingButtonState.pressed:
        return 190;
      case MorphingButtonState.loading:
        return 64;
      case MorphingButtonState.success:
        return 64;
    }
  }

  /// ボタンの角丸を状態に応じて決定
  double _getBorderRadius(ReadingBookState state) {
    switch (state.currentMorphState) {
      case MorphingButtonState.idle:
      case MorphingButtonState.pressed:
        return 16;
      case MorphingButtonState.loading:
      case MorphingButtonState.success:
        return 32;
    }
  }

  /// ボタンのグラデーションを状態に応じて決定
  LinearGradient _getButtonGradient(
    BuildContext context,
    ReadingBookState state,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    switch (state.currentMorphState) {
      case MorphingButtonState.idle:
        return LinearGradient(
          colors: <Color>[colorScheme.primary, colorScheme.primaryContainer],
        );
      case MorphingButtonState.pressed:
        return LinearGradient(
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.8),
            colorScheme.primaryContainer.withValues(alpha: 0.8),
          ],
        );
      case MorphingButtonState.loading:
        return LinearGradient(
          colors: <Color>[
            colorScheme.secondary,
            colorScheme.secondaryContainer,
          ],
        );
      case MorphingButtonState.success:
        return const LinearGradient(
          colors: <Color>[Color(0xFF4CAF50), Color(0xFF81C784)],
        );
    }
  }

  /// ボタンの影の色を状態に応じて決定
  Color _getButtonShadowColor(BuildContext context, ReadingBookState state) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    switch (state.currentMorphState) {
      case MorphingButtonState.idle:
      case MorphingButtonState.pressed:
        return colorScheme.primary;
      case MorphingButtonState.loading:
        return colorScheme.secondary;
      case MorphingButtonState.success:
        return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ReadingBookValueObject value,
    ReadingBookState? state,
  ) {
    final SupportAnimationsViewModel animeVm = ref.read(
      supportAnimationsProvider.notifier,
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
              _buildFormField(
                context,
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
                    child: _buildFormField(
                      context,
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
                    child: _buildFormField(
                      context,
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
              _buildFormField(
                context,
                controller: controllers.bookReviewController,
                label: '書籍感想',
                hint: '読書の感想や学んだことを記録しましょう',
                prefixIcon: Icons.rate_review,
                maxLines: 4,
              ),
              const SizedBox(height: 40),

              // モーフィングボタン
              Center(
                child: _buildSophisticatedMorphingButton(
                  context,
                  value,
                  vm,
                  animeVm,
                  controllers,
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

/// フォームデータを保持する構造体
class _FormData {
  const _FormData({
    required this.name,
    required this.totalPages,
    required this.readingPageNum,
    required this.bookReview,
  });
  final String name;
  final int totalPages;
  final int readingPageNum;
  final String bookReview;
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

  // 状態管理
  MorphingButtonState currentMorphState = MorphingButtonState.idle;
  double loadingProgress = 0;
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

    // アニメーションカーブの設定
    morphingAnimation = CurvedAnimation(
      parent: morphingController!,
      curve: Curves.easeOutCubic, // 滑らかに減速
    );

    loadingAnimation = CurvedAnimation(
      parent: loadingController!,
      curve: Curves.easeInOut, // 加速→減速
    );

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

/// モーフィングボタンのコンテンツ描画用CustomPainter
///
/// ボタンの状態に応じて異なるコンテンツを描画：
/// - idle/pressed: テキスト（「登録する」「更新する」）
/// - loading: アニメーション付きスピナー
/// - success: チェックマーク＋グロー効果
class MorphingButtonContentPainter extends CustomPainter {
  MorphingButtonContentPainter({
    required this.morphState,
    required this.loadingProgress,
    required this.colorScheme,
    required this.isCreateMode,
  });

  final MorphingButtonState morphState;
  final double loadingProgress;
  final ColorScheme colorScheme;
  final bool isCreateMode;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    switch (morphState) {
      case MorphingButtonState.idle:
      case MorphingButtonState.pressed:
        _drawTextContent(canvas, size);
      case MorphingButtonState.loading:
        _drawLoadingContent(canvas, center);
      case MorphingButtonState.success:
        _drawSuccessContent(canvas, center);
    }
  }

  /// テキストコンテンツの描画
  void _drawTextContent(Canvas canvas, Size size) {
    final String text = isCreateMode ? '登録する' : '更新する';
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final Offset textOffset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  /// ローディングスピナーの描画
  void _drawLoadingContent(Canvas canvas, Offset center) {
    // スピナー本体
    final Paint spinnerPaint = Paint()
      ..color = colorScheme.onSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 進捗に応じた円弧を描画
    final double sweepAngle = 2 * math.pi * loadingProgress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 12),
      -math.pi / 2, // 12時方向から開始
      sweepAngle, // 進捗に応じた角度
      false,
      spinnerPaint,
    );

    // 背景円
    final Paint backgroundPaint = Paint()
      ..color = colorScheme.onSecondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, 12, backgroundPaint);
  }

  /// 成功時のチェックマーク描画
  void _drawSuccessContent(Canvas canvas, Offset center) {
    // チェックマーク
    final Paint checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final Path checkPath = Path();
    checkPath.moveTo(center.dx - 8, center.dy);
    checkPath.lineTo(center.dx - 2, center.dy + 6);
    checkPath.lineTo(center.dx + 8, center.dy - 6);

    canvas.drawPath(checkPath, checkPaint);

    // グロー効果
    final Paint glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, 16, glowPaint);
  }

  @override
  bool shouldRepaint(MorphingButtonContentPainter oldDelegate) {
    return morphState != oldDelegate.morphState ||
        loadingProgress != oldDelegate.loadingProgress ||
        isCreateMode != oldDelegate.isCreateMode;
  }
}

/// モーフィングボタンのStatefulWidget
class _MorphingButtonStateful extends StatefulWidget {
  const _MorphingButtonStateful({
    required this.value,
    required this.vm,
    required this.state,
    required this.onSubmit,
    required this.getButtonWidth,
    required this.getBorderRadius,
    required this.getButtonGradient,
    required this.getButtonShadowColor,
  });

  final ReadingBookValueObject value;
  final ReadingBooksViewModel vm;
  final ReadingBookState state;
  final Future<void> Function(
    BuildContext,
    ReadingBookValueObject,
    ReadingBooksViewModel,
    ReadingBookState,
  )
  onSubmit;
  final double Function(ReadingBookState) getButtonWidth;
  final double Function(ReadingBookState) getBorderRadius;
  final LinearGradient Function(BuildContext, ReadingBookState)
  getButtonGradient;
  final Color Function(BuildContext, ReadingBookState) getButtonShadowColor;

  @override
  State<_MorphingButtonStateful> createState() =>
      _MorphingButtonStatefulState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReadingBookValueObject>('value', value));
    properties.add(DiagnosticsProperty<ReadingBooksViewModel>('vm', vm));
    properties.add(DiagnosticsProperty<ReadingBookState>('state', state));
    properties.add(
      ObjectFlagProperty<
        Future<void> Function(
          BuildContext p1,
          ReadingBookValueObject p2,
          ReadingBooksViewModel p3,
          ReadingBookState p4,
        )
      >.has('onSubmit', onSubmit),
    );
    properties.add(
      ObjectFlagProperty<double Function(ReadingBookState p1)>.has(
        'getButtonWidth',
        getButtonWidth,
      ),
    );
    properties.add(
      ObjectFlagProperty<double Function(ReadingBookState p1)>.has(
        'getBorderRadius',
        getBorderRadius,
      ),
    );
    properties.add(
      ObjectFlagProperty<
        LinearGradient Function(BuildContext p1, ReadingBookState p2)
      >.has('getButtonGradient', getButtonGradient),
    );
    properties.add(
      ObjectFlagProperty<
        Color Function(BuildContext p1, ReadingBookState p2)
      >.has('getButtonShadowColor', getButtonShadowColor),
    );
  }
}

class _MorphingButtonStatefulState extends State<_MorphingButtonStateful>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // アニメーション初期化
    widget.state.initializeAnimations(this);
  }

  @override
  void dispose() {
    // AnimationControllerのdispose
    widget.state.morphingController?.dispose();
    widget.state.loadingController?.dispose();
    widget.state.pressController?.dispose();

    // 参照クリア
    widget.state.morphingController = null;
    widget.state.loadingController = null;
    widget.state.pressController = null;
    widget.state.morphingAnimation = null;
    widget.state.loadingAnimation = null;
    widget.state.pressAnimation = null;

    super.dispose();
  }

  /// モーフィングボタンのUI構築
  @override
  Widget build(BuildContext context) {
    // 複数アニメーションの統合監視
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        widget.state.morphingController ??
            widget.state.loadingController ??
            const AlwaysStoppedAnimation<double>(0),
        widget.state.pressController ?? const AlwaysStoppedAnimation<double>(0),
      ]),
      builder: (BuildContext context, Widget? child) {
        return GestureDetector(
          onTapDown: (_) {
            if (!widget.state.isProcessing &&
                widget.state.currentMorphState == MorphingButtonState.idle) {
              unawaited(widget.state.pressController?.forward());
              setState(() {
                widget.state.isPressed = true;
              });
            }
          },
          onTapUp: (_) {
            if (!widget.state.isProcessing) {
              unawaited(widget.state.pressController?.reverse());
              setState(() {
                widget.state.isPressed = false;
              });
            }
          },
          onTapCancel: () {
            if (!widget.state.isProcessing) {
              unawaited(widget.state.pressController?.reverse());
              setState(() {
                widget.state.isPressed = false;
              });
            }
          },
          onTap:
              !widget.state.isProcessing &&
                  widget.state.currentMorphState == MorphingButtonState.idle
              ? () async {
                  await widget.onSubmit(
                    context,
                    widget.value,
                    widget.vm,
                    widget.state,
                  );
                }
              : null,
          child: Transform.scale(
            scale: 1.0 - (widget.state.pressAnimation?.value ?? 0) * 0.05,
            child: SizedBox(
              width: _getAnimatedButtonWidth(),
              height: _getAnimatedButtonHeight(),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // 背景とモーフィング効果
                  _buildMorphingBackground(),

                  // グロー効果
                  _buildGlowEffects(),

                  // コンテンツ
                  _buildAnimatedContent(),

                  // リップル効果
                  _buildRippleEffects(),

                  // プログレスオーバーレイ
                  _buildProgressOverlay(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ボタン幅のアニメーション計算
  double _getAnimatedButtonWidth() {
    final double baseWidth = widget.getButtonWidth(widget.state);
    final double morphValue = widget.state.morphingAnimation?.value ?? 0;

    switch (widget.state.currentMorphState) {
      case MorphingButtonState.idle:
      case MorphingButtonState.pressed:
        return baseWidth;
      case MorphingButtonState.loading:
        return 200 + (64 - 200) * morphValue;
      case MorphingButtonState.success:
        return 64;
    }
  }

  /// ボタン高さ（固定）
  double _getAnimatedButtonHeight() {
    return 64;
  }

  /// モーフィング背景の構築
  Widget _buildMorphingBackground() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          widget.getBorderRadius(widget.state),
        ),
        gradient: widget.getButtonGradient(context, widget.state),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: widget
                .getButtonShadowColor(context, widget.state)
                .withValues(alpha: 0.3),
            blurRadius: 12 + (widget.state.pressAnimation?.value ?? 0) * 8,
            offset: Offset(
              0,
              4 - (widget.state.pressAnimation?.value ?? 0) * 2,
            ),
          ),
          BoxShadow(
            color: widget
                .getButtonShadowColor(context, widget.state)
                .withValues(alpha: 0.1),
            blurRadius: 24 + (widget.state.pressAnimation?.value ?? 0) * 16,
            offset: Offset(
              0,
              8 - (widget.state.pressAnimation?.value ?? 0) * 4,
            ),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          widget.getBorderRadius(widget.state),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(
            widget.getBorderRadius(widget.state),
          ),
          onTap: widget.state.currentMorphState == MorphingButtonState.idle
              ? () async {
                  await widget.onSubmit(
                    context,
                    widget.value,
                    widget.vm,
                    widget.state,
                  );
                }
              : null,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  /// グロー効果の構築
  Widget _buildGlowEffects() {
    if (widget.state.currentMorphState == MorphingButtonState.success) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
              blurRadius: 25,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: const Color(0xFF81C784).withValues(alpha: 0.6),
              blurRadius: 40,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              blurRadius: 60,
              spreadRadius: 5,
            ),
          ],
        ),
      );
    } else if (widget.state.currentMorphState == MorphingButtonState.loading) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// アニメーションコンテンツの構築
  Widget _buildAnimatedContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CustomPaint(
        size: Size(_getAnimatedButtonWidth(), 64),
        painter: MorphingButtonContentPainter(
          morphState: widget.state.currentMorphState,
          loadingProgress: widget.state.loadingProgress,
          colorScheme: Theme.of(context).colorScheme,
          isCreateMode: widget.vm.currentEditMode == ReadingBookEditMode.create,
        ),
      ),
    );
  }

  /// リップル効果の構築
  Widget _buildRippleEffects() {
    if (widget.state.currentMorphState == MorphingButtonState.loading) {
      return CustomPaint(
        size: Size(_getAnimatedButtonWidth(), 64),
        painter: _RippleEffectPainter(
          animation: widget.state.loadingAnimation?.value ?? 0,
          colorScheme: Theme.of(context).colorScheme,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// プログレスオーバーレイの構築
  Widget _buildProgressOverlay() {
    if (widget.state.currentMorphState == MorphingButtonState.loading) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          widget.getBorderRadius(widget.state),
        ),
        child: LinearProgressIndicator(
          value: widget.state.loadingProgress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.3),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// リップル効果描画用CustomPainter
class _RippleEffectPainter extends CustomPainter {
  _RippleEffectPainter({required this.animation, required this.colorScheme});

  final double animation;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width / 2;

    // 複数の波紋を描画
    for (int i = 0; i < 3; i++) {
      final double waveDelay = i * 0.3;
      final double waveAnimation = (animation - waveDelay).clamp(0.0, 1.0);

      if (waveAnimation > 0) {
        final double radius = maxRadius * waveAnimation;
        final double opacity = (1.0 - waveAnimation) * 0.3;

        final Paint ripplePaint = Paint()
          ..color = colorScheme.onSecondary.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawCircle(center, radius, ripplePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_RippleEffectPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
