import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';

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
    final double progress = value.totalPages > 0
        ? (value.readingPageNum / value.totalPages).clamp(0.0, 1.0)
        : 0.0;

    // Start progress animation on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controllers.animateToProgress(progress);
    });

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Title Section
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
          const SizedBox(height: 32),

          // Main Progress Donut Chart
          _ProgressDonutWidget(
            state: controllers,
            value: value,
            onTap: () => _onDonutTap(controllers),
          ),

          const SizedBox(height: 32),

          // Progress Statistics
          _buildProgressInfo(context, value, progress),
        ],
      ),
    );
  }

  Widget _buildProgressInfo(
    BuildContext context,
    ReadingBookValueObject value,
    double progress,
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
/// このウィジェットは進捗のアニメーション表示を担当します：
/// 1. AnimatedBuilderで AnimationController の変化を監視
/// 2. GestureDetector でタップイベントをハンドリング
/// 3. CustomPaint でドーナツチャートを描画
/// 4. 中央部分で進捗状態を表示（完了時は祝福メッセージ）
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
    // AnimatedBuilder: Flutterアニメーションの描画連携コンポーネント
    // 
    // 動作の仕組み：
    // 1. AnimationController.forward() → 0.0から1.0まで時間経過で値が変化
    // 2. Tween.animate() → コントローラー値をbegin〜endの範囲にマッピング
    // 3. AnimatedBuilder → アニメーション値変化を検知してbuilderを再実行
    // 4. CustomPaint → 新しい進捗値でCanvas描画を更新
    // 
    // 結果：60FPSで滑らかにドーナツが伸びるアニメーション
    return AnimatedBuilder(
      animation:
          widget.state.progressController ??
          const AlwaysStoppedAnimation<double>(0),
      builder: (BuildContext context, Widget? child) {
        // GestureDetector: タップイベントを検知してパルスアニメーションを発火
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
                // 背景のグロー効果: ドーナツチャートに奥行きと視覚的魅力を追加
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // メインのドーナツチャート描画
                // CustomPaint: Canvasに直接描画して高パフォーマンスなアニメーションを実現
                CustomPaint(
                  size: const Size(280, 280),
                  painter: ProgressDonutPainter(
                    progress: widget.state.animatedProgress, // アニメーション中の進捗値
                    pulseValue: widget.state.pulseValue,     // タップ時のパルス効果
                    colorScheme: Theme.of(context).colorScheme,
                  ),
                ),

                // 中央コンテンツ: 残りページ数または完了メッセージを表示
                _buildCenterContent(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterContent() {
    final double progress = widget.state.animatedProgress;
    final bool isCompleted = progress >= 1.0;
    final int remainingPages =
        widget.value.totalPages - widget.value.readingPageNum;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Container(
        key: ValueKey<bool>(isCompleted),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isCompleted) ...<Widget>[
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
            ] else ...<Widget>[
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
          ],
        ),
      ),
    );
  }
}

/// ドーナツチャートアニメーション状態管理クラス
/// 
/// このクラスはアニメーション関連の状態とロジックを管理します：
/// - AnimationController: アニメーションの制御（開始/停止/リセット）
/// - Animation`<double>`: 実際のアニメーション値（0.0〜1.0の進捗）
/// - パルスアニメーション: タップ時の視覚的フィードバック
/// - dispose管理: メモリリークを防ぐためのリソース解放
class DonutAnimationState {
  /// 進捗アニメーションを制御するAnimationController
  AnimationController? progressController;
  
  /// 0.0から目標値までの進捗アニメーション
  Animation<double>? progressAnimation;
  
  /// dispose済みかどうかのフラグ（重複dispose防止）
  bool _isDisposed = false;

  /// アニメーションの目標進捗値（0.0〜1.0）
  double targetProgress = 0;
  
  /// 現在の進捗値（アニメーション前の値）
  double progressValue = 0;
  
  /// タップ時のパルス効果の強度（0.0〜1.0）
  double pulseValue = 0;

