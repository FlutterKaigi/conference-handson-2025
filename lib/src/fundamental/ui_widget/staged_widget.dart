import 'package:flutter/widgets.dart';

/// 内部状態とライフサイクルのロジックを管理する StatefulWidget です。
abstract class StagedWidget<T> extends StatefulWidget
    with WidgetsBindingObserver {
  /// コンストラクタ
  const StagedWidget({super.key, bool isWidgetsBindingObserve = false})
    : _isWidgetsBindingObserve = isWidgetsBindingObserve;

  /// （オプション）[WidgetsBindingObserver]監視を指定するフラグ
  ///
  /// _コンストラクタ・パラメータの `isWidgetsBindingObserve`を引き継ぎます。_
  ///
  /// _デフォルト値は、false です。_
  final bool _isWidgetsBindingObserve;

  /// Widget 内部の状態オブジェクトを生成します。
  T? createWidgetState();

  /// Widget 生成時に、一度だけ実行されます。
  ///
  /// - [state] : Widget 内部の状態
  void initState(T? state) {}

  /// 外部から取得したオブジェクト(注)の更新による、`build`前に実行されます。
  ///
  /// - [state] : Widget 内部の状態
  ///
  /// _(注)[InheritedWidget]で取得したオブジェクト。_
  void didChangeDependencies(T? state) {}

  /// 親ウィジェットの再構築による、`build`前に実行されます。
  ///
  /// - [now] : 現在の Widget
  /// - [old] : 以前の Widget
  /// - [state] : Widget 内部の状態
  void didUpdateWidget(StagedWidget<T> now, StagedWidget<T> old, T? state) {}

  /// `build`後に実行されます。
  ///
  /// - [state] : Widget 内部の状態
  void setupState(T? state) {}

  /// Widget 破棄時に、一度だけ実行されます。
  ///
  /// - [state] : Widget 内部の状態
  ///
  /// _アプリ強制終了には対応できないことに注意。_
  void disposeState(T? state) {}

  /// 表示更新のため、何度も実行されます。
  ///
  /// - [state] : Widget 内部の状態
  Widget build(BuildContext context, T? state);

  /// アプリがフォアグラウンドに戻った時に実行されます。
  void onResumed() {}

  /// アプリが非アクティブ状態になった時に実行されます。
  void onInactive() {}

  /// アプリがバックグラウンドに移行した時に実行されます。
  void onPaused() {}

  /// アプリの全てのビューが非表示になった時に実行されます。
  void onHidden() {}

  /// アプリがフレームワークからデタッチされた時に実行されます。
  ///
  /// _アプリ強制終了には対応できないことに注意。_
  void onDetached() {}

  @override
  State<StagedWidget<T>> createState() {
    return _StagedWidgetState<T>();
  }
}

class _StagedWidgetState<T> extends State<StagedWidget<T>>
    with WidgetsBindingObserver {
  _StagedWidgetState();

  // ignore: diagnostic_describe_all_properties
  T? state;

  @override
  void initState() {
    super.initState();
    if (widget._isWidgetsBindingObserve) {
      WidgetsBinding.instance.addObserver(this);
    }
    state = widget.createWidgetState();
    widget.initState(state);
  }

  @override
  void didChangeDependencies() {
    widget.didChangeDependencies(state);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(StagedWidget<T> old) {
    widget.didUpdateWidget(widget, old, state);
    super.didUpdateWidget(old);
  }

  void onAfterBuild() {
    widget.setupState(state);
  }

  @override
  void dispose() {
    widget.disposeState(state);
    state = null;
    if (widget._isWidgetsBindingObserve) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget buildWidget = widget.build(context, state);
    onAfterBuild();
    return buildWidget;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // アプリケーションのライフサイクル状態が変化した際に呼び出されます。
    switch (state) {
      case AppLifecycleState.resumed:
        // アプリがフォアグラウンドに戻った時
        onResumed();
      case AppLifecycleState.inactive:
        // アプリが非アクティブ状態になった時 (一時的な中断、例: 電話着信)
        onInactive();
      case AppLifecycleState.paused:
        // アプリがバックグラウンドに移行した時
        onPaused();
      case AppLifecycleState.hidden:
        // アプリの全てのビューが非表示になった時
        onHidden();
      case AppLifecycleState.detached:
        // アプリがフレームワークからデタッチされた時 (終了間近)
        onDetached();
    }
  }

  /// アプリがフォアグラウンドに戻った時
  void onResumed() {
    widget.onResumed();
  }

  /// アプリが非アクティブ状態になった時
  void onInactive() {
    widget.onInactive();
  }

  /// アプリがバックグラウンドに移行した時
  void onPaused() {
    widget.onPaused();
  }

  /// アプリの全てのビューが非表示になった時
  void onHidden() {
    widget.onHidden();
  }

  /// アプリがフレームワークからデタッチされた時
  ///
  /// _アプリ強制終了には対応できないことに注意。_
  void onDetached() {
    widget.onDetached();
    dispose();
  }
}

/// StagedWidget 内部状態クラス
///
/// Widget 内部の可変状態を保持させるクラスです。
///
/// _const コンストラクタを必要としないことに御留意ください。_
class StagedWidgetState {
  StagedWidgetState();

  // setState()が機能するようにするには、
  // ウィジェットにグローバルキーを設定するなどの対応が必要になるため実装保留中
  void setState(VoidCallback fn) {}
}
