import '../../domain/model/my_counter_domain_model.dart';
import '../../domain/model/reading_books_domain_model.dart';
import '../../fundamental/model/base_objects_model.dart';

// アプリケーションモデルクラス。
class MyApplicationModel extends ApplicationObject {
  MyApplicationModel({this.overrideCounterDomain});

  /// 外部オーバーライド用カウンタードメイン
  CounterDomain? overrideCounterDomain;

  @override
  void initState() {
    // ドメインモデルを生成＆初期化する
    counterDomainProvider(
      this,
      cycle: ModelCycle.init,
      overrideModel: overrideCounterDomain,
    );
  }

  @override
  void disposeState() {
    // ドメインモデルを破棄する
    // アプリの強制終了には対応できないため、破棄処理が不要な設計をしてください。
    counterDomainProvider(this, cycle: ModelCycle.dispose);
  }
}
