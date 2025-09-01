import 'package:conference_handson_2025/src/domain/model/reading_book_value_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_books_value_object.dart';
import '../../../../fundamental/debug/debug_logger.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../../../routing/app_router.dart';
import '../../../model/view_model_packages.dart';

class CurrentlyTasksWidget
    extends ConsumerStagedWidget<ReadingBooksValueObject, ScrollController> {
  /// コンストラクタ
  ///
  /// - [provider] : 引数の Riverpod ref を使って状態値を取得する関数。
  ///
  /// - [builders] : （オプション）[buildList]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッド一覧を返す関数。
  ///
  /// - [selectBuilder] : （オプション）[selectBuild]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッドを返す関数。
  const CurrentlyTasksWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  // ウイジェット内部状態として ScrollController を使います。
  ScrollController? createWidgetState() => ScrollController();

  @override
  // ignore: unnecessary_overrides
  void initState(ScrollController? state) {
    super.initState(state);
  }

  @override
  void disposeState(ScrollController? state) {
    state!.dispose();
    super.disposeState(state);
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ReadingBooksValueObject value,
    ScrollController? state,
  ) {
    // CurrentlyTasksWidget ウイジェットの内部状態
    final ScrollController scrollController = state!;
    
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: ListView.builder(
        controller: scrollController,
        itemCount: value.readingBooks.length,
        itemBuilder: (BuildContext context, int index) {
          final ReadingBookValueObject book = value.readingBooks[index];
          final String title = book.name;
          return Dismissible(
            key: ValueKey(book.name),
            // スワイプ方向を左から右のみに制限
            direction: DismissDirection.startToEnd,
            // アイテムが完全にスワイプされたときに呼ばれるコールバックパターン1()
            // onDismissed: (DismissDirection direction) {
            //   // onTapに記述していたロジックをここに移動
            //   ref
            //       .read(readingBooksProvider.notifier)
            //       .selectReadingBook(index: index);
            //   debugLog('$title がスワイプされました。(削除あり)');
            //   context.goReadingBook();
            // },
             // アイテムが完全にスワイプされたときに呼ばれるコールバックパターン2
            confirmDismiss: (direction) async {
              // 画面遷移などの処理をここに記述
              ref
                  .read(readingBooksProvider.notifier)
                  .selectReadingBook(index: index);
              debugLog('$title がスワイプされました（削除なし）。');
              context.goReadingBook();

              // falseを返すことで、アイテムがリストから削除されるのを防ぎ、元の位置に戻す
              return true;
            },

            // スワイプ中に背景に表示されるウィジェット（右方向スワイプ）
            background: Container(
              color: Colors.blue,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.menu_book, color: Colors.white),
            ),

            // スワイプ中に背景に表示されるウィジェット（左方向スワイプ）
            secondaryBackground: Container(
              color: Colors.blue,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.menu_book, color: Colors.white),
            ),

            // スワイプされる本体のウィジェット
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(title),
                // onTapは不要なので削除
              ),
            ),
          );
        },
      ),
    );
  }
}
