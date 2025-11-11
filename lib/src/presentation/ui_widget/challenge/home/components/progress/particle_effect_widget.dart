import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// パーティクルエフェクトウィジェット（完読時の花火効果）
///

/// - 放射状に拡散するパーティクルの物理シミュレーション
/// - 複数サイズのパーティクルによる奥行き表現
/// - 時間経過による透明度とサイズの変化
class ParticleEffectWidget extends StatelessWidget {
  /// コンストラクタ
  const ParticleEffectWidget({
    required this.animation,
    required this.color,
    super.key,
  });

  /// パーティクル拡散アニメーション（0.0〜1.0）
  final Animation<double> animation;

  /// パーティクルの色
  final Color color;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Animation<double>>('animation', animation),
    );
    properties.add(ColorProperty('color', color));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: _ParticleEffectPainter(
              animationValue: animation.value,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

/// パーティクルエフェクト描画用CustomPainter（強化版）
///

/// - 物理法則に基づく粒子の動き
/// - 複数レイヤーによる視覚的豊かさ
/// - 数学関数（sin）による自然な動きの表現
class _ParticleEffectPainter extends CustomPainter {
  _ParticleEffectPainter({required this.animationValue, required this.color});

  final double animationValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    // メインの爆発的なパーティクル（24個）
    _drawExplosionParticles(canvas, center);

    // 追加の小さなスパークル（36個）
    _drawSparkleParticles(canvas, center);
  }

  /// 爆発的なパーティクルの描画
  ///

  /// - 異なる速度による自然な拡散
  /// - 重ねた円による奥行き表現
  /// - 時間経過による透明度とサイズ変化
  void _drawExplosionParticles(Canvas canvas, Offset center) {
    for (int i = 0; i < 24; i++) {
      // 各パーティクルの角度（360度を24等分）
      final double angle = (i * 2 * math.pi) / 24;

      // 速度のバリエーション（3パターンで異なる速度）
      final double velocity = 1.0 + (i % 3) * 0.5;

      // 距離の計算（速度 × アニメーション進捗 × 最大距離）
      final double distance = animationValue * 200 * velocity;

      // パーティクルサイズ（時間とともに小さくなる、最小1px）
      final double particleSize = ((1 - animationValue) * 10).clamp(1.0, 10.0);

      // 透明度（時間とともに薄くなる）
      final double opacity = ((1 - animationValue) * 0.9).clamp(0.0, 0.9);

      // パーティクルの位置計算（極座標→直交座標変換）
      final Offset particlePosition = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      // メインのパーティクル用Paint
      final Paint paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // 二重の円で奥行きを表現
      // 外側の円（メインのパーティクル）
      canvas.drawCircle(particlePosition, particleSize, paint);

      // 内側の円（ハイライト効果）
      canvas.drawCircle(
        particlePosition,
        particleSize * 0.5,
        Paint()..color = Colors.white.withValues(alpha: opacity * 0.5),
      );
    }
  }

  /// 追加のスパークルパーティクルの描画
  ///

  /// - sin関数による周期的な明滅効果
  /// - 異なる動きパターンによる複雑さの演出
  void _drawSparkleParticles(Canvas canvas, Offset center) {
    for (int i = 0; i < 36; i++) {
      final double angle = (i * 2 * math.pi) / 36;
      final double distance = animationValue * 120;

      // sin関数による動的なサイズ変化（1〜5pxの範囲）
      final double sparkleSize = math.sin(animationValue * 4 * math.pi) * 2 + 1;

      // 複雑なsin関数による明滅効果
      final double opacity =
          (math.sin(animationValue * 6 * math.pi) * 0.5 + 0.5) *
          (1 - animationValue);

      final Offset sparklePosition = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      final Paint sparklePaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(sparklePosition, sparkleSize, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(_ParticleEffectPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
