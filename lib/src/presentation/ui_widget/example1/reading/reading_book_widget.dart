import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../domain/model/reading_books_domain_model.dart';
import '../../../../fundamental/debug/debug_logger.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../../model/view_model_packages.dart';

class ReadingBookWidget
    extends ConsumerStagedWidget<ReadingBookValueObject, ReadingBookState> {
  /// コンストラクタ
  ///
  /// - [provider] : 引数の Riverpod ref を使って状態値を取得する関数。
  ///
  /// - [builders] : （オプション）[buildList]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッド一覧を返す関数。
  ///
  /// - [selectBuilder] : （オプション）[selectBuild]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッドを返す関数。
  const ReadingBookWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  ReadingBookState? createWidgetState() {
    return ReadingBookState();
  }

  @override
  // ignore: unnecessary_overrides
  void initState(ReadingBookState? state) {
    super.initState(state);
  }

  @override
  void disposeState(ReadingBookState? state) {
    if (state != null) {
      state.nameController.dispose();
      state.totalPagesController.dispose();
      state.readingPageNumController.dispose();
      state.bookReviewController.dispose();
      state.formKey.currentState?.reset();
    }
    super.disposeState(state);
  }

  void _submitForm(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBooksViewModel readingBooksViewModel,
    SupportAnimationsViewModel supportAnimationsViewModel,
    ReadingBookState state,
  ) {
    if (state.formKey.currentState!.validate()) {
      state.formKey.currentState!.save();

      final String name = state.nameController.text;
      final int totalPages = int.tryParse(state.totalPagesController.text) ?? 0;
      final int readingPageNum =
          int.tryParse(state.readingPageNumController.text) ?? 0;
      final String bookReview = state.bookReviewController.text;
      final int prevReadingPageNum =
          readingBooksViewModel.editedReadingBook?.readingPageNum ?? 0;

      // 書籍情報を更新
      final ReadingBookValueObject editedReadingBook = readingBooksViewModel
          .updateReadingBook(
            name: name,
            totalPages: totalPages,
            readingPageNum: readingPageNum,
            bookReview: bookReview,
          );
      readingBooksViewModel.commitReadingBook(editedReadingBook);

      // 読書進捗率に変化があれば、アニメーションを表示させます。
      supportAnimationsViewModel.updateAnimationTypeIfProgressChange(
        updatedBook: editedReadingBook,
        prevReadingPageNum: prevReadingPageNum,
      );

      Navigator.pop(context, editedReadingBook); // 結果を前の画面に返す
    }
  }

  Future<void> _deleteBook(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBooksViewModel readingBooksViewModel,
  ) async {
    final bool? isConfirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('書籍の削除'),
          content: Text('「${readingBook.name}」を本当に削除しますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('削除'),
              onPressed: () {
                readingBooksViewModel.removeReadingBook();
                readingBooksViewModel.commitReadingBook(readingBook);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (isConfirmDelete ?? false) {
      if (context.mounted) {
        debugLog('Deleting book: ${readingBook.name}');
        Navigator.pop(context, readingBook);
      }
    }
  }

  TextFormField _buildNameField(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBookState state,
  ) {
    state.nameController.text = readingBook.name;

    return TextFormField(
      controller: state.nameController,
      decoration: const InputDecoration(
        labelText: '書籍タイトル',
        border: OutlineInputBorder(),
        hintText: '例: Flutter実践入門',
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return '書籍タイトルを入力してください';
        }
        return null;
      },
    );
  }

  TextFormField _buildTotalPagesField(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBookState state,
  ) {
    state.totalPagesController.text = readingBook.totalPages.toString();

    return TextFormField(
      controller: state.totalPagesController,
      decoration: const InputDecoration(
        labelText: '書籍総ページ数',
        border: OutlineInputBorder(),
        hintText: '例: 300',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return '総ページ数を入力してください';
        }
        final int? pages = int.tryParse(value);
        if (pages == null || pages <= 0) {
          return '有効なページ数を入力してください';
        }
        return null;
      },
    );
  }

  TextFormField _buildReadingPageNumField(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBookState state,
  ) {
    state.readingPageNumController.text = readingBook.readingPageNum.toString();

    return TextFormField(
      controller: state.readingPageNumController,
      decoration: const InputDecoration(
        labelText: '読書中のページ番号（読書完了ページ数）',
        border: OutlineInputBorder(),
        hintText: '例: 150',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          // 読書開始前は0ページでも許容する場合もあるが、ここでは入力必須とする
          return '読書中のページ番号を入力してください';
        }
        final int? currentPage = int.tryParse(value);
        if (currentPage == null || currentPage < 0) {
          return '有効なページ番号を入力してください';
        }
        final int? totalPages = int.tryParse(state.totalPagesController.text);
        if (totalPages != null && currentPage > totalPages) {
          return '総ページ数を超えることはできません';
        }
        return null;
      },
    );
  }

  TextFormField _buildBookReviewField(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBookState state,
  ) {
    state.bookReviewController.text = readingBook.bookReview;

    return TextFormField(
      controller: state.bookReviewController,
      decoration: const InputDecoration(
        labelText: '書籍感想',
        border: OutlineInputBorder(),
        alignLabelWithHint: true, // 複数行の場合にラベルを上部に合わせる
        hintText: '読書後の感想やメモを自由に入力してください',
      ),
      maxLines: 3,
      // 感想は任意入力とするためバリデーションはなし
    );
  }

  SizedBox _smallSpacer() => const SizedBox(height: 12);

  SizedBox _middleSpacer() => const SizedBox(height: 16);

  SizedBox _largeSpacer() => const SizedBox(height: 24);

  TextStyle _middleTextStyle() => const TextStyle(fontSize: 16);

  EdgeInsets _middleEdgeInsetsAll() => const EdgeInsets.all(16);

  EdgeInsets _smallEdgeInsetsSymmetric() =>
      const EdgeInsets.symmetric(vertical: 12);

  EdgeInsets _middleEdgeInsetsSymmetric() =>
      const EdgeInsets.symmetric(vertical: 16);

  //
  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ReadingBookValueObject value,
    ReadingBookState? state,
  ) {
    final ReadingBookState controllers = state!;
    final ReadingBooksViewModel readingBookVm = ref.read(
      readingBooksProvider.notifier,
    );
    final SupportAnimationsViewModel supportAnimeVm = ref.read(
      supportAnimationsProvider.notifier,
    );

    // --- プレビュー用のメソッド ---
    Future<void> showPreview() async {
      final OverlayState overlay = Overlay.of(context);
      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => entry.remove(),
            child: Material(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: AspectRatio(
                    aspectRatio: 1.4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                controllers.bookReviewController.text.isEmpty
                                    ? '（ここに感想やメモが表示されます）'
                                    : controllers.bookReviewController.text,
                                style: const TextStyle(
                                  fontFamily: 'NotoSerifJP',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const VerticalDivider(width: 32),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      '右ページサンプルテキスト...' * 5,
                                      style: const TextStyle(
                                        fontFamily: 'NotoSerifJP',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  // ignore: lines_longer_than_80_chars
                                  '${int.tryParse(controllers.readingPageNumController.text) ?? 0 + 1}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      overlay.insert(entry);
    }

    return Padding(
      padding: _middleEdgeInsetsAll(),
      child: SingleChildScrollView(
        child: Form(
          key: controllers.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildNameField(context, value, controllers),
              _middleSpacer(),
              _buildTotalPagesField(context, value, controllers),
              _middleSpacer(),
              _buildReadingPageNumField(context, value, controllers),
              _middleSpacer(),
              _buildBookReviewField(context, value, controllers),
              _largeSpacer(),

              // 追加: プレビューボタン
              ElevatedButton.icon(
                icon: const Icon(Icons.preview),
                label: const Text('読書ページをプレビュー'),
                onPressed: showPreview,
              ),

              _largeSpacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: _middleEdgeInsetsSymmetric(),
                  textStyle: _middleTextStyle(),
                ),
                onPressed: () => _submitForm(
                  context,
                  value,
                  readingBookVm,
                  supportAnimeVm,
                  controllers,
                ),
                child: Text(
                  readingBookVm.currentEditMode == ReadingBookEditMode.create
                      ? '登録する'
                      : '編集する',
                ),
              ),
              if (readingBookVm.currentEditMode ==
                  ReadingBookEditMode.edit) ...<Widget>[
                _smallSpacer(),
                ElevatedButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: _smallEdgeInsetsSymmetric(),
                    textStyle: _middleTextStyle(),
                  ),
                  onPressed: () => _deleteBook(context, value, readingBookVm),
                  child: const Text('この書籍を削除する'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ReadingBookState {
  ReadingBookState();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
  final TextEditingController readingPageNumController =
      TextEditingController();
  final TextEditingController bookReviewController = TextEditingController();
}
