import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../model/my_counter_value_object.dart';

/// [provider] が返す状態値の [CountValueObject.isResetting] フラグで、
/// カウント表現を切り替えるウイジェットです。
class ConsumerCounterText
    extends ConsumerStagedWidget<CountValueObject, Object> {
  /// コンストラクタ
  ///
  /// - [provider] : 引数の Riverpod ref を使って状態値を取得する関数。
  ///
  /// - [builders] : （オプション）[buildList]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッド一覧を返す関数。
  ///
  /// - [selectBuilder] : （オプション）[selectBuild]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッドを返す関数。
  const ConsumerCounterText({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  Object? createWidgetState() => null;

  @override
  /// [provider] が返す状態値の
  /// [CountValueObject.isResetting] フラグに対応した build関数を返します。
  ConsumerStagedBuild<CountValueObject, Object> selectBuild(
    List<ConsumerStagedBuild<CountValueObject, Object>> builders,
    CountValueObject value,
  ) {
    return builders[value.isResetting ? 1 : 0];
  }

  @override
  /// [CountValueObject.isResetting] == false の場合のカウント表示
  Widget build(
    BuildContext context,
    WidgetRef ref,
    CountValueObject value,
    Object? state,
  ) {
    return Text(
      '${value.count}',
      style: Theme.of(context).textTheme.headlineMedium,
      key: super.key, // テスト時のチェック用に ConsumerCounterText のキーを Text にも与えている。
    );
  }

  @override
  /// [CountValueObject.isResetting] == true の場合のカウント表示
  Widget build2(
    BuildContext context,
    WidgetRef ref,
    CountValueObject value,
    Object? state,
  ) {
    return Text(
      '<<< ${value.count} >>>',
      style: Theme.of(context).textTheme.headlineMedium,
      key: super.key, // テスト時のチェック用に ConsumerCounterText のキーを Text にも与えている。
    );
  }
}
