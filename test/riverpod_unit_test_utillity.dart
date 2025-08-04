import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// このユーティリティコードは、Riverpod 公式サイトからのコピーです。
//
// Riverpod - providerのテスト
// https://riverpod.dev/ja/docs/essentials/testing

/// [ProviderContainer]を作成し、テスト終了時に自動破棄するテストユーティリティです。
ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const <Override>[],
  List<ProviderObserver>? observers,
}) {
  // ProviderContainerを作成し、オプションでパラメータを指定します。
  final ProviderContainer container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );

  // テスト終了時、containerを破棄します。
  addTearDown(container.dispose);

  return container;
}
