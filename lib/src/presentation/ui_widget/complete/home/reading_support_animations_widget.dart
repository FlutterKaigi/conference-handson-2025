import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../../model/view_model_packages.dart';

class ReadingSupportAnimationsWidget
    extends ConsumerStagedWidget<SupportAnimationTypeEnum, Object> {
  /// コンストラクタ
  ///
  /// - [provider] : 引数の Riverpod ref を使って状態値を取得する関数。
  ///
  /// - [builders] : （オプション）[buildList]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッド一覧を返す関数。
  ///
  /// - [selectBuilder] : （オプション）[selectBuild]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッドを返す関数。
  const ReadingSupportAnimationsWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  /// [ReadingSupportAnimationsWidget] では、ウイジェット内部状態を使いません。
  Object? createWidgetState() => null;

  @override
  /// [provider] が返す状態値の
  /// [SupportAnimationTypeEnum] に対応した build関数を返します。
  ConsumerStagedBuild<SupportAnimationTypeEnum, Object> selectBuild(
    List<ConsumerStagedBuild<SupportAnimationTypeEnum, Object>> builders,
    SupportAnimationTypeEnum value,
  ) {
    return builders[value.index];
  }

  @override
  /// [SupportAnimationTypeEnum.none] に対応した、デフォルトの build関数
  Widget build(
    BuildContext context,
    WidgetRef ref,
    SupportAnimationTypeEnum value,
    Object? state,
  ) {
    return const Offstage();
  }

  @override
  /// [SupportAnimationTypeEnum.cheer] に対応した、デフォルトの build関数
  Widget build2(
    BuildContext context,
    WidgetRef ref,
    SupportAnimationTypeEnum value,
    Object? state,
  ) {
    return _buildHelper(
      context: context,
      animationText: '頑張って！応援してるよ！🎉',
      animationColor: Colors.green,
    );
  }

  @override
  /// [SupportAnimationTypeEnum.scolding] に対応した、デフォルトの build関数
  Widget build3(
    BuildContext context,
    WidgetRef ref,
    SupportAnimationTypeEnum value,
    Object? state,
  ) {
    return _buildHelper(
      context: context,
      animationText: 'もっと集中して！喝！🔥',
      animationColor: Colors.orange,
    );
  }

  Widget _buildHelper({
    required BuildContext context,
    required String animationText,
    required Color animationColor,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: animationColor, // アニメーションの背景として一時的に色付け
        child: Text(
          animationText,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
