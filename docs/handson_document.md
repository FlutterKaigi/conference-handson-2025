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
- ステップ1からステップ3までの完成例
  <img width="300" alt="グラデーションのみ表示" src="./images/hands-on_DynamicBackground.png" />

ステップ1では、アニメーションを実現するための「再生時間」と「動き」の設定を用意します。このステップでは二つのオブジェクトを用意します。

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

`unawaited`により、_backgroundControllerが制御する背景グラデーションのアニメーションを開始します。

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

コメントの解除で波紋アニメーションを配置します。`Stack`を使うことでウィジェットを重ねて表示することができます。

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
