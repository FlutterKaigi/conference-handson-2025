import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/model/reading_book_value_object.dart';
import '../../../../model/view_model_packages.dart';
import '../reading_book_widget.dart';

/// モーフィング背景用のウィジェット
class MorphingBackground extends StatelessWidget {
  const MorphingBackground({
    required this.state,
    required this.onSubmit,
    required this.value,
    required this.vm,
    required this.getBorderRadius,
    required this.getButtonGradient,
    required this.getButtonShadowColor,
    super.key,
  });

  final ReadingBookState state;
  final Future<void> Function(
    BuildContext,
    ReadingBookValueObject,
    ReadingBooksViewModel,
    ReadingBookState,
  )
  onSubmit;
  final ReadingBookValueObject value;
  final ReadingBooksViewModel vm;
  final double Function(ReadingBookState) getBorderRadius;
  final LinearGradient Function(BuildContext, ReadingBookState)
  getButtonGradient;
  final Color Function(BuildContext, ReadingBookState) getButtonShadowColor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReadingBookState>('state', state));
    properties.add(
      ObjectFlagProperty<
        Future<void> Function(
          BuildContext,
          ReadingBookValueObject,
          ReadingBooksViewModel,
          ReadingBookState,
        )
      >.has('onSubmit', onSubmit),
    );
    properties.add(DiagnosticsProperty<ReadingBookValueObject>('value', value));
    properties.add(DiagnosticsProperty<ReadingBooksViewModel>('vm', vm));
    properties.add(
      ObjectFlagProperty<double Function(ReadingBookState)>.has(
        'getBorderRadius',
        getBorderRadius,
      ),
    );
    properties.add(
      ObjectFlagProperty<
        LinearGradient Function(BuildContext, ReadingBookState)
      >.has('getButtonGradient', getButtonGradient),
    );
    properties.add(
      ObjectFlagProperty<Color Function(BuildContext, ReadingBookState)>.has(
        'getButtonShadowColor',
        getButtonShadowColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(getBorderRadius(state)),
        gradient: getButtonGradient(context, state),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: getButtonShadowColor(context, state).withValues(alpha: 0.3),
            blurRadius: 12 + (state.pressAnimation?.value ?? 0) * 8,
            offset: Offset(0, 4 - (state.pressAnimation?.value ?? 0) * 2),
          ),
          BoxShadow(
            color: getButtonShadowColor(context, state).withValues(alpha: 0.1),
            blurRadius: 24 + (state.pressAnimation?.value ?? 0) * 16,
            offset: Offset(0, 8 - (state.pressAnimation?.value ?? 0) * 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(getBorderRadius(state)),
        child: InkWell(
          borderRadius: BorderRadius.circular(getBorderRadius(state)),
          onTap: state.currentMorphState == MorphingButtonState.idle
              ? () async {
                  await onSubmit(context, value, vm, state);
                }
              : null,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
