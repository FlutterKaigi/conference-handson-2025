import 'package:conference_handson_2025/src/app/my_app.dart' as app;
import 'package:conference_handson_2025/src/app/screen/my_detail_page.dart';
import 'package:conference_handson_2025/src/app/screen/my_home_page.dart';
import 'package:conference_handson_2025/src/domain/model/my_counter_domain_model.dart';
import 'package:conference_handson_2025/src/domain/model/my_counter_state_model.dart';
import 'package:conference_handson_2025/src/fundamental/debug/debug_logger.dart';
import 'package:conference_handson_2025/src/presentation/ui_widget/consumer_counter_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    debugLog('riverpod CounterState increments smoke test');
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: app.MyApp()));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Counter increments override test', (WidgetTester tester) async {
    debugLog('riverpod CounterState increments override test');
    // 外部オーバーライドするカウンタードメインオブジェクト
    final CounterDomain domain = CounterDomain(stateModel: CountState());

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(child: app.MyApp(overrideCounterDomain: domain)),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // カウンタードメインのカウント数を外部から+1する。（表示は変更されない）
    domain.increment();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  /// MyHomePage と MyDetailPage でカウンタ状態値の共有を確認する。
  testWidgets('riverpod - share Counter state between pages smoke test', (
    WidgetTester tester,
  ) async {
    debugLog('riverpod - share Counter state between pages smoke test');
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: app.MyApp()));

    // homePageCountKey キーは、
    // ConsumerCounterText.build 内部の Text ウイジェットにも与えているため、
    // Finder 検索で複数件の候補の中から、ラベル表示に使う Text を抽出する。
    final Finder homeCountFinder = find.byKey(homePageCountKey);

    // homePageCountKey キーは、ConsumerCounterText にしか適用されない。
    final ConsumerCounterText counter =
        homeCountFinder.evaluate().single.widget as ConsumerCounterText;
    debugLog(
      'find - ConsumerCounterText hasKey=${counter.key == homePageCountKey}',
    );

    // Finder 検索で、全ての画面を対象とした候補の中から、ラベル表示の Text を抽出する。
    final List<Text> texts = homeCountFinder.allCandidates
        .map((Element e) => e.widget)
        .whereType<Text>()
        .toList();
    // ignore: avoid_function_literals_in_foreach_calls
    texts.forEach((Text text) {
      debugLog('find - ${text.data}, hasKey=${text.key == homePageCountKey}');
    });

    // ホーム画面のカウンタ・ラベルを抽出
    final Text homeCounterLabel = texts.singleWhere(
      (Text text) => text.data?.length == 1,
    );

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // 詳細画面のカウンタ・ラベルを抽出
    final Text detailCounterLabel = homeCountFinder.allCandidates
        .map((Element e) => e.widget)
        .whereType<Text>()
        .singleWhere((Text text) => text.data?.length == 1);

    // Verify that our counter has incremented.
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(MyDetailPage), findsNothing);
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(homeCounterLabel.data, '0');
    expect(detailCounterLabel.data, '1');

    // Tap the 'Go Second' button and trigger a frame.
    await tester.tap(find.text('to current count'));
    await tester.pumpAndSettle(); //画面遷移が完了するまで待機

    final Finder secondCountFinder = find.byKey(detailPageCountKey);
    final RichText secondCounterLabel =
        secondCountFinder.evaluate().single.widget as RichText;

    // Verify that our counter has incremented.
    expect(find.byType(MyHomePage), findsNothing);
    expect(find.byType(MyDetailPage), findsOneWidget);
    /*
    // RichText で表示しているため、find.text ⇒ Text Widget 探索では見つけられない。
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    */
    expect((secondCounterLabel.text as TextSpan).text, '1\n');
  });
}
