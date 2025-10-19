# ConsumerStagedWidget カスタム・ウィジェット実装ガイド

## 概要

**ConsumerStagedWidget<R,T>** カスタム・ウィジェットは、  
**①状況に応じた UI表示｜表示更新**、**②状況に応じた UI表示の切り替え**、**③内部状態の定義**、**④ライフサイクルのハンドリング**を  
*State派生クラスを定義することなく、Widget クラス内のみで行える*ようにした [StatefulWidget](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html) ラッパーです。

* **①状況に応じた UI表示｜表示更新**  
  * Riverpodの`WidgetRef.watch(プロバイダ)`で UI表示が依存する状態値を提供する`プロバイダ`を監視させて、  
  状態値の変更によりリビルドが行われるようにします。

* **②状況に応じた UI表示の切り替え**  
  * ビルドおよびリビルド時の UI表示内容は、`build`メソッドをオーバライドして、  
    コンストラクタ・パラメータの`provider関数`が返す **状態値&lt;R&gt;** が反映されるようにします。  

  * オプション：`provider関数`が表す **状態値 ⇒ 状況種別**に応じて、**いくつかのパターンの`build`メソッド**を利用したい場合は、  
    状況ごとのパターンに合わせて **ビルドメソッド（`build, build2 〜 build20`）のオーバーライド**を行い、  
    状況種別とビルドメソッドの index(`0〜19`)が対応するように、**ビルダー選択メソッド（`selectBuilder`）をオーバーライド**します。  
    *メソッド・オーバーライドでなく、**コンストラクタ・オプションパラメータで `buildersリスト`や `selectBuilder関数`を定義**することもできます。*  

  * 活用例：非同期データの取得のため、最初はローディング表示、データ取得後にアイコン表示、  
    もしくはデータ取得エラー表示に切り替えたい場合、[FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)を使わなくても、  
    `provider関数`で enum [loading, complete, error] を返し、  
    **ビルドメソッド**で ローディング｜アイコン｜エラー用にビルドメソッドをオーバーライドして、  
    **ビルダー選択メソッド**で enum index の返却をオーバーライドさせることで対応することができます。

* **③内部状態の定義**  
  * **ウィジェットの内部状態型 T を ウィジェット ジェネリクス&lt;T&gt;に指定して、  
    ウィジェット内部状態オブジェクトの生成メソッド（`createWidgetStateメソッド`）** をオーバーライドすれば、  
    ウィジェット内（State派生クラスではない）の `initStateメソッド`と`disposeStaeメソッド`や`buildメソッド`に、  
    `内部状態オブジェクト<T> state パラメータ`が提供されるだけでなく、**const ウィジェット生成**も可能になります。
 
  * 活用例：ウィジェット内にスクロールエリアがあり、独自の`ScrollController`を使いたいのであれば、  
    ジェネリクス&lt;T&gt;に ScrollController を指定して、`createWidgetState() => ScrollController();`をオーバーライドすれば、  
    **const ウィジェット生成が可能**なだけでなく、`buildメソッド・パラメータ state`に ScrollControllerオブジェクトも提供されます。

* **④ライフサイクルのハンドリング**  
  * オプション：コンストラクタ・オプションパラメータの `isWidgetsBindingObserve`に`true`を指定すると、  
     [AppLifecycleState](https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html)に対応する ライフサイクル・ハンドラメソッド（`onResume 〜 onHidden`）へのコールバックが発生します。

  * 活用例：アプリがバックグラウンドの間はカウントダウンタイマーを停止させたいのであれば、  
     `onPausedハンドラメソッド`でタイマー停止、`onResumeハンドラメソッド`でタイマー再開を行う処理をオーバーライドします。

```
fundamental/
├── ui_widget/
    ├── consumer_staged_widget.dart   # カスタム・ウイジェット（構造定義）
    └── staged_widget.dart            # カスタム・ウイジェット（構造定義）
```


## 実装のポイント

### 1. 依存パッケージ

状態管理 ⇒ UI 状態値の表示更新反映のため、[Riverpod](https://pub.dev/packages/flutter_riverpod)
の利用を想定しています。


### 2. ConsumerStagedWidget 派生ウィジェットの実装例

#### default/home パッケージにおける派生ウィジェット

```
presentation/
├── app/
    └── screnn/
        └── home/
            └── home_page.dart  # 派生ウイジェットの利用定義元
```

```
presentation/
├── ui_widget/
    └── default/
        └── home/
            ├── currently_tasks_widget.dart     # 読書中書籍一覧表示用 派生ウイジェット（構造定義）
            └── support_animations_widget.dart  # 応援アニメーション表示用 派生ウイジェット（構造定義）
```
