import '../../application/model/my_application_model.dart';
import '../../fundamental/model/base_objects_model.dart';
import '../../presentation/model/my_counter_view_model.dart';
import 'my_counter_state_model.dart';

/// アプリ内共有の カウンター ドメインモデルオブジェクト
CounterDomain? _counterDomain;

/// カウンタ用の Notifier ⇒ ViewModel からしかドメインモデルにアクセスできないよう制限する。
CounterDomain counterDomainProvider(
  Object approver, {
  ModelCycle cycle = ModelCycle.get,
  CounterDomain? overrideModel,
}) {
  return modelProvider<MyApplicationModel, CounterDomain>(
    approver,
    cycle: cycle,
    isApproved: (Object approver) => approver is CounterViewModel,
    getModel: () => _counterDomain,
    initModel: () {
      _counterDomain = overrideModel ?? CounterDomain(stateModel: CountState());
      _counterDomain!.initState();
      return _counterDomain!;
    },
    disposeModel: () {
      final CounterDomain domain = _counterDomain!;
      _counterDomain!.disposeState();
      _counterDomain = null;
      return domain;
    },
  );
}

/// アプリケーションスコープで共有されるカウンターの状態を操作する Domainモデルクラス。
class CounterDomain extends DomainObject<CountState> {
  CounterDomain({required CountState stateModel}) : _stateModel = stateModel;

  final CountState _stateModel;

  @override
  CountState get stateModel => _stateModel;

  void increment() {
    int count = _stateModel.valueObject.count;
    _stateModel.update(_stateModel.valueObject.copyWith(count: ++count));
  }

  void reset() {
    _stateModel.update(_stateModel.valueObject.copyWith(count: 0));
  }

  @override
  void initState() {
    _stateModel.init();
  }

  @override
  void disposeState() {
    _stateModel.dispose();
  }
}
