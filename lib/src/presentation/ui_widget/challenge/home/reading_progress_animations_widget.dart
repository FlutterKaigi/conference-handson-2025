// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
// ignore_for_file: unused_element
// ignore_for_file: unused_import, unused_field

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';
import '../../../model/view_model_packages.dart';
import 'components/progress/dynamic_background_widget.dart';
import 'components/progress/message_text_widget.dart';
import 'components/progress/particle_effect_widget.dart';
import 'components/progress/progress_circle_widget.dart';
import 'components/progress/ripple_effect_widget.dart';
import 'components/progress/sparkle_effect_widget.dart';
import 'components/progress/title_text_widget.dart';

class ReadingProgressAnimationsWidget
    extends ConsumerStagedWidget<ProgressAnimationTypeEnum, Object> {
  /// コンストラクタ
  ///
  /// - [provider] : 引数の Riverpod ref を使って状態値を取得する関数。
  ///
  /// - [builders] : （オプション）[buildList]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッド一覧を返す関数。
  ///
  /// - [selectBuilder] : （オプション）[selectBuild]を上書きする、
  ///   [provider]が返した状態値に対応するビルド・メソッドを返す関数。
  const ReadingProgressAnimationsWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  /// [ReadingProgressAnimationsWidget] では、ウイジェット内部状態を使いません。
  Object? createWidgetState() => null;

  @override
  /// [provider] が返す状態値の
  /// [ProgressAnimationTypeEnum] に対応した build関数を返します。
  ConsumerStagedBuild<ProgressAnimationTypeEnum, Object> selectBuild(
    List<ConsumerStagedBuild<ProgressAnimationTypeEnum, Object>> builders,
    ProgressAnimationTypeEnum value,
  ) {
    return builders[value.index];
  }

  @override
  /// [ProgressAnimationTypeEnum.none] に対応した、デフォルトの build関数
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ProgressAnimationTypeEnum value,
    Object? state,
  ) {
    return const Offstage();
  }

  @override
  /// [ProgressAnimationTypeEnum.progressRate10] に対応した、デフォルトの build関数
  Widget build2(
    BuildContext context,
    WidgetRef ref,
    ProgressAnimationTypeEnum value,
    Object? state,
  ) {
    final String title =
        ref.read(readingBooksProvider.notifier).editedReadingBook?.name ?? '';
    return ProgressAchievementAnimation(
      title: title,
      progressPercent: 10,
      message: '素晴らしいスタート！',
      primaryColor: const Color(0xFF2196F3),
      secondaryColor: const Color(0xFF03DAC6),
      icon: Icons.rocket_launch,
    );
  }

  @override
  /// [ProgressAnimationTypeEnum.progressRate50] に対応した、デフォルトの build関数
  Widget build3(
    BuildContext context,
    WidgetRef ref,
    ProgressAnimationTypeEnum value,
    Object? state,
  ) {
    final String title =
        ref.read(readingBooksProvider.notifier).editedReadingBook?.name ?? '';
    return ProgressAchievementAnimation(
      title: title,
      progressPercent: 50,
      message: '折り返し地点到達！',
      primaryColor: const Color(0xFFFF9800),
      secondaryColor: const Color(0xFFFFEB3B),
      icon: Icons.trending_up,
    );
  }

  @override
  /// [ProgressAnimationTypeEnum.progressRate80] に対応した、デフォルトの build関数
  Widget build4(
    BuildContext context,
    WidgetRef ref,
    ProgressAnimationTypeEnum value,
    Object? state,
  ) {
    final String title =
        ref.read(readingBooksProvider.notifier).editedReadingBook?.name ?? '';
    return ProgressAchievementAnimation(
      title: title,
      progressPercent: 80,
      message: 'もうすぐゴール！',
      primaryColor: const Color(0xFF9C27B0),
      secondaryColor: const Color(0xFFE91E63),
      icon: Icons.speed,
    );
  }

  @override
  /// [ProgressAnimationTypeEnum.progressRate100] に対応した、デフォルトの build関数
  Widget build5(
    BuildContext context,
    WidgetRef ref,
    ProgressAnimationTypeEnum value,
    Object? state,
  ) {
    final String title =
        ref.read(readingBooksProvider.notifier).editedReadingBook?.name ?? '';
    return ProgressAchievementAnimation(
      title: title,
      progressPercent: 100,
      message: '完読おめでとう！',
      primaryColor: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFFFFD700),
      icon: Icons.celebration,
      isCompletion: true,
    );
  }
}

