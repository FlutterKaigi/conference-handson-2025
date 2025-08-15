import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<SupportAnimationsViewModel, AnimationTypeEnum>
supportAnimationsProvider =
    NotifierProvider<SupportAnimationsViewModel, AnimationTypeEnum>(
      // TODO 後日、アプリモデルから正式な初期データを取得できるようにすること。
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
    // riverpod が管理する state 変数内容 ⇒ VO の初期値を生成して返却する。
    // ここでは、VO ⇒ ValueObject としてアニメーション種別の初期値を設定する。
    return animationType;
  }

  /// アニメーション種別更新
  void updateAnimationType({required AnimationTypeEnum animationType}) {
    _animationType = animationType;
    _updateState();

    Timer(const Duration(milliseconds: 3000), () {
      _animationType = AnimationTypeEnum.none;
      _updateState();
    });
  }

  /// riverpod の state 更新
  void _updateState() {
    state = animationType;
  }
}
