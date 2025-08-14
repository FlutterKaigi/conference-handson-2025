import '../../fundamental/model/base_objects_model.dart';
import 'reading_book_value_object.dart';
import 'reading_books_value_object.dart';

/// アプリケーションスコープで共有される読書中書籍一覧の状態モデルクラス。
class ReadingBooksState extends StateObject<ReadingBooksValueObject> {
  ReadingBooksState();

  late int _serialNumber;
  late ReadingBooksValueObject? _valueObject;

  @override
  int get serialNumber => _serialNumber;

  @override
  ReadingBooksValueObject get valueObject => _valueObject!;

  List<ReadingBookValueObject> get readingBooks => _valueObject!.readingBooks;

  void updateReadingBooks(List<ReadingBookValueObject> readingBooks) {
    // ReadingBooksValueObject.readingBooks の一覧内容は不定のため、
    // 状態更新にあたり _valueObject を const 生成していないことに留意。
    final ReadingBooksValueObject value = ReadingBooksValueObject(
      stateType: ReadingBooksValueObject,
      readingBooks: readingBooks,
    );
    update(value);
  }

  @override
  void init() {
    // 【注意】const 生成なので、readingBooks List は unmodifiable list になります。
    _valueObject = const ReadingBooksValueObject(
      stateType: ReadingBooksValueObject,
      readingBooks: <ReadingBookValueObject>[],
    );
    _serialNumber = 0;

    // FIXME ストレージから保存中の読書中書籍一覧を取得するようにすること。
    // ダミーデータを生成
    final List<ReadingBookValueObject> readingBooks =
        List<String>.generate(20, (int index) => '読書中書籍 ${index + 1}')
            .map(
              (String name) => ReadingBookValueObject(
                stateType: ReadingBookValueObject,
                name: name,
                totalPages: 100,
              ),
            )
            .toList();
    updateReadingBooks(readingBooks);
  }

  @override
  void dispose() {
    // FIXME ストレージに読書中書籍一覧を保存するようにすること。
    _valueObject = null;
    _serialNumber = 0;
  }

  @override
  void update(ReadingBooksValueObject value) {
    _valueObject = value;
    _serialNumber++;
  }
}
