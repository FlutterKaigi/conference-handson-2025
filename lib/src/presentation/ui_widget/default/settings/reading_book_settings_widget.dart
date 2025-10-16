import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for FilteringTextInputFormatter
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../../model/view_model_packages.dart';
import '../../../ui_widget/widget_packages.dart';

class ReadingBookSettingsWidget
    extends ConsumerStagedWidget<Object?, ReadingBookSettingsState> {
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

  InputDecoration _buildDebugInputDecorator(
    BuildContext context,
    ReadingBookSettingsState state,
  ) {
    return InputDecoration(
      labelText: 'デバッグ',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildReadingStartSwitch(
    BuildContext context,
    ToggleSwitchViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text('読書開始イベント'),
        ToggleSwitch(viewModel: viewModel),
      ],
    );
  }

  Widget _buildReadingEndSwitch(
    BuildContext context,
    ToggleSwitchViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text('読書終了イベント'),
        ToggleSwitch(viewModel: viewModel),
      ],
    );
  }

  void _submitForm(
    BuildContext context,
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
    ReadingBookSettingsState state,
  ) {
    // 新規追加する書籍情報を入力するフィールドのため書籍タイトルの初期値は空です。
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
    ReadingBookSettingsState state,
  ) {
    // 新規追加する書籍情報を入力するフィールドのため書籍そーページの初期値は空です。
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
    Object? value,
    ReadingBookSettingsState? state,
  ) {
    final ReadingSupportAnimationsViewModel supportVM = ref.read(
      readingSupportAnimationsProvider.notifier,
    );
    final ReadingBooksViewModel vm = ref.read(readingBooksProvider.notifier);
    final ReadingBookSettingsState controllers = state!;

    return Padding(
      padding: _middleEdgeInsetsAll(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // デバッグ用トグルスイッチセクション
          InputDecorator(
            decoration: _buildDebugInputDecorator(context, controllers),
            child: Column(
              children: <Widget>[
                Text(
                  'タップ 10秒後にイベントを発行します。',
                  style: TextTheme.of(context).bodySmall,
                ),
                _buildReadingStartSwitch(context, supportVM.debugStartReading),
                _buildReadingEndSwitch(context, supportVM.debugEndReading),
              ],
            ),
          ),
          _largeSpacer(),
          // 書籍情報設定フォームセクション
          Form(
            key: controllers.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildNameField(context, controllers),
                _middleSpacer(),
                _buildTotalPagesField(context, controllers),
                _largeSpacer(),
                ElevatedButton(
                  onPressed: () => _submitForm(context, vm, controllers),
                  style: ElevatedButton.styleFrom(
                    padding: _middleEdgeInsetsSymmetric(),
                    textStyle: _middleTextStyle(),
                  ),
                  child: const Text('新規追加'),
                ),
              ],
            ),
          ),
        ],
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
