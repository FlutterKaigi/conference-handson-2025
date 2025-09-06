import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../domain/model/reading_book_value_object.dart';
import '../../../../model/view_model_packages.dart';
import '../reading_book_widget.dart';

/// モーフィング背景用のウィジェット
class MorphingBackground extends StatelessWidget {
  const MorphingBackground({
    required this.state,
    required this.value,
    required this.vm,
    super.key,
  });

  final ReadingBookState state;
  final ReadingBookValueObject value;
  final ReadingBooksViewModel vm;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReadingBookState>('state', state));
    properties.add(DiagnosticsProperty<ReadingBookValueObject>('value', value));
    properties.add(DiagnosticsProperty<ReadingBooksViewModel>('vm', vm));
  }

  /// ボタンの角丸を状態に応じて決定
  double _getBorderRadius(ReadingBookState state) {
    switch (state.currentMorphState) {
      case MorphingButtonState.idle:
      case MorphingButtonState.pressed:
        return 16;
      case MorphingButtonState.loading:
      case MorphingButtonState.success:
        return 32;
    }
  }

  /// ボタンのグラデーションを状態に応じて決定
  LinearGradient _getButtonGradient(
      BuildContext context,
      ReadingBookState state,
      ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    switch (state.currentMorphState) {
      case MorphingButtonState.idle:
        return LinearGradient(
          colors: <Color>[colorScheme.primary, colorScheme.primaryContainer],
        );
      case MorphingButtonState.pressed:
        return LinearGradient(
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.8),
            colorScheme.primaryContainer.withValues(alpha: 0.8),
          ],
        );
      case MorphingButtonState.loading:
        return LinearGradient(
          colors: <Color>[
            colorScheme.secondary,
            colorScheme.secondaryContainer,
          ],
        );
      case MorphingButtonState.success:
        return const LinearGradient(
          colors: <Color>[Color(0xFF4CAF50), Color(0xFF81C784)],
        );
    }
  }

  /// ボタンの影の色を状態に応じて決定
  Color _getButtonShadowColor(BuildContext context, ReadingBookState state) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    switch (state.currentMorphState) {
      case MorphingButtonState.idle:
      case MorphingButtonState.pressed:
        return colorScheme.primary;
      case MorphingButtonState.loading:
        return colorScheme.secondary;
      case MorphingButtonState.success:
        return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_getBorderRadius(state)),
        gradient: _getButtonGradient(context, state),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _getButtonShadowColor(context, state).withValues(alpha: 0.3),
            blurRadius: 12 + (state.pressAnimation?.value ?? 0) * 8,
            offset: Offset(0, 4 - (state.pressAnimation?.value ?? 0) * 2),
          ),
          BoxShadow(
            color: _getButtonShadowColor(context, state).withValues(alpha: 0.1),
            blurRadius: 24 + (state.pressAnimation?.value ?? 0) * 16,
            offset: Offset(0, 8 - (state.pressAnimation?.value ?? 0) * 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_getBorderRadius(state)),
        child: InkWell(
          borderRadius: BorderRadius.circular(_getBorderRadius(state)),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
