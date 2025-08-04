import 'package:conference_handson_2025/src/application/model/my_application_model.dart';
import 'package:conference_handson_2025/src/domain/model/my_counter_domain_model.dart';
import 'package:conference_handson_2025/src/domain/model/my_counter_state_model.dart';
import 'package:conference_handson_2025/src/fundamental/debug/debug_logger.dart';
import 'package:conference_handson_2025/src/fundamental/model/base_objects_model.dart';
import 'package:conference_handson_2025/src/presentation/model/my_counter_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'riverpod_unit_test_utillity.dart';

void main() {
  test('riverpod counterViewModel unit test', () {
    debugLog('riverpod counterViewModel unit test');

    // このテストのためにProviderContainerを作成します。
    // テスト間でのProviderContainerの共有はしてはいけません。

    // CounterState 状態モデルからカウント値を取得するテストです。
    final ProviderContainer container = createContainer();

    // counterProvider が内部で利用する counterDomainProvider の初期値をオーバーライドする。
    final CounterDomain domain = CounterDomain(stateModel: CountState());
    final MyApplicationModel appModel = MyApplicationModel(
      overrideCounterDomain: domain,
    );
    counterDomainProvider(
      appModel,
      cycle: ModelCycle.init,
      overrideModel: domain,
    );

    // CounterViewModel.state の CountValueObject からカウント値を取得
    int count = container.read(counterProvider).count;

    expect(count, equals(0));

    // CounterViewModel increment で、CounterState +1 にを更新する。
    container.read(counterProvider.notifier).increment();
    count = container.read(counterProvider).count;

    expect(count, equals(1));
  });
}
