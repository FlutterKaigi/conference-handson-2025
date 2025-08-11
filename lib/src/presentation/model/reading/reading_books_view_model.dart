import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reading_book_value_object.dart';

final NotifierProvider<ReadingBooksViewModel, List<ReadingBookValueObject>>
readingBooksProvider =
    NotifierProvider<ReadingBooksViewModel, List<ReadingBookValueObject>>(
      // TODO 後日、アプリモデルから正式な初期データを取得できるようにすること。
      () => ReadingBooksViewModel.withDummyData(),
    );

/// 読書中書籍・編集モード
enum ReadingBookEditMode {
  /// 新規作成中
  create,

  /// 編集中
  edit,

  /// 削除中
  delete,

  /// 不定
  undecided,
}

/// 読書中書籍一覧・読書状況 ViewModel
class ReadingBooksViewModel extends Notifier<List<ReadingBookValueObject>> {
  /// デフォルト・コンストラクタ
  ReadingBooksViewModel() : this.init();

  /// 初期化指定付・コンストラクタ
  ///
  /// - [readingBooks] : （オプション）読書中書籍一覧
  ReadingBooksViewModel.init({List<ReadingBookValueObject>? readingBooks}) {
    _readingBooks = readingBooks ?? <ReadingBookValueObject>[];
  }

  // ダミーデータを生成するファクトリメソッド
  factory ReadingBooksViewModel.withDummyData() {
    final List<ReadingBookValueObject> readingBooks =
        List<String>.generate(20, (int index) => '読書中書籍 ${index + 1}')
            .map(
              (String name) => ReadingBookValueObject(
                stateType: Object,
                name: name,
                totalPages: 100,
              ),
            )
            .toList();
    return ReadingBooksViewModel.init(readingBooks: readingBooks);
  }

  /// 読書中書籍一覧
  late final List<ReadingBookValueObject> _readingBooks;

  /// 編集中書籍・編集モード
  // ignore: prefer_final_fields
  ReadingBookEditMode _currentEditMode = ReadingBookEditMode.undecided;

  /// 編集中書籍・index
  // ignore: prefer_final_fields
  int? _currentEditIndex;

  /// 編集中書籍
  // ignore: prefer_final_fields
  ReadingBookValueObject? _currentEditReadingBook;

  // 将来的には読書進捗などもここに追加します

  @override
  List<ReadingBookValueObject> build() {
    // riverpod が管理する state 変数内容 ⇒ VO の初期値を生成して返却する。
    // ここでは、VO ⇒ ValueObject として読書中書籍一覧の初期値を設定する。
    return readingBooks;
  }

  /// 読書中書籍一覧
  List<ReadingBookValueObject> get readingBooks =>
      List<ReadingBookValueObject>.unmodifiable(_readingBooks);

  /// 編集モード
  ReadingBookEditMode get currentEditMode => _currentEditMode;

  /// 編集モード
  ReadingBookValueObject? get currentEditReadingBook => _currentEditReadingBook;

  /// 編集モード・書籍選択
  void selectReadingBook({required int index}) {
    _currentEditIndex = index;
    _currentEditReadingBook = _readingBooks[index];
    _currentEditMode = ReadingBookEditMode.edit;
  }

  /// 編集モード：新規追加中
  ReadingBookValueObject addReadingBook({
    required String name,
    required int totalPages,
  }) {
    _currentEditReadingBook = ReadingBookValueObject(
      stateType: ReadingBookValueObject,
      name: name,
      totalPages: totalPages,
    );
    _currentEditIndex = null;
    _currentEditMode = ReadingBookEditMode.create;
    return _currentEditReadingBook!;
  }

  /// 編集モード・読書状況更新中
  ReadingBookValueObject updateReadingBook({
    int? readingPageNum,
    String? bookReview,
  }) {
    _currentEditReadingBook = _readingBooks[_currentEditIndex!].copyWith(
      readingPageNum: readingPageNum,
      bookReview: bookReview,
    );
    _currentEditMode = ReadingBookEditMode.edit;
    return _currentEditReadingBook!;
  }

  /// 編集モード・削除中
  ReadingBookValueObject removeReadingBook() {
    _currentEditReadingBook = readingBooks[_currentEditIndex!];
    _currentEditMode = ReadingBookEditMode.delete;
    return _currentEditReadingBook!;
  }

  /// 編集モード・完了
  void commitReadingBook(ReadingBookValueObject readingBook) {
    _updateState(readingBook);
    _currentEditReadingBook = null;
    _currentEditIndex = null;
    _currentEditMode = ReadingBookEditMode.undecided;
  }

  /// riverpod の state 更新
  void _updateState(ReadingBookValueObject readingBook) {
    switch (_currentEditMode) {
      case ReadingBookEditMode.create:
        _readingBooks.add(readingBook);
      case ReadingBookEditMode.edit:
        _readingBooks[_currentEditIndex!] = readingBook;
      case ReadingBookEditMode.delete:
        _readingBooks.removeAt(_currentEditIndex!);
      case ReadingBookEditMode.undecided:
        break;
    }
    state = readingBooks;
  }
}
