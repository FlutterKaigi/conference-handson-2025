import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 動的背景エフェクトウィジェット
///

/// - AnimationControllerとAnimationの連携
/// - RadialGradientによるグラデーション表現
/// - withValuesによる透明度制御（Flutter 3.27対応）
class DynamicBackgroundWidget extends StatelessWidget {
  /// コンストラクタ
  ///
  /// [animation] 背景の変化を制御するアニメーション（0.0〜1.0）
  /// [primaryColor] メインカラー
  /// [secondaryColor] セカンダリカラー
  const DynamicBackgroundWidget({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
    super.key,
  });

  /// 背景アニメーション（0.0〜1.0の値で変化）
  final Animation<double> animation;

  /// プライマリカラー（メインの色）
  final Color primaryColor;

  /// セカンダリカラー（補助的な色）
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
      // AnimatedBuilderの学習ポイント:
      // animationの値が変わるたびにbuilderが呼ばれ、UIが再構築される
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              // RadialGradient（放射状グラデーション）の学習ポイント:
              // centerから外側に向かって色が変化する
              gradient: RadialGradient(
                center: Alignment.center,
                // FIXME コードを完成させてください。
                // ステップ2: １層目の放射グラデーションの作成
                radius: 0.8 + 1 * 0.4,
                // radius: 0.8 + animation.value * 0.4,
                colors: <Color>[
                primaryColor.withValues(alpha: 0.15 + 1 * 0.1),
                // primaryColor.withValues(alpha: 0.15 + animation.value * 0.1),
                secondaryColor.withValues(
                  alpha: 0.08 + 1 * 0.05,
                ),
                // secondaryColor.withValues(
                //   alpha: 0.08 + animation.value * 0.05,
                // ),
                primaryColor.withValues(alpha: 0.03),
                Colors.transparent,
                ],
                stops: const <double>[0, 0.4, 0.7, 1],
              ),
            ),
          ),
        );
      },
    );
  }
}
