import 'package:conference_handson_2025/src/app/my_app.dart' as app;
import 'package:conference_handson_2025/src/app/screen/my_detail_page.dart';
import 'package:conference_handson_2025/src/app/screen/my_home_page.dart';
import 'package:conference_handson_2025/src/domain/model/my_counter_domain_model.dart';
import 'package:conference_handson_2025/src/domain/model/my_counter_state_model.dart';
import 'package:conference_handson_2025/src/fundamental/debug/debug_logger.dart';
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
    Text homeCounterLabel =
        homeCountFinder
                .evaluate()
                .singleWhere((Element e) => e.widget is Text)
                .widget
            as Text;

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    homeCounterLabel =
        homeCountFinder
                .evaluate()
                .singleWhere((Element e) => e.widget is Text)
                .widget
            as Text;

    // Verify that our counter has incremented.
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(MyDetailPage), findsNothing);
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(homeCounterLabel.data, '1');

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
