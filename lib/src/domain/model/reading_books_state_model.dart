import '../../fundamental/model/base_objects_model.dart';
import 'reading_book_value_object.dart';
import 'reading_books_value_object.dart';

/// アプリケーションスコープで共有される読書中書籍一覧の状態モデルクラス。
class ReadingBooksState extends StateObject<ReadingBooksValueObject> {
  ReadingBooksState({ReadingBooksValueObject? overrideValue})
    : _overrideValue = overrideValue;

  /// （オプション）テスト用初期状態値
  late ReadingBooksValueObject? _overrideValue;

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
    // 外部でテスト用初期状態値が指定されていた場合は、そちらを優先します。
    if (_overrideValue != null) {
      _serialNumber = 0;
      update(_overrideValue!);
      _overrideValue = null;
      return;
    }

    // 【注意】const 生成なので、readingBooks List は unmodifiable list になります。
    _valueObject = const ReadingBooksValueObject(
      stateType: ReadingBooksValueObject,
      readingBooks: <ReadingBookValueObject>[],
    );
    _serialNumber = 0;

    // FIXME ストレージから保存中の読書中書籍一覧を取得するようにすること。
    // ダミーデータを生成
    final List<ReadingBookValueObject> readingBooks = <ReadingBookValueObject>[
      const ReadingBookValueObject(
        stateType: ReadingBookValueObject,
        name: 'Flutter入門',
        totalPages: 100,
      ),
      const ReadingBookValueObject(
        stateType: ReadingBookValueObject,
        name: 'Flutter実践',
        totalPages: 350,
      ),
      const ReadingBookValueObject(
        stateType: ReadingBookValueObject,
        name: 'Introduction to Flutter for Beginners.',
        totalPages: 87,
      ),
    ];
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
