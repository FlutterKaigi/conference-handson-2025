import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../reading_book_widget.dart';

/// プログレスオーバーレイ用のウィジェット
class ProgressOverlay extends StatelessWidget {
  const ProgressOverlay({
    required this.state,
    required this.getBorderRadius,
    super.key,
  });

  final ReadingBookState state;
  final double Function(ReadingBookState) getBorderRadius;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReadingBookState>('state', state));
    properties.add(
      ObjectFlagProperty<double Function(ReadingBookState)>.has(
        'getBorderRadius',
        getBorderRadius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (state.currentMorphState == MorphingButtonState.loading) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(getBorderRadius(state)),
        child: LinearProgressIndicator(
          value: state.loadingProgress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.3),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
