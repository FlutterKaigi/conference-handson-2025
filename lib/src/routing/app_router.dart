// lib/src/routing/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/screen/home/home_page.dart';
import '../app/screen/reading/reading_book_page.dart';
import '../app/screen/settings/settings_page.dart';

// アプリケーションのルートを定義
final GoRouter appRouter = GoRouter(
  initialLocation: '/', // 初期表示するパス
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.home.path,
      name: AppRoutes.home.name, // ルート名 (型安全なナビゲーションで使用)
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.settings.path,
          name: AppRoutes.settings.name, // ルート名
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsPage();
          },
        ),
        GoRoute(
          path: AppRoutes.readingBook.path,
          name: AppRoutes.readingBook.name,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: const ReadingBookPage(),
              transitionsBuilder:
                  (BuildContext context, 
                  Animation<double> animation, 
                  Animation<double> secondaryAnimation, 
                  Widget child) {
                    // 変更点：上から下へのスライドアニメーションを定義
                    final Tween<Offset> tween = Tween<Offset>(
                      begin: const Offset(-1, 0), // 変更点：画面の左端の外側から
                      end: Offset.zero, // 画面の中央へ
                    );

                    final CurvedAnimation curvedAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    );

                    // SlideTransitionウィジェットを返す
                    return SlideTransition(
                      position: tween.animate(curvedAnimation),
                      child: child,
                    );
                  },
            );
          },
        ),
      ],
    ),
  ],
  // エラーページ定義
  errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text('Page not found: ${state.error}')),
  ),
);

// 型安全なナビゲーションのための拡張メソッド
extension AppRouterExtension on BuildContext {
  void goSettings() => goNamed(AppRoutes.settings.name);

  void goReadingBook() => goNamed(AppRoutes.readingBook.name);

  void goReadingGraph() => goNamed(AppRoutes.readingGraph.name);

  // パラメータを伴う画面遷移の場合の例 (今回は不要)
  // void goUserDetails(String userId) =>
  //   goNamed('userDetails', params: {'userId': userId});
}

// ルート名を定数化 (任意ですが推奨)
enum AppRoutes {
  home('/'),
  settings('/settings'),
  readingBook('/reading_book'),
  readingGraph('/reading_book/graph');

  const AppRoutes(this.path);

  final String path;
}