/// 豪華な進捗達成アニメーション
///

/// - 複数のAnimationControllerによる協調アニメーション
/// - コンポーネント分割によるコードの整理
/// - 段階的なアニメーション発火タイミング制御
/// - StatefulWidgetでのアニメーションライフサイクル管理
///
/// 完読率の達成を祝福する印象的なアニメーション表示:
/// - 3Dライクな円形プログレス表示
/// - 多層パーティクル＆スパークルエフェクト
/// - 波紋・背景グラデーションアニメーション
/// - 段階的な色変化とグロー効果
/// - リズミカルなマルチレイヤーアニメーション
class ProgressAchievementAnimation extends StatefulWidget {
  const ProgressAchievementAnimation({
    required this.title,
    required this.progressPercent,
    required this.message,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    this.isCompletion = false,
    super.key,
  });

  /// 書籍タイトル
  final String title;

  /// 達成した進捗率（10, 50, 80, 100）
  final int progressPercent;

  /// 達成メッセージ
  final String message;

  /// メインカラー
  final Color primaryColor;

  /// セカンダリカラー
  final Color secondaryColor;

  /// アイコン
  final IconData icon;

  /// 完読フラグ（100%の場合）
  final bool isCompletion;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(IntProperty('progressPercent', progressPercent));
    properties.add(StringProperty('message', message));
    properties.add(ColorProperty('primaryColor', primaryColor));
    properties.add(ColorProperty('secondaryColor', secondaryColor));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(
      FlagProperty('isCompletion', value: isCompletion, ifTrue: 'completion'),
    );
  }

  @override
  State<ProgressAchievementAnimation> createState() =>
      _ProgressAchievementAnimationState();
}

