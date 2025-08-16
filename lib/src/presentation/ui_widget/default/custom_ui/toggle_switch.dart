import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// [Switch] ウイジェットのラッパークラスです。
class ToggleSwitch extends StatefulWidget {
  /// コンストラクタ
  /// - [viewModel] : スイッチ切替時に実行させる任意処理を定義できます。
  const ToggleSwitch({required this.viewModel, super.key});

  final ToggleSwitchViewModel viewModel;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ToggleSwitchViewModel>('viewModel', viewModel),
    );
  }

  @override
  State<ToggleSwitch> createState() {
    return _ToggleSwitchState();
  }
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  @override
  void initState() {
    super.initState();
    widget.viewModel._bindUpdateState(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.viewModel._unbindUpdateState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: widget.viewModel.isEnable,
      onChanged: (bool value) {
        widget.viewModel._update(value);
      },
    );
  }
}

class ToggleSwitchViewModel {
  /// コンストラクタ
  /// - [initValue] : トグルスイッチ初期値
  /// - [updateHandler] : トグルスイッチ・イベントハンドラ関数
  /// - [onBinde] : （オプション）トグルスイッチ・バインド通知関数
  /// - [onUnBinde] : （オプション）トグルスイッチ・アンバインド通知関数
  ToggleSwitchViewModel({
    required bool initValue,
    required UpdateToggleSwitchState updateHandler,
    void Function()? onBinde,
    void Function()? onUnBinde,
  }) : _isEnable = initValue,
       _updateHandler = updateHandler,
       _onBinde = onBinde,
       _onUnBinde = onUnBinde;

  final UpdateToggleSwitchState _updateHandler;

  /// トグルスイッチ状態値の更新関数バインド
  ///
  /// _このメソッドは、_ToggleSwitchState からコールされます。_
  void _bindUpdateState(void Function() updateState) {
    _updateState = updateState;
    _onBinde?.call();
  }

  /// トグルスイッチ状態値の更新関数アンバインド
  ///
  /// _このメソッドは、_ToggleSwitchState からコールされます。_
  void _unbindUpdateState() {
    _updateState = null;
    _onUnBinde?.call();
  }

  final void Function()? _onBinde;

  final void Function()? _onUnBinde;

  /// トグルスイッチ表示・アップデート関数
  ///
  /// - _ToggleSwitchState から、
  /// [_bindUpdateState] がコールされることににより
  /// setState 関数コールがバインドされます。
  ///
  /// - _ToggleSwitchState から、
  /// [_unbindUpdateState] がコールされることにより
  /// setState 関数コールがアンバインドされます。
  ///
  /// **【注意事項】**<br/>
  /// _「関心の分離」原則では、View は ViewModel をバインドし、
  /// ViewModel よりも長命であり、ViewModel にアクセスや操作ができるとします。_
  ///
  /// _ですが「関心の分離」原則では、 ViewModel は、
  /// View の存在を関知しない（アクセスや操作ができない）を原則とします。_
  ///
  /// _**この TogleSwitch カスタム UI 関数は、内部処理を見せるための学習用です。**_
  ///
  /// _ViewModel が View の setState 関数を保持することは、アクセスの逸脱であり、
  /// コールバック（制御の反転）の利用は、操作の逸脱をしていることに注意下さい。_
  ///
  void Function()? _updateState;

  bool _isEnable;

  /// トグルスイッチ値
  bool get isEnable => _isEnable;

  /// ViewModel と Widget がバインド中か否かのフラグ
  bool get isBinding => _updateState != null;

  /// トグルスイッチ・イベントハンドラ
  ///
  ///  _スイッチ切り替え時に実行させたい関数を定義して下さい。_
  // ignore: avoid_positional_boolean_parameters,
  bool _update(bool value) {
    _updateHandler(value: value, updateState: updateState);
    _updateState?.call();
    return _isEnable = value;
  }

  /// トグルスイッチ状態値・アップデート
  void updateState({required bool value}) {
    _isEnable = value;
    _updateState?.call();
  }
}

/// トグルスイッチ・イベントハンドラ関数型
///
/// - [value] : カレント・トグルスイッチ状態値
/// - [updateState] : トグルスイッチ状態値・アップデート関数<br/>
///   トグルスイッチ状態値の表示を変えたいときに利用して下さい。
typedef UpdateToggleSwitchState =
    void Function({
      required bool value,
      required void Function({required bool value}) updateState,
    });
