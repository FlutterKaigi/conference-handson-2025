import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/model/default/reading_books_view_model.dart';
import '../../../presentation/ui_widget/settings/reading_book_settings_widget.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('読書書籍設定')),
      body: ReadingBookSettingsWidget(
        provider: (WidgetRef ref) =>
            ref.read(readingBooksProvider.notifier).createReadingBook(),
      ),
    );
  }
}
