import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../reading_book_widget.dart';
import 'ripple_effect_painter.dart';

/// リップル効果用のウィジェット
class RippleEffects extends StatelessWidget {
  const RippleEffects({
    required this.state,
    required this.getAnimatedButtonWidth,
    super.key,
  });

  final ReadingBookState state;
  final double Function() getAnimatedButtonWidth;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReadingBookState>('state', state));
    properties.add(
      ObjectFlagProperty<double Function()>.has(
        'getAnimatedButtonWidth',
        getAnimatedButtonWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (state.currentMorphState == MorphingButtonState.loading) {
      return CustomPaint(
        size: Size(getAnimatedButtonWidth(), 64),
        painter: RippleEffectPainter(
          animation: state.loadingAnimation?.value ?? 0,
          colorScheme: Theme.of(context).colorScheme,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
