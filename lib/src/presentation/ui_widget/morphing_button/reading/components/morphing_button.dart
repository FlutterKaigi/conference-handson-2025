import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../domain/model/reading_book_value_object.dart';
import '../../../../model/view_model_packages.dart';
import '../reading_book_widget.dart';
import 'animated_content.dart';
import 'glow_effects.dart';
import 'morphing_background.dart';
import 'progress_overlay.dart';
import 'ripple_effects.dart';

/// モーフィングボタンのStatefulWidget
class MorphingButtonStateful extends StatefulWidget {
  const MorphingButtonStateful({
    required this.value,
    required this.vm,
    required this.animeVm,
    required this.state,
    super.key,
  });

  final ReadingBookValueObject value;
  final ReadingBooksViewModel vm;
  final ReadingProgressAnimationsViewModel animeVm;
  final ReadingBookState state;

  /// フォーム送信処理のメインフロー
  ///
  /// 処理の流れ：
  /// 1. バリデーション実行
  /// 2. データの保存
  /// 3. モーフィングアニメーション実行
  /// 4. 画面遷移
  Future<void> _submitForm(
    BuildContext context,
    ReadingBookValueObject readingBook,
    ReadingBooksViewModel readingBooksViewModel,
    ReadingProgressAnimationsViewModel readingProgressAnimationsViewModel,
    ReadingBookState state,
  ) async {
    // 連打防止処理
    if (state.isProcessing) {
      return;
    }

    // バリデーションチェック
    if (!state.formKey.currentState!.validate()) {
      return;
    }

    state.formKey.currentState!.save();
    state.isProcessing = true;

    try {
      // Step 1: フォームデータの取得
      final _FormData formData = _getFormData(state);

      // Step 2: 更新前のページ数を保存（元のreadingBookから取得）
      final int prevReadingPageNum = readingBook.readingPageNum;

      // Step 3: データモデルの更新
      final ReadingBookValueObject editedReadingBook = _updateBookData(
        readingBooksViewModel,
        formData,
      );

      // Step 4: 進捗アニメーションの更新
      _updateProgressAnimation(
        readingProgressAnimationsViewModel,
        editedReadingBook,
        prevReadingPageNum,
      );

      // Step 5: ボタンのモーフィングアニメーション実行
      await _performMorphingSequence(state);

      // Step 6: 画面遷移
      if (context.mounted) {
        await _navigateBack(context, editedReadingBook);
      }
    } finally {
      state.isProcessing = false;
    }
  }

  /// フォームデータの取得
  _FormData _getFormData(ReadingBookState state) {
    return _FormData(
      name: state.nameController.text,
      totalPages: int.tryParse(state.totalPagesController.text) ?? 0,
      readingPageNum: int.tryParse(state.readingPageNumController.text) ?? 0,
      bookReview: state.bookReviewController.text,
    );
  }

  /// 読書データの更新と保存
  ReadingBookValueObject _updateBookData(
    ReadingBooksViewModel viewModel,
    _FormData formData,
  ) {
    final ReadingBookValueObject editedBook = viewModel.updateReadingBook(
      name: formData.name,
      totalPages: formData.totalPages,
      readingPageNum: formData.readingPageNum,
      bookReview: formData.bookReview,
    );
    viewModel.commitReadingBook(editedBook);
    return editedBook;
  }

  /// 進捗アニメーションの更新
  void _updateProgressAnimation(
    ReadingProgressAnimationsViewModel animationViewModel,
    ReadingBookValueObject updatedBook,
    int previousPageNum,
  ) {
    animationViewModel.updateAnimationTypeIfProgressChange(
      updatedBook: updatedBook,
      prevReadingPageNum: previousPageNum,
    );
  }

  /// 画面遷移処理
  Future<void> _navigateBack(
    BuildContext context,
    ReadingBookValueObject editedBook,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (context.mounted) {
      Navigator.pop(context, editedBook);
    }
  }

