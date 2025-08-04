// lib/src/my_app.dart
import 'package:flutter/material.dart';

import '../application/model/my_application_model.dart';
import '../domain/model/my_counter_domain_model.dart';
import '../fundamental/ui_widget/staged_widget.dart';
import '../routing/app_router.dart';

class MyApp extends StagedWidget<MyApplicationModel> {
  const MyApp({
    super.key,
    super.isWidgetsBindingObserve = true,
    this.overrideCounterDomain,
  });

  /// 外部オーバーライド用カウンタードメイン
  /// （テスト時の利用を想定しています）
  // ignore: diagnostic_describe_all_properties
  final CounterDomain? overrideCounterDomain;

  @override
  MyApplicationModel? createWidgetState() {
    return MyApplicationModel(overrideCounterDomain: overrideCounterDomain);
  }

  @override
  void initState(MyApplicationModel? state) {
    state!.initState();
  }

  @override
  void disposeState(MyApplicationModel? state) {
    state!.disposeState();
  }

  @override
  Widget build(BuildContext context, MyApplicationModel? state) {
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
