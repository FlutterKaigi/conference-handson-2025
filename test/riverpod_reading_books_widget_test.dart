import 'package:conference_handson_2025/src/app/app.dart' as app;
import 'package:conference_handson_2025/src/app/screen/home/home_page.dart';
import 'package:conference_handson_2025/src/app/screen/reading/reading_book_page.dart';
import 'package:conference_handson_2025/src/app/screen/settings/settings_page.dart';
import 'package:conference_handson_2025/src/domain/model/reading_book_value_object.dart';
import 'package:conference_handson_2025/src/domain/model/reading_books_domain_model.dart';
import 'package:conference_handson_2025/src/domain/model/reading_books_state_model.dart';
import 'package:conference_handson_2025/src/domain/model/reading_books_value_object.dart';
import 'package:conference_handson_2025/src/fundamental/debug/debug_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('addReadingBook smoke test', (WidgetTester tester) async {
    debugLog('riverpod ReadingBooksState addBook smoke test');

    //　読書中書籍 0件 でテストを行うため、ドメイン・オブジェクトをオーバライドします。
    const ReadingBooksValueObject value = ReadingBooksValueObject(
      stateType: ReadingBooksDomainModel,
      readingBooks: <ReadingBookValueObject>[],
    );
    final ReadingBooksState state = ReadingBooksState(overrideValue: value);
    final ReadingBooksDomainModel domain = ReadingBooksDomainModel(
      overrideStateModel: state,
    );

    // アプリを起動
    await tester.pumpWidget(
      ProviderScope(child: app.App(overrideReadingBooksDomain: domain)),
    );

    // ホーム画面が表示されていることを確認
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);

    // 空の読書中書籍一覧であることを確認
    expect(find.text('Flutter入門'), findsNothing);
    expect(domain.readingBooks.isEmpty, true);

    // アプリバーの歯車アイコンをタップして、設定画面を開く。
    await tester.tap(find.byIcon(Icons.settings));

    // 設定画面への画面遷移が完了する（画面表示が落ち着く）まで待機
    await tester.pumpAndSettle();

    // 設定画面が表示されていることを確認
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(SettingsPage), findsOneWidget);

    // 上段にある 書籍タイトル入力テキストフィールドに書籍名を入力
    await tester.enterText(find.byType(TextField).first, 'Flutter入門');

    // 下段にある 書籍総ページ数入力テキストフィールドにページ数を入力
    await tester.enterText(find.byType(TextField).last, '350');

    // 新規追加ボタンをタップして読書中書籍を追加＋ホーム画面への復帰を待機
    await tester.tap(find.text('新規追加'));
    await tester.pumpAndSettle();

    // ホーム画面が表示されていることを確認
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);

    // 読書中書籍一覧に、書籍が追加されていることをチェック
    expect(find.text('Flutter入門'), findsOneWidget);
    expect(domain.readingBooks.isNotEmpty, true);

    // 読書中書籍カードをタップして、読書中書籍編集画面を開く
    await tester.tap(find.text('Flutter入門'));
    await tester.pumpAndSettle();

    // 読書中書籍編集画面が表示されていることを確認
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(ReadingBookPage), findsOneWidget);

    // １段目にある 書籍タイトル入力テキストフィールドの書籍名をチェック
    expect(findTextField(find, 0), 'Flutter入門');

    // ２段目にある 書籍総ページ数入力テキストフィールドのページ数をチエック
    expect(findTextField(find, 1), '350');

    // 補足：読書中書籍の設定内容をデバッグ出力
    final Finder finder = find.byType(TextField);
    finder.evaluate().forEach((Element e) {
      final TextField tf = e.widget as TextField;
      final String text = tf.controller?.text ?? '';
      debugLog('TextField - $text');
    });

    // GoRouter 16.0 によるものか不明ですが、
    // Widget test 終了時の画面表示がキャッシュされているのか、
    // 次のテストでもカレント画面とされてしまう不具合があるようなので、
    // アプリバーのページバックボタンをタップして、ホーム画面に戻る
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ホーム画面が表示されていることを確認
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(ReadingBookPage), findsNothing);
  });

  testWidgets('updateReadingBook smoke test', (WidgetTester tester) async {
    debugLog('riverpod ReadingBooksState update smoke test');

    //　読書中書籍 1件 でテストを行うため、ドメイン・オブジェクトをオーバライドします。
    const ReadingBookValueObject readingBook = ReadingBookValueObject(
      stateType: ReadingBookValueObject,
      name: 'Flutter入門',
      totalPages: 350,
      readingPageNum: 0,
      bookReview: '',
    );
    const ReadingBooksValueObject value = ReadingBooksValueObject(
      stateType: ReadingBooksDomainModel,
      readingBooks: <ReadingBookValueObject>[readingBook],
    );
    final ReadingBooksState state = ReadingBooksState(overrideValue: value);
    final ReadingBooksDomainModel domain = ReadingBooksDomainModel(
      overrideStateModel: state,
    );

    // アプリを起動
    await tester.pumpWidget(
      ProviderScope(child: app.App(overrideReadingBooksDomain: domain)),
    );
    await tester.pumpAndSettle();

    // ホーム画面が表示されていることを確認
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);

    // 読書中書籍一覧に Flutter入門 があることを確認
    expect(find.text('Flutter入門'), findsOneWidget);
    expect(domain.readingBooks.isNotEmpty, true);

    // Flutter入門 のカードをタップして、読書中書籍編集画面を開く
    await tester.tap(find.text('Flutter入門'));
    await tester.pumpAndSettle();

    // 読書中書籍編集画面が表示されていることを確認
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(ReadingBookPage), findsOneWidget);

    // 補足：読書中書籍の設定内容をデバッグ出力
    final Finder finder = find.byType(TextField);
    finder.evaluate().forEach((Element e) {
      final TextField tf = e.widget as TextField;
      final String text = tf.controller?.text ?? '';
      debugLog('（編集前）TextField - $text');
    });

    // １段目にある 書籍タイトル入力テキストフィールドの書籍名をチェック
    expect(findTextField(find, 0), 'Flutter入門');

    // ２段目にある 書籍総ページ数入力テキストフィールドのページ数をチエック
    expect(findTextField(find, 1), '350');

    // ３段目にある 読書中ページ番号入力テキストフィールドのページ番号をチエック
    expect(findTextField(find, 2), '0');

    // ４段目にある 読書中書籍レビュー入力テキストフィールドの内容をチエック
    expect(findTextField(find, 3), '');

    // 上段にある 書籍タイトル入力テキストフィールドの書籍名を変更
    await tester.enterText(find.byType(TextField).first, 'Flutter実践入門');

    // 「編集する」ボタンをタップして読書中書籍を更新＋ホーム画面への復帰を待機
    await tester.tap(find.text('編集する'));
    await tester.pumpAndSettle();

    // ホーム画面が表示されていることを確認
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(ReadingBookPage), findsNothing);

    // 読書中書籍一覧に Flutter実践入門 があることを確認
    expect(find.text('Flutter実践入門'), findsOneWidget);
    expect(find.text('Flutter入門'), findsNothing);
    expect(domain.readingBooks.isNotEmpty, true);
  });

  testWidgets('removeReadingBook smoke test', (WidgetTester tester) async {
    debugLog('riverpod ReadingBooksState delete smoke test');

    //　読書中書籍 1件 でテストを行うため、ドメイン・オブジェクトをオーバライドします。
    const ReadingBookValueObject readingBook = ReadingBookValueObject(
      stateType: ReadingBookValueObject,
      name: 'Flutter入門',
      totalPages: 350,
      readingPageNum: 0,
      bookReview: '',
    );
    const ReadingBooksValueObject value = ReadingBooksValueObject(
      stateType: ReadingBooksDomainModel,
      readingBooks: <ReadingBookValueObject>[readingBook],
    );
    final ReadingBooksState state = ReadingBooksState(overrideValue: value);
    final ReadingBooksDomainModel domain = ReadingBooksDomainModel(
      overrideStateModel: state,
    );

    // アプリを起動
    await tester.pumpWidget(
      ProviderScope(child: app.App(overrideReadingBooksDomain: domain)),
    );
    await tester.pumpAndSettle();

    // ホーム画面が表示されていることを確認
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);

    // 読書中書籍一覧に Flutter入門 があることを確認
    expect(find.text('Flutter入門'), findsOneWidget);
    expect(domain.readingBooks.isNotEmpty, true);

    // Flutter入門 のカードをタップして、読書中書籍編集画面を開く
    await tester.tap(find.text('Flutter入門'));
    await tester.pumpAndSettle();

    // 読書中書籍編集画面が表示されていることを確認
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(ReadingBookPage), findsOneWidget);

    // 補足：読書中書籍の設定内容をデバッグ出力
    final Finder finder = find.byType(TextField);
    finder.evaluate().forEach((Element e) {
      final TextField tf = e.widget as TextField;
      final String text = tf.controller?.text ?? '';
      debugLog('（編集前）TextField - $text');
    });

    // １段目にある 書籍タイトル入力テキストフィールドの書籍名をチェック
    expect(findTextField(find, 0), 'Flutter入門');

    // ２段目にある 書籍総ページ数入力テキストフィールドのページ数をチエック
    expect(findTextField(find, 1), '350');

    // ３段目にある 読書中ページ番号入力テキストフィールドのページ番号をチエック
    expect(findTextField(find, 2), '0');

    // ４段目にある 読書中書籍レビュー入力テキストフィールドの内容をチエック
    expect(findTextField(find, 3), '');

    // 「この書籍を削除する」ボタンをタップして読書中書籍を削除させる。
    await tester.tap(find.text('この書籍を削除する'));
    await tester.pumpAndSettle();

    // ダイアログの「削除」をタップして読書中書籍を削除＋ホーム画面への復帰を待機
    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();

    // ホーム画面が表示されていることを確認
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(ReadingBookPage), findsNothing);

    // 読書中書籍一覧に Flutter入門 が無く、一覧が空になっていることを確認
    expect(find.text('Flutter入門'), findsNothing);
    expect(domain.readingBooks.isEmpty, true);
  });
}

String findTextField(CommonFinders find, int index) {
  final TextField tf =
      find.byType(TextField).evaluate().elementAt(index).widget as TextField;
  return tf.controller?.text ?? '';
}
