import 'package:conference_handson_2025/src/application/model/application_model.dart';
import 'package:conference_handson_2025/src/domain/model/reading_book_value_object.dart';
import 'package:conference_handson_2025/src/domain/model/reading_books_domain_model.dart';
import 'package:conference_handson_2025/src/domain/model/reading_books_state_model.dart';
import 'package:conference_handson_2025/src/domain/model/reading_books_value_object.dart';
import 'package:conference_handson_2025/src/fundamental/debug/debug_logger.dart';
import 'package:conference_handson_2025/src/fundamental/model/base_objects_model.dart';
import 'package:conference_handson_2025/src/presentation/model/view_model_packages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'riverpod_unit_test_utillity.dart';

void main() {
  test('riverpod readingBooksViewModel unit test', () {
    debugLog('riverpod readingBooksViewModel unit test');

    // このテストのためにProviderContainerを作成します。
    // テスト間でのProviderContainerの共有はしてはいけません。

    // CounterState 状態モデルからカウント値を取得するテストです。
    final ProviderContainer container = createContainer();

    //　読書中書籍 0件 でテストを行うため、ドメイン・オブジェクトをオーバライドします。
    const ReadingBooksValueObject value = ReadingBooksValueObject(
      stateType: ReadingBooksDomainModel,
      readingBooks: <ReadingBookValueObject>[],
    );
    final ReadingBooksState state = ReadingBooksState(overrideValue: value);
    final ReadingBooksDomainModel domain = ReadingBooksDomainModel(
      overrideStateModel: state,
    );

    // readingBooksProvider が内部で利用する ドメインProvider の初期値をオーバーライドする。
    final ApplicationModel appModel = ApplicationModel(
      overrideReadingBooksDomain: domain,
    );
    readingBooksDomainModelProvider(
      appModel,
      cycle: ModelCycle.init,
      overrideModel: domain,
    );

    // ReadingBooksViewModel.state の ReadingBooksValueObject から一覧を取得
    List<ReadingBookValueObject> readingBooks = container
        .read(readingBooksProvider)
        .readingBooks;

    debugLog(
      '読書支援書籍一覧の初期値が、0件であることをチェックする。\n'
      ' （readingBooks.length=${readingBooks.length}）\n',
    );
    expect(readingBooks.length, equals(0));

    // ReadingBooksViewModel addReadingBook で、読書支援書籍を新規追加する。
    ReadingBookValueObject book = container
        .read(readingBooksProvider.notifier)
        .addReadingBook(name: 'Flutter入門', totalPages: 350);
    container.read(readingBooksProvider.notifier).commitReadingBook(book);
    readingBooks = container.read(readingBooksProvider).readingBooks;

    debugLog(
      '読書支援書籍一覧に、"Flutter入門"を追加したことをチェックする。\n'
      ' （readingBooks.length=${readingBooks.length}）, \n'
      ' （readingBooks.first.name=${readingBooks.first.name}）\n',
    );
    expect(readingBooks.length, equals(1));
    expect(readingBooks.first.name, equals('Flutter入門'));

    // ReadingBooksViewModel updateReadingBook で、読書支援書籍を編集する。
    container.read(readingBooksProvider.notifier).selectReadingBook(index: 0);
    book = container
        .read(readingBooksProvider.notifier)
        .updateReadingBook(name: 'Flutter実践入門');
    container.read(readingBooksProvider.notifier).commitReadingBook(book);
    readingBooks = container.read(readingBooksProvider).readingBooks;

    debugLog(
      '書籍名を、"Flutter入門"から"Flutter実践入門"に編集したことをチェックする。\n'
      ' （readingBooks.length=${readingBooks.length}）, \n'
      ' （readingBooks.first.name=${readingBooks.first.name}）\n',
    );
    expect(readingBooks.length, equals(1));
    expect(readingBooks.first.name, equals('Flutter実践入門'));

    // 削除用書籍を追加する。
    book = container
        .read(readingBooksProvider.notifier)
        .addReadingBook(name: 'Vibeでええやん？', totalPages: 100);
    container.read(readingBooksProvider.notifier).commitReadingBook(book);
    readingBooks = container.read(readingBooksProvider).readingBooks;

    debugLog(
      '読書支援書籍一覧に、削除テスト用書籍の"Vibeでええやん？"を追加したことをチェックする。\n'
      ' （readingBooks.length=${readingBooks.length}）, \n'
      ' （readingBooks.first.name=${readingBooks.first.name}）, \n'
      ' （readingBooks.last.name=${readingBooks.last.name}）\n',
    );
    expect(readingBooks.length, equals(2));
    expect(readingBooks.last.name, equals('Vibeでええやん？'));

    // ReadingBooksViewModel removeReadingBook で、読書支援書籍を削除する。
    container.read(readingBooksProvider.notifier).selectReadingBook(index: 1);
    book = container.read(readingBooksProvider.notifier).removeReadingBook();
    container.read(readingBooksProvider.notifier).commitReadingBook(book);
    readingBooks = container.read(readingBooksProvider).readingBooks;

    debugLog(
      '読書支援書籍一覧から、書籍の"Vibeでええやん？"を削除したことをチェックする。\n'
      ' （readingBooks.length=${readingBooks.length}）, \n'
      ' （readingBooks.first.name=${readingBooks.first.name}）, \n'
      ' （readingBooks.last.name=${readingBooks.last.name}）\n',
    );
    expect(readingBooks.length, equals(1));
    expect(readingBooks.first.name, equals('Flutter実践入門'));
    expect(readingBooks.last.name, equals('Flutter実践入門'));
  });
}
