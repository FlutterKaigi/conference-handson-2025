import 'package:conference_handson_2025/src/app/app.dart' as app;
import 'package:conference_handson_2025/src/app/screen/home/home_page.dart';
import 'package:conference_handson_2025/src/app/screen/reading/reading_book_page.dart';
import 'package:conference_handson_2025/src/app/screen/settings/settings_page.dart';
import 'package:conference_handson_2025/src/domain/model/reading_book_value_object.dart';
import 'package:conference_handson_2025/src/domain/model/reading_books_domain_model.dart';
import 'package:conference_handson_2025/src/domain/model/reading_books_state_model.dart';
import 'package:conference_handson_2025/src/domain/model/reading_books_value_object.dart';
import 'package:conference_handson_2025/src/fundamental/debug/debug_logger.dart';
import 'package:conference_handson_2025/src/presentation/ui_widget/morphing_button/reading/reading_book_widget.dart'
    as custom;
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
    await tester.pumpAndSettle();

    // ホーム画面が表示されていることを確認
    debugLog('アプリ起動画面にホームページ（HomePage ウィジェット）が表示されていることをチェックする。\n');
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);

    // 空の読書中書籍一覧であることを確認
    debugLog(
      'ホームページの読書中書籍一覧に、何も表示されていないことをチェックする。\n'
      ' （domain.readingBooks.isEmpty=${domain.readingBooks.isEmpty}）\n',
    );
    expect(find.text('Flutter入門'), findsNothing);
    expect(domain.readingBooks.isEmpty, true);

    // アプリバーの歯車アイコンをタップして、設定画面を開く。
    await tester.tap(find.byIcon(Icons.settings));

    // 設定画面への画面遷移が完了する（画面表示が落ち着く）まで待機
    await tester.pumpAndSettle();

    // 設定画面が表示されていることを確認
    debugLog(
      'アプリバーの歯車アイコンをタップして、\n'
      '設定画面（SettingsPage ウィジェット）に遷移したことをチェックする。\n',
    );
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
    debugLog(
      '設定画面で、書籍(書籍名："Flutter入門"、総ページ数：350)の「新規追加」を行い、\n'
      'ホーム画面（HomePage ウィジェット）に遷移したことをチェックする。\n',
    );
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);

    // 読書中書籍一覧に、書籍が追加されていることをチェック
    debugLog(
      'ホーム画面の読書中書籍一覧に、新規追加した"Flutter入門"が追加されたことをチェックする。\n'
      ' （domain.readingBooks.length=${domain.readingBooks.length}）, \n'
      ' （domain.readingBooks.first.name=${domain.readingBooks.first.name}）\n',
    );
    expect(find.text('Flutter入門'), findsOneWidget);
    expect(domain.readingBooks.isNotEmpty, true);

    // 読書中書籍カードをタップして、読書中書籍編集画面を開く
    await tester.tap(find.text('Flutter入門'));
    await tester.pumpAndSettle();

    // 読書中書籍編集画面が表示されていることを確認
    debugLog(
      '読書中書籍一覧の"Flutter入門"をタップして、\n'
      '読書中書籍編集画面（ReadingBookPage ウィジェット）に遷移したことをチェックする。\n'
      ' （domain.readingBooks.first.name=${domain.readingBooks.first.name}）, \n'
      // ignore: lines_longer_than_80_chars
      ' （domain.readingBooks.totalPages=${domain.readingBooks.first.totalPages}）, \n'
      // ignore: lines_longer_than_80_chars
      ' （domain.readingBooks.readingPageNum=${domain.readingBooks.first.readingPageNum}）, \n'
      // ignore: lines_longer_than_80_chars
      ' （domain.readingBooks.bookReview=${domain.readingBooks.first.bookReview}）\n',
    );
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
    debugLog('');

    // GoRouter 16.0 によるものか不明ですが、
    // Widget test 終了時の画面表示がキャッシュされているのか、
    // 次のテストでもカレント画面とされてしまう不具合があるようなので、
    // アプリバーのページバックボタンをタップして、ホーム画面に戻る
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ホーム画面が表示されていることを確認
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(ReadingBookPage), findsNothing);
    debugLog(
      'アプリバーのページバックボタンをタップして、\n'
      'ホーム画面（HomePage ウィジェット）に戻ったことをチェックする。\n',
    );
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
    debugLog('アプリ起動画面にホームページ（HomePage ウィジェット）が表示されていることをチェックする。\n');
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);

    // 読書中書籍一覧に Flutter入門 があることを確認
    debugLog(
      'ホーム画面の読書中書籍一覧に、ProviderScopeでオーバライドした"Flutter入門"があることをチェックする。\n'
      ' （domain.readingBooks.length=${domain.readingBooks.length}）,  \n'
      ' （domain.readingBooks.first.name=${domain.readingBooks.first.name}）\n',
    );
    expect(find.text('Flutter入門'), findsOneWidget);
    expect(domain.readingBooks.isNotEmpty, true);

    // Flutter入門 のカードをタップして、読書中書籍編集画面を開く
    await tester.tap(find.text('Flutter入門'));
    await tester.pumpAndSettle();

    // 読書中書籍編集画面が表示されていることを確認
    debugLog(
      '読書中書籍一覧の"Flutter入門"をタップして、\n'
      '読書中書籍編集画面（ReadingBookPage ウィジェット）に遷移したことをチェックする。\n'
      ' （domain.readingBooks.first.name=${domain.readingBooks.first.name}）, \n'
      // ignore: lines_longer_than_80_chars
      ' （domain.readingBooks.totalPages=${domain.readingBooks.first.totalPages}）, \n'
      // ignore: lines_longer_than_80_chars
      ' （domain.readingBooks.readingPageNum=${domain.readingBooks.first.readingPageNum}）, \n'
      // ignore: lines_longer_than_80_chars
      ' （domain.readingBooks.bookReview=${domain.readingBooks.first.bookReview}）\n',
    );
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(ReadingBookPage), findsOneWidget);

    // 補足：読書中書籍の設定内容をデバッグ出力
    final Finder finder = find.byType(TextField);
    finder.evaluate().forEach((Element e) {
      final TextField tf = e.widget as TextField;
      final String text = tf.controller?.text ?? '';
      debugLog('（編集前）TextField - $text');
    });
    debugLog('');

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

    if (find.text('編集する').evaluate().isNotEmpty) {
      // 「編集する」ボタンが見える位置までスクロールする
      await tester.ensureVisible(find.text('編集する'));
      await tester.pumpAndSettle();

      // 「編集する」ボタンをタップして読書中書籍を更新＋ホーム画面への復帰を待機
      await tester.tap(find.text('編集する'));
      await tester.pumpAndSettle();
    } else if (find
        .byKey(custom.ReadingBookWidget.morphingButtonKey)
        .evaluate()
        .isNotEmpty) {
      // 読書中書籍編集画面の「編集」モーフィングボタンをタップする場合
      // カスタム UI では、アニメーション表示のためにボタンを CustomPaint で描画します。
      // このため 通常の find.text(ラベル名) を使ったヒット処理が行えないので、
      // Key を使った、カスタム UI 専用のテスト処理を行います。

      // Keyを使ってモーフィングボタンが見える位置までスクロールする
      await tester.ensureVisible(
        find.byKey(custom.ReadingBookWidget.morphingButtonKey),
      );
      await tester.pumpAndSettle();

      // Keyを使ってモーフィングボタンを検索し、タップする
      await tester.tap(find.byKey(custom.ReadingBookWidget.morphingButtonKey));

      // 編集中のアニメーションの Future<void>.delayed() で処理が停止するため、
      // 編集終了時の _navigateBack ⇒ Navigator.pop() を待たず、強制的にホーム画面に戻る。
      await tester.pageBack();
      await tester.pumpAndSettle();
    } else {
      throw UnsupportedError('Unknown ReadingBookWidget Edit button');
    }

    // ホーム画面が表示されていることを確認
    debugLog(
      '読書中書籍編集画面で、書籍名を"Flutter入門"から"Flutter実践入門"に「編集」して、\n'
      'ホーム画面（HomePage ウイジェット）に遷移したことをチェックする。\n',
    );
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(ReadingBookPage), findsNothing);

    // 読書中書籍一覧に Flutter実践入門 があることを確認
    debugLog(
      '読書中書籍一覧に、書籍名を変更した"Flutter入門"があることをチェックする。\n'
      ' （domain.readingBooks.length=${domain.readingBooks.length}）, \n'
      ' （domain.readingBooks.first.name=${domain.readingBooks.first.name}）\n',
    );
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
    debugLog('アプリ起動画面にホームページ（HomePage ウィジェット）が表示されていることをチェックする。\n');
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);

    // 読書中書籍一覧に Flutter入門 があることを確認
    debugLog(
      'ホーム画面の読書中書籍一覧に、ProviderScopeでオーバライドした"Flutter入門"があることをチェックする。\n'
      ' （domain.readingBooks.length=${domain.readingBooks.length}）,  \n'
      ' （domain.readingBooks.first.name=${domain.readingBooks.first.name}）\n',
    );
    expect(find.text('Flutter入門'), findsOneWidget);
    expect(domain.readingBooks.isNotEmpty, true);

    // Flutter入門 のカードをタップして、読書中書籍編集画面を開く
    await tester.tap(find.text('Flutter入門'));
    await tester.pumpAndSettle();

    // 読書中書籍編集画面が表示されていることを確認
    debugLog(
      '読書中書籍一覧の"Flutter入門"をタップして、\n'
      '読書中書籍編集画面（ReadingBookPage ウィジェット）に遷移したことをチェックする。\n'
      ' （domain.readingBooks.first.name=${domain.readingBooks.first.name}）, \n'
      // ignore: lines_longer_than_80_chars
      ' （domain.readingBooks.totalPages=${domain.readingBooks.first.totalPages}）, \n'
      // ignore: lines_longer_than_80_chars
      ' （domain.readingBooks.readingPageNum=${domain.readingBooks.first.readingPageNum}）, \n'
      // ignore: lines_longer_than_80_chars
      ' （domain.readingBooks.bookReview=${domain.readingBooks.first.bookReview}）\n',
    );
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(ReadingBookPage), findsOneWidget);

    // 補足：読書中書籍の設定内容をデバッグ出力
    final Finder finder = find.byType(TextField);
    finder.evaluate().forEach((Element e) {
      final TextField tf = e.widget as TextField;
      final String text = tf.controller?.text ?? '';
      debugLog('（編集前）TextField - $text');
    });
    debugLog('');

    // １段目にある 書籍タイトル入力テキストフィールドの書籍名をチェック
    expect(findTextField(find, 0), 'Flutter入門');

    // ２段目にある 書籍総ページ数入力テキストフィールドのページ数をチエック
    expect(findTextField(find, 1), '350');

    // ３段目にある 読書中ページ番号入力テキストフィールドのページ番号をチエック
    expect(findTextField(find, 2), '0');

    // ４段目にある 読書中書籍レビュー入力テキストフィールドの内容をチエック
    expect(findTextField(find, 3), '');

    // 「この書籍を削除する」ボタンが見える位置までスクロールする
    await tester.ensureVisible(find.text('この書籍を削除する'));
    await tester.pumpAndSettle();

    // 「この書籍を削除する」ボタンをタップして読書中書籍を削除させる。
    await tester.tap(find.text('この書籍を削除する'));
    await tester.pumpAndSettle();

    // ダイアログの「削除」をタップして読書中書籍を削除＋ホーム画面への復帰を待機
    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();

    // ホーム画面が表示されていることを確認
    debugLog(
      '読書中書籍編集画面の「この書籍を削除する」をタップして、確認ダイアログの「削除」もタップして、\n'
      'ホーム画面（HomePage ウイジェット）に遷移したことをチェックする。\n',
    );
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(ReadingBookPage), findsNothing);

    // 読書中書籍一覧に Flutter入門 が無く、一覧が空になっていることを確認
    debugLog(
      '読書中書籍一覧に、削除した"Flutter入門"がなくなっていることをチェックする。\n'
      ' （domain.readingBooks.length=${domain.readingBooks.length}）\n',
    );
    expect(find.text('Flutter入門'), findsNothing);
    expect(domain.readingBooks.isEmpty, true);
  });
}

String findTextField(CommonFinders find, int index) {
  final TextField tf =
      find.byType(TextField).evaluate().elementAt(index).widget as TextField;
  return tf.controller?.text ?? '';
}
