import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../../model/view_model_packages.dart';

// FIXME ダミーのウィジェットコード（バレルファイルで参照されていません）
// FIXME ダミーのコードから、完成形のパッケージのコードに差し替えてバレルファイルを修正してください。
class ReadingSupportAnimationsWidget
    extends ConsumerStagedWidget<SupportAnimationTypeEnum, Object> {
  const ReadingSupportAnimationsWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    SupportAnimationTypeEnum value,
    Object? state,
  ) {
    throw UnimplementedError();
  }

  @override
  Object? createWidgetState() {
    throw UnimplementedError();
  }
}
