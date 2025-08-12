# Agent 指示プロンプト・メモ

## 主要３画面のコード生成について
読書支援アプリの主要３画面
[HomePage](../lib/src/app/screen/home/home_page.dart),
[SettingsPage](../lib/src/app/screen/settings/settings_page.dart),
[ReadingBookPage](../lib/src/app/screen/reading/reading_book_page.dart) は、  
**Gemini in Android Studio** の **Agent mode (preview)** を使ってベースコードを作成しました。  

- **Gemini in Android Studio - Agent mode**  
  https://developer.android.com/studio/gemini/agent-mode

- _主要３画面のベースコードを生成させたプロンプトについては、以降の`生成プロンプト`を参照下さい。_  
  - **注意** 生成されたコードをそのまま利用したのではないことに留意下さい。  
    生成されたコードは、エンジニアによりコード解析および機能単位への抽象化を行い、  
    プレゼンテーション層の `UI Widget` や `ViewModel` にリライトの上で分割されています。


## 主要３画面（プロンプト生成コード）の手動リライトについて
プロンプトにより生成された主要３画面のベースコードは、`StatefulWidget` や `StatelessWidget` を継承し、  
`ListView.builder` や `ElevatedButton` および `Form` に `TextFormField` などのマテリアルウイジェットによる  
レイアウトとロジックのみで構成されていました。

また生成された読書中書籍の一覧を表示させる `CurrentlyTasksWidget` もまた `StatelessWidget` 派生で、  
コンストラクタ引数で `CurrentlyTasksViewModel` を直接受け取る実装になっており、  
この ViewModel が提供するコンテンツデータも `List<String>` の「書籍タイトル一覧」があるだけでした。

これらは、**コード生成プロンプトの要件設定が貧弱である**ことが要因でありますが、  
AI Agent の教本となるプロジェクトコードがない状況で、独自のアーキテクチャまで盛り込まれたコードが、  
一括生成できるようなプロンプトができたとしても、 自然言語による詳細な具象実装指導と変わらなくなるため、  
画面機能のみをコード生成させ、付帯部のコード実装や生成コードのリライトについては、手動で行ないました。

このため`読書中書籍の読書情報`を表す ValueObject として
[ReadingBookValueObject](../lib/src/presentation/model/reading/reading_book_value_object.dart) を手動作成し、  
コードファイル [lib/src/presentation/model/reading/reading_book_value_object.dart](../lib/src/presentation/model/reading/reading_book_value_object.dart) として追加して、

さらに`読書中書籍一覧`を管理する ViewModel として
[ReadingBooksViewModel](../lib/src/presentation/model/reading/reading_books_view_model.dart) も手動作成し、  
これらの ViewModel とValueObject が `riverpod - WidgetRef` を用いてグローバルに参照できるよう、  
`readingBooksProvider` ⇒ `riverpod - NotifierProvider` の手動作成および、
コードファイル [lib/src/presentation/model/reading/reading_books_view_model.dart](../lib/src/presentation/model/reading/reading_books_view_model.dart) の追加まで行っています。

これらにより `CurrentlyTasksWidget` は、[ConsumerStagedWidget](../lib/src/fundamental/ui_widget/consumer_staged_widget.dart) 派生にリライトされ、  
`HomePage` ウイジェットも `riverpod - ConsumerWidget` に手動リライトしています。

_`ホーム画面`だけでなく、読書中書籍情報の`設定画面`や`編集画面`もまた、  
`ViewModel` および `Provider関数` の手動作成および、`riverpod - ConsumerWidget` 対応に手動リライトしています。_


### **HomePage 画面ベースの生成プロンプト**
```text
ユーザに現在の読書進捗状況を伝え進捗を応援する HomePage 画面を作って下さい。
そして作成した HomePage 画面のコードは、lib/src/app/screen/home/home_page.dart ファイルに保管して下さい。

ただし画面は、以下の要件を満たして下さい。

- Scaffold をルート Widget として、AppBar に、SettingsHomePage を開く Action として「歯車アイコン 」があります。
- 画面ボディのルートウィジェットは、Stack ウイジェットになっています。
  - Stack ウィジェットの上層は、
    アニメーション表示用の SupportAnimationsWidget で、
    下層は、読書中書籍一覧の CurrentlyTasksWidget を表示します。
- CurrentlyTasksWidget は、読書中の書籍タイトルの一覧をスクロール表示します。
  - CurrentlyTasksWidget は、コンストラクタ引数として CurrentlyTasksViewModel オブジェクトを受け取ります。
  - CurrentlyTasksViewModel は、プロパティに表示コンテンツの読書中書籍一覧やスクロール位置を持っています。
- SupportAnimationsWidget は、コンストラクタ引数として、SupportAnimationsViewModel オブジェクトを受け取ります。
  - SupportAnimationsViewModel は、None, Cheer, Scolding 種別を持つ AnimationTypeEnum プロパティを持っています。
  - SupportAnimationsWidget は、SupportAnimationsViewModel の AnimationTypeEnum が、None のときは、Offstage を表示します。
```


### **SettingsPage 画面ベースの生成プロンプト**
```text
ユーザが読書進捗支援したい読書書籍を新規追加する SettingsPage 画面を作って下さい。
そして作成した SettingsPage 画面のコードは、lib/src/app/screen/settings/settings_page.dart ファイルに保管して下さい。

ただし画面は、以下の要件を満たして下さい。

- Scaffold をルート Widget とします。
- 画面ボディのルートウィジェットは、Column があり、書籍情報と読書進捗状況を入力する TextField ウイジェットと書籍進捗状況編集ボタンが並びます。
  - Column ウィジェットには、以下の順番で、読書書籍情報の TextField と読書書籍の新規追加ボタンが並びます。
    - 書籍タイトル TextField String name 
    - 書籍総ページ数 TextField int totalPage
    - 新規追加ボタン
```


### **ReadingBookPage 画面ベースの生成プロンプト**
```text
ユーザに読書進捗状況の新規作成と読書状況更新および読書書籍を削除する ReadingBookPage 画面を作って下さい。
そして作成した ReadingBookPage 画面のコードは、lib/src/app/screen/reading/reading_book_page.dart ファイルに保管して下さい。

ただし画面は、以下の要件を満たして下さい。

- Scaffold をルート Widget とします。
- 画面ボディのルートウィジェットは、Column があり、書籍情報と読書進捗状況を入力する TextField ウイジェットと書籍進捗状況編集ボタンが並びます。
  - Column ウィジェットには、以下の順番で TextField と編集ボタンが並びます。
    - 書籍タイトル TextField String name 
    - 書籍総ページ数 TextField int totalPage
    - 読書中のページ番号（読書完了ページ数）TextField int readingPageNum
    - 書籍感想 TextField String bookReview
    - 読書状況更新ボタン
    - 書籍削除ボタン
```


### **ベース要件**
