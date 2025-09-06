import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/model/reading_books_domain_model.dart';
import '../../../../model/view_model_packages.dart';
import '../reading_book_widget.dart';
import 'morphing_button_content_painter.dart';

/// アニメーションコンテンツ用のウィジェット
class AnimatedContent extends StatelessWidget {
  const AnimatedContent({
    required this.state,
    required this.vm,
    required this.getAnimatedButtonWidth,
    super.key,
  });

  final ReadingBookState state;
  final ReadingBooksViewModel vm;
  final double Function() getAnimatedButtonWidth;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReadingBookState>('state', state));
    properties.add(DiagnosticsProperty<ReadingBooksViewModel>('vm', vm));
    properties.add(
      ObjectFlagProperty<double Function()>.has(
        'getAnimatedButtonWidth',
        getAnimatedButtonWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CustomPaint(
        size: Size(getAnimatedButtonWidth(), 64),
        painter: MorphingButtonContentPainter(
          morphState: state.currentMorphState,
          loadingProgress: state.loadingProgress,
          colorScheme: Theme.of(context).colorScheme,
          isCreateMode: vm.currentEditMode == ReadingBookEditMode.create,
        ),
      ),
    );
  }
}
