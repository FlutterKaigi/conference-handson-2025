// lib/src/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/screen/home/home_page.dart';
import '../app/screen/my_detail_page.dart';
import '../app/screen/my_home_page.dart';
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
          path: AppRoutes.count.path,
          name: AppRoutes.count.name, // ルート名
          builder: (BuildContext context, GoRouterState state) {
            return const MyHomePage(title: 'Flutter Demo');
          },
        ),
        GoRoute(
          path: AppRoutes.detail.path,
          name: AppRoutes.detail.name, // ルート名
          builder: (BuildContext context, GoRouterState state) {
            return const MyDetailPage();
          },
        ),
        GoRoute(
          path: AppRoutes.books.path,
          name: AppRoutes.books.name, // ルート名
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
        ),
        GoRoute(
          path: AppRoutes.settings.path,
          name: AppRoutes.settings.name, // ルート名
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsPage();
          },
        ),
        GoRoute(
          path: AppRoutes.readingBook.path,
          name: AppRoutes.readingBook.name, // ルート名
          builder: (BuildContext context, GoRouterState state) {
            return const ReadingBookPage();
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
  void goHome() => goNamed(AppRoutes.home.name);

  void goCount() => goNamed(AppRoutes.count.name);

  void goDetail() => goNamed(AppRoutes.detail.name);

  void goBooks() => goNamed(AppRoutes.books.name);

  void goSettings() => goNamed(AppRoutes.settings.name);

  void goReadingBook() => goNamed(AppRoutes.readingBook.name);

  // パラメータを伴う画面遷移の場合の例 (今回は不要)
  // void goUserDetails(String userId) =>
  //   goNamed('userDetails', params: {'userId': userId});
}

// ルート名を定数化 (任意ですが推奨)
enum AppRoutes {
  home('/'),
  count('/count'),
  detail('/detail'),
  books('/books'),
  settings('/settings'),
  readingBook('/reading_book');

  const AppRoutes(this.path);

  final String path;
}
