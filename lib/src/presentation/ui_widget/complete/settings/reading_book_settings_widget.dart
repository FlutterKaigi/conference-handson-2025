import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';

// FIXME ダミーのウィジェットコード（バレルファイルで参照されていません）
// FIXME ダミーのコードから、完成形のパッケージのコードに差し替えてバレルファイルを修正してください。
class ReadingBookSettingsWidget
    extends ConsumerStagedWidget<Object?, ReadingBookSettingsState> {
  const ReadingBookSettingsWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    Object? value,
    ReadingBookSettingsState? state,
  ) {
    throw UnimplementedError();
  }

  @override
  ReadingBookSettingsState? createWidgetState() {
    throw UnimplementedError();
  }
}

class ReadingBookSettingsState {
  ReadingBookSettingsState();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
}
