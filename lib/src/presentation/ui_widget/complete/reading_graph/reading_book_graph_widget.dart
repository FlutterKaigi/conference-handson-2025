import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';

// FIXME ダミーのウィジェットコード（バレルファイルで参照されていません）
// FIXME ダミーのコードから、完成形のパッケージのコードに差し替えてバレルファイルを修正してください。
class ReadingBookGraphWidget
    extends ConsumerStagedWidget<ReadingBookValueObject, Object> {
  const ReadingBookGraphWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ReadingBookValueObject value,
    Object? state,
  ) {
    throw UnimplementedError();
  }

  @override
  Object? createWidgetState() {
    throw UnimplementedError();
  }
}