  /// 現在のアニメーション進捗値を取得（アニメーション中は動的な値、未初期化時は固定値）
  /// 
  /// Animation.value の取得タイミング：
  /// - AnimationController.forward() 実行中 → 0.0〜1.0で時間変化
  /// - Tween.animate() → コントローラー値をbegin〜endにマッピング
  /// - 例：Tween(begin: 0.3, end: 0.7) + controller.value = 0.5 → 0.5の値を返す
  double get animatedProgress => progressAnimation?.value ?? progressValue;

  /// アニメーションの初期化（TickerProviderを使ってAnimationControllerを作成）
  /// 
  /// Flutterアニメーションの基本構成要素：
  /// 1. AnimationController: アニメーションの時間管理（duration, vsync）
  /// 2. Tween: 値の変化範囲を定義（begin → end）
  /// 3. CurvedAnimation: アニメーションカーブ（easeOutCubic = 滑らかに減速）
  /// 4. TickerProvider: フレーム同期のためのvsync提供
  void initializeAnimations(TickerProvider vsync) {
    // AnimationController: アニメーションの心臓部
    // duration: アニメーション実行時間（2秒）
    // vsync: 画面リフレッシュと同期してパフォーマンス向上
    progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );

    // 初期のTween（0→0）を作成
    // 実際の値は animateToProgress() で動的に再作成されます
    progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: progressController!,
        curve: Curves.easeOutCubic, // 最初速く、だんだん遅くなる自然なカーブ
      ),
    );
  }

  /// 指定した進捗値まで滑らかにアニメーション
  /// 2秒かけてeaseOutCubicカーブで進捗を更新
  /// 
  /// アニメーション実行の流れ：
  /// 1. 新しいTweenを作成（現在値 → 目標値）
  /// 2. CurvedAnimationでイージング適用
  /// 3. AnimationController.reset()で初期状態にリセット
  /// 4. AnimationController.forward()でアニメーション開始
  void animateToProgress(double progress) {
    if (targetProgress != progress && progressController != null) {
      targetProgress = progress;

      // Tween: アニメーション値の変化を定義
      // begin: 現在のアニメーション値（連続性を保つため）
      // end: 目標となる進捗値（0.0〜1.0）
      progressAnimation = Tween<double>(
        begin: animatedProgress, // 現在値から開始（スムーズな継続）
        end: progress,           // 目標値まで
      ).animate(
        // CurvedAnimation: 線形変化を自然なカーブに変換
        CurvedAnimation(
          parent: progressController!,     // AnimationControllerと連携
          curve: Curves.easeOutCubic,     // 滑らかに減速するカーブ
        ),
      );

      // アニメーション実行
      progressController!.reset();    // 0.0からスタート
      unawaited(progressController!.forward()); // 1.0まで進行
    }
  }

  /// タップ時のパルスアニメーション（視覚的フィードバック）
  /// 300ms間だけpulseValueを1.0にしてドーナツを強調表示
  void triggerPulseAnimation() {
    pulseValue = 1;
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        pulseValue = 0;
      }),
    );
  }

  /// リソースの解放（AnimationControllerのdispose）
  /// 重複dispose防止のため_isDisposedフラグで制御
  void dispose() {
    if (!_isDisposed && progressController != null) {
      progressController!.dispose();
      _isDisposed = true;
    }
  }
}

/// ドーナツチャート描画用のCustomPainter
/// 
/// CustomPainterを継承してCanvasに直接描画することで：
/// - 高パフォーマンスなアニメーション描画を実現
/// - 複雑な図形（ドーナツ、グロー、ドット）を自在に制御
/// - shouldRepaintで再描画の最適化
/// 
/// 描画要素：
/// 1. 背景円（グレーのアウトライン）
/// 2. 進捗アーク（プライマリカラーの円弧）
/// 3. グロー効果（ぼかしを使った発光表現）
/// 4. 進捗ドット（円弧の終端にある動的な点）
class ProgressDonutPainter extends CustomPainter {
  ProgressDonutPainter({
    required this.progress,
    required this.pulseValue,
    required this.colorScheme,
  });

  /// アニメーション中の進捗値（0.0〜1.0）
  final double progress;
  
