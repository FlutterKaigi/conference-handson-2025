import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/reading_book_value_object.dart';

final NotifierProvider<
  ReadingProgressAnimationsViewModel,
  ProgressAnimationTypeEnum
>
readingProgressAnimationsProvider =
    NotifierProvider<
      ReadingProgressAnimationsViewModel,
      ProgressAnimationTypeEnum
    >(() => ReadingProgressAnimationsViewModel());

/// アニメーション種別
enum ProgressAnimationTypeEnum {
  none, // 何も表示しない
  progressRate10, // 読了率 10%
  progressRate50, // 読了率 50%
  progressRate80, // 読了率 80%
  progressRate100, // 読了率 100%（読了）
}

/// 読書進捗率達成アニメーション ViewModel
class ReadingProgressAnimationsViewModel
    extends Notifier<ProgressAnimationTypeEnum> {
  ReadingProgressAnimationsViewModel()
    : _animationType = ProgressAnimationTypeEnum.none;

  ProgressAnimationTypeEnum _animationType;

  /// アニメーション種別
  // ignore: unnecessary_getters_setters
  ProgressAnimationTypeEnum get animationType => _animationType;

  @override
  ProgressAnimationTypeEnum build() {
    // riverpod が管理する state 変数内容 ⇒ VO の初期値を生成して返却する。
    // ここでは、VO ⇒ ValueObject としてアニメーション種別の初期値を設定する。
    return animationType;
  }

  /// （読書進捗率別）アニメーション種別更新
  ///
  /// 読書進捗率が 100%達成か、10%,50%,80%,100% を跨いでいれば、
  /// アニメーション種別を更新して、進捗率に従ったアニメーションを表示させます。
  ///
  /// - [updatedBook] : 読書進捗率更新済書籍（書籍の総ページ数と現在の読了ページ数を持つ）
  /// - [prevReadingPageNum] : 以前の読了ページ数
  void updateAnimationTypeIfProgressChange({
    required ReadingBookValueObject updatedBook,
    required int prevReadingPageNum,
  }) {
    // 読書進捗更新前後のアニメーション種別を取得
    final ProgressAnimationTypeEnum editedType = _checkProgressRate(
      updatedBook.totalPages,
      updatedBook.readingPageNum,
    );
    final ProgressAnimationTypeEnum prevType = _checkProgressRate(
      updatedBook.totalPages,
      prevReadingPageNum,
    );

    // 進捗率が更新された場合のみ、アニメーション種別を更新します。
    if (prevType.index < editedType.index) {
      updateAnimationType(animationType: editedType);
    }
  }

  /// 読書進捗率チェッカー
  ProgressAnimationTypeEnum _checkProgressRate(
    int totalPages,
    int readingPageNum,
  ) {
    final double rate = readingPageNum / totalPages;
    return switch (rate) {
      < 0.1 => ProgressAnimationTypeEnum.none,
      < 0.5 => ProgressAnimationTypeEnum.progressRate10,
      < 0.8 => ProgressAnimationTypeEnum.progressRate50,
      < 1.0 => ProgressAnimationTypeEnum.progressRate80,
      _ => ProgressAnimationTypeEnum.progressRate100,
    };
  }

  /// アニメーション種別更新
  void updateAnimationType({required ProgressAnimationTypeEnum animationType}) {
    _animationType = animationType;
    _updateState();

    Timer(const Duration(milliseconds: 10000), () {
      _animationType = ProgressAnimationTypeEnum.none;
      _updateState();
    });
  }

  /// riverpod の state 更新
  void _updateState() {
    state = animationType;
  }
}
