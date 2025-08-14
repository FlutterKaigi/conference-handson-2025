import 'package:conference_handson_2025/src/domain/model/reading_books_state_model.dart';
import 'package:conference_handson_2025/src/presentation/model/reading/reading_books_view_model.dart';

import '../../application/model/application_model.dart';
import '../../fundamental/model/base_objects_model.dart';
import 'reading_book_value_object.dart';

/// アプリ内共有の カウンター ドメインモデルオブジェクト
ReadingBooksDomainModel? _readingBooksDomainModel;

/// カウンタ用の Notifier ⇒ ViewModel からしかドメインモデルにアクセスできないよう制限する。
ReadingBooksDomainModel readingBooksDomainModelProvider(
  Object approver, {
  ModelCycle cycle = ModelCycle.get,
  ReadingBooksDomainModel? overrideModel,
}) {
  return modelProvider<ApplicationModel, ReadingBooksDomainModel>(
    approver,
    cycle: cycle,
    isApproved: (Object approver) => approver is ReadingBooksViewModel,
    getModel: () => _readingBooksDomainModel,
    initModel: () {
      _readingBooksDomainModel = overrideModel ?? ReadingBooksDomainModel();
      _readingBooksDomainModel!.initState();
      return _readingBooksDomainModel!;
    },
    disposeModel: () {
      final ReadingBooksDomainModel domain = _readingBooksDomainModel!;
      _readingBooksDomainModel!.disposeState();
      _readingBooksDomainModel = null;
      return domain;
    },
  );
}

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

/// アプリケーションスコープで共有される読書中書籍一覧の状態を操作する Domainモデルクラス。
class ReadingBooksDomainModel extends DomainObject<ReadingBooksState> {
  /// デフォルト・コンストラクタ
  ReadingBooksDomainModel() {
    _stateModel = ReadingBooksState();
  }

  /// 読書中書籍一覧・状態モデル
  late final ReadingBooksState _stateModel;

  /// 読書中書籍一覧
  final List<ReadingBookValueObject> _readingBooks = <ReadingBookValueObject>[];

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
  void initState() {
    _stateModel.init();
    _readingBooks.clear();
    _readingBooks.addAll(_stateModel.readingBooks);
  }

  @override
  void disposeState() {
    _stateModel.dispose();
    _readingBooks.clear();
  }

  @override
  ReadingBooksState get stateModel => _stateModel;

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

  /// 編集モード：新規追加用・テンプレート書籍作成
  void createReadingBook() {
    _currentEditReadingBook = null;
    _currentEditIndex = null;
    _currentEditMode = ReadingBookEditMode.create;
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
    String? name,
    int? totalPages,
    int? readingPageNum,
    String? bookReview,
  }) {
    _currentEditReadingBook = _readingBooks[_currentEditIndex!].copyWith(
      name: name,
      totalPages: totalPages,
      readingPageNum: readingPageNum,
      bookReview: bookReview,
    );
    _currentEditMode = ReadingBookEditMode.edit;
    return _currentEditReadingBook!;
  }

  /// 編集モード・削除中
  ReadingBookValueObject removeReadingBook() {
    _currentEditReadingBook = _readingBooks[_currentEditIndex!];
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

  /// state 更新
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
    _stateModel.update(
      _stateModel.valueObject.copyWith(readingBooks: _readingBooks),
    );
  }
}
