import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// （ReadingBookPage）アニメーション画面遷移ページ
class ReadingBookTransitionPage<T> extends CustomTransitionPage<T> {
  const ReadingBookTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
         transitionsBuilder: ReadingBookTransitionPage.customTransitionsBuilder,
       );

  /// カスタム画面遷移アニメーションビルダー
  static Widget customTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 変更点：左から右へのスライドアニメーションを定義
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
  }
}
