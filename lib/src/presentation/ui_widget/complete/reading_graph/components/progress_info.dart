import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/model/reading_book_value_object.dart';
import 'stat_item.dart';

/// 進捗統計情報用のウィジェット
class ProgressInfo extends StatelessWidget {
  const ProgressInfo({required this.value, super.key});

  final ReadingBookValueObject value;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReadingBookValueObject>('value', value));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          StatItem(
            value: '${value.readingPageNum}',
            label: '読了ページ',
            icon: Icons.book_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          StatItem(
            value: '${value.totalPages}',
            label: '総ページ',
            icon: Icons.menu_book_outlined,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}
