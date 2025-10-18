import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';

// FIXME ダミーのウィジェットコード（バレルファイルで参照されていません）
// FIXME ダミーのコードから、完成形のパッケージのコードに差し替えてバレルファイルを修正してください。
class ReadingBookWidget
    extends ConsumerStagedWidget<ReadingBookValueObject, ReadingBookState> {
  const ReadingBookWidget({
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
    ReadingBookState? state,
  ) {
    throw UnimplementedError();
  }

  @override
  ReadingBookState? createWidgetState() {
    throw UnimplementedError();
  }
}

class ReadingBookState {
  ReadingBookState();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
  final TextEditingController readingPageNumController =
      TextEditingController();
  final TextEditingController bookReviewController = TextEditingController();
}
