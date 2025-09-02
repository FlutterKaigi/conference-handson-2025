import 'package:go_router/go_router.dart';

/// （SettingsPage）アニメーション画面遷移ページ
class SettingsTransitionPage<T> extends NoTransitionPage<T> {
  const SettingsTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  });
}
