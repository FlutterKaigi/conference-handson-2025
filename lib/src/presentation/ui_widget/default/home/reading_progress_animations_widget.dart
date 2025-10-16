import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../../model/view_model_packages.dart';

/// 読書進捗率達成アニメーション Widget
class ReadingProgressAnimationsWidget
    extends ConsumerStagedWidget<ProgressAnimationTypeEnum, Object> {
  /// コンストラクタ
  ///
  /// - [provider] : 引数の Riverpod ref を使って状態値を取得する関数。
  ///
  /// - [builders] : （オプション）[buildList]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッド一覧を返す関数。
  ///
  /// - [selectBuilder] : （オプション）[selectBuild]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッドを返す関数。
  const ReadingProgressAnimationsWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  /// [ReadingProgressAnimationsWidget] では、ウイジェット内部状態を使いません。
  Object? createWidgetState() => null;

  @override
  /// [provider] が返す状態値の
  /// [ProgressAnimationTypeEnum] に対応した build関数を返します。
  ConsumerStagedBuild<ProgressAnimationTypeEnum, Object> selectBuild(
    List<ConsumerStagedBuild<ProgressAnimationTypeEnum, Object>> builders,
    ProgressAnimationTypeEnum value,
  ) {
    return builders[value.index];
  }

  @override
  /// [ProgressAnimationTypeEnum.none] に対応した、デフォルトの build関数
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ProgressAnimationTypeEnum value,
    Object? state,
  ) {
    return const Offstage();
  }

  @override
  /// [ProgressAnimationTypeEnum.progressRate10] に対応した、デフォルトの build関数
  Widget build2(
    BuildContext context,
    WidgetRef ref,
    ProgressAnimationTypeEnum value,
    Object? state,
  ) {
    final String title =
        ref.read(readingBooksProvider.notifier).editedReadingBook?.name ?? '';
    return _buildHelper(
      context: context,
      animationText: '$title 読了率 10%を達成しました！ 🔥',
      animationColor: Colors.blue,
    );
  }

  @override
  /// [ProgressAnimationTypeEnum.progressRate50] に対応した、デフォルトの build関数
  Widget build3(
    BuildContext context,
    WidgetRef ref,
    ProgressAnimationTypeEnum value,
    Object? state,
  ) {
    final String title =
        ref.read(readingBooksProvider.notifier).editedReadingBook?.name ?? '';
    return _buildHelper(
      context: context,
      animationText: '$title 読了率 50%を達成しました！ 🔥',
      animationColor: Colors.blue,
    );
  }

  @override
  /// [ProgressAnimationTypeEnum.progressRate80] に対応した、デフォルトの build関数
  Widget build4(
    BuildContext context,
    WidgetRef ref,
    ProgressAnimationTypeEnum value,
    Object? state,
  ) {
    final String title =
        ref.read(readingBooksProvider.notifier).editedReadingBook?.name ?? '';
    return _buildHelper(
      context: context,
      animationText: '$title 読了率 80%を達成しました！ 🔥',
      animationColor: Colors.blue,
    );
  }

  @override
  /// [ProgressAnimationTypeEnum.progressRate100] に対応した、デフォルトの build関数
  Widget build5(
    BuildContext context,
    WidgetRef ref,
    ProgressAnimationTypeEnum value,
    Object? state,
  ) {
    final String title =
        ref.read(readingBooksProvider.notifier).editedReadingBook?.name ?? '';
    return _buildHelper(
      context: context,
      animationText: '$title 読了おめでとうございます！ 🔥',
      animationColor: Colors.blue,
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
