import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/reading_books_domain_model.dart';
import '../../../presentation/model/view_model_packages.dart';
import '../../../presentation/ui_widget/widget_packages.dart';
import '../../../routing/app_router.dart';

class ReadingBookPage extends ConsumerWidget {
  /// コンストラクタ
  const ReadingBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ReadingBooksViewModel vm = ref.read(readingBooksProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          vm.currentEditMode == ReadingBookEditMode.create
              ? '書籍の新規登録'
              : '書籍情報の編集',
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.pie_chart), // 円グラフアイコン
            onPressed: context.goReadingGraph,
            tooltip: 'グラフ',
          ),
        ],
      ),
      body: ReadingBookWidget(
        provider: (WidgetRef ref) =>
            ref.watch(readingBooksProvider.notifier).currentEditReadingBook!,
      ),
    );
  }
}
