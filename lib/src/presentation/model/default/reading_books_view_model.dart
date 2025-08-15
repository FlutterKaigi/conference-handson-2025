import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/reading_book_value_object.dart';
import '../../../domain/model/reading_books_domain_model.dart';
import '../../../domain/model/reading_books_value_object.dart';

final NotifierProvider<ReadingBooksViewModel, ReadingBooksValueObject>
readingBooksProvider =
    NotifierProvider<ReadingBooksViewModel, ReadingBooksValueObject>(
      () => ReadingBooksViewModel(),
    );

/// 読書中書籍一覧・読書状況 ViewModel
class ReadingBooksViewModel extends Notifier<ReadingBooksValueObject> {
  /// デフォルト・コンストラクタ
  ReadingBooksViewModel();

  /// 読書中書籍一覧
  late final ReadingBooksDomainModel _domainModel;

  // 将来的には読書進捗などもここに追加します

  @override
  ReadingBooksValueObject build() {
    // 外部定義されたアプリ全体共有の 読書中書籍一覧 オブジェクトを参照して VO の初期化を行う。
    // riverpod が管理する state 変数内容 ⇒ VO の初期値を生成して返却する。
    _domainModel = readingBooksDomainModelProvider(this);
    return _domainModel.stateModel.valueObject;
  }

  /// 読書中書籍一覧
  List<ReadingBookValueObject> get readingBooks => _domainModel.readingBooks;

  /// 編集モード
  ReadingBookEditMode get currentEditMode => _domainModel.currentEditMode;

  /// 編集モード
  ReadingBookValueObject? get currentEditReadingBook =>
      _domainModel.currentEditReadingBook;

  /// 編集モード・書籍選択
  void selectReadingBook({required int index}) =>
      _domainModel.selectReadingBook(index: index);

  /// 編集モード：新規追加用・テンプレート書籍作成
  void createReadingBook() => _domainModel.createReadingBook();

  /// 編集モード：新規追加中
  ReadingBookValueObject addReadingBook({
    required String name,
    required int totalPages,
  }) => _domainModel.addReadingBook(name: name, totalPages: totalPages);

  /// 編集モード・読書状況更新中
  ReadingBookValueObject updateReadingBook({
    String? name,
    int? totalPages,
    int? readingPageNum,
    String? bookReview,
  }) => _domainModel.updateReadingBook(
    name: name,
    totalPages: totalPages,
    readingPageNum: readingPageNum,
    bookReview: bookReview,
  );

  /// 編集モード・削除中
  ReadingBookValueObject removeReadingBook() =>
      _domainModel.removeReadingBook();

  /// 編集モード・完了
  void commitReadingBook(ReadingBookValueObject readingBook) {
    _domainModel.commitReadingBook(readingBook);
    // 【注意】エレガントではありませんが、
    // 　　　　ドメインモデルは、riverpod を関知していないので、
    // 　　　　ViewModel が riverpod state を更新して画面反映させること。
    state = _domainModel.stateModel.valueObject;
  }
}
