import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            // 30秒後にイベントを発行してフラグを OFF にします。
            Timer(const Duration(seconds: 10), () {
              // FIXME アニメーション種類を増やし、表示パターンを増やすこと。
              _updateAnimationType(animationType: AnimationTypeEnum.cheer);
              updateState(value: !value);
            });
          }
          return value;
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
            // 30秒後にイベントを発行してフラグを OFF にします。
            Timer(const Duration(seconds: 10), () {
              // FIXME アニメーション種類を増やし、表示パターンを増やすこと。
              _updateAnimationType(animationType: AnimationTypeEnum.scolding);
              updateState(value: !value);
            });
          }
          return value;
        },
  );
}
