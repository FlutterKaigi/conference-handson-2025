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
    widget.viewModel._updateState = () {
      setState(() {});
    };
  }

  @override
  void dispose() {
    widget.viewModel._updateState = null;
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
  ToggleSwitchViewModel({
    required this.initValue,
    required UpdateToggleSwitchState updateHandler,
  }) : _updateHandler = updateHandler;

  final UpdateToggleSwitchState _updateHandler;
  void Function()? _updateState;

  /// 初期値
  final bool initValue;

  bool _isEnable = false;

  /// トグルスイッチ値
  bool get isEnable => _isEnable;

  /// トグルスイッチ・イベントハンドラ
  ///
  ///  _スイッチ切り替え時に実行させたい関数を定義して下さい。_
  // ignore: avoid_positional_boolean_parameters,
  bool _update(bool value) {
    _isEnable = _updateHandler(value: value, updateState: updateState);
    _updateState?.call();
    return _isEnable;
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
/// - 返却値 : 表示させたいトグルスイッチの状態値を返してください。
typedef UpdateToggleSwitchState =
    bool Function({
      required bool value,
      required void Function({required bool value}) updateState,
    });
