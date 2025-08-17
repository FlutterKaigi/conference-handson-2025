# conference_handson_2025

## 機能要件

## 基本機能
状態構成要素を ドメインモデル、状態モデル、ViewModel、ValueObject に分割し、  
riverpod で状態値のグローバルアクセスおよび UI更新を行い、GoRouterで画面遷移させます。

## 開発環境前提
### 開発プラットフォーム OS
- ios/Android アプリをビルドする必要性から macOS を想定しています。

### 開発環境 IDE
- Gemini in Android Studio で Agent mode (preview) が使えるよう、  
  最新の Android Studio Narwhal Feature Drop の利用を想定しています。  
  - Android Studio Narwhal Feature Drop  
    https://developer.android.com/studio
  - Android Studio Narwhal Feature Drop | 2025.1.2  
    https://developer.android.com/studio/releases  
    https://developer.android.com/studio/releases#rules
  - ~~Android Studio Narwhal Feature Drop | 2025.1.3 Canary 3~~  
    ~~https://developer.android.com/studio/preview~~
  - Agent mode  
    https://developer.android.com/studio/gemini/agent-mode
  - Save and manage prompts with the Prompt Library  
    Share and manage project-level prompts  
    https://developer.android.com/studio/gemini/prompt-library#share-project-prompts  
    プロジェクトレベルのプロンプトを共有するため、`.idea/project.prompts.xml` を git登録しています。

- 最新の Xcode の利用を想定しています。  
  _Version 16.2_

### Flutter/Dart バージョン
- Flutter stable 3.32.8
    - Channel stable
- Dart stable 3.9.0
    - Dart SDK version: 3.35.1 (stable)  
- DevTools 2.48.0

### fvm
このプロジェクトでは、Flutter SDK バージョンを統一するため `fvm` を利用しています。
- fvm 3.2.1  
　https://pub.dev/packages/fvm

プロジェクトリポジトリには、SDK 3.32.8 を指定した `.fvmrc` が配置されているので、
プロジェクトのルートディレクトリで、`fvm use`を実行すれば SDK がインストールされ、
fvm コマンドで Flutter SDK 3.32.8 が利用できるようになります。

fvm をインストールされていない方は、下記のツールのインストールを実行しておいてください。
- fvm ツールのインストールコマンド（Linux/macOS）
```bash
curl -fsSL https://fvm.app/install.sh | bash
```

### Makefile
このプロジェクトでは、アプリの実行やコード生成をコンソールで行えるよう `Makefile`を利用しています。  
初めにプロジェクトのルートで `make setup`を実行して、コード生成など開発環境の初期設定を行ってください。

また `make run`でデバッグ版アプリのビルドと実行ができるようになっています。

この他にもコマンドがありますが、 flutter コマンドを fvm を介して実行させているだけなので、  
プロジェクトのルートにある `Makefile`の中を見ていただければ、
どんなコマンドで何ができるのかすぐに理解できると思います。

`make`コマンドは、macOS であれば標準で組み込まれているのでインストールする必要はありません。

### Android Studio 設定
プロジェクトへの fvm 設定が終わり、プロジェクトで使う Flutter/Dart バージョンが定まったら、    
Android Studio の Flutter/Dart 関連の設定を行います。

1. Android SDK 設定（利用する Android SDK を指定します）  
   Settings > Languages & Frameworks > Android SDK > Android SDK location:  
   （Android SDK インストール先のパスを指定）例 ⇒ /Users/rie/android/sdk

2. Dart SDK 設定  
   Settings > Languages & Frameworks > Dart > Dart SDK path:（Dart SDK インストール先）  
   ⇒ プロジェクトの .fvm/flutter_sdk/bin/cache/dart-sdk① になります。  
   Android Studio は絶対パス指定を要求するので具体的な①パスは、以下の ①のようにになることと、  
   設定後はシンボリックリンクの実態先② に変わることに注意してください。
- ①/Users/rie/yumemi/code_check/search_repositories_on_github/.fvm/flutter_sdk/bin/cache/dart-sdk
- ②/Users/rie/fvm/versions/3.27.3/bin/cache/dart-sdk

3. Flutter SDK 設定  
   Settings > Languages & Frameworks > Flutter > SDK (current project only) >  
   Flutter SDK path: （Flutter SDK インストール先）  
   ⇒ プロジェクトの .fvm/flutter_sdk/bin/cache/dart-sdk① になります。  
   Android Studio は絶対パス指定を要求するので具体的な①パスは、以下の ①のようにになることと、  
   設定後はシンボリックリンクの実態先② に変わることに注意してください。
- ①/Users/rie/yumemi/code_check/search_repositories_on_github/.fvm/flutter_sdk
- ②/Users/rie/fvm/versions/3.27.3

