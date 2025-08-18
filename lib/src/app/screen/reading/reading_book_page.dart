import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/reading_book_value_object.dart';
import '../../../presentation/model/view_model_packages.dart';
import '../../../presentation/ui_widget/widget_packages.dart';
import '../../../routing/app_router.dart';

class ReadingBookPage extends ConsumerWidget {
  /// コンストラクタ
  const ReadingBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ReadingBooksViewModel vm = ref.read(readingBooksProvider.notifier);
    final ReadingBookValueObject? book = vm.currentEditReadingBook;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          book?.name ?? '書籍情報',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.pie_chart, color: Colors.black),
            onPressed: context.goReadingGraph,
            tooltip: 'グラフ',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: Hero(
              tag: 'book-hero-${book?.name ?? ''}',
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.book,
                          size: 60,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(height: 12),
                        if (book != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              book.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ReadingBookWidget(
                provider: (WidgetRef ref) => ref
                    .watch(readingBooksProvider.notifier)
                    .currentEditReadingBook!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
