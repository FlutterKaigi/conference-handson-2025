// lib/src/my_app.dart
import 'package:conference_handson_2025/src/domain/model/reading_books_domain_model.dart';
import 'package:flutter/material.dart';

import '../application/model/application_model.dart';
import '../fundamental/ui_widget/staged_widget.dart';
import '../routing/app_router.dart';

/// 読書進捗支援アプリ・ルートウィジェット
class App extends StagedWidget<ApplicationModel> {
  const App({
    super.key,
    super.isWidgetsBindingObserve = true,
    this.overrideReadingBooksDomain,
  });

  /// 外部オーバーライド用読書中諸世紀一覧ドメイン
  /// （テスト時の利用を想定しています）
  // ignore: diagnostic_describe_all_properties
  final ReadingBooksDomainModel? overrideReadingBooksDomain;

  @override
  ApplicationModel? createWidgetState() {
    return ApplicationModel(
      overrideReadingBooksDomain: overrideReadingBooksDomain,
    );
  }

  @override
  void initState(ApplicationModel? state) {
    state!.initState();
  }

  @override
  void disposeState(ApplicationModel? state) {
    state!.disposeState();
  }

  @override
  Widget build(BuildContext context, ApplicationModel? state) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          // テーマカラーを任意で変更 (例: deepPurple)
          seedColor: Colors.deepPurple,
        ),
        // Material 3 を有効化
        useMaterial3: true,
      ),
      // ダークテーマもMaterial 3で設定
      darkTheme: ThemeData.dark(useMaterial3: true),
      // システム設定に応じてテーマを切り替え
      themeMode: ThemeMode.system,
      routerConfig: appRouter, // ここで GoRouter の設定を渡す
    );
  }
}