class _ProgressAchievementAnimationState
    extends State<ProgressAchievementAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _progressController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _sparkleController;
  late AnimationController _backgroundController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    unawaited(_startAnimationSequence());
  }

  /// アニメーションの初期化
  ///

  /// - 異なる duration で複数のAnimationControllerを作成
  /// - TickerProviderStateMixinのvsyncを使ったパフォーマンス最適化
  /// - 各アニメーションの役割分担
  void _initializeAnimations() {
    // 1. メインアニメーション（全体の登場演出）
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 2. プログレスアニメーション（進捗率の表示）
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 3. パーティクルアニメーション（完読時の花火）
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // 4. パルスアニメーション（呼吸するような拡縮）
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 5. 波紋エフェクト（同心円状の波紋）
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // 6. スパークルエフェクト（星形パーティクルの周回）
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // FIXME コードを完成させてください。
    // ステップ1：アニメーションの設定の分割（再生時間）
    // _backgroundController = AnimationController(
    //   duration: const Duration(milliseconds: 5000),
    //   vsync: this,
    // );

    // フェードインアニメーション（より滑らか）
    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
    );

    // スケールアニメーション（より弾力的）
    _scaleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.1, 0.7, curve: Curves.elasticOut),
    );

    // バウンスアニメーション（新規追加）
    _bounceAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 1, curve: Curves.bounceOut),
    );

    // プログレス表示アニメーション（よりドラマチック）
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutQuart,
    );

    // パルスアニメーション（より大きな変化）
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // 波紋アニメーション
    _rippleAnimation = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOutQuart,
    );

    // スパークルアニメーション
    _sparkleAnimation = CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    );

    // FIXME コードを完成させてください。
    // ステップ1：アニメーションの設定の分割（動き）
    // _backgroundAnimation = CurvedAnimation(
    //   parent: _backgroundController,
    //   curve: Curves.easeInOutSine,
    // );
  }

  Future<void> _startAnimationSequence() async {
    // FIXME コードを完成させてください。
    // ステップ3: アニメーションの配置と実行
    // unawaited(_backgroundController.repeat(reverse: true));

    // パルスアニメーションを繰り返し開始
    unawaited(_pulseController.repeat(reverse: true));

    // メインアニメーション開始
    unawaited(_mainController.forward());

    // 波紋エフェクト開始（同時）
    unawaited(_rippleController.forward());

    // プログレスアニメーション開始（少し遅延）
    await Future<void>.delayed(const Duration(milliseconds: 200));
    unawaited(_progressController.forward());

    // スパークルエフェクト開始
    await Future<void>.delayed(const Duration(milliseconds: 400));
    unawaited(_sparkleController.repeat());

    // パーティクルアニメーション開始（完読時は早めに、それ以外は後で）
    if (widget.isCompletion) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      unawaited(_particleController.forward());
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      unawaited(_particleController.forward());
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _sparkleController.dispose();
    // FIXME コードを完成させてください。
    // ステップ1: アニメーションの設定の分割（動き）を追加後、disposeを追加
    // _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// - Stackによる複数レイヤーの重ね合わせ
    /// - AnimatedBuilderによる効率的な再描画制御
    /// - コンポーネント分割による可読性向上
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // FIXME コードを完成させてください。
            // ステップ3: アニメーションの配置と実行
            // DynamicBackgroundWidget(
            //   animation: _backgroundAnimation,
            //   primaryColor: widget.primaryColor,
            //   secondaryColor: widget.secondaryColor,
            // ),

            // FIXME コードを完成させてください。
            // ステップ4: ２層目の波紋
            // RippleEffectWidget(
            //   animation: _rippleAnimation,
            //   primaryColor: widget.primaryColor,
            //   secondaryColor: widget.secondaryColor,
            // ),

            // FIXME コードを完成させてください。
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

            // FIXME コードを完成させてください。
            // ステップ4: 【おまけ】他のアニメーションを重ねる①
            // if (widget.isCompletion)
            //   ParticleEffectWidget(
            //     animation: _particleController,
            //     color: widget.secondaryColor,
            //   ),

            // FIXME コードを完成させてください。
            // ステップ4: 【おまけ】他のアニメーションを重ねる②
            // SparkleEffectWidget(
            //   animation: _sparkleAnimation,
            //   primaryColor: widget.primaryColor,
            //   secondaryColor: widget.secondaryColor,
            //   isCompletion: widget.isCompletion,
            // ),
          ],
        ),
      ),
    );
  }

  /// メインコンテンツの構築
  ///
  /// - Columnによる縦方向のレイアウト
  /// - SizedBoxによる幅制限とスペーシング
  /// - 条件分岐による動的なウィジェット表示
  Widget _buildMainContent() {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // FIXME コードを完成させてください。
          // ステップ2: プログレス円とアイコンを配置
          // ProgressCircleWidget(
          //   progressAnimation: _progressAnimation,
          //   pulseAnimation: _pulseAnimation,
          //   progressPercent: widget.progressPercent,
          //   primaryColor: widget.primaryColor,
          //   secondaryColor: widget.secondaryColor,
          //   icon: widget.icon,
          // ),
          const SizedBox(height: 32),

          // タイトルテキスト
          TitleTextWidget(
            title: widget.title,
            primaryColor: widget.primaryColor,
          ),
          const SizedBox(height: 16),

          // メッセージテキスト
          MessageTextWidget(
            message: widget.message,
            primaryColor: widget.primaryColor,
          ),
        ],
      ),
    );
  }
}
