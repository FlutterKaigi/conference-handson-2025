import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';

/// 読書進捗ドーナツチャートウィジェット
///
/// このウィジェットは読書進捗を視覚的に表現します：
/// 1. ドーナツチャート形式の進捗表示
/// 2. タップでパルスアニメーション
/// 3. 完了時の祝福メッセージ
class ReadingBookGraphWidget
    extends ConsumerStagedWidget<ReadingBookValueObject, DonutAnimationState> {
  const ReadingBookGraphWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  DonutAnimationState? createWidgetState() {
    return DonutAnimationState();
  }

  @override
  void disposeState(DonutAnimationState? state) {
    // disposeは_ProgressDonutWidgetStateで行う
    super.disposeState(state);
  }

  /// ドーナツチャートタップ時の処理
  /// パルスアニメーションと触覚フィードバックを実行
  void _onDonutTap(DonutAnimationState state) {
    state.triggerPulseAnimation();
    unawaited(HapticFeedback.lightImpact());
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ReadingBookValueObject value,
    DonutAnimationState? state,
  ) {
    final DonutAnimationState controllers = state!;
    final double progress = _calculateProgress(value);

    // ビルド後に進捗アニメーションを開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controllers.animateToProgress(progress);
    });

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // タイトルセクション
          _buildTitleSection(context, value, progress),
          const SizedBox(height: 32),

          // メインのドーナツチャート
          _ProgressDonutWidget(
            state: controllers,
            value: value,
            onTap: () => _onDonutTap(controllers),
          ),
          const SizedBox(height: 32),

          // 進捗統計情報
          _buildProgressInfo(context, value),
        ],
      ),
    );
  }

  /// 進捗率の計算
  double _calculateProgress(ReadingBookValueObject value) {
    if (value.totalPages <= 0) {
      return 0;
    }
    return (value.readingPageNum / value.totalPages).clamp(0, 1);
  }

  /// タイトルセクションの構築
  Widget _buildTitleSection(
    BuildContext context,
    ReadingBookValueObject value,
    double progress,
  ) {
    return Column(
      children: <Widget>[
        Text(
          value.name.isNotEmpty ? value.name : '読書進捗',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(1)}% 完了',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 進捗統計情報の構築
  Widget _buildProgressInfo(
    BuildContext context,
    ReadingBookValueObject value,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildStatItem(
            context,
            '${value.readingPageNum}',
            '読了ページ',
            Icons.book_outlined,
            Theme.of(context).colorScheme.primary,
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            context,
            '${value.totalPages}',
            '総ページ',
            Icons.menu_book_outlined,
            Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  /// 統計アイテムの構築
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// ドーナツチャートのアニメーション描画ウィジェット
///
/// 進捗のアニメーション表示を担当します：
/// 1. AnimatedBuilderでAnimationControllerの変化を監視
/// 2. GestureDetectorでタップイベントをハンドリング
/// 3. CustomPaintでドーナツチャートを描画
/// 4. 中央部分で進捗状態を表示
class _ProgressDonutWidget extends StatefulWidget {
  const _ProgressDonutWidget({
    required this.state,
    required this.value,
    required this.onTap,
  });

  final DonutAnimationState state;
  final ReadingBookValueObject value;
  final VoidCallback onTap;

  @override
  State<_ProgressDonutWidget> createState() => _ProgressDonutWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
    properties.add(DiagnosticsProperty<ReadingBookValueObject>('value', value));
    properties.add(DiagnosticsProperty<DonutAnimationState>('state', state));
  }
}

class _ProgressDonutWidgetState extends State<_ProgressDonutWidget>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.state.initializeAnimations(this);
  }

  @override
  void dispose() {
    widget.state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// AnimatedBuilder: アニメーションの変化を監視して再描画
    ///
    /// アニメーションフロー：
    /// 1. AnimationController.forward() → 0.0から1.0まで値が変化
    /// 2. Tween.animate() → コントローラー値を実際の進捗値にマッピング
    /// 3. AnimatedBuilder → 値変化を検知してbuilderを再実行
    /// 4. CustomPaint → 新しい値でドーナツチャートを再描画
    return AnimatedBuilder(
      animation:
          widget.state.progressController ??
          const AlwaysStoppedAnimation<double>(0),
      builder: (BuildContext context, Widget? child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // 背景のグロー効果
                _buildBackgroundGlow(context),

                // メインのドーナツチャート
                CustomPaint(
                  size: const Size(280, 280),
                  painter: ProgressDonutPainter(
                    progress: widget.state.animatedProgress,
                    pulseValue: widget.state.pulseValue,
                    colorScheme: Theme.of(context).colorScheme,
                  ),
                ),

                // 中央コンテンツ
                _buildCenterContent(context),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 背景のグロー効果を構築
  Widget _buildBackgroundGlow(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  /// 中央コンテンツの構築
  /// 進捗状況に応じて「残りページ数」または「完読メッセージ」を表示
  Widget _buildCenterContent(BuildContext context) {
    final double progress = widget.state.animatedProgress;
    final bool isCompleted = progress >= 1.0;
    final int remainingPages =
        widget.value.totalPages - widget.value.readingPageNum;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Container(
        key: ValueKey<bool>(isCompleted),
        padding: const EdgeInsets.all(16),
        child: isCompleted
            ? _buildCompletionContent(context)
            : _buildProgressContent(context, remainingPages),
      ),
    );
  }

  /// 完了時のコンテンツ
  Widget _buildCompletionContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.celebration_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        const SizedBox(height: 8),
        Text(
          '完読達成！',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 進行中のコンテンツ
  Widget _buildProgressContent(BuildContext context, int remainingPages) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '残り',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$remainingPages',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
            height: 1,
          ),
        ),
        Text(
          'ページ',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// ドーナツチャートアニメーション状態管理クラス
///
/// アニメーション関連の状態とロジックを管理：
/// - AnimationController: アニメーションの制御
/// - Animation: 実際のアニメーション値
/// - パルスアニメーション: タップ時の視覚的フィードバック
class DonutAnimationState {
  /// 進捗アニメーションコントローラー
  AnimationController? progressController;

  /// 進捗アニメーション
  Animation<double>? progressAnimation;

  /// dispose済みフラグ
  bool _isDisposed = false;

  /// アニメーションの目標進捗値
  double targetProgress = 0;

  /// 現在の進捗値
  double progressValue = 0;

  /// パルス効果の強度
  double pulseValue = 0;

  /// 現在のアニメーション進捗値を取得
  ///
  /// AnimationControllerが実行中の場合は動的な値を返し、
  /// 未初期化の場合は固定値を返します
  double get animatedProgress => progressAnimation?.value ?? progressValue;

  /// アニメーションの初期化
  ///
  /// Flutterアニメーションの基本構成：
  /// 1. AnimationController: 時間管理（duration, vsync）
  /// 2. Tween: 値の変化範囲（begin → end）
  /// 3. CurvedAnimation: アニメーションカーブ
  void initializeAnimations(TickerProvider vsync) {
    // AnimationController: 2秒間のアニメーション
    progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );

    // 初期のアニメーション（0→0）
    progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: progressController!,
        curve: Curves.easeOutCubic, // 滑らかに減速するカーブ
      ),
    );
  }

  /// 指定した進捗値までアニメーション
  ///
  /// アニメーション実行の流れ：
  /// 1. 新しいTweenを作成（現在値 → 目標値）
  /// 2. CurvedAnimationでイージング適用
  /// 3. コントローラーをリセット後、forward()で実行
  void animateToProgress(double progress) {
    if (targetProgress != progress && progressController != null) {
      targetProgress = progress;

      // 現在値から目標値へのTweenを作成
      progressAnimation =
          Tween<double>(
            begin: animatedProgress, // 現在のアニメーション値から開始
            end: progress, // 目標値まで
          ).animate(
            CurvedAnimation(
              parent: progressController!,
              curve: Curves.easeOutCubic, // 自然な減速カーブ
            ),
          );

      // アニメーション実行
      progressController!.reset(); // 0.0にリセット
      unawaited(progressController!.forward()); // 1.0まで進行
    }
  }

  /// タップ時のパルスアニメーション
  /// 300ms間パルス効果を表示
  void triggerPulseAnimation() {
    pulseValue = 1;
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        pulseValue = 0;
      }),
    );
  }

  /// リソースの解放
  void dispose() {
    if (!_isDisposed && progressController != null) {
      progressController!.dispose();
      _isDisposed = true;
    }
  }
}

