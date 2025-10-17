import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/model/view_model_packages.dart';
import '../../../presentation/ui_widget/widget_packages.dart';
import '../../../routing/app_router.dart';

class HomePage extends ConsumerWidget {
  /// コンストラクタ
  const HomePage({super.key});

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
          // 中層: 読書応援・アニメーション表示
          ReadingSupportAnimationsWidget(
            provider: (WidgetRef ref) =>
                ref.watch(readingSupportAnimationsProvider),
          ),
          // 上層: 読書進捗達成・アニメーション表示
          ReadingProgressAnimationsWidget(
            provider: (WidgetRef ref) =>
                ref.watch(readingProgressAnimationsProvider),
          ),
        ],
      ),
    );
  }
}
