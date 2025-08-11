import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [ConsumerStagedWidget] : build 関数型
///
/// [R] : Provider が返却する [value] の返却値型
///
/// [T] : Widget 内部の状態型
typedef ConsumerStagedBuild<R, T> =
    Widget Function(BuildContext context, WidgetRef ref, R value, T? state);

/// [ConsumerStagedWidget] : build 選択関数型
///
/// 状況に応じた UI表示内容を切り替えるため、
/// build 関数一覧([builders]) から、状態値([value])に対応する
/// ビルダー([ConsumerStagedBuild])を選択する関数型を表します。
///
/// - [value] : Provider が返却した状態値
///
/// - [builders] : ビルド種別ごとのビルド関数一覧
///
/// [R] : Provider が返却する [value] の返却値型
///
/// [T] : Widget 内部の状態型
typedef SelectBuilder<R, T> =
    ConsumerStagedBuild<R, T> Function(
      List<ConsumerStagedBuild<R, T>> builders,
      R value,
    );

/// [ConsumerStagedWidget] : build 一覧取得関数型
///
/// 状況に応じた UI表示内容を切り替えるため、
/// 状態値([value])に対応するビルド関数一覧
/// (List<[ConsumerStagedBuild])を返す関数型を表します。
///
/// - [value] : Provider が返却した状態値
///
/// - [state] : Widget 内部の状態オブジェクト
///
/// [R] : Provider が返却する [value] の返却値型
///
/// [T] : Widget 内部の [state] の状態型
typedef ConsumerStagedBuilders<R, T> =
    List<ConsumerStagedBuild<R, T>> Function(
      BuildContext context,
      WidgetRef ref,
      R value,
      T? state,
    );

/// 状況に応じた UI表示内容を切り替えられるようにするウィジェットです。
///
/// _内部状態とライフサイクルのロジックも管理します。_
///
/// [R] : [provider] が返す状態値型
///
/// [T] : Widget 内部の状態型
abstract class ConsumerStagedWidget<R, T> extends StatefulWidget {
  /// コンストラクタ
  ///
  /// [provider]パラメータで取得した**状態値**に対応した UI表示に切り替えるウイジェットを生成します。
  ///
  /// _内部定義された build関数一覧([buildList])と build選択関数([selectBuild])を利用します。_
  ///
  const ConsumerStagedWidget({
    required this.provider,
    this.builders,
    this.selectBuilder,
    bool isWidgetsBindingObserve = false,
    super.key,
  }) : _isWidgetsBindingObserve = isWidgetsBindingObserve;

  /// 引数の Riverpod ref を使って状態値を取得する関数
  final R Function(WidgetRef ref) provider;

  /// （オプション）[provider]が返した状態値に対応するビルド・メソッド一覧を返す関数
  ///
  /// コンストラクタ・パラメータで `builders`が指定されていた場合、[buildList] を上書きします。
  final ConsumerStagedBuilders<R, T>? builders;

  /// （オプション）[provider]が返した状態値に対応するビルド・メソッドを返す関数
  ///
  /// コンストラクタ・パラメータで `selectBuilder`が指定されていた場合、[selectBuild] を上書きします。
  final SelectBuilder<R, T>? selectBuilder;

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
  void didUpdateWidget(
    ConsumerStagedWidget<R, T> now,
    ConsumerStagedWidget<R, T> old,
    T? state,
  ) {}

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

  /// [provider]が返した状態値に対応する ビルド・メソッドを返す関数
  ///
  /// - [value] : [provider]が返した状態値
  ///
  /// - [builders] : ビルド種別ごとのビルド・メソッド一覧<br/>
  /// _index は、0〜19 までしか対応していません。_<br/>
  /// _0〜19 ⇒ [build],[build2]〜[build20] メソッド_
  ConsumerStagedBuild<R, T> selectBuild(
    List<ConsumerStagedBuild<R, T>> builders,
    R value,
  ) {
    // （デフォルト）ビルド・メソッドのみ
    return builders[0];
  }

  /// （デフォルト）ビルド・メソッド
  ///
  /// [selectBuild] が返しうる、ビルド種別 index 1番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build(BuildContext context, WidgetRef ref, R value, T? state);

  /// [selectBuild] が返しうる、ビルド種別 index 2番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build2(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 3番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build3(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 4番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build4(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 5番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build5(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 6番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build6(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 7番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build7(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 8番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build8(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 9番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build9(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 10番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build10(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 11番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build11(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 12番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build12(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 13番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build13(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 14番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build14(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 15番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build15(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 16番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build16(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 17番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build17(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 18番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build18(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 19番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build19(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 20番目に対応する build メソッド
  ///
  /// - [value] : [provider] により提供された状態値オブジェクト(VO)
  /// - [state] : Widget 内部の状態
  Widget build20(BuildContext context, WidgetRef ref, R value, T? state) =>
      const Offstage();

  /// [selectBuild] が返しうる、ビルド種別 index 並びに対応する build関数一覧
  List<ConsumerStagedBuild<R, T>> get buildList => <ConsumerStagedBuild<R, T>>[
    build,
    build2,
    build3,
    build4,
    build5,
    build6,
    build7,
    build8,
    build9,
    build10,
    build11,
    build12,
    build13,
    build14,
    build15,
    build16,
    build17,
    build18,
    build19,
    build20,
  ];

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
  State<ConsumerStagedWidget<R, T>> createState() {
    return _ConsumerStagedWidgetState<R, T>();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<R Function(WidgetRef ref)>.has('provider', provider),
    );
    properties.add(
      ObjectFlagProperty<
        ConsumerStagedBuild<R, T> Function(
          List<ConsumerStagedBuild<R, T>> builders,
          R value,
        )?
      >.has('selectBuild', selectBuild),
    );
    properties.add(
      IterableProperty<ConsumerStagedBuild<R, T>>('buildList', buildList),
    );
    properties.add(
      ObjectFlagProperty<SelectBuilder<R, T>?>.has(
        'selectBuilder',
        selectBuilder,
      ),
    );
    properties.add(
      ObjectFlagProperty<ConsumerStagedBuilders<R, T>?>.has(
        'builders',
        builders,
      ),
    );
  }
}

class _ConsumerStagedWidgetState<R, T> extends State<ConsumerStagedWidget<R, T>>
    with WidgetsBindingObserver {
  _ConsumerStagedWidgetState();

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
  void didUpdateWidget(ConsumerStagedWidget<R, T> old) {
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
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final R value = widget.provider(ref);
        final List<ConsumerStagedBuild<R, T>> builders =
            widget.builders?.call(context, ref, value, state) ??
            widget.buildList;
        final ConsumerStagedBuild<R, T> build =
            widget.selectBuilder?.call(builders, value) ??
            widget.selectBuild(builders, value);

        final Widget buildWidget = build(context, ref, value, state);
        onAfterBuild();
        return buildWidget;
      },
    );
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
