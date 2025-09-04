import 'package:flutter/material.dart';

/// リップル効果描画用CustomPainter
class RippleEffectPainter extends CustomPainter {
  RippleEffectPainter({required this.animation, required this.colorScheme});

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
  bool shouldRepaint(RippleEffectPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
