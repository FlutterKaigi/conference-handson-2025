import '../../domain/model/reading_books_domain_model.dart';
import '../../fundamental/model/base_objects_model.dart';

/// 読書進捗支援アプリ・アプリケーションモデルクラス。
class ApplicationModel extends ApplicationObject {
  ApplicationModel({this.overrideReadingBooksDomain});

  /// 外部オーバーライド用読書中書籍一覧ドメイン
  ReadingBooksDomainModel? overrideReadingBooksDomain;

  @override
  void initState() {
    // ドメインモデルを生成＆初期化する
    readingBooksDomainModelProvider(
      this,
      cycle: ModelCycle.init,
      overrideModel: overrideReadingBooksDomain,
    );
  }

  @override
  void disposeState() {
    // ドメインモデルを破棄する
    // アプリの強制終了には対応できないため、破棄処理が不要な設計をしてください。
    readingBooksDomainModelProvider(this, cycle: ModelCycle.dispose);
  }
}
