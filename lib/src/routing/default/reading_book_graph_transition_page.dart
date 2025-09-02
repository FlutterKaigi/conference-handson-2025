import 'package:go_router/go_router.dart';

/// （ReadingBookGraphPage）アニメーション画面遷移ページ
class ReadingBookGraphTransitionPage<T> extends NoTransitionPage<T> {
  const ReadingBookGraphTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  });
}
