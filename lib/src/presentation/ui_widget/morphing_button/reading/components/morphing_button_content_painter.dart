import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../reading_book_widget.dart';

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

    // モーフィング状態の種別に応じてアニメーション描画を切り替える。
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
