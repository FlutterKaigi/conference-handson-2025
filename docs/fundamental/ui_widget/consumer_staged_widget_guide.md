# ConsumerStagedWidget カスタム・ウィジェット解説ガイド

## 概要

**[ConsumerStagedWidget<R,T>](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L53-L478)** は、  
**①状況に応じた UI表示｜表示更新**、**②状況に応じた UI表示の切り替え**、**③内部状態の定義**、**④ライフサイクルのハンドリング**を  
*State派生クラスを定義することなく、Widget クラス内のみで行える*ようにした [StatefulWidget](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html) のラッパーです。

* **①状況に応じた UI表示｜表示更新**  
  * riverpodの [WidgetRef.watch(プロバイダ)](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/WidgetRef/watch.html) で、  
  UI表示が依存する状態値を提供する [プロバイダ](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/NotifierProvider-class.html) を監視させて、  
  状態値の変更によりウィジェットのリビルドが行われるようにします。

  * また、その`プロバイダ・オブジェクト`を **[コンストラクタ・パラメータ注入](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L61-L86)** することで、  
    `ビルドおよびリビルド時に、ウィジェット内での最新の状態値の取得と UI表示への反映`ができるようにします。

* **②状況に応じた UI表示の切り替え**  
  * デフォルト：ビルドおよびリビルド時の UI表示内容は、オーバーライドされた [build](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L148-L154) メソッドにより、  
    コンストラクタ・パラメータの`provider関数`が返す **状態値&lt;R&gt;** の反映を行います。  

  * オプション：`provider関数`が表す **状態値 ⇒ 状況種別**に応じて、**いくつかのパターンの`build`メソッド**を切り替えたい場合は、  
    状況ごとのパターンに合わせて **ビルドメソッド（[build, build2 〜 build20](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L148-L287)）のオーバーライド**を行い、  
    状況種別とビルドメソッドの index `0〜19` が対応するように、**ビルダー選択メソッド（[selectBuilder](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L133-L146)）をオーバーライド**します。  
    　  
    *メソッド・オーバーライドでなく、  
    **コンストラクタ・オプションパラメータの [buildersリスト](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L78-L81) や
    [selectBuilder関数](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L83-L86) に定義**することもできます。*  

  * 活用例：非同期データの取得のため、最初はローディング表示、データ取得後にアイコン表示、  
    もしくはデータ取得エラー表示に切り替えたい場合、[FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)を使わなくても、  
    `provider関数`で `enum [loading, complete, error]` を返し、  
    **ビルドメソッド**で ローディング｜アイコン｜エラー用にビルドメソッドをオーバーライドして、  
    **ビルダー選択メソッド**で `enum index` を返却するようにメソッド・オーバーライドすれば対応できます。

* **③内部状態の定義**  
  * **ウィジェットの内部状態型 T を ウィジェット ジェネリクス&lt;T&gt;に指定して、  
    ウィジェット内部状態オブジェクトの生成メソッド（[createWidgetState](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L95-L96)）** をオーバライドしてそれが返るようにすれば、  
    ウィジェット内（State派生クラスではない）の [initStateメソッド](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L98-L101) と
    [disposeStateメソッド](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L103-L108) や
    [buildメソッド](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L148-L154) に、  
    `内部状態オブジェクト<T> state パラメータ`が提供されるだけでなく、**const ウィジェット生成**も可能になります。
 
  * 活用例：ウィジェット内にスクロールエリアがあり、独自の`ScrollController`を使いたいのであれば、  
    ジェネリクス&lt;T&gt;に ScrollController を指定して、`createWidgetState() => ScrollController();`をオーバーライドすれば、  
    **const ウィジェット生成が可能**なだけでなく、`buildメソッド・パラメータ state`に ScrollControllerオブジェクトも提供されます。

