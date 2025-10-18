import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_books_value_object.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';

// FIXME ダミーのウィジェットコード（バレルファイルで参照されていません）
// FIXME ダミーのコードから、完成形のパッケージのコードに差し替えてバレルファイルを修正してください。
class CurrentlyTasksWidget
    extends ConsumerStagedWidget<ReadingBooksValueObject, ScrollController> {
  const CurrentlyTasksWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ReadingBooksValueObject value,
    ScrollController? state,
  ) {
    throw UnimplementedError();
  }

  @override
  ScrollController? createWidgetState() {
    throw UnimplementedError();
  }
}
