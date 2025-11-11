import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';
import 'components/progress_donut_chart.dart';
import 'components/progress_info.dart';
import 'components/title_section.dart';

/// 読書進捗ドーナツチャートウィジェット
///
/// このウィジェットは読書進捗を視覚的に表現します：
/// 1. ドーナツチャート形式の進捗表示
/// 2. タップでパルスアニメーション
/// 3. 完了時の祝福メッセージ
class ReadingBookGraphWidget
    extends ConsumerStagedWidget<ReadingBookValueObject, DonutAnimationState> {
  const ReadingBookGraphWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  DonutAnimationState? createWidgetState() {
    return DonutAnimationState();
  }

  @override
  void disposeState(DonutAnimationState? state) {
    // disposeは_ProgressDonutWidgetStateで行う
    super.disposeState(state);
  }

  /// ドーナツチャートタップ時の処理
  /// パルスアニメーションと触覚フィードバックを実行
  void _onDonutTap(DonutAnimationState state) {
    state.triggerPulseAnimation();
    unawaited(HapticFeedback.lightImpact());
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ReadingBookValueObject value,
    DonutAnimationState? state,
  ) {
    final DonutAnimationState controllers = state!;
    final double progress = _calculateProgress(value);

    // FIXME コードを完成させてください。
    // ステップ1: 画面表示完了後に円グラフ描画を予約する処理を追加
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controllers.animateToProgress(progress);
    // });

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // タイトルセクション
            TitleSection(value: value, progress: progress),
            const SizedBox(height: 32),

            // メインのドーナツチャート
            ProgressDonutChart(
              state: controllers,
              value: value,
              onTap: () => _onDonutTap(controllers),
            ),
            const SizedBox(height: 32),

            // 進捗統計情報
            ProgressInfo(value: value),
          ],
        ),
      ),
    );
  }

  /// 進捗率の計算
  double _calculateProgress(ReadingBookValueObject value) {
    if (value.totalPages <= 0) {
      return 0;
    }
    return (value.readingPageNum / value.totalPages).clamp(0, 1);
  }
}

/// ドーナツチャートアニメーション状態管理クラス
///
/// アニメーション関連の状態とロジックを管理：
/// - AnimationController: アニメーションの制御
/// - Animation: 実際のアニメーション値
/// - パルスアニメーション: タップ時の視覚的フィードバック
class DonutAnimationState {
  /// 進捗アニメーションコントローラー
  AnimationController? progressController;

  /// 進捗アニメーション
  Animation<double>? progressAnimation;

  /// dispose済みフラグ
  bool _isDisposed = false;

  /// アニメーションの目標進捗値
  double targetProgress = 0;

  /// 現在の進捗値
  double progressValue = 0;

  /// パルス効果の強度
  double pulseValue = 0;

  /// 現在のアニメーション進捗値を取得
  ///
  /// AnimationControllerが実行中の場合は動的な値を返し、
  /// 未初期化の場合は固定値を返します
  double get animatedProgress => progressAnimation?.value ?? progressValue;

  /// アニメーションの初期化
  ///
  /// Flutterアニメーションの基本構成：
  /// 1. AnimationController: 時間管理（duration, vsync）
  /// 2. Tween: 値の変化範囲（begin → end）
  /// 3. CurvedAnimation: アニメーションカーブ
  void initializeAnimations(TickerProvider vsync) {
    // AnimationController: 2秒間のアニメーション
    progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );

    // 初期のアニメーション（0→0）
    progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: progressController!,
        curve: Curves.easeOutCubic, // 滑らかに減速するカーブ
      ),
    );
  }

  /// 指定した進捗値までアニメーション
  ///
  /// アニメーション実行の流れ：
  /// 1. 新しいTweenを作成（現在値 → 目標値）
  /// 2. CurvedAnimationでイージング適用
  /// 3. コントローラーをリセット後、forward()で実行
  void animateToProgress(double progress) {
    if (targetProgress != progress && progressController != null) {
      targetProgress = progress;

      // FIXME コードを完成させてください。
      // ステップ2: 進捗に合わせた終了値を指定し開始する
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

      // FIXME コードを完成させてください。
      // progressController!.reset();
      // unawaited(progressController!.forward());
    }
  }

  /// タップ時のパルスアニメーション
  /// 300ms間パルス効果を表示
  void triggerPulseAnimation() {
    pulseValue = 1;
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        pulseValue = 0;
      }),
    );
  }

  /// リソースの解放
  void dispose() {
    if (!_isDisposed && progressController != null) {
      progressController!.dispose();
      _isDisposed = true;
    }
  }
}