4. Dart フォーマット設定  
   フォーマット桁数を Flutter lint 想定に合わせるため 80桁に指定してください。
- Settings > Editor > Code Style > Dart > Editor > Line length [80]  
  （dart format に合わせたフォーマット桁数）

5. Flutter フォーマット設定  
   ファイルセーブごとにインポートの修正とフォーマットを適用するため以下の設定を行ってください。
- Settings > Languages & Frameworks > Flutter > Editor > [v] Format code on save
- Settings > Languages & Frameworks > Flutter > Editor > [v] Organize imports on save

**補足 Format 関係の設定について**  
Flutter lint は、analysis_options.yaml に設定されたルールに従いますが、  
このルールは、dart format コマンドでフォーマットされたコードを想定しており、  
現在の dart format コマンドは、フォーマット桁数を 80 に限定しているため 80桁に指定します。  
将来の Dart 3.7 からは、analysis_options.yaml に format: セクションが追加され、  
フォーマット桁数の指定ができるようになります。


### Gemini CLI 設定
Flutter 3.35 / Dart 3.9 から、`Dart and MCP Server` が利用できるようになりました。  
`Dart and Flutter MCP Server`、Dartと Flutterの開発ツールのアクションを AIアシスタントクライアントに公開します。  
そこでプロジェクトで `Gemini CLI`から `Dart and Flutter MCP Server`を使って開発アシストができるようにします。

- Flutter のバージョンを 3.35 以上にする。  
  プロジェクト内の .fvmrc 設定を 3.55 以上に更新しています。
```json
{
  "flutter": "3.35.1"
}

```

- Gemini CLI 最新バージョンのインストール（および更新）は、  
  npx や npm ツールが使えるのであれば、以下の何れかのコマンドでできます。  
  `$ npx @google/gemini-cli`   
  `$ npm install -g @google/gemini-cli@latest`

- ローカルプロジェクト内で `Dart and Flutter MCP Server` + `Gemini CLI` を利用するには、  
  プロジェクト内の `.gemini/settings.json` ファイルに Dart and Flutter MCP サーバーを追加しています。
```json
{
  "mcpServers": {
    "dart": {
      "command": "dart",
      "args": [
        "mcp-server",
        "--experimental-mcp-server"
      ]
    }
  }
}

```


**参考資料**  

- Dart and Flutter MCP サーバー
    - [Dart and Flutter MCP server](https://dart.dev/tools/mcp-server)  
      [https://dart.dev/tools/mcp-server](https://dart.dev/tools/mcp-server)

- Gemini CLI インストール
    - [Quick Install](https://github.com/google-gemini/gemini-cli/tree/main?tab=readme-ov-file#quick-install)  
      [https://github.com/google-gemini/gemini-cli/tree/main?tab=readme-ov-file#quick-install](https://github.com/google-gemini/gemini-cli/tree/main?tab=readme-ov-file#quick-install)

- Gemini CLI で Dart and Flutter MCP サーバを利用する設定
    - [MCP servers with the Gemini CLI - How to set up your MCP server](https://github.com/google-gemini/gemini-cli/blob/main/docs/tools/mcp-server.md#how-to-set-up-your-mcp-server)  
      [https://github.com/google-gemini/gemini-cli/blob/main/docs/tools/mcp-server.md#how-to-set-up-your-mcp-server](https://github.com/google-gemini/gemini-cli/blob/main/docs/tools/mcp-server.md#how-to-set-up-your-mcp-server)


## プロジェクトリポジトリの設定について
- デフォルトブランチは、`develop`となっています。

### Issues テンプレートの設定

### Pull Reauest テンプレートの設定

### dependabot 設定

### GitHub Actions 設定

## アプリの特徴について

### 国際化対応

### Dark Theme 対応
MaterialApp プロパティの theme /darkTheme 用の Theme を設定し、  
プラットフォームシステムでの Light / Dark モード切り替えに視覚的に対応しました。

### Lint 制約強化
このプロジェクトでは、FlutterKaigi 2024 公式アプリの `analysis_options.yaml`をベースに、独自のルールを適用しています。

### 宣言型画面遷移対応
画面遷移に go_router の Type-safe Route を利用しています。

### アプリケーションレベルのエラーハンドリング対応

### ユースケースレベルのエラーダイアログ対応

### ユニットテスト
test/ディレクトリ配下にユニットテストを追加しています。  
また `make unit-test`でユニットテストを実行できるようにもしています。

## アプリの設計について

### レイヤ構成による依存関係の分離

## その他の対応

## アプリ画像

## 要件定義書
- [`docs/requirements.md`](./docs/requirements.md)  
  [要件定義書](./docs/requirements.md)