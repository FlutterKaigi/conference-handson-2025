import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/my_counter_domain_model.dart';
import 'my_counter_value_object.dart';

final NotifierProvider<CounterViewModel, CountValueObject> counterProvider =
    NotifierProvider<CounterViewModel, CountValueObject>(
      () => CounterViewModel(),
    );

/// 画面内で共有されるカウンターの状態モデルを参照して、カレント状態値を管理するクラス。
class CounterViewModel extends Notifier<CountValueObject> {
  CounterViewModel();

  final int maxValue = 10;

  @override
  CountValueObject build() {
    // 外部定義されたアプリ全体共有の CountDomain オブジェクトを参照して VO の初期化を行う。
    // riverpod が管理する state 変数内容 ⇒ VO の初期値を生成して返却する。
    final CounterDomain domain = counterDomainProvider(this);
    return CountValueObject(
      stateType: domain.stateModel.runtimeType,
      count: domain.stateModel.valueObject.count,
    );
  }

  void increment() {
    final CounterDomain domain = counterDomainProvider(this);
    domain.increment();
    _resetOrNot(domain);
    _updateState(domain);
  }

  // ドメインモデルが保持する状態モデルの
  // カウント値が maxValueを超えれば、指定秒後に0にリセットする。
  void _resetOrNot(CounterDomain domain) {
    if (domain.stateModel.valueObject.count >= maxValue) {
      Timer(const Duration(seconds: 2), () {
        domain.reset();
        _updateState(domain);
      });
    }
  }

  /// riverpod の state 更新
  void _updateState(CounterDomain domain) {
    state = state.copyWith(
      stateType: domain.stateModel.runtimeType,
      count: domain.stateModel.valueObject.count,
      isLoading: domain.stateModel.valueObject.count >= maxValue,
    );
  }
}
