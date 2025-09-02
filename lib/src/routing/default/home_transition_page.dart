import 'package:go_router/go_router.dart';

/// （HomePage）アニメーション画面遷移ページ
class HomeTransitionPage<T> extends NoTransitionPage<T> {
  const HomeTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  });
}
