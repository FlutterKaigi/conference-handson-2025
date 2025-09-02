import 'package:go_router/go_router.dart';

/// （ReadingBookPage）アニメーション画面遷移ページ
class ReadingBookTransitionPage<T> extends NoTransitionPage<T> {
  const ReadingBookTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  });
}
