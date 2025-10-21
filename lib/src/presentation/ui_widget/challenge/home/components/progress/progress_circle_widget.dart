import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 3Dライクなプログレスサークルウィジェット
///

/// - 複数のBoxShadowによる立体感表現
/// - RadialGradientによる3D効果
/// - CustomPainterとContainerの組み合わせ
/// - アイコンとテキストのレイアウト
class ProgressCircleWidget extends StatelessWidget {
  /// コンストラクタ
  const ProgressCircleWidget({
    required this.progressAnimation,
    required this.pulseAnimation,
    required this.progressPercent,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    super.key,
  });

  /// プログレス進捗アニメーション（0.0〜1.0）
  final Animation<double> progressAnimation;

  /// パルスアニメーション（0.95〜1.15で拡縮）
  final Animation<double> pulseAnimation;

  /// 達成した進捗率（10, 50, 80, 100）
  final int progressPercent;

  /// プライマリカラー
  final Color primaryColor;

  /// セカンダリカラー
  final Color secondaryColor;

  /// 表示するアイコン
  final IconData icon;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Animation<double>>(
        'progressAnimation',
        progressAnimation,
      ),
    );
    properties.add(
      DiagnosticsProperty<Animation<double>>('pulseAnimation', pulseAnimation),
    );
    properties.add(IntProperty('progressPercent', progressPercent));
    properties.add(ColorProperty('primaryColor', primaryColor));
    properties.add(ColorProperty('secondaryColor', secondaryColor));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          // FIXME コードを完成させてください。
          // ステップ3: アニメーションの値で動きを実現①
          scale: 1,
          // scale: pulseAnimation.value,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // RadialGradientで立体感を演出
              gradient: RadialGradient(
                colors: <Color>[
                  Colors.white.withValues(alpha: 0.9), // 中心部は明るく
                  primaryColor, // メインカラー
                  secondaryColor, // セカンダリカラー
                  primaryColor.withValues(alpha: 0.8), // 外側は少し暗く
                ],
                stops: const <double>[0, 0.3, 0.7, 1],
              ),
              // 複数のBoxShadowで立体感と光の表現
              boxShadow: <BoxShadow>[
                // メインシャドウ（影の部分）
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.6),
                  // FIXME コードを完成させてください。
                  // ステップ3: アニメーションの値で動きを実現②
                  blurRadius: 25 + 1 * 10,
                  // blurRadius: 25 + pulseAnimation.value * 10,
                  spreadRadius: 8,
                  offset: const Offset(0, 5), // 下方向に影
                ),
                // グローエフェクト（光の部分）
                BoxShadow(
                  color: secondaryColor.withValues(alpha: 0.4),
                  // FIXME コードを完成させてください。
                  // ステップ3: アニメーションの値で動きを実現③
                  blurRadius: 40 + 1 * 15,
                  // blurRadius: 40 + pulseAnimation.value * 15,
                  spreadRadius: 15,
                ),
                // 内側のハイライト（上からの光）
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: -5,
                  offset: const Offset(-3, -3), // 左上からのハイライト
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // 3Dライクなプログレス表示
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CustomPaint(
                    painter: _Enhanced3DProgressPainter(
                      // FIXME コードを完成させてください。
                      // ステップ3: アニメーションの値で動きを実現④
                      progress: 1 * (progressPercent / 100),
                      // progress:
                      //     progressAnimation.value * (progressPercent / 100),
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                      pulseValue: pulseAnimation.value,
                    ),
                  ),
                ),

                // アイコン（パルスと連動してサイズ変化）
                Transform.scale(
                  // FIXME コードを完成させてください。
                  // ステップ3: アニメーションの値で動きを実現⑤
                  // scale: 1.0 + 1 * 0.2,
                  scale: 1.0 + pulseAnimation.value * 0.2,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                ),

                // プログレス数値表示
                Positioned(
                  bottom: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${(progressPercent * progressAnimation.value).toInt()}%',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 3Dライクなプログレス描画用CustomPainter
///

/// - LinearGradientとSweepGradientの使い分け
/// - drawArcによる円弧の描画
/// - ハイライト効果による立体感表現
class _Enhanced3DProgressPainter extends CustomPainter {
  _Enhanced3DProgressPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.pulseValue,
  });

  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final double pulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2 - 10;
    final double strokeWidth = 8 + pulseValue * 4;

    // 背景円（立体感のあるグラデーション）
    final Shader backgroundShader = LinearGradient(
      colors: <Color>[
        Colors.white.withValues(alpha: 0.1),
        Colors.black.withValues(alpha: 0.2),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final Paint backgroundPaint = Paint()
      ..shader = backgroundShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // プログレス表示（進捗がある場合のみ）
    if (progress > 0) {
      // メインプログレス（回転グラデーション）
      final Shader progressShader = SweepGradient(
        colors: <Color>[
          primaryColor,
          secondaryColor,
          primaryColor.withValues(alpha: 0.8),
          secondaryColor,
        ],
        stops: const <double>[0, 0.3, 0.7, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      final Paint progressPaint = Paint()
        ..shader = progressShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // 12時方向から時計回りに進捗を描画
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // 12時方向から開始
        2 * math.pi * progress, // 進捗に応じた角度
        false,
        progressPaint,
      );

      // ハイライトライン（立体感演出）
      final Paint highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6 + pulseValue * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      // プログレスの内側にハイライトを描画
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 4),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_Enhanced3DProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        pulseValue != oldDelegate.pulseValue;
  }
}
