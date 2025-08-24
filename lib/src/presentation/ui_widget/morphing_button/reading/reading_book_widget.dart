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

  Future<void> _submitForm(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBooksViewModel readingBooksViewModel,
    ReadingBookState state,
  ) async {
    // Prevent button spam
    if (state.isProcessing) {
      return;
    }

    if (state.formKey.currentState!.validate()) {
      state.formKey.currentState!.save();
      state.isProcessing = true;

      try {
        // Prepare data before animation
        final String name = state.nameController.text;
        final int totalPages =
            int.tryParse(state.totalPagesController.text) ?? 0;
        final int readingPageNum =
            int.tryParse(state.readingPageNumController.text) ?? 0;
        final String bookReview = state.bookReviewController.text;

        // Update data model
        final ReadingBookValueObject editedReadingBook = readingBooksViewModel
            .updateReadingBook(
              name: name,
              totalPages: totalPages,
              readingPageNum: readingPageNum,
              bookReview: bookReview,
            );
        readingBooksViewModel.commitReadingBook(editedReadingBook);

        // Start morphing animation sequence
        await _performMorphingSequence(state);

        // Add transition delay for better visual feedback
        await Future<void>.delayed(const Duration(milliseconds: 400));

        // Navigate back after animation completes
        if (context.mounted) {
          Navigator.pop(context, editedReadingBook);
        }
      } finally {
        // Always reset processing state
        state.isProcessing = false;
      }
    }
  }

  Future<void> _performMorphingSequence(ReadingBookState state) async {
    try {
      // Phase 1: Button press with sophisticated animation
      state.currentMorphState = MorphingButtonState.pressed;
      unawaited(HapticFeedback.lightImpact());

      // Start morphing animation
      if (state.morphingController != null) {
        unawaited(state.morphingController!.forward());
      }

      // Press animation with haptic feedback
      if (state.pressController != null) {
        await state.pressController!.forward();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await state.pressController!.reverse();
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }

      // Phase 2: Morph to loading state with smooth transition
      state.currentMorphState = MorphingButtonState.loading;

      // Smooth morphing transition
      if (state.morphingController != null) {
        await state.morphingController!.forward();
      }

      // Start loading animation with ripple effects
      if (state.loadingController != null) {
        // Reset and start loading animation
        state.loadingController!.reset();

        // Create sophisticated loading sequence with ripples
        unawaited(state.loadingController!.repeat());

        // Simulate actual work with progress updates
        for (int i = 0; i <= 100; i += 10) {
          state.loadingProgress = i / 100.0;
          await Future<void>.delayed(const Duration(milliseconds: 25));
        }

        // Stop loading animation
        state.loadingController!.stop();
      } else {
        // Fallback loading with enhanced visual feedback
        for (int i = 0; i <= 100; i += 10) {
          state.loadingProgress = i / 100.0;
          await Future<void>.delayed(const Duration(milliseconds: 25));
        }
      }

      // Phase 3: Success state with celebration
      state.currentMorphState = MorphingButtonState.success;
      unawaited(HapticFeedback.mediumImpact());

      // Success celebration animation
      if (state.morphingController != null) {
        // Quick bounce effect for success
        await state.morphingController!.reverse();
        await state.morphingController!.forward();
      }

      // Hold success state with glow effect - EXTENDED for visibility
      await Future<void>.delayed(const Duration(milliseconds: 800));
    } finally {
      // Reset all animation controllers to initial state
      state.morphingController?.reset();
      state.loadingController?.reset();
      state.pressController?.reset();
      state.loadingProgress = 0;
      state.currentMorphState = MorphingButtonState.idle;
    }
  }

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

  Widget _buildSophisticatedMorphingButton(
    BuildContext context,
    ReadingBookValueObject value,
    ReadingBooksViewModel vm,
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
          ) => _submitForm(context, value, vm, state),
      getButtonWidth: _getButtonWidth,
      getBorderRadius: _getBorderRadius,
      getButtonGradient: _getButtonGradient,
      getButtonShadowColor: _getButtonShadowColor,
    );
  }

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

              _buildFormField(
                context,
                controller: controllers.bookReviewController,
                label: '書籍感想',
                hint: '読書の感想や学んだことを記録しましょう',
                prefixIcon: Icons.rate_review,
                maxLines: 4,
              ),
              const SizedBox(height: 40),

              Center(
                child: _buildSophisticatedMorphingButton(
                  context,
                  value,
                  vm,
                  controllers,
                ),
              ),

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

enum MorphingButtonState { idle, pressed, loading, success }

class ReadingBookState {
  ReadingBookState();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
  final TextEditingController readingPageNumController =
      TextEditingController();
  final TextEditingController bookReviewController = TextEditingController();

  // Animation controllers - will be initialized with proper vsync
  AnimationController? morphingController;
  AnimationController? loadingController;
  AnimationController? pressController;

