import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/model/view_model_packages.dart';
import '../../../presentation/ui_widget/widget_packages.dart';

class ReadingBookGraphPage extends ConsumerWidget {
  /// コンストラクタ
  const ReadingBookGraphPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('読書進捗グラフ')),
      body: ReadingBookGraphWidget(
        provider: (WidgetRef ref) =>
            ref.read(readingBooksProvider.notifier).currentEditReadingBook!,
      ),
    );
  }
}