/// ドーナツチャート描画用CustomPainter
///
/// CustomPainterを使用してCanvasに直接描画：
/// - 高パフォーマンスなアニメーション
/// - 複雑な図形の自在な制御
/// - shouldRepaintで再描画を最適化
///
/// 描画要素：
/// 1. 背景円（グレーのアウトライン）
/// 2. 進捗アーク（プライマリカラー）
/// 3. グロー効果（発光表現）
/// 4. 進捗ドット（円弧の終端）
class ProgressDonutPainter extends CustomPainter {
  ProgressDonutPainter({
    required this.progress,
    required this.pulseValue,
    required this.colorScheme,
  });

  /// アニメーション中の進捗値（0.0〜1.0）
  final double progress;

  /// パルス効果の強度（0.0〜1.0）
  final double pulseValue;

  /// Material Design 3のカラースキーム
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    // 描画の基本パラメータ
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2 - 20;
    const double strokeWidth = 16;

    // 1. 背景円の描画
    _drawBackgroundCircle(canvas, center, radius, strokeWidth);

    // 2. 進捗アークとグロー効果の描画
    if (progress > 0) {
      _drawProgressArc(canvas, center, radius, strokeWidth);
      _drawProgressDot(canvas, center, radius);
    }
  }

  /// 背景円の描画（グレーのアウトライン）
  void _drawBackgroundCircle(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
  ) {
    final Paint backgroundPaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
  }

  /// 進捗アークとグロー効果の描画
  void _drawProgressArc(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
  ) {
    // グロー効果（下レイヤー）
    final Paint glowPaint = Paint()
      ..color = colorScheme.primary.withValues(
        alpha: 0.3 + pulseValue * 0.2, // パルス時に明るくなる
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 12時方向から開始
      2 * math.pi * progress, // 進捗に応じた角度
      false,
      glowPaint,
    );

    // メインの進捗アーク（上レイヤー）
    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          strokeWidth +
          (pulseValue * 4) // パルス時に太くなる
      ..strokeCap = StrokeCap.round
      ..color = colorScheme.primary;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 12時方向から開始
      2 * math.pi * progress, // 進捗に応じた角度
      false,
      progressPaint,
    );
  }

  /// 進捗ドットの描画（円弧の終端）
  void _drawProgressDot(Canvas canvas, Offset center, double radius) {
    // ドットの位置計算
    final double endAngle = -math.pi / 2 + 2 * math.pi * progress;
    final Offset dotPosition = Offset(
      center.dx + math.cos(endAngle) * radius,
      center.dy + math.sin(endAngle) * radius,
    );

    // ドットのグロー効果
    final Paint dotGlowPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(dotPosition, 8 + pulseValue * 3, dotGlowPaint);

    // メインのドット
    final Paint dotPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(dotPosition, 6 + pulseValue * 2, dotPaint);
  }

  /// 再描画が必要かどうかを判定
  /// progressまたはpulseValueが変化した時のみ再描画
  @override
  bool shouldRepaint(ProgressDonutPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        pulseValue != oldDelegate.pulseValue;
  }
}