  // Animations
  Animation<double>? morphingAnimation;
  Animation<double>? loadingAnimation;
  Animation<double>? pressAnimation;

  MorphingButtonState currentMorphState = MorphingButtonState.idle;
  double loadingProgress = 0;
  bool isPressed = false;
  bool isProcessing = false; // Prevent button spam

  /// モーフィングボタンアニメーションの初期化
  /// 
  /// 3つのAnimationControllerで複雑なボタン変形を実現：
  /// 1. morphingController: ボタンの形状変化（幅・角丸・色の変化）
  /// 2. loadingController: ローディング中の回転アニメーション
  /// 3. pressController: タップ時のプレス効果（スケール変化）
  /// 
  /// 各アニメーションは異なるCurveを使い分けて自然な動作を実現
  void initializeAnimations(TickerProvider vsync) {
    // 重複初期化を防止
    if (morphingController != null) {
      return;
    }

    // 1. モーフィングController（ボタン形状変化）
    // 600ms でボタンが矩形 → 円形に変形
    morphingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );

    // 2. ローディングController（スピナー回転）
    // 2秒でローディングアニメーションが完了
    loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    );

    // 3. プレスController（タップ効果）
    // 200ms でプレス効果（スケール縮小→元に戻る）
    pressController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: vsync,
    );

    // CurvedAnimation: 線形変化を自然なカーブに変換
    morphingAnimation = CurvedAnimation(
      parent: morphingController!,
      curve: Curves.easeOutCubic,      // 滑らかに減速（形状変化に適している）
    );

    loadingAnimation = CurvedAnimation(
      parent: loadingController!,
      curve: Curves.easeInOut,         // 加速→減速（回転に適している）
    );

    pressAnimation = CurvedAnimation(
      parent: pressController!,
      curve: Curves.easeOut,           // 素早いレスポンス（タップ効果に適している）
    );

    // ローディング進捗の連動設定
    // AnimationController.value の変化を loadingProgress に自動反映
    loadingController!.addListener(() {
      loadingProgress = loadingController!.value;
    });
  }

  void dispose() {
    // Safely dispose animation controllers only if they exist
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

    // Clear animation references
    morphingController = null;
    loadingController = null;
    pressController = null;
    morphingAnimation = null;
    loadingAnimation = null;
    pressAnimation = null;

    // Dispose text controllers
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
/// 
/// CustomPainterを使うことで：
/// - 状態変化に応じた滑らかなコンテンツ切り替え
/// - 複雑な図形（チェックマーク、スピナー）の高品質描画
/// - パフォーマンス最適化（shouldRepaintによる再描画制御）
class MorphingButtonContentPainter extends CustomPainter {
  MorphingButtonContentPainter({
    required this.morphState,
    required this.loadingProgress,
    required this.colorScheme,
    required this.isCreateMode,
  });

  /// 現在のモーフィング状態
  final MorphingButtonState morphState;
  /// ローディングの進捗（0.0〜1.0）
  final double loadingProgress;
  /// Material Design 3 カラースキーム
  final ColorScheme colorScheme;
  /// 作成モードか編集モードかの判定
  final bool isCreateMode;

  /// Canvas描画メソッド（状態変化時に呼ばれる）
  /// 
  /// モーフィング状態に応じて適切な描画メソッドを呼び分け：
  /// 1. idle/pressed → テキスト描画
  /// 2. loading → スピナー描画  
  /// 3. success → チェックマーク描画
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    switch (morphState) {
      case MorphingButtonState.idle:
      case MorphingButtonState.pressed:
        _drawTextContent(canvas, size);        // テキスト描画
      case MorphingButtonState.loading:
        _drawLoadingContent(canvas, center);   // ローディングスピナー描画
      case MorphingButtonState.success:
        _drawSuccessContent(canvas, center);   // 成功チェックマーク描画
    }
  }

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
  /// 
  /// アニメーション付きの円弧スピナーを実現：
  /// - loadingProgress (0.0〜1.0) に応じて円弧の角度が変化
  /// - 背景円（薄い色）+ 進捗円弧（濃い色）の組み合わせ
  /// - StrokeCap.round で線端を丸くして洗練された見た目
  void _drawLoadingContent(Canvas canvas, Offset center) {
    // アニメーション付きスピナー（前景）
    final Paint spinnerPaint = Paint()
      ..color = colorScheme.onSecondary           // セカンダリカラーの文字色
      ..style = PaintingStyle.stroke              // 線だけ描画
      ..strokeWidth = 3                           // 線の太さ
      ..strokeCap = StrokeCap.round;             // 線端を丸く

    // loadingProgress に基づいて円弧の角度を計算
    // 0.0 → 0°, 1.0 → 360°（2π）
    final double sweepAngle = 2 * math.pi * loadingProgress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 12), // 半径12の円
      -math.pi / 2,                                // 12時方向から開始
      sweepAngle,                                  // 進捗に応じた角度
      false,                                       // 扇形ではなく円弧
      spinnerPaint,
    );

    // 背景円（薄い色のガイドライン）
    final Paint backgroundPaint = Paint()
      ..color = colorScheme.onSecondary.withValues(alpha: 0.3) // 半透明
      ..style = PaintingStyle.stroke                            // 線だけ描画
      ..strokeWidth = 3;                                       // 同じ太さ

    canvas.drawCircle(center, 12, backgroundPaint);
  }

  /// 成功時のチェックマーク描画
  /// 
  /// 成功状態の視覚的フィードバック：
  /// - Pathを使ったカスタムチェックマーク形状
  /// - グロー効果による祝福感の演出
  /// - 白色で統一された清潔な成功表現
  void _drawSuccessContent(Canvas canvas, Offset center) {
    // チェックマークの描画設定
    final Paint checkPaint = Paint()
      ..color = Colors.white                   // 白色（成功の象徴）
      ..style = PaintingStyle.stroke          // 線だけ描画
      ..strokeWidth = 3                       // やや太い線
      ..strokeCap = StrokeCap.round;         // 線端を丸く

    // チェックマーク形状をPathで定義
    // ✓ の形を3つの座標点で描画
    final Path checkPath = Path();
    checkPath.moveTo(center.dx - 8, center.dy);     // 左端点
    checkPath.lineTo(center.dx - 2, center.dy + 6); // 中央下点（チェックの角）
    checkPath.lineTo(center.dx + 8, center.dy - 6); // 右上端点

    canvas.drawPath(checkPath, checkPaint);

    // 成功グロー効果（祝福感の演出）
    final Paint glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3) // 半透明の白
      ..style = PaintingStyle.fill                  // 塗りつぶし
      ..maskFilter = const MaskFilter.blur(         // ぼかし効果
        BlurStyle.normal, 
        8,
      );

    canvas.drawCircle(center, 16, glowPaint);
  }

  /// 再描画が必要かどうかを判定（パフォーマンス最適化）
  /// 
  /// 以下の値が変化した場合のみ再描画：
  /// - morphState: ボタン状態の変化
  /// - loadingProgress: ローディング進捗の変化
  /// - isCreateMode: 作成/編集モードの切り替え
  @override
  bool shouldRepaint(MorphingButtonContentPainter oldDelegate) {
    return morphState != oldDelegate.morphState ||         // 状態変化
        loadingProgress != oldDelegate.loadingProgress ||   // 進捗変化
        isCreateMode != oldDelegate.isCreateMode;          // モード変化
  }
}

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
    // Initialize animations with proper TickerProvider
    widget.state.initializeAnimations(this);
  }

  @override
  void dispose() {
    // Properly dispose all animation controllers
    widget.state.morphingController?.dispose();
    widget.state.loadingController?.dispose();
    widget.state.pressController?.dispose();

    // Clear references
    widget.state.morphingController = null;
    widget.state.loadingController = null;
    widget.state.pressController = null;
    widget.state.morphingAnimation = null;
    widget.state.loadingAnimation = null;
    widget.state.pressAnimation = null;

    super.dispose();
  }

  /// モーフィングボタンのUI構築
  /// 
  /// AnimatedBuilderで複数のアニメーションを統合：
  /// - Listenable.merge で複数のAnimationControllerを組み合わせ
  /// - 任意のアニメーションが変化すると自動的にbuilderが再実行
  /// - GestureDetectorでタップ状態を細かく制御（Down/Up/Cancel）
  @override
  Widget build(BuildContext context) {
    // 複数アニメーションの統合監視
    // morphingController と pressController の両方を監視
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        widget.state.morphingController ??         // 形状変化アニメーション
            widget.state.loadingController ??      // ローディングアニメーション
            const AlwaysStoppedAnimation<double>(0),
        widget.state.pressController ??            // プレス効果アニメーション
            const AlwaysStoppedAnimation<double>(0),
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
                  // Background with sophisticated morphing
                  _buildMorphingBackground(),

                  // Glow effects
                  _buildGlowEffects(),

                  // Content with smooth transitions
                  _buildAnimatedContent(),

                  // Ripple effects
                  _buildRippleEffects(),

                  // Progress overlay
                  _buildProgressOverlay(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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

  double _getAnimatedButtonHeight() {
    return 64;
  }

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
          // Additional dynamic shadow
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
            // Additional celebration glow
            BoxShadow(
              color: const Color(0xFF81C784).withValues(alpha: 0.6),
              blurRadius: 40,
              spreadRadius: 1,
            ),
            // Pulsing outer glow
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              blurRadius: 60,
              spreadRadius: 5,
            ),
          ],
        ),
      );
    } else if (widget.state.currentMorphState == MorphingButtonState.loading) {
      // Loading state glow
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

class _RippleEffectPainter extends CustomPainter {
  _RippleEffectPainter({required this.animation, required this.colorScheme});

  final double animation;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width / 2;

    // Create multiple ripple waves
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