* **④ライフサイクルのハンドリング**  
  * オプション：コンストラクタ・オプションパラメータの [isWidgetsBindingObserve](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L71) に`true`を指定すると、  
     [AppLifecycleState](https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html)に対応する
     ライフサイクル・ハンドラメソッド（[onResume 〜 onHidden](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L313-L328)）へのコールバックが発生します。

  * 活用例：アプリがバックグラウンドの間はカウントダウンタイマーを停止させたいのであれば、  
     `onPausedハンドラメソッド`でタイマー停止、`onResumeハンドラメソッド`でタイマー再開を行う処理をオーバーライドします。

```
fundamental/
└── ui_widget/
    ├── consumer_staged_widget.dart    カスタム・ウイジェット（構造定義）
    └── staged_widget.dart             カスタム・ウイジェット（構造定義）
```


## このプロジェクトでの使用例

### 1. 依存パッケージ

状態管理 ⇒ UI 状態値の表示更新反映のため、[flutter_riverpod](https://pub.dev/packages/flutter_riverpod) を利用しています。

- 【参照】flutter_riverpod プラグイン導入 - **[pubspec.yaml](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/pubspec.yaml#L15)**


### 2. ConsumerStagedWidget 派生ウィジェットの実装例

#### default/home 読書進捗率達成表示用 派生ウィジェット

ConsumerStagedWidget 派生ウィジェットの実装例として、  
defaultディレクトリの読書進捗率達成表示用 UIウィジェット（[ReadingProgressAnimationsWidget](../../../lib/src/presentation/ui_widget/default/home/reading_progress_animations_widget.dart)）について解説します。

はじめに、**読書進捗率達成表示用 UIウィジェットの実装先** は、  
`UIウィジェット・クラス定義先` と `UIウィジェットのインスタンスの生成先（Widgetツリーへのバインド先）`に分かれていることに留意ください。

- **[HomePage](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/app/screen/home/home_page.dart#L8-L45)**  
  **読書進捗率達成表示用 - ConsumerStagedWidget 派生ウィジェット生成先**  
```
presentation/
└── app/
    └── screnn/
        └── home/
            └── home_page.dart    派生ウイジェットの利用先（生成定義元）
```

- **[ReadingProgressAnimationsWidget](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/ui_widget/default/home/reading_progress_animations_widget.dart#L7-L138)**  
  **読書進捗率達成表示用 - ConsumerStagedWidget 派生ウィジェット定義先**  
```
presentation/
└── ui_widget/
    └── default/
        └── home/
            └── reading_progress_animations_widget.dart   派生ウイジェット（構造定義元）
```

#### ①状況に応じた UI表示｜表示更新

**[HomePage ページウィジェット](../../../lib/src/app/screen/home/home_page.dart)** の
[buildメソッド](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/app/screen/home/home_page.dart#L12-L44) では、  
`UI表示の状態データを提供する riverpod プロバイダーの監視`と `プロバイダから状態値を取得`するため、  
[ReadingProgressAnimationsWidget](../../../lib/src/presentation/ui_widget/default/home/reading_progress_animations_widget.dart) の
provider コンストラクタ・パラメータ関数に  
`(WidgetRef ref) => ref.watch(readingBooksProvider)` を渡してインスタンス生成を行い、  
`Widgetツリーに 読書進捗率達成表示用 UIウィジェットをバインド`させています。

- _provider コンストラクタ・パラメータ関数の `(WidgetRef ref) => ref.watch(readingBooksProvider)` は、  
  **[アニメーション種別](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/model/default/reading_progress_animations_view_model.dart#L17-L24)の状態データ** と
  **[読書進捗率達成アニメーション ViewModel](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/model/default/reading_progress_animations_view_model.dart#L26-L102)** を管理する  
  **[readingProgressAnimationsProvider](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/model/default/reading_progress_animations_view_model.dart#L7-L15)** に関して、
  `状態データの変化を riverpod に監視させる`、  
  `関数の評価により状態データ（アニメーション種別）を取得する`という、２つの役目を負っています。_

- _これにより`状態更新による 読書進捗率達成表示用 UIウィジェットのリビルド`と、  
  `パラメータ関数評価による 最新状態データ（アニメーション種別）の取得`ができるようになります。_

```dart
      body: Stack(
        children: <Widget>[
          // 下層: 読書中書籍一覧
          CurrentlyTasksWidget(
            provider: (WidgetRef ref) => ref.watch(readingBooksProvider),
          ),
          // 中層: 読書応援・アニメーション表示
          ReadingSupportAnimationsWidget(
            provider: (WidgetRef ref) =>
                ref.watch(readingSupportAnimationsProvider),
          ),
          // 上層: 読書進捗達成・アニメーション表示
          ReadingProgressAnimationsWidget(
            provider: (WidgetRef ref) =>
                ref.watch(readingProgressAnimationsProvider),
          ),
        ],
      ),
```

```dart
/// アニメーション種別
enum ProgressAnimationTypeEnum {
  none, // 何も表示しない
  progressRate10, // 読了率 10%
  progressRate50, // 読了率 50%
  progressRate80, // 読了率 80%
  progressRate100, // 読了率 100%（読了）
}
```

#### ②状況に応じた UI表示の切り替え

`読書進捗率達成表示用 UIウィジェット`の
**[ReadingProgressAnimationsWidget](../../../lib/src/presentation/ui_widget/default/home/reading_progress_animations_widget.dart)** は、  
プロバイダから取得した状態値(アニメーション種別 ⇒ none,10%,50%,80%,100%の読了達成率）に従って、UI表示を切り替えます。

このため UIウィジェットは、`アニメーション種別を、暗黙的に派生元の基盤内で provider パラメータ関数から取得`して、  
UIウィジェットの **[build 〜 build5 メソッド](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/ui_widget/default/home/reading_progress_animations_widget.dart#L40-L117)をオーバライド** して、
`アニメーション種別ごとの UI表示構築を定義`して、  
**[selectBuild メソッド](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/ui_widget/default/home/reading_progress_animations_widget.dart#L30-L38)をオーバーライド** して、
`アニメーション種別と buildメソッドを対応させる関数を定義`します。

- _selectBuild メソッドの
  `value パラメータには、provider パラメータ関数から取得されたアニメーション種別`が入り、  
  `builders パラメータに与えられる buildメソッドの index番号リスト`は、派生元の **[buildList](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/ui_widget/consumer_staged_widget.dart#L289-L311)** から取得されます。  
  そしてメソッドボディの `return builders[value.index];` 式により、  
  アニメーション種別の enum index値と、buildメソッドの index値が対応するようにしています。_

- _build 〜 build5 の各メソッドには、  
  アニメーション種別 enum index 番号にに対応する UI表示を構築するコードを定義します。  
  使用していませんが`value パラメータには、provider パラメータ関数から取得されたアニメーション種別`が入ります。  
  また `state パラメータは UIウィジェットの内部状態`ですが、この UIウィジェットでは内部状態を使わないので null が入ります。_


```dart
  @override
  /// [provider] が返す状態値の
  /// [ProgressAnimationTypeEnum] に対応した build関数を返します。
  ConsumerStagedBuild<ProgressAnimationTypeEnum, Object> selectBuild(
    List<ConsumerStagedBuild<ProgressAnimationTypeEnum, Object>> builders,
    ProgressAnimationTypeEnum value,
  ) {
    return builders[value.index];
  }
```

```dart
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

  〜〜 省略 〜〜

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
```


`読書進捗率達成アニメーション ViewModel`の
**[ReadingProgressAnimationsViewModel](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/model/default/reading_progress_animations_view_model.dart#L26-L102)** は、  
読書中書籍情報からカレント読了達成率の算定および、アニメーション種別の取得と更新のビジネスロジックを提供します。

このため ViewModel は、
**[animationType ゲッター](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/model/default/reading_progress_animations_view_model.dart#L32-L36)** で`アニメーション種別を取得`して、  
**[updateAnimationType メソッド](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/model/default/reading_progress_animations_view_model.dart#L87-L101)** で`アニメーション種別を更新`するだけでなく、  
**[updateAnimationTypeIfProgressChange メソッド](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/model/default/reading_progress_animations_view_model.dart#L45-L85)** で、
`読書中書籍情報からカレント読了達成率を算定`して、  
さらに`カレント読了達成率と同期させるためアニメーション種別を更新`します。
