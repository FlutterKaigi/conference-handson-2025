import 'dart:math' as math;

import 'package:flutter/material.dart';

/// (進捗アニメーション対応)ドーナツチャート描画用CustomPainter
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
class ProgressDonutChartPainter extends CustomPainter {
  ProgressDonutChartPainter({
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
  bool shouldRepaint(ProgressDonutChartPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        pulseValue != oldDelegate.pulseValue;
  }
}
