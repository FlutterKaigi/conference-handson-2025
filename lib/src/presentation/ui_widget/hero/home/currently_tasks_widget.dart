import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../domain/model/reading_books_value_object.dart';
import '../../../../fundamental/debug/debug_logger.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../../../routing/app_router.dart';
import '../../../model/view_model_packages.dart';

class CurrentlyTasksWidget
    extends ConsumerStagedWidget<ReadingBooksValueObject, BookListSearchState> {
  /// コンストラクタ
  ///
  /// - [provider] : 引数の Riverpod ref を使って状態値を取得する関数。
  ///
  /// - [builders] : （オプション）[buildList]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッド一覧を返す関数。
  ///
  /// - [selectBuilder] : （オプション）[selectBuild]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッドを返す関数。
  const CurrentlyTasksWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  BookListSearchState? createWidgetState() => BookListSearchState();

  @override
  void initState(BookListSearchState? state) {
    super.initState(state);
    state!.init();
  }

  @override
  void disposeState(BookListSearchState? state) {
    state!.dispose();
    super.disposeState(state);
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ReadingBooksValueObject value,
    BookListSearchState? state,
  ) {
    final List<ReadingBookValueObject> filteredBooks =
        state!.searchQuery.isEmpty
        ? value.readingBooks
        : value.readingBooks
              .where(
                (ReadingBookValueObject book) => book.name
                    .toLowerCase()
                    .contains(state.searchQuery.toLowerCase()),
              )
              .toList();

    final List<ReadingBookValueObject> readingBooks = filteredBooks
        .where(
          (ReadingBookValueObject book) =>
              book.readingState == ReadingState.reading,
        )
        .toList();

    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: state.searchController,
            onChanged: (String value) => state.updateSearchQuery(value),
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (readingBooks.isNotEmpty) ...<Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Reading',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredBooks.length,
            itemBuilder: (BuildContext context, int index) {
              final ReadingBookValueObject book = filteredBooks[index];
              final int originalIndex = value.readingBooks.indexOf(book);
              return BookCard(
                book: book,
                onTap: () {
                  ref
                      .read(readingBooksProvider.notifier)
                      .selectReadingBook(index: originalIndex);
                  debugLog('${book.name} がタップされました。');
                  context.goReadingBook();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class BookListSearchState {
  late final TextEditingController searchController;
  String searchQuery = '';
  VoidCallback? _updateCallback;

  void init() {
    searchController = TextEditingController();
  }

  void dispose() {
    searchController.dispose();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    _updateCallback?.call();
  }

  void setUpdateCallback(VoidCallback callback) {
    _updateCallback = callback;
  }
}

class BookCard extends StatelessWidget {
  const BookCard({required this.book, required this.onTap, super.key});

  final ReadingBookValueObject book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double progress = book.totalPages > 0
        ? book.readingPageNum / book.totalPages
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: 'book-hero-${book.name}',
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.book,
                      size: 40,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(height: 8),
                    if (book.readingState == ReadingState.reading)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${book.readingPageNum} / ${book.totalPages} ページ',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (book.readingState == ReadingState.complete)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '読了',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReadingBookValueObject>('book', book));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }
}
