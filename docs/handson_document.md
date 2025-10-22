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
アニメーションの遅延実行やトランジションアニメーションを適用したウィジェット切り替えを学習しました。これらの技術を通じて、単なる静的なUIではなく、ユーザーの操作に自然に応答する動的なUIを構築することができます。


### 完成させたカスタムUI の機能要件表現を確認する。
ハンズオンお疲れ様でした。これでカスタムUIの虫食い実装は完了です。作成したカスタムUIの要件について改めて確認します。

- 進捗応援アニメーション
  - 読書進捗に応じた応援アニメーションを書籍一覧ページに重ねて表示する。
  - アニメーションは複数組み合わせ、読書の達成感や継続するためのモチベーションの向上を目指す。
- 読書進捗グラフ
  - 本の総ページ数に対する現在の進捗や残りページ数を視覚的に表現する。
  - 瞬間的な表示ではなく、徐々に描画することで進捗の積み重ねの視覚的表現を強化し、努力の肯定感を高める。

シンプルなUIでも機能は満たせますが、アニメーションを実装することで、ユーザーへの印象づけや動機づけなど、体験を向上させることができます。


### ベースUIと カスタムUI のコードを比較してみる。
構造が違いすぎるので不要

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
