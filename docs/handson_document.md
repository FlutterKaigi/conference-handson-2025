# FlutterKaigi 2025 ハンズオン・ドキュメント

現時点のドキュメントは、作りかけです。
----------

## はじめに
FlutterKaigi 2025 ハンズオンのメインテーマは、 **「魅力のある UIを作る」** です。  
アプリの魅力を上げるため、UI にアニメーションやデコレーションを追加する基礎知識を学んでもらうことになりました。  

そしてこのハンズオンでは、単なる UI Widget カタログにならないよう、アプリ開発を模した体験になるよう、  
単純で飾り気のないベース模擬アプリに、デコレーションやアニメーションを追加していくという、  
**「ベースUIと カスタムUIのコードや見栄えの比較ができる」** ことをサブテーマとしています。

これにより、アイテムの状態や状態変更に応じたアクションを返してはくれますが、
単純で飾り気のない模擬アプリの **ベースUIコード** を残したまま、  
デコレーションやアニメーションを盛り込んだ **カスタムUIコード** を併設追加＆切替可能にすることで、  
コードやアプリ表現力向上の比較と これらの違いを学んでもらう趣向となっております。  

- _読了ページ更新と進捗グラフ（ベース表現） ⇒ アニメーション＋デコレーション表現例_
  <img width="800" alt="読了ページと進捗グラフ" src="./images/hands-on_sample_1.png" />

- 読了ページ更新の進捗達成リアクション表現（ベース表現） ⇒ アニメーション＋デコレーション表現例  
  <img width="800" alt="読了ページ進捗達成のリアクション" src="./images/hands-on_sample_2.png" />


----------

## アプリ構想

アプリのコンセプトは、**読書支援** としました。

コンセプトのシチュエーションに従って `読書支援したい書籍の追加` や `読書中書籍の一覧表示` に、  
`読了ページの更新とそのタイミングでの進捗達成報告` や `読書進捗状況のグラフ表示`、  
さらにできればアラーム設定など `何らかのタイミングでの叱咤激励` ができる **模擬アプリ** とします。

これを行うには、`読書中書籍の一覧表示`や`タップした書籍の選択`ができる **ホーム画面（HomePage）** と、
`管理したい書籍の追加など`を行う **設定画面（SettingsPage）** や、
`選択された書籍の情報を更新`する **書籍編集画面（ReadingBookPage）** に、
`読了したページの進捗を可視化`する **グラフ表示画面（ReadingBookGraphPage）** を設け、
`読書進捗率の達成ごとにメッセージをオーバラップ表示`させる、**アニメーション機能** を盛り込むことで、

単なるウィジェット・カタログにならないよう、ハンズオンに参加してくださるみなさんが実施に触ってみて、
リアルタイムでカスタム UIが表示され、読了ページの更新に伴ったリアクションや画面遷移ができることを目指します。

とはいえ実際に書籍情報を DBに永続化させたり、イベント管理のためにタイマーやバックグラウンドサービスを導入...すると、 
コードやロジックが複雑になり、目的である `シンプルなベースUIコードとリッチなカスタムUIコードとの対比` の妨げになりますから、
**導入するプラグインは、基本的な状態管理や画面遷移に留める** ことにいたしました。

----------

## 模擬アプリとしてのハンズオン・プロジェクト

1. 実装詳細を理解してもらうためコード生成を使わない。  
2. 画面遷移に `go_router`、状態管理に `riverpod` を使い、不変状態値には `freezed を使わない愚直実装` を行う。  
3. 読書管理する書籍の新規追加や情報編集と削除の Unit test と Widget test を利用した簡易結合テストを実装する。  
4. 模擬アプリのため、読書中書籍情報の永続化やアラームは利用しない。このため擬似的に挙動を起こすようにする。  

### システム設計

### アーキテクチャ設計

### フィーチャー設計

----------

## ベースUI とカスタムUI のコードや見栄えの比較ができる工夫

### ConsumerStagedWidget

### バレルファイル

----------

## ハンズオン開発環境を作ろう。

### ハンズオン環境構築

----------

## ベースUI を見てみよう。

### default バレルファイルを有効にする。

### ベースUI を使った機能要件表現を確認する

### ベースUI コードを確認する。

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

// デフォルト設定 （ui_widget）
// export 'default/widget_packages.dart';

// 各UIパッケージ 設定 （ui_widget）
// export 'hero/widget_packages.dart'; // model設置はありません。（model/default を利用します）
// export 'interactive_donut_chart/widget_packages.dart'; // model設置はありません。（model/default を利用します）
// export 'morphing_button/widget_packages.dart'; // model設置はありません。（model/default を利用します）
// export 'enhanced_progress/widget_packages.dart'; // model設置はありません。（model/default を利用します）

// 完成形設定 （ui_widget）
// export 'complete/widget_packages.dart'; // model設置はありません。（model/default を利用します）

// ハンズオン設定 （ui_widget）
export 'challenge/widget_packages.dart'; // model設置はありません。（model/default を利用します）
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
アニメーションを実現するための「再生時間」と「動き」の設定を用意します。このステップでは二つのオブジェクトを用意します。

`AnimationController` はアニメーションの再生時間（`duration`）を制御する役割を担います。コンストラクタでは以下の設定をしています。

- `duration`: アニメーションの再生時間を指定します。`Duration`クラスを使って時間を指定します。
- `vsync`: アニメーションを画面のリフレッシュレートと同期させるための引数です。これにより、アニメーションがカクつかずに、非常に滑らかに見えます。

`Animation` は`AnimationController`の進行度を、具体的な動きのパターンに変換します。ここで使用する`CurvedAnimation`はアニメーションの進行に緩急をつけ滑らかな動きにすることができます。コンストラクタでは以下の設定をしています。

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


### 複数アニメーションを連動させる


### 遅延実行とトランジションで滑らかな表現をする


### 完成させたカスタムUI の機能要件表現を確認する。

### ベースUIと カスタムUI のコードを比較してみる。

----------

## 完成版カスタムUI と比較しよう。

### complete バレルファイルを有効にする。

### 完成版カスタムUI の機能要件表現を確認する。

### 完成版カスタムUI コードを確認する。

----------

## 宿題

----------

## お疲れ様でした。

----------
