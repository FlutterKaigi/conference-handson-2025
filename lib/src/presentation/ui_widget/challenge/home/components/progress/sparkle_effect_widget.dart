import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// スパークルエフェクトウィジェット
///

/// - 複雑な数学関数（sin、cos）を使ったアニメーション
/// - Path APIを使った星形の描画
/// - 完読時の特別演出
class SparkleEffectWidget extends StatelessWidget {
  /// コンストラクタ
  ///
  /// [animation] スパークルの動きを制御するアニメーション（0.0〜1.0）
  /// [primaryColor] メインカラー
  /// [secondaryColor] セカンダリカラー
  /// [isCompletion] 完読フラグ（trueの場合、より多くのスパークルを表示）
  const SparkleEffectWidget({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isCompletion,
    super.key,
  });

  /// スパークルアニメーション
  final Animation<double> animation;

  /// プライマリカラー
  final Color primaryColor;

  /// セカンダリカラー
  final Color secondaryColor;

  /// 完読フラグ（100%達成時はtrue）
  final bool isCompletion;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Animation<double>>('animation', animation),
    );
    properties.add(ColorProperty('primaryColor', primaryColor));
    properties.add(ColorProperty('secondaryColor', secondaryColor));
    properties.add(
      FlagProperty('isCompletion', value: isCompletion, ifTrue: 'completion'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: _SparkleEffectPainter(
              animationValue: animation.value,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              isCompletion: isCompletion,
            ),
          ),
        );
      },
    );
  }
}

/// スパークルエフェクト描画用CustomPainter
///

/// - 三角関数（sin、cos）を使った円運動
/// - Pathを使った複雑な図形（星形）の描画
/// - 複数のアニメーション要素の組み合わせ
class _SparkleEffectPainter extends CustomPainter {
  _SparkleEffectPainter({
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isCompletion,
  });

  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isCompletion;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    // 完読時は20個、通常時は12個のスパークル
    final int sparkleCount = isCompletion ? 20 : 12;

    for (int i = 0; i < sparkleCount; i++) {
      // 各スパークルの角度（円周上に等間隔で配置）
      final double angle = (i * 2 * math.pi) / sparkleCount;

      // スパークルの位相（個別のアニメーションタイミング）
      final double sparklePhase = (animationValue + i * 0.1) % 1.0;

      // 距離の計算（sinカーブで前後に動く）
      final double distance = 80 + math.sin(sparklePhase * 2 * math.pi) * 40;

      // サイズの計算（別のsinカーブでサイズが変動）
      final double sparkleSize = 2 + math.sin(sparklePhase * 4 * math.pi) * 3;

      // 透明度の計算（sinカーブで明滅）
      final double opacity = math.sin(sparklePhase * math.pi) * 0.8;

      // スパークルの位置を計算（極座標から直交座標に変換）
      final Offset sparklePosition = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      // Paint設定
      final Paint sparklePaint = Paint()
        ..color = (i.isEven ? primaryColor : secondaryColor).withValues(
          alpha: opacity,
        )
        ..style = PaintingStyle.fill;

      // 星形のスパークルを描画
      _drawStar(canvas, sparklePosition, sparkleSize, sparklePaint);
    }
  }

  /// 星形を描画するヘルパーメソッド
  ///

  /// - Path APIを使った複雑な図形の描画
  /// - 極座標系での図形計算
  /// - for文を使った繰り返し描画
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final Path starPath = Path();
    final double outerRadius = size;
    final double innerRadius = size * 0.4;

    // 星形は10個の頂点で構成（外側5個、内側5個）
    for (int i = 0; i < 10; i++) {
      final double angle = (i * math.pi) / 5;
      // 偶数インデックスは外側、奇数は内側の頂点
      final double radius = i.isEven ? outerRadius : innerRadius;

      // 極座標から直交座標に変換（-π/2で12時方向を起点にする）
      final double x = center.dx + math.cos(angle - math.pi / 2) * radius;
      final double y = center.dy + math.sin(angle - math.pi / 2) * radius;

      if (i == 0) {
        // 最初の点は移動
        starPath.moveTo(x, y);
      } else {
        // 以降の点は線を引く
        starPath.lineTo(x, y);
      }
    }

    // パスを閉じて星形を完成
    starPath.close();
    canvas.drawPath(starPath, paint);
  }

  @override
  bool shouldRepaint(_SparkleEffectPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
