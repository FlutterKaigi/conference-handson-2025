# FlutterKaigi 2025 ハンズオン・ドキュメント

現時点のドキュメントは、作りかけです。
----------

## はじめに
FlutterKaigi 2025 ハンズオンのメインテーマは、 **「魅力のある UIを作る」** です。  
アプリの魅力を上げるため、UI にアニメーションやデコレーションを追加する基礎知識を学んでもらうことになりました。  

そしてこのハンズオンでは、単なる UI Widget カタログにならないよう、アプリ開発を模した体験になるよう、  
単純で飾り気のないベース模擬アプリに、デコレーションやアニメーションを追加していくという、  
**「ベースUIと カスタムUIのコードや見栄えの比較ができる」** ことをサブテーマとしています。

またアプリのコンセプトは、**読書支援** としました。

これらから、アイテムの状態や状態変更に応じたアクションを返してはくれますが、 単純で飾り気のない模擬アプリの  
**ベースUIコード** を残したまま、デコレーションやアニメーションを盛り込んだ **カスタムUIコード** を併設＆切替可能に  
することで、コードやアプリ表現力向上の比較と これらの違いを学んでもらう趣向となっております。  

- _読了ページ更新と進捗グラフ（ベース表現） ⇒ アニメーション＋デコレーション表現_
  <img width="800" alt="読了ページと進捗グラフ" src="./images/hands-on_sample_1.png" />

- 読了ページ更新の進捗達成リアクション表現（ベース表現） ⇒ アニメーション＋デコレーション表現  
  <img width="800" alt="読了ページ進捗達成のリアクション" src="./images/hands-on_sample_2.png" />


----------

## アプリ構想

アプリのコンセプトは、**読書支援** としたことを受け、

コンセプトのシチュエーションに従って `読書支援したい書籍の追加` や `読書中書籍の一覧表示` に、  
`読了ページの更新とそのタイミングでの進捗達成報告` や `読書進捗状況のグラフ表示`、さらにできれば  
アラーム設定など `何らかのタイミングでの激励や一喝` ができる **模擬アプリ** を作ることにしました。

これらを行うには、`管理したい書籍の追加など`を行う **設定画面（SettingsPage）** や、  
`読書中書籍の一覧表示`や`タップした書籍の選択`ができる **ホーム画面（HomePage）** と、  
`選択された書籍の情報を更新`する **書籍編集画面（ReadingBookPage）** に、  
`読了したページの進捗を可視化`する **グラフ表示画面（ReadingBookGraphPage）** を設け、  
`読書進捗率の達成ごとにメッセージをオーバラップ表示`させる、**アニメーション機能** を盛り込むことで、

単なるウィジェット・カタログにならないよう、ハンズオンに参加してくださるみなさんが実際に触ってみられること、  
リアルタイムでカスタム UIが表示され、読了ページの更新に伴ったリアクションや画面遷移ができることを目指します。

さらにこれら、書籍の新規追加や 読書中書籍の一覧表示、および選択された書籍の編集や削除のテストも追加したいものです。

...とはいえ実際に書籍情報を DBに永続化させたり、イベント管理のためにタイマーやバックグラウンドサービスを導入すると、  
コードやロジックが複雑になり、目的である `シンプルなベースUIコードとリッチなカスタムUIコードとの対比` の妨げになりますから、  
**導入するプラグインは、基本的な状態管理や画面遷移に留める** ことなどの制限をいれました。

- 【参照】アプリ要件初期稿 - [ハンズオン・アプリ要件](reference_documents/requirements.md)

----------

## 模擬アプリとしてのハンズオン・プロジェクト

### 全体方針
1. 実装詳細を理解してもらうためコード生成を使わない。  
2. 画面遷移に `go_router`、状態管理に `flutter_riverpod` を使うが、不変状態値には `freezed を使わない愚直実装` を行う。  
   またウィジェット内部状態の簡素化も `hooks_riverpod を使わない実装` で行い、プラグイン依存を基礎機能に限定させる。
3. 読書管理する書籍の新規追加や情報編集と削除の Unit test と Widget test を利用した簡易結合テストを実装する。  
4. 模擬アプリのため、読書中書籍情報の永続化やアラームは利用しない。このため擬似的に挙動を起こすようにする。  

### 基本設計

#### アーキテクチャ
**保守性**、 **拡張性**、 **理解容易性** を向上させる設計方針を満たすよう、  
アプリ全体で `レイヤードアーキテクチャ`を採用し、UIウィジェットには `MVVM アーキテクチャ`を適用します。  

- レイヤードアーキテクチャにより、  
  上位レイヤーは下位レイヤーにのみ依存させ、逆を認めない原則 ⇒  
  `上位レイヤーが、下位レイヤーのオブジェクトを保持する。`  
  `上位レイヤーは、下位レイヤーに公開インターフェース（状態取得 と 状態更新通知）のみを提供する。`により、  
  一方向の依存関係 ⇒ `上位下達の経路フロー`の実現と厳守を行い、設計方針を満足させます。

ビジネスロジックやデータアクセスの本体は、状態データレイヤに、  
UIウィジェットでの状態データの取得や更新依頼は、プレゼンテーションレイヤに実装することで **関心事の分離** を図ります。  

_これにより機能要件の追加や変更における、修正範囲の限定化（最小化）と影響範囲の明確化（依存関係制御）を確保して、  
保守性や拡張性およびコードの見通し（理解性）を向上させます。_

