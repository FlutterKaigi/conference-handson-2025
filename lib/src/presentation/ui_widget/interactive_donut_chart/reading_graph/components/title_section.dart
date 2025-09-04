import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/model/reading_book_value_object.dart';

/// タイトルセクション用のウィジェット
class TitleSection extends StatelessWidget {
  const TitleSection({required this.value, required this.progress, super.key});

  final ReadingBookValueObject value;
  final double progress;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReadingBookValueObject>('value', value));
    properties.add(DoubleProperty('progress', progress));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value.name.isNotEmpty ? value.name : '読書進捗',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(1)}% 完了',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
