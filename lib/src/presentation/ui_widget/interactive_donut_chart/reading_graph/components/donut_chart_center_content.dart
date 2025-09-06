import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/model/reading_book_value_object.dart';
import '../reading_book_graph_widget.dart';

/// ドーナツチャート・中央コンテンツ用のウィジェット
///
/// 進捗状況に応じて「残りページ数」または「完読メッセージ」を表示します。
class DonutChartCenterContent extends StatelessWidget {
  const DonutChartCenterContent({
    required this.state,
    required this.value,
    super.key,
  });

  final DonutAnimationState state;
  final ReadingBookValueObject value;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DonutAnimationState>('state', state));
    properties.add(DiagnosticsProperty<ReadingBookValueObject>('value', value));
  }

  @override
  Widget build(BuildContext context) {
    final double progress = state.animatedProgress;
    final bool isCompleted = progress >= 1.0;
    final int remainingPages = value.totalPages - value.readingPageNum;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Container(
        key: ValueKey<bool>(isCompleted),
        padding: const EdgeInsets.all(16),
        child: isCompleted
            ? const CompletionContent()
            : ProgressContent(remainingPages: remainingPages),
      ),
    );
  }
}

/// 完了時のコンテンツ用のウィジェット
class CompletionContent extends StatelessWidget {
  const CompletionContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.celebration_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        const SizedBox(height: 8),
        Text(
          '完読達成！',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// 進行中のコンテンツ用のウィジェット
class ProgressContent extends StatelessWidget {
  const ProgressContent({required this.remainingPages, super.key});

  final int remainingPages;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('remainingPages', remainingPages));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '残り',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$remainingPages',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
            height: 1,
          ),
        ),
        Text(
          'ページ',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
