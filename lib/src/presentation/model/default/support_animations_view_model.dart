import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/reading_book_value_object.dart';
import '../../ui_widget/default/custom_ui/toggle_switch.dart';

final NotifierProvider<SupportAnimationsViewModel, AnimationTypeEnum>
supportAnimationsProvider =
    NotifierProvider<SupportAnimationsViewModel, AnimationTypeEnum>(
      () => SupportAnimationsViewModel(),
    );

/// アニメーション種別
enum AnimationTypeEnum {
  none, // 何も表示しない
  cheer, // 応援アニメーション
  scolding, // 叱咤アニメーション
  progressRate10, // 読了率 10%
  progressRate50, // 読了率 50%
  progressRate80, // 読了率 80%
  progressRate100, // 読了率 100%（読了）
}

class SupportAnimationsViewModel extends Notifier<AnimationTypeEnum> {
  SupportAnimationsViewModel() : _animationType = AnimationTypeEnum.none;

  AnimationTypeEnum _animationType;

  /// アニメーション種別
  // ignore: unnecessary_getters_setters
  AnimationTypeEnum get animationType => _animationType;

  @override
  AnimationTypeEnum build() {
    _updateAnimationType = updateAnimationType;

    // riverpod が管理する state 変数内容 ⇒ VO の初期値を生成して返却する。
    // ここでは、VO ⇒ ValueObject としてアニメーション種別の初期値を設定する。
    return animationType;
  }

  /// （読書進捗率別）アニメーション種別更新
  ///
  /// 読書進捗率が 100%達成か、10%,30%,50%,70%,90% を跨いでいれば、
  /// アニメーション種別を更新して、進捗率に従ったアニメーションを表示させます。
  ///
  /// - [updatedBook] : 読書進捗率更新済書籍（書籍の総ページ数と現在の読了ページ数を持つ）
  /// - [prevReadingPageNum] : 以前の読了ページ数
  void updateAnimationTypeIfProgressChange({
    required ReadingBookValueObject updatedBook,
    required int prevReadingPageNum,
  }) {
    // 読書進捗更新前後のアニメーション種別を取得
    final AnimationTypeEnum editedType = _checkProgressRate(
      updatedBook.totalPages,
      updatedBook.readingPageNum,
    );
    final AnimationTypeEnum prevType = _checkProgressRate(
      updatedBook.totalPages,
      prevReadingPageNum,
    );

    // 進捗率が更新された場合のみ、アニメーション種別を更新します。
    if (prevType.index < editedType.index) {
      updateAnimationType(animationType: editedType);
    }
  }

  /// 読書進捗率チェッカー
  AnimationTypeEnum _checkProgressRate(int totalPages, int readingPageNum) {
    final double rate = readingPageNum / totalPages;
    return switch (rate) {
      < 0.1 => AnimationTypeEnum.none,
      < 0.5 => AnimationTypeEnum.progressRate10,
      < 0.8 => AnimationTypeEnum.progressRate50,
      < 1.0 => AnimationTypeEnum.progressRate80,
      _ => AnimationTypeEnum.progressRate100,
    };
  }

  /// アニメーション種別更新
  void updateAnimationType({required AnimationTypeEnum animationType}) {
    _animationType = animationType;
    _updateState();

    Timer(const Duration(milliseconds: 10000), () {
      _animationType = AnimationTypeEnum.none;
      _updateState();
    });
  }

  /// riverpod の state 更新
  void _updateState() {
    state = animationType;
  }

  /// アニメーション種別更新ラッパー （関数定義からアクセス可能にするためのラッパー）
  static late final void Function({required AnimationTypeEnum animationType})
  _updateAnimationType;

  /// デバッグ・読書開始時設定
  ///
  /// _デバッグ読書開始フラグの初期値や_
  /// _デバッグ発行する読書開始時イベントの処理を定義しています。_
  final ToggleSwitchViewModel debugStartReading = ToggleSwitchViewModel(
    initValue: false,
    updateHandler:
        ({
          required bool value,
          required void Function({required bool value}) updateState,
        }) {
          if (value) {
            // 10秒後にイベントを発行してフラグを OFF にします。
            Timer(const Duration(seconds: 10), () {
              _updateAnimationType(animationType: AnimationTypeEnum.cheer);
              updateState(value: !value);
            });
          }
        },
  );

  /// デバッグ・読書終了時設定
  ///
  /// _デバッグ読書終了フラグの初期値や_
  /// _デバッグ発行する読書終了時イベントの処理を定義しています。_
  ToggleSwitchViewModel debugEndReading = ToggleSwitchViewModel(
    initValue: false,
    updateHandler:
        ({
          required bool value,
          required void Function({required bool value}) updateState,
        }) {
          if (value) {
            // 10秒後にイベントを発行してフラグを OFF にします。
            Timer(const Duration(seconds: 10), () {
              _updateAnimationType(animationType: AnimationTypeEnum.scolding);
              updateState(value: !value);
            });
          }
        },
  );
}