  /// タップ時のパルス効果強度（0.0〜1.0）
  final double pulseValue;
  
  /// Material Design 3のカラースキーム
  final ColorScheme colorScheme;

  /// Canvas描画メソッド（アニメーション変更時に呼ばれる）
  @override
  void paint(Canvas canvas, Size size) {
    // 描画の基本パラメータを計算
    final Offset center = Offset(size.width / 2, size.height / 2); // 円の中心点
    final double radius = math.min(size.width, size.height) / 2 - 20; // 半径
    const double strokeWidth = 16; // ドーナツの太さ

    // 1. 背景円の描画（グレーの薄いアウトライン）
    final Paint backgroundPaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.2) // 薄いグレー
      ..style = PaintingStyle.stroke                        // 線だけ描画
      ..strokeWidth = strokeWidth                           // 線の太さ
      ..strokeCap = StrokeCap.round;                       // 線端を丸く

    canvas.drawCircle(center, radius, backgroundPaint);

    // 2. 進捗アークの描画（プライマリカラーで進捗を表現）
    if (progress > 0) {
      final Paint progressPaint = Paint()
        ..style = PaintingStyle.stroke                       // 線だけ描画
        ..strokeWidth = strokeWidth + (pulseValue * 4)      // パルス時に太くなる
        ..strokeCap = StrokeCap.round                        // 線端を丸く
        ..color = colorScheme.primary;                       // プライマリカラー

      // 3. グロー効果の描画（発光するような視覚効果）
      final Paint glowPaint = Paint()
        ..color = colorScheme.primary.withValues(
          alpha: 0.3 + pulseValue * 0.2,                    // パルス時に明るくなる
        )
        ..style = PaintingStyle.stroke                       // 線だけ描画
        ..strokeWidth = strokeWidth + 8                      // メインより太い線
        ..strokeCap = StrokeCap.round                        // 線端を丸く
        ..maskFilter = const MaskFilter.blur(               // ぼかし効果
          BlurStyle.normal, 
          8,
        );

      // グロー効果を先に描画（下レイヤー）
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),   // 描画範囲
        -math.pi / 2,                                      // 開始角度（12時方向）
        2 * math.pi * progress,                            // 進捗に応じた角度
        false,                                             // 扇形ではなく弧
        glowPaint,
      );

      // メインの進捗アークを描画（上レイヤー）
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),   // 描画範囲
        -math.pi / 2,                                      // 開始角度（12時方向）
        2 * math.pi * progress,                            // 進捗に応じた角度
        false,                                             // 扇形ではなく弧
        progressPaint,
      );

      // 4. 進捗ドットの描画（円弧の終端にある動的な点）
      final double endAngle = -math.pi / 2 + 2 * math.pi * progress; // 終端角度
      final Offset dotPosition = Offset(
        center.dx + math.cos(endAngle) * radius,              // X座標
        center.dy + math.sin(endAngle) * radius,              // Y座標
      );

      final Paint dotPaint = Paint()
        ..color = colorScheme.primary                         // プライマリカラー
        ..style = PaintingStyle.fill;                        // 塗りつぶし

      canvas.drawCircle(dotPosition, 6 + pulseValue * 2, dotPaint);

      // ドットのグロー効果（ドット周りの光る効果）
      final Paint dotGlowPaint = Paint()
        ..color = colorScheme.primary.withValues(alpha: 0.4) // 半透明
        ..style = PaintingStyle.fill                          // 塗りつぶし
        ..maskFilter = const MaskFilter.blur(                // ぼかし効果
          BlurStyle.normal, 
          4,
        );

      canvas.drawCircle(dotPosition, 8 + pulseValue * 3, dotGlowPaint);
    }
  }

  /// 再描画が必要かどうかを判定（パフォーマンス最適化）
  /// progressまたはpulseValueが変化した時のみ再描画
  @override
  bool shouldRepaint(ProgressDonutPainter oldDelegate) {
    return progress != oldDelegate.progress ||     // 進捗値が変化
        pulseValue != oldDelegate.pulseValue;      // パルス値が変化
  }
}