  /// モーフィングボタンのアニメーションシーケンス
  ///
  /// 3つのフェーズで構成：
  /// Phase 1: ボタン押下アニメーション
  /// Phase 2: ローディングアニメーション
  /// Phase 3: 成功アニメーション
  Future<void> _performMorphingSequence(ReadingBookState state) async {
    try {
      // Phase 1: ボタン押下アニメーション
      await _animateButtonPress(state);

      // Phase 2: ローディングアニメーション
      await _animateLoading(state);

      // Phase 3: 成功アニメーション
      await _animateSuccess(state);
    } finally {
      _resetAnimationState(state);
    }
  }

  /// Phase 1: ボタン押下アニメーション
  /// ボタンが押されたことを視覚的・触覚的にフィードバック
  Future<void> _animateButtonPress(ReadingBookState state) async {
    state.currentMorphState = MorphingButtonState.pressed;
    unawaited(HapticFeedback.lightImpact()); // 軽い振動フィードバック

    // モーフィング開始
    if (state.morphingController != null) {
      unawaited(state.morphingController!.forward());
    }

    // プレスアニメーション（押す→戻る）
    if (state.pressController != null) {
      await state.pressController!.forward();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await state.pressController!.reverse();
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  /// Phase 2: ローディングアニメーション
  /// データ処理中を表現する回転アニメーション
  Future<void> _animateLoading(ReadingBookState state) async {
    state.currentMorphState = MorphingButtonState.loading;

    // ボタンを円形に変形
    if (state.morphingController != null) {
      await state.morphingController!.forward();
    }

    // ローディングプログレス表示
    await _showLoadingProgress(state);
  }

  /// ローディングプログレスの表示
  Future<void> _showLoadingProgress(ReadingBookState state) async {
    if (state.loadingController != null) {
      state.loadingController!.reset();
      unawaited(state.loadingController!.repeat());
    }

    // プログレスバーのアニメーション（0% → 100%）
    for (int i = 0; i <= 100; i += 10) {
      state.loadingProgress = i / 100.0;
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }

    state.loadingController?.stop();
  }

  /// Phase 3: 成功アニメーション
  /// 処理完了を祝福するアニメーション
  Future<void> _animateSuccess(ReadingBookState state) async {
    state.currentMorphState = MorphingButtonState.success;
    unawaited(HapticFeedback.mediumImpact()); // 中程度の振動フィードバック

    // バウンス効果で成功を表現
    if (state.morphingController != null) {
      await state.morphingController!.reverse();
      await state.morphingController!.forward();
    }

    // 成功状態を維持（視認性のため長めに表示）
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  /// アニメーション状態のリセット
  void _resetAnimationState(ReadingBookState state) {
    state.morphingController?.reset();
    state.loadingController?.reset();
    state.pressController?.reset();
    state.loadingProgress = 0;
    state.currentMorphState = MorphingButtonState.idle;
  }

  /// ボタンの幅を状態に応じて決定
  double _getButtonWidth(ReadingBookState state) {
    switch (state.currentMorphState) {
      case MorphingButtonState.idle:
        return 200;
      case MorphingButtonState.pressed:
        return 190;
      case MorphingButtonState.loading:
        return 64;
      case MorphingButtonState.success:
        return 64;
    }
  }

  /// ボタンの角丸を状態に応じて決定
  double _getBorderRadius(ReadingBookState state) {
    switch (state.currentMorphState) {
      case MorphingButtonState.idle:
      case MorphingButtonState.pressed:
        return 16;
      case MorphingButtonState.loading:
      case MorphingButtonState.success:
        return 32;
    }
  }

  @override
  State<MorphingButtonStateful> createState() => _MorphingButtonStatefulState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ReadingBookValueObject>('value', value));
    properties.add(DiagnosticsProperty<ReadingBooksViewModel>('vm', vm));
    properties.add(
      DiagnosticsProperty<ReadingProgressAnimationsViewModel>(
        'animeVm',
        animeVm,
      ),
    );
    properties.add(DiagnosticsProperty<ReadingBookState>('state', state));
  }
}

class _MorphingButtonStatefulState extends State<MorphingButtonStateful>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // アニメーション初期化
    widget.state.initializeAnimations(this);
  }

  @override
  void dispose() {
    // AnimationControllerのdispose
    widget.state.morphingController?.dispose();
    widget.state.loadingController?.dispose();
    widget.state.pressController?.dispose();

    // 参照クリア
    widget.state.morphingController = null;
    widget.state.loadingController = null;
    widget.state.pressController = null;
    widget.state.morphingAnimation = null;
    widget.state.loadingAnimation = null;
    widget.state.pressAnimation = null;

    super.dispose();
  }

  /// モーフィングボタンのUI構築
  @override
  Widget build(BuildContext context) {
    // 複数アニメーションの統合監視
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        widget.state.morphingController ??
            widget.state.loadingController ??
            const AlwaysStoppedAnimation<double>(0),
        widget.state.pressController ?? const AlwaysStoppedAnimation<double>(0),
      ]),
      builder: (BuildContext context, Widget? child) {
        return GestureDetector(
          onTapDown: (_) {
            if (!widget.state.isProcessing &&
                widget.state.currentMorphState == MorphingButtonState.idle) {
              unawaited(widget.state.pressController?.forward());
              setState(() {
                widget.state.isPressed = true;
              });
            }
          },
          onTapUp: (_) {
            if (!widget.state.isProcessing) {
              unawaited(widget.state.pressController?.reverse());
              setState(() {
                widget.state.isPressed = false;
              });
            }
          },
          onTapCancel: () {
            if (!widget.state.isProcessing) {
              unawaited(widget.state.pressController?.reverse());
              setState(() {
                widget.state.isPressed = false;
              });
            }
          },
          onTap:
              !widget.state.isProcessing &&
                  widget.state.currentMorphState == MorphingButtonState.idle
              ? () async {
                  await widget._submitForm(
                    context,
                    widget.value,
                    widget.vm,
                    widget.animeVm,
                    widget.state,
                  );
                }
              : null,
          child: Transform.scale(
            scale: 1.0 - (widget.state.pressAnimation?.value ?? 0) * 0.05,
            child: SizedBox(
              width: _getAnimatedButtonWidth(),
              height: _getAnimatedButtonHeight(),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // 背景とモーフィング効果
                  MorphingBackground(
                    state: widget.state,
                    value: widget.value,
                    vm: widget.vm,
                  ),

                  // グロー効果
                  GlowEffects(state: widget.state),

                  // コンテンツ
                  AnimatedContent(
                    state: widget.state,
                    vm: widget.vm,
                    getAnimatedButtonWidth: _getAnimatedButtonWidth,
                  ),

                  // リップル効果
                  RippleEffects(
                    state: widget.state,
                    getAnimatedButtonWidth: _getAnimatedButtonWidth,
                  ),

                  // プログレスオーバーレイ
                  ProgressOverlay(
                    state: widget.state,
                    getBorderRadius: widget._getBorderRadius,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ボタン幅のアニメーション計算
  double _getAnimatedButtonWidth() {
    final double baseWidth = widget._getButtonWidth(widget.state);
    final double morphValue = widget.state.morphingAnimation?.value ?? 0;

    switch (widget.state.currentMorphState) {
      case MorphingButtonState.idle:
      case MorphingButtonState.pressed:
        return baseWidth;
      case MorphingButtonState.loading:
        return 200 + (64 - 200) * morphValue;
      case MorphingButtonState.success:
        return 64;
    }
  }

  /// ボタン高さ（固定）
  double _getAnimatedButtonHeight() {
    return 64;
  }
}

/// フォームデータを保持する構造体
class _FormData {
  const _FormData({
    required this.name,
    required this.totalPages,
    required this.readingPageNum,
    required this.bookReview,
  });

  final String name;
  final int totalPages;
  final int readingPageNum;
  final String bookReview;
}
