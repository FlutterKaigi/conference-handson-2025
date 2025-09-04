import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../reading_book_widget.dart';

/// グロー効果用のウィジェット
class GlowEffects extends StatelessWidget {
  const GlowEffects({required this.state, super.key});

  final ReadingBookState state;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReadingBookState>('state', state));
  }

  @override
  Widget build(BuildContext context) {
    if (state.currentMorphState == MorphingButtonState.success) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
              blurRadius: 25,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: const Color(0xFF81C784).withValues(alpha: 0.6),
              blurRadius: 40,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              blurRadius: 60,
              spreadRadius: 5,
            ),
          ],
        ),
      );
    } else if (state.currentMorphState == MorphingButtonState.loading) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
