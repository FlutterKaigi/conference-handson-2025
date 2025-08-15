import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/model/home/support_animations_view_model.dart';
import '../../../presentation/model/reading/reading_books_view_model.dart';
import '../../../presentation/ui_widget/home/currently_tasks_widget.dart';
import '../../../presentation/ui_widget/home/support_animations_widget.dart';
import '../../../routing/app_router.dart';

class HomePage extends ConsumerWidget {
  /// コンストラクタ
  const HomePage({super.key});

  void _cycleAnimationType(WidgetRef ref) {
    final SupportAnimationsViewModel vm = ref.read(
      supportAnimationsProvider.notifier,
    );
    final AnimationTypeEnum currentType = vm.animationType;
    final int nextTypeIndex =
        (AnimationTypeEnum.values.indexOf(currentType) + 1) %
        AnimationTypeEnum.values.length;
    vm.updateAnimationType(
      animationType: AnimationTypeEnum.values[nextTypeIndex],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('読書進捗応援'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings), // 歯車アイコン
            onPressed: context.goSettings,
            tooltip: '設定',
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          // 下層: 読書中書籍一覧
          CurrentlyTasksWidget(
            provider: (WidgetRef ref) => ref.watch(readingBooksProvider),
          ),
          // 上層: アニメーション表示
          SupportAnimationsWidget(
            provider: (WidgetRef ref) => ref.watch(supportAnimationsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _cycleAnimationType(ref),
        tooltip: 'アニメーション切替 (デバッグ用)',
        child: const Icon(Icons.animation),
      ),
    );
  }
}
