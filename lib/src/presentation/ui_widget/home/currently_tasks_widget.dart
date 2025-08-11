import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../fundamental/debug/debug_logger.dart';
import '../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../../routing/app_router.dart';
import '../../model/reading/reading_book_value_object.dart';
import '../../model/reading/reading_books_view_model.dart';

class CurrentlyTasksWidget
    extends
        ConsumerStagedWidget<List<ReadingBookValueObject>, ScrollController> {
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
  void disposeState(ScrollController? state) {
    state!.dispose();
    super.disposeState(state);
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    List<ReadingBookValueObject> value,
    ScrollController? state,
  ) {
    // CurrentlyTasksWidget ウイジェットの内部状態
    final ScrollController scrollController = state!;

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true, // スクロールバーを常に表示（任意）
      child: ListView.builder(
        controller: scrollController,
        itemCount: value.length,
        itemBuilder: (BuildContext context, int index) {
          final String title = value[index].name;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(title),
              onTap: () {
                ref
                    .read(readingBooksProvider.notifier)
                    .selectReadingBook(index: index);
                debugLog('$title がタップされました。');
                context.goReadingBook();
              },
            ),
          );
        },
      ),
    );
  }
}