- 関心事のレイヤ構成  
  - **状態データレイヤ** の依存関係  
    - **[アプリケーションモデル](../lib/src/application/model/application_model.dart)** が、状態データの取得や更新通知のインターフェースを提供するドメインモデルを保持し、  
    - **[ドメインモデル](../lib/src/domain/model/reading_books_domain_model.dart)** が、状態データの値の保持や更新および提供を行うステートモデルを保持して、  
    - **[ステートモデル](../lib/src/domain/model/reading_books_state_model.dart)** が、状態データが依存する DB等の機能を提供するインフラストラクチャを保持して、    
    - **値オブジェクト（[ValueObject](https://www.google.com/search?q=ValueObject+ddd)）
      [①](../lib/src/domain/model/reading_book_value_object.dart)[②](../lib/src/domain/model/reading_books_value_object.dart)** が、状態データのカレント値を表す不変データのクラス定義を担い、  
    - **[インフラストラクチャ](../lib/src/infrastructure/package_info.dart)** が、プラグインによるDB等の基盤機能をラップするオブジェクトを保持します。  
      - _模擬アプリでは、データの永続化などを行いません。  
        このためプロジェクトのインフラストラクチャのレイヤは、利用されないので空実装（空ディレクトリ）になっています。  
        これにより読書中書籍一覧が永続化できないので、**ステートモデルの初期化処理では [ダミーデータ](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/domain/model/reading_books_state_model.dart#L51-L69) を設定** しています。_

  - **プレゼンテーションレイヤ** の依存関係  
    _ここでは、UIウィジェットを [読書進捗率達成アニメーション表示](../lib/src/presentation/ui_widget/default/home/currently_tasks_widget.dart) に仮定しています。_  
    - **ページウィジェット** は、  
      [ホームページウィジェット](../lib/src/app/screen/home/home_page.dart) が UIウィジェットを保持するので、
      `状態データ更新とUIウィジェットの表示更新を同期させる`ため、  
      状態データとViewModelを提供する riverpodプロバイダーの監視と、UIウィジェットへのプロバイダーオブジェクトの  
      提供を行います。 
    - **UIウィジェット** は、  
      [読書進捗率達成アニメーション表示](../lib/src/presentation/ui_widget/default/home/currently_tasks_widget.dart) であれば、
      `表示種別に従ったアニメの表示|非表示と書籍名を表示させる`ため、  
      プロバイダーより提供された状態データ（表示種別）の他に、  
      [WidgetRef](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/WidgetRef-class.html) を介して
      [読書中書籍一覧 ViewModel](../lib/src/presentation/model/default/reading_books_view_model.dart) から表示データ値（読書中書籍情報の書籍名）を取得して描画を行います。  
    - **プロバイダー** は、  
      riverpodの [NotifierProvider](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/NotifierProvider-class.html) を表し、  
      [notifierプロパティ](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/NotifierProvider/notifier.html) から
      対応する [ViewModel](../lib/src/presentation/model/default/reading_progress_animations_view_model.dart) を取得して、
      [stateプロパティ](https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/AnyNotifier/state.html) の値を状態データとして返します。
    - **ViewModel** は、  
      [読書進捗率達成 ViewModel](../lib/src/presentation/model/default/reading_progress_animations_view_model.dart) であれば、
      状態データとして 読了率 enum を返し、  
      [読書中書籍一覧 ViewModel](../lib/src/presentation/model/default/reading_books_view_model.dart) であれば、
      状態データとして [ドメインモデル](../lib/src/domain/model/reading_books_domain_model.dart) を介して  
      [ステートモデル](../lib/src/domain/model/reading_books_state_model.dart) から
      [読書中書籍一覧 ValueObject](../lib/src/domain/model/reading_books_value_object.dart) を取得して返します。
    - **ValueObject** は、  
      [読書中書籍一覧 ValueObject](../lib/src/domain/model/reading_books_value_object.dart) であれば、  
      読書中書籍情報の一覧として [読書中書籍 ValueObject](../lib/src/domain/model/reading_books_value_object.dart) の一覧を返します。

#### 自動テスト
**アプリケーションモデル** は、コンストラクタ引数オプションで、  
ステートモデル（状態データ）をラップする`ドメインモデルのオブジェクトを外部から依存注入できる`ようにしているだけでなく、  
そして **ドメインモデル** もコンストラクタ引数オプションで、`任意のステータスモデルのオブジェクトを外部から依存注入できる`うえ、  
さらに **ステートモデル** も、コンストラクタ引数オプションで、`任意のデータ値を外部から依存注入できる`ようにします。  

_これにより **[Unit test](../test/riverpod_reading_books_unit_test.dart)** や 
**[Widget test](../test/riverpod_reading_books_widget_test.dart)** で、  
**任意のデータ値の手動生成とアプリケーションモデルへの依存注入ができる** ようになっています。_

#### コード生成実験
ハンズオンプロジェクトでは、**[Gemini in Android Studio - Agent mode](https://developer.android.com/studio/gemini/agent-mode)** を取り入れ、  
実験的なコード生成を行っています。

- 【参照】プロンプト設計初期稿 - [Agent 指示プロンプト・メモ](reference_documents/prompt_memo.md)

#### ハンズオン・プロジェクト全体構成
```text
lib
└── src
    ├── app                    アプリ・ウィジェット（ページウィジェットのオブジェクトを保持）
    │   └── scren
    │       ├── home           読書中書籍一覧・ページウィジェット　　　（UIウィジェットのオブジェクトを保持）
    │       ├── reading        読書中書籍編集・ページウィジェット　　　（UIウィジェットのオブジェクトを保持）
    │       ├── reading_graph  読書中書籍進捗グラフ・ページウィジェット（UIウィジェットのオブジェクトを保持）
    │       └── settings       設定・ページウィジェット　　　　　　　　（UIウィジェットのオブジェクトを保持）
    ├── application
    │   └── model              アプリ・モデル　（ドメインモデルのオブジェクを保持）
    ├── domain
    │   └── model              ドメイン・モデル（読書中書籍の状態モデルなどを定義）
    ├── fundamental
    │   ├── model              基底基盤モデル　（ValueObjectなどを定義）
    │   └── ui_widget          基底ウィジェット（ConsumerStagedWidgetなどを定義）
    ├── infrastructure
    ├── presentation
    │   ├── model    （各ViewModelオブジェクトは、状態種別と状態値を保持し、riverpod providerに保持されます）
    │   │   ├── default
    │   │   │   ├── reading_books_view_model.dart               （読書中書籍一覧の状態値を定義）
    │   │   │   ├── reading_progress_animation_view_model.dart  （読書中書籍進捗の状態種別と状態値を定義）
    │   │   │   ├── reading_support_animation_view_model.dart   （激励一喝の状態種別と状態値を定義）
    │   │   │   └── view_model_packges.dat    　　　　　　        （defaultディレクトリ用のバレルファイル）
    │   │   └── view_model_packges.dat　　　　　　　　 　　　　　　　（ViewModel全体統括のバレルファイル）
    │   ├── ui_widget（各UIウィジェットは、状態種別や状態値更新と連動するため providerオブジェクトをバインドします）
    │   │   ├── default
    │   │   │   ├── home
    │   │   │   │   ├── currently_tasks_widget.dart              読書中書籍一覧表示のUIウィジェット
    │   │   │   │   ├── reading_progress_animations_widget.dart  読書中書籍進捗表示のUIウィジェット
    │   │   │   │   └── reading_support_animations_widget.dart   激励一喝表示のUIウィジェット
    │   │   │   ├── reading
    │   │   │   │   └── reading_book_widget.dart                 読書中書籍編集表示のUIウィジェット
    │   │   │   ├── reading_graph
    │   │   │   │   └── reading_book_graph_widget.dart           読書中書籍進捗グラフ表示のUIウィジェット
    │   │   │   ├── settings
    │   │   │   │   └── reading_book_settings_widget.dart        設定表示のUIウィジェット
    │   │   │   └── widget_packages.dart                        （defaultディレクトリ用のバレルファイル）
    │   │   ├── challenge
    │   │   │   ├── home                                        （詳細構成については、completeを参照）
    │   │   │   ├── reading                                     （詳細構成については、completeを参照）
    │   │   │   ├── reading_graph                               （詳細構成については、completeを参照）
    │   │   │   ├── settings                                    （詳細構成については、completeを参照）
    │   │   │   └── widget_packages.dart                        （challengeディレクトリ用のバレルファイル）
    │   │   ├── complete
    │   │   │   ├── home
    │   │   │   │   ├── components
    │   │   │   │   │   └── progress                             読書中書籍進捗表示のUIコンポーネントを定義
    │   │   │   │   ├── currently_tasks_widget.dart              読書中書籍一覧表示のUIウィジェット
    │   │   │   │   ├── reading_progress_animations_widget.dart  読書中書籍進捗表示のUIウィジェット
    │   │   │   │   └── reading_support_animations_widget.dart   激励一喝表示のUIウィジェット
    │   │   │   ├── reading
    │   │   │   │   └── reading_book_widget.dart                 読書中書籍編集表示のUIウィジェット
    │   │   │   ├── reading_graph
    │   │   │   │   ├── components                               読書中書籍進捗グラフ表示のUIコンポーネントを定義
    │   │   │   │   └── reading_book_graph_widget.dart           読書中書籍進捗グラフ表示のUIウィジェット
    │   │   │   ├── settings
    │   │   │   │   └── reading_book_settings_widget.dart        設定表示のUIウィジェット
    │   │   │   └── widget_packages.dart                        （completeディレクトリ用のバレルファイル）
    │   │   └── widget_packages.dart                            （UIウィジェット全体統括のバレルファイル）
    │   └── rouging                                              GoRoutrの Named Routeを定義
    └── test                                                     Unit test と Widget test を定義
```

### 使用プラグイン

ハンズオン・プロジェクトでは、`何がどうなっているのか`というコード実装詳細を見て理解してもらうため、  
便利なライブラリによる、処理実態の隠蔽化や、不慣れだと意図が判らない拡張機能をなるべく避けるようにしました。  
これにより使用するプラグインには、`コード生成を行わない`、`基礎機能に限定する` という制約をつけています。

このため 利用プラグインは、 **[go_router](https://pub.dev/packages/go_router)** と
**[flutter_riverpod](https://pub.dev/packages/flutter_riverpod)** に留めています。

- **go_router プラグイン利用の実装箇所**  
  ハンズオン・プロジェクトでは、画面遷移のために [名前付きルート｜Named routes topic](https://pub.dev/documentation/go_router/latest/topics/Named%20routes-topic.html) を使い、  
  [lib/src/routing/app_router.dart](../lib/src/routing/app_router.dart) でルーティング定義を行っています。

- **flutter_riverpod プラグイン利用の実装箇所**  
  riverpod 利用箇所については、ページウィジェットや UIウィジェットのプロバイダー実装箇所を参照ください。

- 【参照】[pubspec.yaml](../pubspec.yaml)

### ハンズオン・プロジェクト独自のライブラリ

#### 不変データクラス作成
riverpod を使う上で不変データの保証が必須です。
一般的に riverpod で不変データを扱うには、**[freezed](https://pub.dev/packages/freezed)** が使われますが、  
今回は愚直に、`hashCode`と`== オペレーター`のオーバーライドおよび、`JSON serialize | deserialize`の実装を行います。

- ハンズオンプロジェクトでは、`hashCode`と`== オペレーター`のオーバーライドを行う  
  プラグイン [equatable](https://pub.dev/packages/equatable) のユーティリティ [equatable_utils.dart](https://github.com/felangel/equatable/blob/fc5cf81060b3aab54fc6e641ebdfe998b00a619b/lib/src/equatable_utils.dart) のコードを利用させてもらい、  
  ハンズオン・プロジェクト用修正版 [lib/src/fundamental/model/equatable_utils.dart](../lib/src/fundamental/model/equatable_utils.dart) ユーティリティを作りました。

- どのようにこのユーティリティを使うのかは、`読書中書籍情報`と`読書中書籍情報一覧`の不変データクラス  
  **[ReadingBookValueObject](../lib/src/domain/model/reading_book_value_object.dart)** と
  **[ReadingBooksValueObject](../lib/src/domain/model/reading_books_value_object.dart)** の実装コードを確認下さい。  

  - 具体的には、  
    **[props](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/domain/model/reading_book_value_object.dart#L108-L115)** に `値オブジェクトのプロパティ名一覧` を定義し、  
    **[hashCode](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/domain/model/reading_book_value_object.dart#L97-L98)** と
    **[operator ==](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/domain/model/reading_book_value_object.dart#L100-L106)** にボイラープレートコードを記述して、  
    **[copyWith](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/domain/model/reading_book_value_object.dart#L81-L95)** を新規追加して、各プロパティの名前付引数と値指定時の更新ロジックを実装します。  
    _props は、値オブジェクト派生元の **[ValueObject](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/fundamental/model/base_objects_model.dart#L191-L268) 抽象基盤クラス** により提供されます_

  - 併せてこれらの不変データクラスで `JSON serialize | deserialize`を担う、  
    **[toJson()](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/domain/model/reading_book_value_object.dart#L64-L72)** と
    **[fromJson()](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/domain/model/reading_book_value_object.dart#L29-L37)** のコードも確認ください。

#### StatefulWidget ラッパー作成
ウィジェットのサブツリー内で ListView 一覧表示を行う場合、ウィジェット内部状態に ScrollController が必要になるときもあります。  
一般的にウィジェットの内部状態を扱うときは、StatefulWidget＋Stateクラス作成の煩雑さを避けるため
**[hooks_riverpod](https://pub.dev/packages/hooks_riverpod)** が使われますが、  
今回は、プラグイン使用を基礎機能に限定するよう、StatefulWidget をラップして、派生先ウィジェットでStateクラスを作る必要のない、  
**[StagedWidget](../lib/src/fundamental/ui_widget/staged_widget.dart) 抽象基盤クラス** と
**[ConsumerStagedWidget](../lib/src/fundamental/ui_widget/consumer_staged_widget.dart) 抽象基盤クラス** を用意しました。  

- こららの抽象基盤クラスの使い方は、  
  **[App](../lib/src/app/app.dart)** や
  **[CurrentlyTasksWidget](../lib/src/presentation/ui_widget/default/home/currently_tasks_widget.dart)** の実装コードを確認下さい。

  - 具体的には、  
    ウィジェット内部状態型 **T** を 
    [_App<**T**>_](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/app/app.dart#L9-L10) 
    または [_CurrentlyTasksWidget<R,**T**>_](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/ui_widget/default/home/currently_tasks_widget.dart#L10-L11) のように、  
    派生先ウィジェットのジェネリクスで指定し、
    **[createWidgetState](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/ui_widget/default/home/currently_tasks_widget.dart#L28-L30)** で `内部状態オブジェクト` を定義すれば、  
    **[initState](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/ui_widget/default/home/currently_tasks_widget.dart#L32-L36)** や
    **[disposeState](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/ui_widget/default/home/currently_tasks_widget.dart#L38-L42)** や
    **[build](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/lib/src/presentation/ui_widget/default/home/currently_tasks_widget.dart#L44-L78)** メソッドの state パラメータに内部状態オブジェクトが提供されるので、  
    各メソッドごとに必要な処理を実装します。  

----------

## ベースUI とカスタムUI のコードや見栄えの比較ができる工夫

ハンズオンのサブテーマは、**「ベースUIと カスタムUIのコードや見栄えの比較ができる」** です。  
これは、**ベースUI**、**カスタムUI**、**ハンズオン作業中**...それぞれの UIコードについて、  
1. `作業ブランチを切り替えることなく、それぞれの UIコードが比較できる` だけでなく、  
2. `模擬アプリの UI表現が、手軽に切り替えられる` ことを要求しています。

_この要件を満たすため、以下の工夫を行っています。_

- ハンズオン・プロジェクトでは、`ベースUI`、`カスタムUI`、`ハンズオン作業中`の 各UIコードを、  
  **defaultディレクトリ**、**completeディレクトリ**、**challengeディレクトリ** に分けて配置することで、  
  一番目の `作業ブランチを切り替えることなく、それぞれのUIコードが確認できる` ようにしています。

- そして、二番目の`模擬アプリが参照する UI表現の切り替え`は、  
  **バレルファイル** に、`どのディレクトリ配下の UIコードを import する`のかを記述して、  
  `ページウィジェットは、バレルファイルから import した UIウィジェットを表示する`ことで実現します。

- さらに、`プレゼンテーションレイヤの依存関係の複雑さを隠蔽`するため、  
  StatefulWidget ラッパーの **ConsumerStagedWidget** にウィジェット内部状態管理だけでなく、  
  `状況ごとのビルドコードの切り替えや、riverpod プロバイダーとのボイラープレートコードの移譲機能`を追加しました。  

### バレルファイルについて

バレルファイル(Barrel files)は、複数のファイルを 1つの import文で済ませるための単一のファイルです。  
_今回の使い方では、default、complete、challenge 何れかの UIコードしかアプリで利用されなくなりますが、  
ハンズオンプロジェクトは、勉強用の模擬アプリのため、アプリで参照されないコードの発生を許容しています。  
また一般的には、 不必要な export を避けること、循環参照にならないようにする注意が必要なことに御留意ください。_

- 【参照】プロジェクト実装概要 - **[バレルファイル ガイド](fundamental/barrel_file_guide.md)**  

### ConsumerStagedWidget について


----------

## ハンズオン開発環境を作ろう。

ここまで、**FlutterKaigi 2025 ハンズオン** と **ハンズオン・リポジトリ（ハンズオン・プロジェクト）** の説明をいたしました。

ここからは、**ハンズオンに参加してくださったみなさまの作業** について説明させていただきます。  

### Flutter開発環境構築

Flutter開発環境および Android や iOS 開発のセットアップされていない場合は、  
公式サイト [Docs | Flutter](https://docs.flutter.dev/) で説明されている、以下の設定が完了している必要があります。

- Flutterセットアップ  
  [Set up and test drive Flutter](https://docs.flutter.dev/get-started/quick)

  - Android 開発セットアップ  
    [Set up Android development](https://docs.flutter.dev/platform-integration/android/setup)

  - iOS 開発セットアップ  
    [Set up iOS development](https://docs.flutter.dev/platform-integration/ios/setup)

  - _**Flutter SDK バージョンは、最新版にアップグレードしておいてください。**  
    (2025/11/01 現在) Flutter 3.35.7 channel stable, Dart 3.9.2, DevTools 2.48.0_
    - _過去のバージョンを使う必要がある場合は、後述の **`fvm`** をご利用ください。_

Flutter開発環境(IDE)に `VS Code` や `Android Studio` を使う場合は、  
公式サイト [Tools | Flutter](https://docs.flutter.dev/tools) で説明されている、以下の設定が完了している必要があります。

- Flutter Developing Tools  
  [Tools | Flutter](https://docs.flutter.dev/tools)

  - Android Studio と IntelliJ  
    [Android Studio and IntelliJ | Flutter](https://docs.flutter.dev/tools/android-studio)

  - VS Code  
    [VS Code | Flutter](https://docs.flutter.dev/tools/vs-code)

_このハンズオン・プロジェクトは、Flutter Web にも対応しています。  
Android や iOS セットアップをされていない場合は、Chromeブラウザを使った動作確認もできます。_

### ハンズオン環境構築

ハンズオン・プロジェクトでは、チーム開発のため **[fvm](https://pub.dev/packages/fvm)** を使って Flutter バージョンを統一させており、  
また [Makefile](../Makefile) を利用して、模擬アプリの起動やユニットテストの実行も簡易化もしていますが、  
Flutter SDKが最新版（3.35.1 以上）であれば、それらを利用する必要はありません。

**模擬アプリの起動** や **ユニットテストの実行** には、`flutter run` や `flutter test test/` コマンドや、  
`Android Studio` などの IDE が用意している、アプリ実行やテスト機能をご利用ください。

_**何らかの理由で、Flutter SDKを 3.35.1 未満にする必要がある場合**は、  
**[開発環境前提](https://github.com/FlutterKaigi/conference-handson-2025/blob/develop/README.md#%E9%96%8B%E7%99%BA%E7%92%B0%E5%A2%83%E5%89%8D%E6%8F%90)** を参照して、
`fvm` と `Makefile`の`make run`や`make unit-test`コマンドをご利用ください。_

- 【参照】プロジェクト開発環境構築 - [README.md](../README.md)

### リポジトリのクローン
Flutter開発環境構築とハンズオン環境構築が完了しましたら、  
ハンズオン・リポジトリ **[conference-handson-2025](https://github.com/FlutterKaigi/conference-handson-2025)** をクローンして、  
お使いの Android Studio や VS Code などの IDE で、リポジトリのプロジェクト・ルートを開いてください。

----------

## ベースUI を見てみよう。

ハンズオン・プロジェクトの環境構築が済みましたので、まずは手始めにベース UI を確認してみましょう。  

### default バレルファイルを有効にする。

ベースUIのコードファイルは、`lib/src/presentation/ui_widget/default/`ディレクトリに配置されているので、  
**defaultディレクトリのバレルファイル(`lib/src/presentation/ui_widget/default/widget_packages.dart`)** が有効になるよう、  
**UIウィジェット・パッケージ全体のバレルファイル** を修正します。

UIウィジェット・パッケージ全体のバレルファイル [lib/src/presentation/ui_widget/widget_packages.dart](../lib/src/presentation/ui_widget/widget_packages.dart) を開いて、  
デフォルト設定(`default/widget_packages.dart`)の export 行のコメントアウトのみを外して、  
他の export 行がコメントアウトされていることを確認します。  

```dart
// UI Widget として各ページごとの任意のパッケージをインポートできるようにするバレルパッケージです。

// デフォルト設定 （ui_widget/default）
export 'default/widget_packages.dart';

// 完成形設定 （ui_widget/complete）
// export 'complete/widget_packages.dart';

// ハンズオン設定 （ui_widget/challenge）
// export 'challenge/widget_packages.dart';
```
_ハンズオン・リポジトリを Gitクローンしてから、バレルファイルの変更をしていなければ、上記のようになっています。_

### ベースUI を使った機能要件表現を確認する

前ステップで、ui_widget/defaultディレクトリ配下の ベースUIのコードを参照させるようにしました。  
これで模擬アプリを起動すれば、ベースUIによる各種機能要件の表示が行われるようになっています。

- **Flutter SDK が最新版の場合(Flutter SDK 3.35.1 以上)**  
  ターミナルで `flutter run` を実行するか、  
  `Android Studio` のアプリ実行 ⇒ `Run 'main.dart'`を利用ください。

  - **fvm を利用する場合(Flutter SDK 3.35.1 未満)**

    - **macOS/Linux 環境の方へ**  
      ターミナルで `make run` を実行して、  
      起動中の iOSシミュレーターや Android エミュレータをデバイスとして選択してください。

    - **Windows 環境の方へ**  
      ターミナルで `fvm flutter run` を実行して、  
      起動中の iOSシミュレーターや Android エミュレータをデバイスとして選択してください。

  - _ハンズオン・プロジェクトの Flutter実行環境は、iOS/Android の他に Web も有効にしているので、  
    iOS シミュレータや Android エミュレーターでなく、Chromeで動作確認することもできます。_  

#### 読了したページの更新に伴う進捗率達成メッセージを表示する。
- ホーム画のFlutter入門をタップして、書籍編集画面を開きます。  
  <img width="600" alt="書籍編集画面オープン" src="./images/hands-on_base_step_1.png" />

- 読書完了ページ数に 10 を入力して「編集する」のタップで、ホーム画面に戻れば、  
  総ページ数の 10%が達成されているので、進捗率 10%達成メッセージがオーバーラップ表示されます。  
  <img width="600" alt="読了ページ更新＋進捗率達成表示" src="./images/hands-on_base_step_2.png" />

#### 読了したページの進捗をグラフで表示する。
- ホーム画のFlutter入門をタップして、書籍編集画面を開き、アプリバーにある円グラフアイコンをタップして、  
  グラフ画面を開けば、読了ページ数と総ページ数から、進捗率がドーナツグラフで表示されます。  
  <img width="800" alt="読了進捗率ドーナツグラフ表示" src="./images/hands-on_base_step_3.png" />

#### 激励や一喝のメッセージを表示する。
_この機能要件は、読書支援アプリが表示されたタイミングやアラーム設定など、  
何らかのイベントを契機に **激励や一喝のメッセージをオーバーラップ表示** させるものですが、  
模擬アプリでは、イベント発行のためにアラームプラグインなどを組み込まないことにしているため、  
設定画面の読書開始や読書終了スイッチの ON により、擬似イベントを発行していることに留意ください。_

- ホーム画のアプリバーにある歯車アイコンをタップして、設定画面を開き、  
  読書開始イベントのスイッチを ONにして、アプリバーのバックアイコンでホーム画面に戻らせます。
  <img width="800" alt="書籍編集画面オープン" src="./images/hands-on_base_step_4.png" />

- イベント ON から10秒経過すると、激励メッセージがオーバーラップ表示されます。  
  <img width="600" alt="読了ページ更新" src="./images/hands-on_base_step_5.png" />

#### その他（基本要件確認）
カスタムUIを利用しない読書支援アプリの基本要件についても確認してみてください。

- **基本要件**  
  - **設定画面（SettingsPage）** での `書籍の新規追加`、  
  - **ホーム画面（HomePage）** での `一覧表示やタップした書籍の選択`、  
  - **書籍編集画面（ReadingBookPage）** での`書籍情報の編集や、書籍の削除`

##### 書籍の新規追加
- ホーム画のアプリバーにある歯車アイコンをタップして、設定画面を開きます。  
  <img width="600" alt="設定画面オープン" src="./images/hands-on_basic_step_1.png" />

- 書籍名と総ページ数を入力して「新規追加」をタップすると、ホーム画面に書籍が追加されています。  
  <img width="600" alt="書籍新規追加" src="./images/hands-on_basic_step_2.png" />

##### 一覧から選択した書籍の編集
- ホーム画の書籍一覧からMCPサーバー入門をタップして、書籍編集画面を開きます。  
  <img width="600" alt="書籍編集画面オープン" src="./images/hands-on_basic_step_3.png" />

- 書籍名をMCPサーバー実践に変更して「編集する」をタップすると、ホーム画面の書籍名がMCPサーバー実践に更新されています。  
  <img width="600" alt="書籍情報更新" src="./images/hands-on_basic_step_4.png" />

##### 一覧から選択した書籍の削除
- ホーム画の書籍一覧からMCPサーバー実践をタップして、書籍編集画面を開き、  
  「書籍を削除する」をタップして、確認ダイアログでも「削除」をタップします。  
  <img width="800" alt="書籍編集画面オープン＋削除操作" src="./images/hands-on_basic_step_5.png" />

- ホーム画面の書籍一覧からMCPサーバ実践が削除されています。  
  <img width="260" alt="書籍削除" src="./images/hands-on_basic_step_6.png" />

#### 自動テストについて
前段の **基本要件** については、Unit test も提供されていますので、あわせて御確認ください。

テストでは、各モデル機能をチェックする `riverpod`を介した **書籍の追加や編集と削除の単体テスト** と  
`Integration test`を模した、**画面操作のリアクションをチェックする Widget test** が設けられています。

- **Flutter SDK が最新版の場合(Flutter SDK 3.35.1 以上)**  
  ターミナルで `flutter test test/` を実行して、  
  ターミナルに出力される、テストステップと実行結果のログメッセージを確認してください。  
  あるいは、`Android Studio` などの単体テスト機能を利用ください。

  - **fvm を利用する場合(Flutter SDK 3.35.1 未満)**  

    - **macOS/Linux 環境の方へ**  
      ターミナルで `make unit-test` を実行して、  
      ターミナルに出力される、テストステップと実行結果のログメッセージを確認してください。

    - **Windows 環境の方へ**  
      ターミナルで `fvm flutter test test/` を実行して、  
      ターミナルに出力される、テストステップと実行結果のログメッセージを確認してください。

### ベースUI コードを確認する。

#### ベースUIコードに関連するファイル構成
```text
lib
└── src
    ├── app                    アプリ・ウィジェット（ページウィジェットのオブジェクトを保持）
    │   └── scren
    │       ├── home           読書中書籍一覧・ページウィジェット　　　（UIウィジェットのオブジェクトを保持）
    │       ├── reading        読書中書籍編集・ページウィジェット　　　（UIウィジェットのオブジェクトを保持）
    │       ├── reading_graph  読書中書籍進捗グラフ・ページウィジェット（UIウィジェットのオブジェクトを保持）
    │       └── settings       設定・ページウィジェット　　　　　　　　（UIウィジェットのオブジェクトを保持）
    ├── presentation
    │   ├── model    （各ViewModelオブジェクトは、状態種別と状態値を保持し、riverpod providerに保持されます）
    │   │   ├── default
    │   │   │   ├── reading_books_view_model.dart               （読書中書籍一覧の状態値を定義）
    │   │   │   ├── reading_progress_animation_view_model.dart  （読書中書籍進捗の状態種別と状態値を定義）
    │   │   │   ├── reading_support_animation_view_model.dart   （激励一喝の状態種別と状態値を定義）
    │   │   │   └── view_model_packges.dat    　　　　　　        （defaultディレクトリ用のバレルファイル）
    │   │   └── view_model_packges.dat　　　　　　　　 　　　　　　　（ViewModel全体統括のバレルファイル）
    │   ├── ui_widget（各UIウィジェットは、状態種別や状態値更新と連動するため providerオブジェクトをバインドします）
    │   │   ├── default
    │   │   │   ├── home
    │   │   │   │   ├── currently_tasks_widget.dart              読書中書籍一覧表示のUIウィジェット
    │   │   │   │   ├── reading_progress_animations_widget.dart  読書中書籍進捗表示のUIウィジェット
    │   │   │   │   └── reading_support_animations_widget.dart   激励一喝表示のUIウィジェット
    │   │   │   ├── reading
    │   │   │   │   └── reading_book_widget.dart                 読書中書籍編集表示のUIウィジェット
    │   │   │   ├── reading_graph
    │   │   │   │   └── reading_book_graph_widget.dart           読書中書籍進捗グラフ表示のUIウィジェット
    │   │   │   ├── settings
    │   │   │   │   └── reading_book_settings_widget.dart        設定表示のUIウィジェット
    │   │   │   └── widget_packages.dart                        （defaultディレクトリ用のバレルファイル）
    │   │   └── widget_packages.dart                            （UIウィジェット全体統括のバレルファイル）
```

#### ページウィジェット コード
- **screen**
  - **home（書籍一覧画面）**
    - [home_page.dart](../lib/src/app/screen/home/home_page.dart)  
      読書中書籍一覧画面のページウィジェット  
      -  _読書中書籍一覧表示のUIウィジェットに、`readingBooksProvider.notifier` を監視させてバインドします。_
      -  _読書中書籍進捗表示のUIウィジェットに、`readingSupportAnimationsProvider.notifier` を監視させてバインドします。_
      -  _激励一喝表示のUIウィジェットに、`readingProgressAnimationsProvider.notifier` を監視させてバインドします。_

  - **reading（書籍編集画面）**
    - [reading_book_page.dart](../lib/src/app/screen/reading/reading_book_page.dart)  
      読書中書籍編集画面のページウィジェット  
      -  _読書中書籍編集表示のUIウィジェットに、`readingBooksProvider.notifier` を監視させてバインドします。_

  - **reading_graph（書籍進捗率グラフ画面）**
    - [reading_graph_page.dart](../lib/src/app/screen/reading_graph/reading_graph_page.dart)  
      読書中書籍進捗率グラフのページウィジェット  
      -  _読書中書籍進捗グラフ表示のUIウィジェットに、`readingBooksProvider.notifier` を監視させてバインドします。_

  - **settings（設定画面）**
    - [settings_page.dart](../lib/src/app/screen/settings/settings_page.dart)  
      設定画面のページウィジェット  
      -  _設定表示のUIウィジェットに、`readingBooksProvider.notifier` を監視させてバインドします。_

#### ベースUI コード
- **ベースUIコード**  
  - **home（書籍一覧画面のUI表示）**  
    - [currently_tasks_widget.dart](../lib/src/presentation/ui_widget/default/home/currently_tasks_widget.dart)  
      読書中書籍一覧表示のUIウィジェット

    - [reading_progress_animations_widget.dart](../lib/src/presentation/ui_widget/default/home/reading_progress_animations_widget.dart)  
      読書中書籍進捗表示のUIウィジェット

    - [reading_support_animations_widget.dart](../lib/src/presentation/ui_widget/default/home/reading_support_animations_widget.dart)  
      激励一喝表示のUIウィジェット

  - **reading（書籍編集画面のUI表示）**  
    - [reading_book_widget.dart](../lib/src/presentation/ui_widget/default/reading/reading_book_widget.dart)  
      読書中書籍編集表示のUIウィジェット

  - **reading_graph（書籍進捗率グラフ画面のUI表示）**  
    - [reading_book_graph_widget.dart](../lib/src/presentation/ui_widget/default/reading_graph/reading_book_graph_widget.dart)  
      読書中書籍進捗グラフ表示のUIウィジェット

  - **settings（設定画面のUI表示）**  
    - [reading_book_settings_widget.dart](../lib/src/presentation/ui_widget/default/settings/reading_book_settings_widget.dart)  
      設定表示のUIウィジェット

- **UIウィジェット - バレルファイル**
  - **UIウィジェット全体統括用**  
    [widget_packages.dart](../lib/src/presentation/ui_widget/widget_packages.dart)  

    - **defaultディレクトリ用**  
      [widget_packages.dart](../lib/src/presentation/ui_widget/default/widget_packages.dart)  

#### ViewModel コード
_**ViewModel**は、`default`、`complete`、`challenge`ともに **defaultのコードを共用** しています。_

- **ViewModelコード**  
  - **default**  
    - [reading_books_view_model.dart](../lib/src/presentation/model/default/reading_books_view_model.dart)  
      読書中書籍一覧の状態値を保持する ViewModel  
      _オブジェクトは、`readingBooksProvider` に保持されます。_

    - [reading_progress_animations_view_model.dart](../lib/src/presentation/model/default/reading_progress_animations_view_model.dart)  
      読書中書籍進捗の状態種別と状態値を保持する ViewModel  
      _オブジェクトは、`readingProgressAnimationsProvider` に保持されます。_

    - [reading_support_animations_view_model.dart](../lib/src/presentation/model/default/reading_support_animations_view_model.dart)  
      激励一喝の状態種別と状態値を保持する ViewModel  
      _オブジェクトは、`readingSupportAnimationsProvider` に保持されます。_

- **ViewModel - バレルファイル**
  - **ViewModel全体統括用**  
    [view_model_packages.dart](../lib/src/presentation/model/view_model_packages.dart)

    - **defaultディレクトリ用**  
      [view_model_packages.dart](../lib/src/presentation/model/default/view_model_packages.dart)

----------

## カスタムUI を完成させよう。
ここからは実際に手を動かしつつカスタムUIの実装内容を確認していきます。

進行の都合上、全てのコードを紹介することはできませんが、重要な箇所を虫食い状態にしたコードを用意しております。

こちらの虫食いコードを使って実装を進めていきます。

### challenge バレルファイルを有効にする。
まずはバレルファイルを修正し、虫食いコードが配置されているファイル群をアプリケーション内で参照するようにします。

lib/src/presentation/ui_widget/widget_packages.dart
```dart
// UI Widget として各ページごとの任意のパッケージをインポートできるようにするバレルパッケージです。

// デフォルト設定 （ui_widget/default）
// export 'default/widget_packages.dart';

// 完成形設定 （ui_widget/complete）
// export 'complete/widget_packages.dart';

// ハンズオン設定 （ui_widget/challenge）
export 'challenge/widget_packages.dart';
```

現時点のコードは虫食い状態ですが、ビルド可能です。アプリケーションを起動しておくことで後続のハンズオンの動作確認がスムーズになります。
今のうちに起動しておきましょう。

### 穴開きカスタムUI コードを完成させる。
ハンズオン作業はいくつかの工程に分けて進めていきます。各工程ごとに技術の説明と実装を行い、これを繰り返していきます。

実装するコードの完成系が虫食いの近くにコメントで添えてあります。ハンズオンは手入力でご参加いただいても、動作確認を目的にコメント解除で完成系コードを適用しても問題ありません。ご自身の取り組みやすい方法でご参加ください。


### 装飾を重ねて華やかな演出をする
このパートでは次の技術要素を扱います。

- `AnimationController`と`Animation`
- `AnimatedBuilder`と`animation.value`
- `Stack` と`unawaited`

`AnimationController`はアニメーションの時間軸を制御し、`Animation`はその進行度を具体的な数値に変換します。`AnimatedBuilder`は、`animation.value`の変化を検知してUIを自動的に再構築し、滑らかな動きを実現します。

これらの技術を活用して、読書進捗に応じた応援メッセージを画面に表示します。各書籍の読了ページ数を変更し「編集する」ボタンを押下すると一覧ページに遷移します。この時に表示する応援メッセージを華やかにします。現時点では応援メッセージは表示されません。

#### ステップ1: アニメーション設定の分割
- ステップ1からステップ3までの完成例  
  <img width="300" alt="グラデーションのみ表示" src="./images/hands-on_DynamicBackground.png" />

ステップ1では、アニメーションを実現するための「再生時間」と「動き」の設定を用意します。このステップでは二つのオブジェクトを用意します。

`AnimationController` はアニメーションの再生時間（`duration`）を制御する役割を担います。コンストラクタでは以下の設定をしています。

- `duration`: アニメーションの再生時間を指定します。`Duration`クラスを使って時間を指定します。
- `vsync`: アニメーションを画面のリフレッシュレートと同期させるための引数です。これにより、アニメーションがカクつかずに、非常に滑らかに見えます。

`Animation` は`AnimationController`の進行度を、具体的な動きのパターンに変換します。ここで使用する`CurvedAnimation`はアニメーションの進行に緩急をつけ滑らかな動きにできます。コンストラクタでは以下の設定をしています。

- `parent`: アニメーションの「時間軸」となる`AnimationController`を指定します。
- `curve`: アニメーションの動きを指定します。`Curves.easeInOutSine`は、滑らかに加速と減速を繰り返す波のような動きを生成します。これにより、背景のグラデーションが穏やかに膨張・収縮するような効果を生み出します。

このステップではグラデーションのアニメーション表現を代表して実装します。このグラデーションは重ねる装飾のうちの一番下地になります。他の表現についても同様の構造でオブジェクトを用意しています。

では、グラデーション表現の`AnimationController`と`Animation`を用意します。

**作業対象**
```
lib/src/presentation/ui_widget/challenge/home/reading_progress_animations_widget.dart

lib
├── src
│   ├── app
│   ├── application
│   ├── domain
│   ├── fundamental
│   ├── infrastructure
│   ├── presentation
│   │   ├── ui_widget
│   │   │   ├── challenge
│   │   │   │   ├── home
│   │   │   │   │   ├── components
│   │   │   │   │   ├── currently_tasks_widget.dart
│   │   │   │   │   ├── reading_progress_animations_widget.dart  // これが対象
│   │   │   │   │   └── reading_support_animations_widget.dart
```

修正前の時点ではグラデーション用のコードがコメントアウトされています。

**修正前**
```dart
void _initializeAnimations() {
  // 省略（他のコントローラー）

  // ステップ1：アニメーションの設定の分割（再生時間）
  // _backgroundController = AnimationController(
  //   duration: const Duration(milliseconds: 5000),
  //   vsync: this,
  // );

  // 省略（他のアニメーション）

  // ステップ1：アニメーションの設定の分割（動き）
  // _backgroundAnimation = CurvedAnimation(
  //   parent: _backgroundController,
  //   curve: Curves.easeInOutSine,
  // );
}
```

`_backgroundController`変数は、グラデーションを5秒間かけて変化させるよう、時間の定義をしています。`duration`を5000ミリ秒（5秒）に設定しています。

`_backgroundAnimation`変数は、グラデーションの動きを滑らかに加速と減速を繰り返す波のような動きにするための動きの定義をしています。`CurvedAnimation`を使い、時間軸（`_backgroundController`）に`Curves.easeInOutSine`という緩急パターンを適用しています。

**修正後**
```dart
void _initializeAnimations() {
  // 省略（他のコントローラー）

  // ステップ1：アニメーションの設定の分割（再生時間）
  _backgroundController = AnimationController(
    duration: const Duration(milliseconds: 5000),
    vsync: this,
  );

  // 省略（他のアニメーション）

  // ステップ1：アニメーションの設定の分割（動き）
  _backgroundAnimation = CurvedAnimation(
    parent: _backgroundController,
    curve: Curves.easeInOutSine,
  );
 }
```

#### ステップ2: １層目の放射グラデーション
重ね合わせるアニメーション表現の一番下層の放射グラデーションを用意します。このグラデーションは時間の進行に合わせて動くようにします。

`AnimatedBuilder` はアニメーションを動かすための再描画機能です。引数で指定した`animation`の値が変化するたびに、`builder`メソッド内のUIを再構築します。引数は次の通りです。

- `animation`: アニメーションの変化を監視する`Animation`オブジェクトを指定します。前ステップで作成した`Animation`オブジェクトを指定します。`Animation`オブジェクトは時間軸の変化に合わせて0.0から1.0まで変化する値を持ちます。
- `builder`: `Animation`オブジェクトの現在の値（`animation.value`）を使ってUIを構築するための関数です。Animationの値が更新されるたびに呼び出されUIを再構築します。ここで放射グラデーションの表現を組み立てます。

放射グラデーションは`RadialGradient` を使います。中心から外側に向かって色が放射状に変化するグラデーションを定義できます。引数は次の通りです。

- `center:` グラデーションの中心点を指定します。`Alignment.center`で中央に配置しています。
- `radius:` グラデーションが広がる半径を定義します。今回は`0.8 + animation.value * 0.4`の式を指定し、`animation.value`（`0.0`から`1.0`に変化）に応じてグラデーションの半径が`0.8`から`1.2`まで動的に変化します。
- `colors:` グラデーションを構成する色のリストです。リストの最初の色がグラデーションの中心の色となり、リストの最後の色がグラデーションの最も外側の色になります。
グラデーションに使用する4つの色と、それぞれの透明度を定義します。今回は`witchValues`を使用し`Color` オブジェクトの値を`animation.value`の値の変化に応じて動的に変化するようにしています。`primaryColor.withValues(alpha: 0.15 + animation.value * 0.1)`のように`alpha` （透明度）を動的に変更しています。
- `stops:` `colors` リストの色がグラデーションのどの位置（中心からの距離）で変化するかを制御します。要素の順番は`colors` の順番に対応しています。0.0が中心に近く、1.0は最も外側です。それぞれの色が、グラデーションのどこで完全にその色になるかを指定します。

では、グラデーションの動きをanimation.valueで動的な表現にしていきましょう。

**作業対象**
```
lib/src/presentation/ui_widget/challenge/home/components/progress/dynamic_background_widget.dart

lib
├── src
│   ├── app
│   ├── application
│   ├── domain
│   ├── fundamental
│   ├── infrastructure
│   ├── presentation
│   │   ├── ui_widget
│   │   │   ├── challenge
│   │   │   │   ├── home
│   │   │   │   │   ├── components
│   │   │   │   │   │   └── progress
│   │   │   │   │   │       ├── dynamic_background_widget.dart  // これが対象
│   │   │   │   │   │       ├── その他ウィジェット
│   │   │   │   │   ├── currently_tasks_widget.dart
│   │   │   │   │   ├── reading_progress_animations_widget.dart
│   │   │   │   │   └── reading_support_animations_widget.dart
```

修正前の時点ではanimation.valueとする部分が全て固定値１になっています。

**修正前**
```dart
@override
Widget build(BuildContext context) {
  // ステップ2: １層目の放射グラデーション
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8 + 1 * 0.4,
              // radius: 0.8 + animation.value * 0.4,
              colors: <Color>[
                primaryColor.withValues(alpha: 0.15 + 1 * 0.1),
                // primaryColor.withValues(alpha: 0.15 + animation.value * 0.1),
                secondaryColor.withValues(
                  alpha: 0.08 + 1 * 0.05,
                ),
                // secondaryColor.withValues(
                //   alpha: 0.08 + animation.value * 0.05,
                // ),
                primaryColor.withValues(alpha: 0.03),
                Colors.transparent,
              ],
              stops: const <double>[0, 0.4, 0.7, 1],
            ),
          ),
        ),
      );
    },
  );
}
```

グラデーション半径と色の透明度を固定値ではなく、`Animation`オブジェクトから受け取れる動的な値に変更します。

**修正後**
```dart
@override
Widget build(BuildContext context) {
  // ステップ2: １層目の放射グラデーション
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8 + animation.value * 0.4,
              colors: <Color>[
                primaryColor.withValues(alpha: 0.15 + animation.value * 0.1),
                secondaryColor.withValues(
                  alpha: 0.08 + animation.value * 0.05,
                ),
                primaryColor.withValues(alpha: 0.03),
                Colors.transparent,
              ],
              stops: const <double>[0, 0.4, 0.7, 1],
            ),
          ),
        ),
      );
    },
  );
}
```

#### ステップ3: アニメーションの配置と実行
ここまでに作成した放射グラデーションを画面表示します。`Stack` の`children` に前のステップで操作した`DynamicBackgroundWidget`を配置します。

`DynamicBackgroundWidget`の引数にはアニメーションの値をもつ`Animation`オブジェクトと色を渡しています。なお、進捗に応じて適用する色を変えるように裏側で作り込まれています。

**作業対象**
```
lib/src/presentation/ui_widget/challenge/home/reading_progress_animations_widget.dart

lib
├── src
│   ├── app
│   ├── application
│   ├── domain
│   ├── fundamental
│   ├── infrastructure
│   ├── presentation
│   │   ├── ui_widget
│   │   │   ├── challenge
│   │   │   │   ├── home
│   │   │   │   │   ├── components
│   │   │   │   │   ├── currently_tasks_widget.dart
│   │   │   │   │   ├── reading_progress_animations_widget.dart  // これが対象
│   │   │   │   │   └── reading_support_animations_widget.dart
```

修正前の時点ではグラデーションの配置がコメントアウトされています。

**修正前**
```dart
child: Stack(
  alignment: Alignment.center,
  children: <Widget>[
    // ステップ3: アニメーションの配置と実行
    // DynamicBackgroundWidget(
    //   animation: _backgroundAnimation,
    //   primaryColor: widget.primaryColor,
    //   secondaryColor: widget.secondaryColor,
    // ),
```

Stackにグラデーションのウィジェットを配置します。アニメーションに必要な`Animation`オブジェクトや色情報を引数で渡しています。

**修正後**
```dart
child: Stack(
  alignment: Alignment.center,
  children: <Widget>[
    // ステップ3: アニメーションの配置と実行
    DynamicBackgroundWidget(
      animation: _backgroundAnimation,
      primaryColor: widget.primaryColor,
      secondaryColor: widget.secondaryColor,
    ),
```

続いて`unawaited()`を使ってアニメーションを開始します。アニメーションはアプリの動作を阻害しないよう非同期で動作します。`unawaited()` は、非同期処理の完了を待たない場合に発生する警告を抑制するために使用されます。ここでは、`_backgroundController.repeat` が返す`Future` を待つ必要がないことを明示的に示しています。

コントローラーが持つメソッドを実行することで開始されます。今回は`_backgroundController.repeat(reverse: true)`を実行し、繰り返し再生させます。

修正前はグラデーションの開始がコメントアウトされています。

**修正前**
```dart
Future<void> _startAnimationSequence() async {
  // ステップ3: アニメーションの配置と実行
  // unawaited(_backgroundController.repeat(reverse: true));
```

`unawaited`により非同期で、_backgroundControllerが制御する背景グラデーションのアニメーションを開始します。

**修正後**
```dart
Future<void> _startAnimationSequence() async {
  // ステップ3: アニメーションの配置と実行
  unawaited(_backgroundController.repeat(reverse: true));
```

- ステップ1からステップ3までの完成例（再掲）  
  <img width="300" alt="グラデーションのみ表示" src="./images/hands-on_DynamicBackground.png" />



なお、本サンプルアプリでは、応援メッセージは10秒後に自動的に非表示になるよう実装しています。

### ステップ4: ２層目の波紋
- ステップ4の完成例  
  <img width="300" alt="波紋の表示" src="./images/hands-on_RippleEffec.png" />

アニメーションを重ねていることを体験するために、もう一つ重ねます。前ステップの放射グラデーションの上に波紋の表現を重ねます。

波紋を表すウィジェットは作成済みです。canvas.drawCircleでの円の描画を、繰り返し処理で0.25秒ずらして4回行っています。詳細はファイルの内容をご確認ください。
（lib/src/presentation/ui_widget/enhanced_progress/home/components/ripple_effect_widget.dart）

```
lib/src/presentation/ui_widget/challenge/home/reading_progress_animations_widget.dart

lib
├── src
│   ├── app
│   ├── application
│   ├── domain
│   ├── fundamental
│   ├── infrastructure
│   ├── presentation
│   │   ├── ui_widget
│   │   │   ├── challenge
│   │   │   │   ├── home
│   │   │   │   │   ├── components
│   │   │   │   │   ├── currently_tasks_widget.dart
│   │   │   │   │   ├── reading_progress_animations_widget.dart  // これが対象
│   │   │   │   │   └── reading_support_animations_widget.dart
```

修正前の時点ではグラデーションの上に重ねる波紋アニメーションの配置がコメントアウトされています。

**修正前**
```dart
child: Stack(
  alignment: Alignment.center,
  children: <Widget>[
    // ステップ3: アニメーションの配置と実行
    DynamicBackgroundWidget(
      animation: _backgroundAnimation,
      primaryColor: widget.primaryColor,
      secondaryColor: widget.secondaryColor,
    ),

    // ステップ4: ２層目の波紋
    // RippleEffectWidget(
    //   animation: _rippleAnimation,
    //   primaryColor: widget.primaryColor,
    //   secondaryColor: widget.secondaryColor,
    // ),
```

コメントの解除で波紋アニメーションを配置します。`Stack`を使うことでウィジェットを重ねて表示できます。

**修正後**
```dart
child: Stack(
  alignment: Alignment.center,
  children: <Widget>[
    // ステップ3: アニメーションの配置と実行
    DynamicBackgroundWidget(
      animation: _backgroundAnimation,
      primaryColor: widget.primaryColor,
      secondaryColor: widget.secondaryColor,
    ),

    // ステップ4: ２層目の波紋
    RippleEffectWidget(
      animation: _rippleAnimation,
      primaryColor: widget.primaryColor,
      secondaryColor: widget.secondaryColor,
    ),

```

- ステップ4の完成例（再掲）  
  <img width="300" alt="波紋の表示" src="./images/hands-on_RippleEffec.png" />

#### まとめ
この工程では、アニメーションの「時間」と「動き」を、`AnimationController`と`Animation`で個別に定義することで、複雑な演出を構造的に管理できることを確認しました。`AnimatedBuilder`ではアニメーション値に応じて変化する表現を実装しました。さらに、`Stack`ウィジェットを利用して、複数の装飾を重ねて華やかなアニメーションを実装する手法を学びました。

この章で学んだ技術は、単一のアニメーションを実装するだけでなく、複数のアニメーションを協調させてリッチな表現を作り出すための基礎となります。


### 複数アニメーションを連動させる
このパートでは次の技術要素を扱います。

- `Listenable.merge`
- 複数の`animation.value`

複数のアニメーションを協調させて複雑な演出を作り出します。Listenable.mergeを使うことで、複数の独立したAnimationControllerを一つにまとめて監視できます。

１つのUI表現のなかで複数の異なる時間軸のアニメーション値（animation.value）を利用し、応援メッセージの中心となるコンテンツを作成します。

#### ステップ1: 複数のコントローラーを統合的に監視
- ステップ1の完成例  
  <img width="300" alt="応援のメインコンテンツ" src="./images/hands-on_MainContent_1.png" />


複数のアニメーションを組み合わせた統合的な制御を行うよう設定をします。

これまでの放射グラデーションなどでは、`AnimatedBuilder` の引数には単一の`Animation` オブジェクトを渡していました。これは時間経過によるUI更新を渡した`Animation`に紐づいた単一の`AnimationController`を監視することにより実現していました。

今回は、複数の時間軸によるアニメーション値の変化を利用します。`AnimatedBuilder`の`animation`引数に`Listenable.merge`を指定します。`Listenable.merge`は、複数の`AnimationController`を一つのリスナーとして統合します。

ここでは、`_mainController`, `_progressController`, `_pulseController`のいずれかの値が変更されるたびに、`AnimatedBuilder`が子ウィジェットを再構築するようになります。これにより複数のアニメーションを連動させたUI構築が可能になります。

**作業対象**
```
lib/src/presentation/ui_widget/challenge/home/reading_progress_animations_widget.dart

lib
├── src
│   ├── app
│   ├── application
│   ├── domain
│   ├── fundamental
│   ├── infrastructure
│   ├── presentation
│   │   ├── ui_widget
│   │   │   ├── challenge
│   │   │   │   ├── home
│   │   │   │   │   ├── components
│   │   │   │   │   ├── currently_tasks_widget.dart
│   │   │   │   │   ├── reading_progress_animations_widget.dart  // これが対象
│   │   │   │   │   └── reading_support_animations_widget.dart
```

修正前の時点では、`Stack`でグラデーションと波紋のウィジェットを重ねて配置しています。その上に応援メッセージの中心となるコンテンツを配置します。

**修正前**
```dart
child: Stack(
  alignment: Alignment.center,
  children: <Widget>[
    DynamicBackgroundWidget(省略

    RippleEffectWidget(省略

    // ステップ1: 複数のコントローラーを統合的に監視
    // AnimatedBuilder(
    //   animation: Listenable.merge(<Listenable>[
    //     _mainController,
    //     _progressController,
    //     _pulseController,
    //   ]),
    //   builder: (BuildContext context, Widget? child) {
    //     return FadeTransition(
    //       opacity: _fadeAnimation,
    //       child: Transform.scale(
    //         scale: _scaleAnimation.value * _bounceAnimation.value,
    //         child: _buildMainContent(),
    //       ),
    //     );
    //   },
    // ),
```

`Listenable.merge`で複数のコントローラーを監視します。これにより複数のアニメーション値の変化を組み合わせた表現が可能になります。

このステップでは`Listenable.merge`が主題です。ハンズオン負荷軽減のため`builder`以下はコメント解除にて実装してください。

**修正後**
```dart
child: Stack(
  alignment: Alignment.center,
  children: <Widget>[
    DynamicBackgroundWidget(省略

    RippleEffectWidget(省略

    // ステップ1: 複数のコントローラーを統合的に監視
    AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _mainController,
        _progressController,
        _pulseController,
      ]),
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value * _bounceAnimation.value,
            child: _buildMainContent(),
          ),
        );
      },
    ),
```

- ステップ1の完成例（再掲）  
  <img width="300" alt="応援のメインコンテンツ" src="./images/hands-on_MainContent_1.png" />


`builder`での記述に登場する`_fadeAnimation`、`_scaleAnimation`、`_bounceAnimation`はいずれも`_mainController`で管理されており、同じ時間軸のなかで動いています。

よって`Listenable.merge`の特徴はまだ発揮されていません。他のコントローラーの値を利用しているのは`_buildMainContent()`の中です。後続のステップで修正します。

#### ステップ2: 応援メッセージを配置
- ステップ2の完成例  
  <img width="300" alt="動きのないメインコンテンツ" src="./images/hands-on_MainContent_2.png" />


このステップでは応援メッセージの中心を担うウィジェットを配置します。技術的に新しいものはないので、コメントを解除して実装します。

ここで配置する`ProgressCircleWidget`には、引数で２つの`Animation`オブジェクトを渡しています。これらの`_progressAnimation`と`_pulseAnimation` は前ステップの`Listenable.merge`で監視している`_progressController`と`_pulseController`を利用しています。

次のステップでは、`ProgressCircleWidget`の中で各アニメーション値を利用した実装をします。

**作業対象**
```
lib/src/presentation/ui_widget/challenge/home/reading_progress_animations_widget.dart

lib
├── src
│   ├── app
│   ├── application
│   ├── domain
│   ├── fundamental
│   ├── infrastructure
│   ├── presentation
│   │   ├── ui_widget
│   │   │   ├── challenge
│   │   │   │   ├── home
│   │   │   │   │   ├── components
│   │   │   │   │   ├── currently_tasks_widget.dart
│   │   │   │   │   ├── reading_progress_animations_widget.dart  // これが対象
│   │   │   │   │   └── reading_support_animations_widget.dart
```

修正前は応援メッセージの中心を構成する`ProgressCircleWidget`の配置がコメントアウトされています。

**修正前**
```dart
Widget _buildMainContent() {
  return SizedBox(
    width: 400,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // ステップ2: 応援メッセージを配置
        // ProgressCircleWidget(
        //   progressAnimation: _progressAnimation,
        //   pulseAnimation: _pulseAnimation,
        //   progressPercent: widget.progressPercent,
        //   primaryColor: widget.primaryColor,
        //   secondaryColor: widget.secondaryColor,
        //   icon: widget.icon,
        // ),
```

`ProgressCircleWidget`に複数の`Animation`を渡して配置します。これらの`Animation`の値をウィジェット内で利用します。

**修正後**
```dart
Widget _buildMainContent() {
  return SizedBox(
    width: 400,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // ステップ2: 応援メッセージを配置
        ProgressCircleWidget(
          progressAnimation: _progressAnimation,
          pulseAnimation: _pulseAnimation,
          progressPercent: widget.progressPercent,
          primaryColor: widget.primaryColor,
          secondaryColor: widget.secondaryColor,
          icon: widget.icon,
        ),
```

- ステップ2の完成例（再掲）  
  <img width="300" alt="動きのないメインコンテンツ" src="./images/hands-on_MainContent_2.png" />

中央に表示されたコンテンツが`ProgressCircleWidget`です。現時点ではサイズは固定、進捗プログレスも動かない状態ですが、次のステップで修正します。

#### ステップ3: アニメーションの値で動きを実現
- ステップ3の完成例  
  <img width="300" alt="動く応援のメインコンテンツ" src="./images/hands-on_MainContent_3.png" />

応援メッセージを表す`ProgressCircleWidget`内で、アニメーション値を利用して動きをつけます。

コード内の５箇所でアニメーション値を利用しています。

1. `Transform.scale` を使い円全体を拡大・縮小します。`scale`プロパティに`double`値を指定することで、子ウィジェットのサイズを変更します。ここに`pulseAnimation.value`を適用し、アニメーションの進行に合わせて拡大率を変更させます。`pulseAnimation.value`は0.95〜1.15を往復するよう設定をしています。
    
    ```dart
    return Transform.scale(
      // ステップ3: アニメーションの値で動きを実現①
      scale: pulseAnimation.value,
      child: Container(
    ```
    
2. `BoxShadow` を使い影とグロー効果（柔らかい光）を表現します。`blurRadius`プロパティは影のぼかしの度合いを表し、ここに`pulseAnimation.value` を適用し、アニメーションの進行に合わせて影のぼかしを変更させます。
    1. １つ目の`BoxShadow`では影を表現しており、円の拡大縮小に合わせて影のぼかしを連動させます。
        
        ```dart
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.6),
          // ステップ3: アニメーションの値で動きを実現②
          blurRadius: 25 + pulseAnimation.value * 10,
          spreadRadius: 8,
          offset: const Offset(0, 5),
        ),
        ```
        
    2. ２つ目の`BoxShadow`ではグロー効果を表現しており、円の拡大縮小に合わせて別の色のぼかしを連動させます。
        
        ```dart
        BoxShadow(
          color: secondaryColor.withValues(alpha: 0.4),
          // ステップ3: アニメーションの値で動きを実現③
          blurRadius: 40 + pulseAnimation.value * 15,
          spreadRadius: 15,
        ),
        ```
        
3. 進捗円弧を滑らかに表示します。`_Enhanced3DProgressPainter`は進捗に応じた円弧を描画する独自のクラスです。ここに渡す進捗は`progressAnimation.value`を使って計算するようにします。時間経過に応じた進捗を渡し、滑らかな進捗円弧を`drawArc` で描画します。
    
    ```dart
    child: CustomPaint(
      painter: _Enhanced3DProgressPainter(
        // ステップ3: アニメーションの値で動きを実現④
        progress:
            progressAnimation.value * (progressPercent / 100),
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        pulseValue: pulseAnimation.value,
      ),
    ),
    ```
    
4. `Transform.scale` を使って円の中心に表示するアイコンを拡大・縮小します。円の拡大縮小でも利用している`pulseAnimation.value`を計算に組み込むことで円の動きに合わせて拡大率を変更させます。
    
    ```dart
    Transform.scale(
      // ステップ3: アニメーションの値で動きを実現⑤
      scale: 1.0 + pulseAnimation.value * 0.2,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: Icon(icon, size: 32, color: Colors.white),
      ),
    ),
    ```

ここまで見てきたようにProgressCircleWidget内では、pulseAnimation.valueやprogressAnimation.valueといった複数の異なるアニメーション値を利用し、１つの応援メッセージの中に異なる時間軸で管理された値を取り入れた複雑な動きのアニメーションを実現しています。

**作業対象**
```
lib/src/presentation/ui_widget/challenge/home/components/progress/progress_circle_widget.dart

lib
├── src
│   ├── app
│   ├── application
│   ├── domain
│   ├── fundamental
│   ├── infrastructure
│   ├── presentation
│   │   ├── ui_widget
│   │   │   ├── challenge
│   │   │   │   ├── home
│   │   │   │   │   ├── components
│   │   │   │   │   │   └── progress
│   │   │   │   │   │       ├── progress_circle_widget.dart  // これが対象
│   │   │   │   │   │       ├── その他ウィジェット
│   │   │   │   │   ├── currently_tasks_widget.dart
│   │   │   │   │   ├── reading_progress_animations_widget.dart
│   │   │   │   │   └── reading_support_animations_widget.dart
```

**修正前**
`xxxAnimation.value`とする部分を全て固定値１にしています。


固定値１にしていた修正前のコードはコメントアウトで残しています。コードが長いため、一部省略して掲載しています。

**修正後**
```dart
@override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: pulseAnimation,
    builder: (BuildContext context, Widget? child) {
      return Transform.scale(
        // ステップ3: アニメーションの値で動きを実現①
        // scale: 1,
        scale: pulseAnimation.value,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              // 省略
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.6),
                // ステップ3: アニメーションの値で動きを実現②
                // blurRadius: 25 + 1 * 10,
                blurRadius: 25 + pulseAnimation.value * 10,
                spreadRadius: 8,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: secondaryColor.withValues(alpha: 0.4),
                // ステップ3: アニメーションの値で動きを実現③
                // blurRadius: 40 + 1 * 15,
                blurRadius: 40 + pulseAnimation.value * 15,
                spreadRadius: 15,
              ),
              BoxShadow(
                // 省略
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _Enhanced3DProgressPainter(
                    // ステップ3: アニメーションの値で動きを実現④
                    // progress:
                    //     1 * (progressPercent / 100),
                    progress:
                        progressAnimation.value * (progressPercent / 100),
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    pulseValue: pulseAnimation.value,
                  ),
                ),
              ),

              Transform.scale(
                // ステップ3: アニメーションの値で動きを実現⑤
                // scale: 1.0 + 1 * 0.2,
                scale: 1.0 + pulseAnimation.value * 0.2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
              ),
```

- ステップ3の完成例（再掲）  
  <img width="300" alt="動く応援のメインコンテンツ" src="./images/hands-on_MainContent_3.png" />


異なる時間軸の動きが協調して、中央の円が大きくなったり小さくなったり、進捗プログレスもじわっと描画されようになりました。

これで応援アニメーションの主要な実装は完了しました。次のステップでは、おまけとして他のアニメーション表現を重ねます。

#### ステップ4: 【おまけ】他のアニメーションを重ねる
- ステップ4の完成例  
  <img width="300" alt="完成した応援のメインコンテンツ" src="./images/hands-on_MainContent_4.png" />


おまけに他のアニメーション表現のウィジェットも`Stack` に追加します。コメントを解除して適用してください。より華やかな演出になります。

**作業対象**
```
lib/src/presentation/ui_widget/challenge/home/reading_progress_animations_widget.dart

lib
├── src
│   ├── app
│   ├── application
│   ├── domain
│   ├── fundamental
│   ├── infrastructure
│   ├── presentation
│   │   ├── ui_widget
│   │   │   ├── challenge
│   │   │   │   ├── home
│   │   │   │   │   ├── components
│   │   │   │   │   ├── currently_tasks_widget.dart
│   │   │   │   │   ├── reading_progress_animations_widget.dart  // これが対象
│   │   │   │   │   └── reading_support_animations_widget.dart
```

粒子が広がる`ParticleEffectWidget`と星が飛び散る`SparkleEffectWidget`を有効化し、演出を重ねます。

**修正後**
```dart
// ステップ4: 【おまけ】他のアニメーションを重ねる①
if (widget.isCompletion)
  ParticleEffectWidget(
    animation: _particleController,
    color: widget.secondaryColor,
  ),

// ステップ4: 【おまけ】他のアニメーションを重ねる②
SparkleEffectWidget(
  animation: _sparkleAnimation,
  primaryColor: widget.primaryColor,
  secondaryColor: widget.secondaryColor,
  isCompletion: widget.isCompletion,
),
```

- ステップ4の完成例（再掲）  
  <img width="300" alt="完成した応援のメインコンテンツ" src="./images/hands-on_MainContent_4.png" />

#### まとめ

この工程では、複数のアニメーションを協調させて複雑な演出を作り出すための技術を学習しました。`Listenable.merge`を使うことで、複数の独立した`AnimationController`を一つにまとめました。これにより、異なる時間軸で動く複数のアニメーションを監視できます。これらの技術を用いることで、よりリッチで説得力のあるUIを構築できるようになります。

### 遅延実行とトランジションで滑らかな表現をする
このパートでは次の技術要素を扱います。

- `WidgetsBinding.instance.addPostFrameCallback`
- `Tween`
- `AnimatedSwitcher`

アニメーションの遅延実行やトランジションを適用したウィジェット切り替えを学習します。

### ステップ1: 画面表示完了後に円グラフ描画を予約
- ステップ1からステップ2までの完成例  
  <img width="300" alt="進捗円グラフ" src="./images/hands-on_DonutChart_1.png" />


今回の進捗円グラフは画面表示の瞬間に描画するのではなく、背景のグレーの円を含む画面表示の完了後に、それをなぞる様に遅延実行し、進捗円グラフの描画をします。

`WidgetsBinding.instance.addPostFrameCallback` メソッドは画面の描画が完了した直後に一度だけ実行されるコールバック関数を登録します。ここに進捗円グラフを描画する処理を渡します。

```
lib/src/presentation/ui_widget/challenge/reading_graph/reading_book_graph_widget.dart

lib
├── src
│   ├── app
│   ├── application
│   ├── domain
│   ├── fundamental
│   ├── infrastructure
│   ├── presentation
│   │   ├── ui_widget
│   │   │   ├── challenge
│   │   │   │   ├── reading_graph
│   │   │   │   │   ├── components
│   │   │   │   │   └── reading_book_graph_widget.dart  // これが対象
```

修正前は進捗円グラフの描画処理がコメントアウトされています。

**修正前**
```dart
// ステップ1: 画面表示完了後に円グラフ描画を予約
// WidgetsBinding.instance.addPostFrameCallback((_) {
//   controllers.animateToProgress(progress);
// });
```

円グラフの描画を行う`animateToProgress`メソッドの呼び出しを含むコールバック関数を遅延実行に指定します。

**修正後**
```dart
// ステップ1: 画面表示完了後に円グラフ描画を予約
WidgetsBinding.instance.addPostFrameCallback((_) {
  controllers.animateToProgress(progress);
});
```

具体的な描画を行う`animateToProgress`メソッドは後続のステップで確認します。

### ステップ2: 進捗に合わせた終了値を指定し開始
前ステップでコールバックに指定した`animateToProgress` メソッド内を修正します。

`Tween`で動作範囲と動きを定義し、`unawaited`内でアニメーションを実行します。

`Tween`は、アニメーションがどの値からどの値まで変化するかを定義します。ここでは、現在の進捗値（`animatedProgress`）から最終的な目標の進捗値（`progress`）まで変化するよう設定しています。
`.animate()`は、生成した`Tween`を`AnimationController`に紐づけ、アニメーションの動きのパターンを適用しています。`progressController`を時間軸として使用し、`Curves.easeOutCubic`というカーブ（緩急）を適用しています。これにより、アニメーションが滑らかに加速してから徐々に減速し、自然な動きで目標値に到達します。

`progressController!.reset()`は、コントローラーの値を`0.0`にリセットする命令です。新しいアニメーションを開始する前に、前の状態をクリアしています。
`unawaited()` にコントローラーの`forward()` メソッドの呼び出しを指定し、アニメーションを実行しています。

修正前は動きの定義と実行それぞれコメントアウトされています。

**修正前**
```dart
// ステップ2: 進捗に合わせた終了値を指定し開始
// progressAnimation =
//     Tween<double>(
//       begin: animatedProgress, 
//       end: progress,
//     ).animate(
//       CurvedAnimation(
//         parent: progressController!,
//         curve: Curves.easeOutCubic,
//       ),
//     );

// progressController!.reset();
// unawaited(progressController!.forward());
```

緩急のある動きを定義し、非同期でアニメーションの実行を指示します。

**修正後**
```dart
// ステップ2: 進捗に合わせた終了値を指定し開始
progressAnimation =
    Tween<double>(
      begin: animatedProgress,
      end: progress,
    ).animate(
      CurvedAnimation(
        parent: progressController!,
        curve: Curves.easeOutCubic,
      ),
    );

progressController!.reset();
unawaited(progressController!.forward());
```

- ステップ1からステップ2までの完成例（再掲）  
  <img width="300" alt="進捗円グラフ" src="./images/hands-on_DonutChart_1.png" />



### ステップ3: 完読時には専用メッセージ表示
- ステップ3の完成例  
  <img width="300" alt="進捗円グラフに完読メッセージ" src="./images/hands-on_DonutChart_2.png" />

完読時は円グラフの中央にお祝いメッセージが表示されるように修正します。表示するウィジェットを切り替える際にトランジションアニメーションを適用するように`AnimatedSwitcher`を利用します。

`AnimatedSwitcher`は次の引数を利用します。
- `duration`: トランジションアニメーションの適用時間のミリ秒を指定します。
- `child`:`AnimatedSwitcher`が監視するウィジェットです。このウィジェットの`key` に渡している値に変化があった場合は「ウィジェットが切り替わった」と判断してアニメーションをトリガーします。今回は完読したかの真偽値がキーです。
- `child`: 表示メッセージを条件演算子を使って切り替えてます。完読の場合は「完読達成！」メッセージを表示するウィジェットが採用されます。

**作業対象**
```
lib/src/presentation/ui_widget/challenge/reading_graph/components/donut_chart_center_content.dart

lib
├── src
│   ├── app
│   ├── application
│   ├── domain
│   ├── fundamental
│   ├── infrastructure
│   ├── presentation
│   │   ├── ui_widget
│   │   │   ├── challenge
│   │   │   │   ├── reading_graph
│   │   │   │   │   ├── components
│   │   │   │   │   │   ├── donut_chart_center_content.dart  // これが対象
│   │   │   │   │   │   ├── その他ウィジェット
│   │   │   │   │   └── reading_book_graph_widget.dart
```

作業前の時点では仮の実装があります。ここでは残ページ数を表示するウィジェットを指定しています。

**修正前**
```dart
// ステップ3: 完読時には専用メッセージ表示
// return AnimatedSwitcher(
//   duration: const Duration(milliseconds: 600),
//   child: Container(
//     key: ValueKey<bool>(isCompleted),
//     padding: const EdgeInsets.all(16),
//     child: isCompleted
//         ? const CompletionContent()
//         : ProgressContent(remainingPages: remainingPages),
//   ),
// );
return Container(
  key: ValueKey<bool>(isCompleted),
  padding: const EdgeInsets.all(16),
  child: ProgressContent(remainingPages: remainingPages),
);
```

完読時には残ページ数ではなく専用メッセージを表示するように`AnimatedSwitcher`で切り替えます。
`isCompleted`の値は円グラフが1周すると`true`に変わります。その時に、自動的に表示内容が「残り〇ページ」を示す`ProgressContent`から、「完読達成！」を示す`CompletionContent`へと切り替わります。変化は600ミリ秒かけてトランジションアニメーションを適用します。

**修正後**
```dart
// ステップ3: 完読時には専用メッセージ表示
return AnimatedSwitcher(
  duration: const Duration(milliseconds: 600),
  child: Container(
    key: ValueKey<bool>(isCompleted),
    padding: const EdgeInsets.all(16),
    child: isCompleted
        ? const CompletionContent()
        : ProgressContent(remainingPages: remainingPages),
  ),
);
```

- ステップ3の完成例（再掲）  
  <img width="300" alt="進捗円グラフに完読メッセージ" src="./images/hands-on_DonutChart_2.png" />


#### まとめ
アニメーションの遅延実行やトランジションアニメーションを適用したウィジェット切り替えを学習しました。これらの技術を通じて、単なる静的なUIではなく、ユーザーの操作に自然に応答する動的なUIを構築できます。


### 完成させたカスタムUI の機能要件表現を確認する。
ハンズオンお疲れ様でした。これでカスタムUIの虫食い実装は完了です。作成したカスタムUIの要件について改めて確認します。

- 進捗応援アニメーション
  - 読書進捗に応じた応援アニメーションを書籍一覧ページに重ねて表示する。
  - アニメーションは複数組み合わせ、読書の達成感や継続するためのモチベーションの向上を目指す。
- 読書進捗グラフ
  - 本の総ページ数に対する現在の進捗や残りページ数を視覚的に表現する。
  - 瞬間的な表示ではなく、徐々に描画することで進捗の積み重ねの視覚的表現を強化し、努力の肯定感を高める。

シンプルなUIでも機能は満たせますが、アニメーションを実装することで、ユーザーへの印象づけや動機づけなど、体験の向上ができます。


----------

## 完成版カスタムUI と比較しよう。

Android Studio などの IDEを使っている方は、`lib/src/presentation/ui_widget/challenge/`ディレクトリと  
`lib/src/presentation/ui_widget/complete/`ディレクトリを選択してから、マウス右クリックを行って、  
ポップアップメニューから **compare Directories** を選択して両者を比較してみてください。 

- _ハンズオンでの作業がうまく行っていれば、目立った違いが出ていないと思います。_
- _ここで食い違いが見つかりましたら、challengeディレクトリのカスタムUIコードを修正してください。_

### complete バレルファイルを有効にする。

完成版カスタムUIのコードファイルは、
`lib/src/presentation/ui_widget/complete/`ディレクトリに配置されているので、  
**completeディレクトリのバレルファイル(`lib/src/presentation/ui_widget/complete/widget_packages.dart`)** が有効になるよう、  
**UIウィジェット・パッケージ全体のバレルファイル** を修正します。

UIウィジェット・パッケージ全体のバレルファイル [lib/src/presentation/ui_widget/widget_packages.dart](../lib/src/presentation/ui_widget/widget_packages.dart) を開いて、  
デフォルト設定(`complete/widget_packages.dart`)の export 行のコメントアウトのみを外して、  
他の export 行をコメントアウトしてください。

```dart
// UI Widget として各ページごとの任意のパッケージをインポートできるようにするバレルパッケージです。

// デフォルト設定 （ui_widget/default）
// export 'default/widget_packages.dart';

// 完成形設定 （ui_widget/complete）
export 'complete/widget_packages.dart';

// ハンズオン設定 （ui_widget/challenge）
// export 'challenge/widget_packages.dart';
```

### 完成版カスタムUI の機能要件表現を確認する。

ui_widget/completeディレクトリ配下の 完成形カスタムUIのコードを参照させるようにしたので、  
**①[ベースUI を使った機能要件表現を確認する](#%E3%83%99%E3%83%BC%E3%82%B9ui-%E3%82%92%E4%BD%BF%E3%81%A3%E3%81%9F%E6%A9%9F%E8%83%BD%E8%A6%81%E4%BB%B6%E8%A1%A8%E7%8F%BE%E3%82%92%E7%A2%BA%E8%AA%8D%E3%81%99%E3%82%8B)** 章の
**読了したページの更新に伴う進捗率達成メッセージを表示する。** と  
**読了したページの進捗をグラフで表示する。** での操作を参考に、完成形カスタムUIでのデザインやアニメーション表現を確認してください。

- _①リンクURLが「ベースUIを使った機能要件表現を確認する」ベースになるため、右クリックして別ウィンドウでお開きください。_
- _アニメーション表現は、読了したページ数が 規定の進捗率（10%, 50%, 80%, 100%）に初めて達したときに変化しますので、  
  機能要件表現を確認をされる際は、これら規定の進捗率を考慮しながら読了ページを更新してみてください。_

### 完成版カスタムUI コードを確認する。

#### 完成形カスタムUIコードに関連するファイル構成
```text
lib
└── src
    ├── presentation
    │   ├── ui_widget（各UIウィジェットは、状態種別や状態値更新と連動するため providerオブジェクトをバインドします）
    │   │   ├── complete
    │   │   │   ├── home
    │   │   │   │   ├── components
    │   │   │   │   │   └── progress                             読書中書籍進捗表示のUIコンポーネントを定義
    │   │   │   │   ├── currently_tasks_widget.dart              読書中書籍一覧表示のUIウィジェット　　　（defaultと同実装）
    │   │   │   │   ├── reading_progress_animations_widget.dart  読書中書籍進捗表示のUIウィジェット　　　（completeカスタム）
    │   │   │   │   └── reading_support_animations_widget.dart   激励一喝表示のUIウィジェット　　　　　　（defaultと同実装）
    │   │   │   ├── reading
    │   │   │   │   └── reading_book_widget.dart                 読書中書籍編集表示のUIウィジェット　　　（defaultと同実装）
    │   │   │   ├── reading_graph
    │   │   │   │   ├── components                               読書中書籍進捗グラフ表示のUIコンポーネントを定義
    │   │   │   │   └── reading_book_graph_widget.dart           読書中書籍進捗グラフ表示のUIウィジェット（completeカスタム）
    │   │   │   ├── settings
    │   │   │   │   └── reading_book_settings_widget.dart        設定表示のUIウィジェット　　　　　　　　（defaultと同実装）
    │   │   │   └── widget_packages.dart                        （completeディレクトリ用のバレルファイル）
    │   │   └── widget_packages.dart                            （UIウィジェット全体統括のバレルファイル）
```

#### 完成形カスタムUI コード
- **完成形カスタムUIコード**
  - **home（書籍一覧画面のUI表示）**
    - [reading_progress_animations_widget.dart](../lib/src/presentation/ui_widget/complete/home/reading_progress_animations_widget.dart)  
      読書中書籍進捗表示のUIウィジェット

  - **reading_graph（書籍進捗率グラフ画面のUI表示）**
    - [reading_book_graph_widget.dart](../lib/src/presentation/ui_widget/complete/reading_graph/reading_book_graph_widget.dart)  
      読書中書籍進捗グラフ表示のUIウィジェット

- **UIウィジェット - バレルファイル**
  - **UIウィジェット全体統括用**  
    [widget_packages.dart](../lib/src/presentation/ui_widget/widget_packages.dart)

    - **completeディレクトリ用**  
      [widget_packages.dart](../lib/src/presentation/ui_widget/complete/widget_packages.dart)

- **【補足】完成形カスタムUIの機能要件実装設計ガイド**  
  _よろしければ、カスタムUI実装設計時のキーポイント説明も御参照ください。_  
  - **読書中書籍進捗グラフ表示**  
    [インタラクティブドーナツチャート実装ガイド](./ui_widget/interactive_donut_chart_guide.md)

----------

## 宿題

**読了したページの更新に伴う進捗率達成メッセージ** や **読了したページの進捗のグラフ表示** のカスタムUIがあるのに、  
**激励や一喝のメッセージ** はどこに行ったのだろうと思われているのではないでしょうか。

この機能要件については、ハンズオンチームでのカスタムUI実装をしていないので、  
これは、ハンズオンに参加してくださったみなさまへの宿題とさせていただきます。

----------

## お疲れ様でした。

----------
