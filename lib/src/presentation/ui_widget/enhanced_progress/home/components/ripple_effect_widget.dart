import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 波紋エフェクトウィジェット
///

/// - CustomPainterを使った直接描画
/// - 複数の波紋の時差アニメーション
/// - Canvas APIによる円の描画
class RippleEffectWidget extends StatelessWidget {
  /// コンストラクタ
  ///
  /// [animation] 波紋の広がりを制御するアニメーション（0.0〜1.0）
  /// [primaryColor] メインカラー
  /// [secondaryColor] セカンダリカラー
  const RippleEffectWidget({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
    super.key,
  });

  /// 波紋アニメーション（0.0〜1.0の値で波紋が広がる）
  final Animation<double> animation;

  /// プライマリカラー（奇数番目の波紋）
  final Color primaryColor;

  /// セカンダリカラー（偶数番目の波紋）
  final Color secondaryColor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Animation<double>>('animation', animation),
    );
    properties.add(ColorProperty('primaryColor', primaryColor));
    properties.add(ColorProperty('secondaryColor', secondaryColor));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Positioned.fill(
          // CustomPaintの学習ポイント:
          // painterを使って任意の図形を描画できる
          child: CustomPaint(
            painter: _RippleEffectPainter(
              animationValue: animation.value,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
            ),
          ),
        );
      },
    );
  }
}

/// 波紋エフェクト描画用CustomPainter
///

/// - CustomPainterの継承とpaint/shouldRepaintの実装
/// - Canvas APIを使った円の描画
/// - 時差アニメーションによる自然な波紋表現
class _RippleEffectPainter extends CustomPainter {
  _RippleEffectPainter({
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  /// アニメーション値（0.0〜1.0）
  final double animationValue;

  /// プライマリカラー
  final Color primaryColor;

  /// セカンダリカラー
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 画面の中心点を計算
    final Offset center = Offset(size.width / 2, size.height / 2);
    // 最大半径（画面の対角線の半分）
    final double maxRadius = math.max(size.width, size.height) / 2;

    // 4つの波紋を時差をつけて描画
    for (int i = 0; i < 4; i++) {
      // 時差の計算（0.25秒ずつずらす）
      final double delay = i * 0.25;
      // 各波紋の進行度を計算（負の値はclampで0にする）
      final double rippleProgress = (animationValue - delay).clamp(0.0, 1.0);

      // 波紋が始まっている場合のみ描画
      if (rippleProgress > 0) {
        // 半径の計算（時間とともに広がる）
        final double radius = maxRadius * rippleProgress;
        // 透明度の計算（時間とともに薄くなる）
        final double opacity = (1.0 - rippleProgress) * 0.3;

        // Paint（描画設定）の作成
        final Paint ripplePaint = Paint()
          // 偶奇で色を変える（i.isEvenを使用）
          ..color = (i.isEven ? primaryColor : secondaryColor).withValues(
            alpha: opacity,
          )
          ..style = PaintingStyle
              .stroke // 塗りつぶしではなく線のみ
          ..strokeWidth = 3.0 - rippleProgress * 2; // 時間とともに線が細くなる

        // 円を描画
        canvas.drawCircle(center, radius, ripplePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_RippleEffectPainter oldDelegate) {
    // アニメーション値が変わった時のみ再描画
    return animationValue != oldDelegate.animationValue;
  }
}
