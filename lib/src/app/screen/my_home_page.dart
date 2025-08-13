import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/my_counter_value_object.dart';
import '../../presentation/model/my_counter_view_model.dart';
import '../../presentation/ui_widget/consumer_counter_text.dart';
import '../../routing/app_router.dart';

const Key homePageCountKey = Key('home_count');

class MyHomePage extends ConsumerWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            const Text('If the count value higher 10, it will be reset.'),
            // provider から取得した状態値の isResetting で表現を切り替える、カウンタ値テキスト
            ConsumerCounterText(
              provider: (WidgetRef ref) => ref.watch(counterProvider),
              // ignore: always_specify_types
              builders: (context, ref, value, state) {
                // ignore: lines_longer_than_80_chars テスト時のチェック用に ConsumerCounterText のキーを Text にも与えている。
                Widget text(String label) => Text(
                  label,
                  style: Theme.of(context).textTheme.headlineMedium,
                  key: super.key,
                );

                // ignore: always_specify_types, lines_longer_than_80_chars
                Widget build(context, ref, CountValueObject value, state) =>
                    text('${value.count}');
                // ignore: always_specify_types, lines_longer_than_80_chars
                Widget build2(context, ref, CountValueObject value, state) =>
                    text('*** ${value.count} ***');

                // ignore: always_specify_types
                return [build, build2];
              },
              // ignore: always_specify_types
              selectBuilder: (builders, CountValueObject providerValue) =>
                  builders[providerValue.isResetting ? 1 : 0],
              key: homePageCountKey,
            ),
            //
            const SizedBox(height: 16), // Optional: for spacing
            ElevatedButton(
              onPressed: () {
                // go_router を使った画面遷移
                context.goDetail();
              },
              child: const Text('to current count'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}
