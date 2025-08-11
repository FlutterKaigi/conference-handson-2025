import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for FilteringTextInputFormatter
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../fundamental/debug/debug_logger.dart';
import '../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../model/reading/reading_book_value_object.dart';
import '../../model/reading/reading_books_view_model.dart';

class ReadingBookSettingsWidget
    extends
        ConsumerStagedWidget<ReadingBookValueObject, ReadingBookSettingsState> {
  /// コンストラクタ
  ///
  /// - [provider] : 引数の Riverpod ref を使って状態値を取得する関数。
  ///
  /// - [builders] : （オプション）[buildList]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッド一覧を返す関数。
  ///
  /// - [selectBuilder] : （オプション）[selectBuild]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッドを返す関数。
  const ReadingBookSettingsWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  ReadingBookSettingsState? createWidgetState() {
    return ReadingBookSettingsState();
  }

  @override
  // ignore: unnecessary_overrides
  void initState(ReadingBookSettingsState? state) {
    super.initState(state);
  }

  @override
  void disposeState(ReadingBookSettingsState? state) {
    if (state != null) {
      state.nameController.dispose();
      state.totalPagesController.dispose();
      state.formKey.currentState?.reset();
    }
    super.disposeState(state);
  }

  @override
  /// デバッグのため [selectBuilder] をオーバーライド
  ConsumerStagedBuild<ReadingBookValueObject, ReadingBookSettingsState>
  selectBuild(
    List<ConsumerStagedBuild<ReadingBookValueObject, ReadingBookSettingsState>>
    builders,
    ReadingBookValueObject value,
  ) {
    debugLog(
      'debug - ReadingBookSettingsWidget.selectBuild - name=${value.name}',
    );
    // （デフォルト）ビルド・メソッドのみ
    return builders[0];
  }

  void _submitForm(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBooksViewModel readingBooksViewModel,
    ReadingBookSettingsState state,
  ) {
    if (state.formKey.currentState!.validate()) {
      final String name = state.nameController.text;
      final int totalPages = int.tryParse(state.totalPagesController.text) ?? 0;

      final ReadingBookValueObject newBook = readingBooksViewModel
          .addReadingBook(name: name, totalPages: totalPages);
      readingBooksViewModel.commitReadingBook(newBook);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('書籍「${newBook.name}」を追加します。')));

      Navigator.pop(context, newBook); // 結果を前の画面に返す
    }
  }

  TextFormField _buildNameField(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBookSettingsState state,
  ) {
    return TextFormField(
      controller: state.nameController,
      decoration: const InputDecoration(
        labelText: '書籍タイトル',
        hintText: '例: Flutter実践入門',
        border: OutlineInputBorder(),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return '書籍タイトルを入力してください。';
        }
        return null;
      },
    );
  }

  TextFormField _buildTotalPagesField(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBookSettingsState state,
  ) {
    return TextFormField(
      controller: state.totalPagesController,
      decoration: const InputDecoration(
        labelText: '書籍総ページ数',
        hintText: '例: 300',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return '総ページ数を入力してください。';
        }
        final int? pages = int.tryParse(value);
        if (pages == null) {
          return '有効な数値を入力してください。';
        }
        if (pages <= 0) {
          return '総ページ数は1以上の数値を入力してください。';
        }
        return null;
      },
    );
  }

  SizedBox _middleSpacer() => const SizedBox(height: 16);

  SizedBox _largeSpacer() => const SizedBox(height: 24);

  TextStyle _middleTextStyle() => const TextStyle(fontSize: 16);

  EdgeInsets _middleEdgeInsetsAll() => const EdgeInsets.all(16);

  EdgeInsets _middleEdgeInsetsSymmetric() =>
      const EdgeInsets.symmetric(vertical: 16);

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ReadingBookValueObject value,
    ReadingBookSettingsState? state,
  ) {
    final ReadingBooksViewModel vm = ref.read(readingBooksProvider.notifier);
    final ReadingBookSettingsState controllers = state!;

    return Padding(
      padding: _middleEdgeInsetsAll(),
      child: Form(
        key: controllers.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildNameField(context, value, controllers),
            _middleSpacer(),
            _buildTotalPagesField(context, value, controllers),
            _largeSpacer(),
            ElevatedButton(
              onPressed: () => _submitForm(context, value, vm, controllers),
              style: ElevatedButton.styleFrom(
                padding: _middleEdgeInsetsSymmetric(),
                textStyle: _middleTextStyle(),
              ),
              child: const Text('新規追加'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingBookSettingsState {
  ReadingBookSettingsState();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
}
