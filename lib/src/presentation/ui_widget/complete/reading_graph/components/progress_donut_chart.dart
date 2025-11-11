import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/model/reading_book_value_object.dart';
import '../../../challenge/reading_graph/components/progress_donut_chart_painter.dart';
import '../../widget_packages.dart';
import 'background_glow.dart';
import 'donut_chart_center_content.dart';

/// (進捗アニメーション対応)ドーナツチャート・ウィジェット
///
/// 進捗のアニメーション表示を担当します：
/// 1. AnimatedBuilderでAnimationControllerの変化を監視
/// 2. GestureDetectorでタップイベントをハンドリング
/// 3. CustomPaintでドーナツチャートを描画
/// 4. 中央部分で進捗状態を表示
class ProgressDonutChart extends StatefulWidget {
  const ProgressDonutChart({
    required this.state,
    required this.value,
    required this.onTap,
    super.key,
  });

  final DonutAnimationState state;
  final ReadingBookValueObject value;
  final VoidCallback onTap;

  @override
  State<ProgressDonutChart> createState() => _ProgressDonutChartState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
    properties.add(DiagnosticsProperty<ReadingBookValueObject>('value', value));
    properties.add(DiagnosticsProperty<DonutAnimationState>('state', state));
  }
}

class _ProgressDonutChartState extends State<ProgressDonutChart>
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
                const BackgroundGlow(),

                // メインのドーナツチャート
                CustomPaint(
                  size: const Size(280, 280),
                  painter: ProgressDonutChartPainter(
                    progress: widget.state.animatedProgress,
                    pulseValue: widget.state.pulseValue,
                    colorScheme: Theme.of(context).colorScheme,
                  ),
                ),

                // 中央コンテンツ
                DonutChartCenterContent(
                  state: widget.state,
                  value: widget.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
