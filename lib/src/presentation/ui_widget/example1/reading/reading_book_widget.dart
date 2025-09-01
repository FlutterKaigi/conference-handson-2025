import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../fundamental/debug/debug_logger.dart';
import '../../../model/view_model_packages.dart';

// 変更点：ConsumerStatefulWidget に変更
class ReadingBookWidget extends ConsumerStatefulWidget {
  const ReadingBookWidget({super.key, required ReadingBookValueObject Function(WidgetRef ref) provider});

  @override
  ConsumerState<ReadingBookWidget> createState() => _ReadingBookWidgetState();
}

// 変更点：Stateクラスを作成し、SingleTickerProviderStateMixin を追加
class _ReadingBookWidgetState extends ConsumerState<ReadingBookWidget>
    with SingleTickerProviderStateMixin {
  // 以前のReadingBookStateの内容をStateクラスのプロパティとして管理
  final ReadingBookState _formState = ReadingBookState();
  
  // プレビュー機能用の状態
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;

@override
void initState() {
  super.initState();
  // AnimationControllerの初期化
  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  // 変更点： .notifier を追加してViewModelにアクセスする
  final ReadingBookValueObject? initialBook = ref.read(readingBooksProvider.notifier).editedReadingBook;
  
  if (initialBook != null) {
    _formState.nameController.text = initialBook.name;
    _formState.totalPagesController.text = initialBook.totalPages.toString();
    _formState.readingPageNumController.text = initialBook.readingPageNum.toString();
    _formState.bookReviewController.text = initialBook.bookReview;
  }
}

  @override
  void dispose() {
    // 全てのコントローラーを破棄
    _formState.dispose();
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  // --- プレビュー機能のメソッド ---
  Future<void> _showOverlay(BuildContext context, Widget previewContent) async {
    await _hideOverlay();
    final OverlayState overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: _hideOverlay,
          behavior: HitTestBehavior.opaque,
          child: Material(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: FadeTransition(
                opacity: _animationController,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1).animate(
                    CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
                  ),
                  child: previewContent,
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_overlayEntry!);
    await _animationController.forward();
  }

  Future<void> _hideOverlay() async {
    if (_overlayEntry != null) {
      await _animationController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  // 読書ページのプレビューウィジェットを作成するメソッド
  Widget _buildBookPreviewWidget() {
    final int currentPageNum = int.tryParse(_formState.readingPageNumController.text) ?? 0;
    final String bookReviewText = _formState.bookReviewController.text;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: AspectRatio(
        aspectRatio: 1.4, // 本の見開きに近い比率
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              // 左ページ
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    bookReviewText.isEmpty ? '（ここに感想やメモが表示されます）' : bookReviewText,
                    style: TextStyle(fontFamily: 'NotoSerifJP', color: Colors.grey[700]),
                  ),
                ),
              ),
              const VerticalDivider(width: 32),
              // 右ページ
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          '右ページのテキストサンプルです...' * 10,
                          style: TextStyle(fontFamily: 'NotoSerifJP', color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    Text(
                      '${currentPageNum + 1}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 既存のメソッド（Stateクラス内に移動） ---

  @override
  Widget build(BuildContext context) {
    final ReadingBooksViewModel _ = ref.watch(readingBooksProvider.notifier);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: _formState.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // プレビューボタン
              GestureDetector(
                onLongPressStart: (LongPressStartDetails details) {
                  debugLog('プレビューを開始');
                  _showOverlay(context, _buildBookPreviewWidget());
                },
                onLongPressEnd: (LongPressEndDetails details) {
                  debugLog('プレビューを終了');
                  _hideOverlay();
                },
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.preview),
                  label: const Text('読書ページをプレビュー'),
                  onPressed: () {
                    // 通常タップ時の動作（例：ヒントを表示）
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ボタンを長押しするとプレビューが表示されます。')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // ... (削除ボタンのロジックも同様)
            ],
          ),
        ),
      ),
    );
  }
}

// フォームの状態を管理するクラス（変更なし）
class ReadingBookState {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalPagesController = TextEditingController();
  final TextEditingController readingPageNumController = TextEditingController();
  final TextEditingController bookReviewController = TextEditingController();

  void dispose() {
    nameController.dispose();
    totalPagesController.dispose();
    readingPageNumController.dispose();
    bookReviewController.dispose();
    formKey.currentState?.reset();
  }
}
