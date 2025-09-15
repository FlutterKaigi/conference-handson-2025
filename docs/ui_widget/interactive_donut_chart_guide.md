# インタラクティブドーナツチャート実装ガイド

## 概要

インタラクティブドーナツチャートは、読書進捗を視覚的に表現する高度なグラフィックUIコンポーネントです。CustomPainterを使用したCanvas描画とアニメーションを組み合わせ、ユーザーの操作に反応するインタラクティブな体験を提供します。

## 実装のポイント

### 1. アーキテクチャ設計

```
interactive_donut_chart/
├── reading_book_graph_widget.dart    # メインウィジェット
├── components/
    ├── progress_donut_chart.dart     # ドーナツチャート本体
    ├── progress_donut_chart_painter.dart # Canvas描画ロジック
    ├── donut_chart_center_content.dart   # 中央コンテンツ
    ├── background_glow.dart          # 背景グロー効果
    ├── progress_info.dart            # 統計情報表示
    ├── stat_item.dart               # 統計アイテム
    └── title_section.dart           # タイトルセクション
```

責任の分離により、複雑なグラフィック処理を管理しやすい構造にしています。

### 2. CustomPainterによる高性能な描画

#### 基本的な描画構成 (34-48行目)

```dart
@override
void paint(Canvas canvas, Size size) {
  // 描画の基本パラメータ
  final Offset center = Offset(size.width / 2, size.height / 2);
  final double radius = math.min(size.width, size.height) / 2 - 20;
  const double strokeWidth = 16;

  // 1. 背景円の描画
  _drawBackgroundCircle(canvas, center, radius, strokeWidth);

  // 2. 進捗アークとグロー効果の描画
  if (progress > 0) {
    _drawProgressArc(canvas, center, radius, strokeWidth);
    _drawProgressDot(canvas, center, radius);
  }
}
```

**学習ポイント:**
- **Canvas**: 低レベルな描画API、高いパフォーマンス
- **center calculation**: レスポンシブな中心点の算出
- **conditional rendering**: 進捗が0の場合は描画をスキップして最適化

#### 背景円の描画 (50-64行目)

```dart
void _drawBackgroundCircle(
  Canvas canvas,
  Offset center,
  double radius,
  double strokeWidth,
) {
  final Paint backgroundPaint = Paint()
    ..color = colorScheme.outline.withValues(alpha: 0.2)
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round;

  canvas.drawCircle(center, radius, backgroundPaint);
}
```

**技術解説:**
- **Paint オブジェクト**: 描画スタイルの設定
- **PaintingStyle.stroke**: 塗りつぶしではなく線描画を指定
- **StrokeCap.round**: 線の端を丸くする設定
- **alpha透明度**: Material Design 3のカラースキームを活用

**参考リンク:** 
- [Flutter公式: CustomPainter class](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)
- [Flutter公式: Canvas class](https://api.flutter.dev/flutter/dart-ui/Canvas-class.html)

#### グロー効果付き進捗アーク (66-107行目)

```dart
void _drawProgressArc(Canvas canvas, Offset center, double radius, double strokeWidth) {
  // グロー効果（下レイヤー）
  final Paint glowPaint = Paint()
    ..color = colorScheme.primary.withValues(
      alpha: 0.3 + pulseValue * 0.2, // パルス時に明るくなる
    )
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth + 8
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

  canvas.drawArc(
    Rect.fromCircle(center: center, radius: radius),
    -math.pi / 2, // 12時方向から開始
    2 * math.pi * progress, // 進捗に応じた角度
    false,
    glowPaint,
  );

  // メインの進捗アーク（上レイヤー）
  final Paint progressPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth + (pulseValue * 4) // パルス時に太くなる
    ..strokeCap = StrokeCap.round
    ..color = colorScheme.primary;

  canvas.drawArc(
    Rect.fromCircle(center: center, radius: radius),
    -math.pi / 2,
    2 * math.pi * progress,
    false,
    progressPaint,
  );
}
```

**高度な描画技術:**
- **レイヤー描画**: グロー効果を下に、メインアークを上に重ねる
- **MaskFilter.blur**: ぼかし効果でグロー表現
- **動的なstrokeWidth**: パルス効果で線の太さを変化
- **角度計算**: -π/2で12時方向から開始、progressで角度を制御

**数学的な解説:**
- `2 * math.pi * progress`: 進捗率を角度（ラジアン）に変換
- `-math.pi / 2`: 時計の12時方向を開始点に設定
- `progress.clamp(0, 1)`: 値の範囲を0-1に制限

### 3. 進捗ドットの動的配置

```dart
void _drawProgressDot(Canvas canvas, Offset center, double radius) {
  // ドットの位置計算
  final double endAngle = -math.pi / 2 + 2 * math.pi * progress;
  final Offset dotPosition = Offset(
    center.dx + math.cos(endAngle) * radius,
    center.dy + math.sin(endAngle) * radius,
  );

  // ドットのグロー効果
  final Paint dotGlowPaint = Paint()
    ..color = colorScheme.primary.withValues(alpha: 0.4)
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  canvas.drawCircle(dotPosition, 8 + pulseValue * 3, dotGlowPaint);

  // メインのドット
  final Paint dotPaint = Paint()
    ..color = colorScheme.primary
    ..style = PaintingStyle.fill;

  canvas.drawCircle(dotPosition, 6 + pulseValue * 2, dotPaint);
}
```

**三角関数の活用:**
- `math.cos(endAngle) * radius`: X座標の計算
- `math.sin(endAngle) * radius`: Y座標の計算
- 円周上の任意の点を正確に配置する数学的手法

**視覚的な工夫:**
- グロー効果で存在感を強化
- パルス効果でサイズを動的に変化
- 二重円描画で立体感を演出

### 4. アニメーション状態管理

#### アニメーション初期化 (131-145行目)

```dart
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
```

**アニメーション設計の考慮点:**
- **duration**: 2秒という適度な時間で自然な動き
- **curve**: easeOutCubicで滑らかな減速
- **初期値**: begin=0, end=0で初期状態を設定

**参考リンク:** 
- [Flutter公式: AnimationController](https://api.flutter.dev/flutter/animation/AnimationController-class.html)
- [Material Design: Easing](https://m3.material.io/styles/motion/easing-and-duration)

#### 動的アニメーション更新 (147-173行目)

```dart
void animateToProgress(double progress) {
  if (targetProgress != progress && progressController != null) {
    targetProgress = progress;

    // 現在値から目標値へのTweenを作成
    progressAnimation = Tween<double>(
      begin: animatedProgress, // 現在のアニメーション値から開始
      end: progress, // 目標値まで
    ).animate(
      CurvedAnimation(
        parent: progressController!,
        curve: Curves.easeOutCubic, // 自然な減速カーブ
      ),
    );

    // アニメーション実行
    progressController!.reset(); // 0.0にリセット
    unawaited(progressController!.forward()); // 1.0まで進行
  }
}
```

**動的アニメーション技術:**
- **現在値の保持**: 前のアニメーション値をbeginに設定
- **seamless transition**: 途切れのない連続的なアニメーション
- **条件付き実行**: 値が変わった時のみアニメーション実行

### 5. パルス効果によるインタラクション

#### タップ時のパルスアニメーション (175-184行目)

```dart
void triggerPulseAnimation() {
  pulseValue = 1;
  unawaited(
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      pulseValue = 0;
    }),
  );
}
```

#### メインウィジェットでの統合 (40-44行目)

```dart
void _onDonutTap(DonutAnimationState state) {
  state.triggerPulseAnimation();
  unawaited(HapticFeedback.lightImpact());
}
```

**ユーザビリティ設計:**
- **短い持続時間**: 300msで素早いフィードバック
- **触覚連携**: 視覚と触覚の両方でフィードバック提供
- **非ブロッキング**: UIの操作性を妨げない軽量な実装

### 6. 描画最適化

#### shouldRepaint最適化 (134-140行目)

```dart
@override
bool shouldRepaint(ProgressDonutChartPainter oldDelegate) {
  return progress != oldDelegate.progress ||
         pulseValue != oldDelegate.pulseValue;
}
```

**パフォーマンス最適化:**
- **変更検知**: 実際に値が変わった時のみ再描画
- **CPU効率**: 不要な描画処理を回避
- **滑らかなアニメーション**: フレームレート向上に寄与

## CustomPainter技術の詳細解説

### 1. Canvas座標系の理解

```dart
// 画面座標系: 左上が原点(0,0)
final Offset center = Offset(size.width / 2, size.height / 2);

// 円の角度: -π/2が12時方向（上）
const double startAngle = -math.pi / 2;

// ラジアン単位での角度計算
final double sweepAngle = 2 * math.pi * progress;
```

**座標変換の数学:**
- **デカルト座標**: (x, y) = (centerX + r*cos(θ), centerY + r*sin(θ))
- **角度変換**: 度数 = ラジアン × (180/π)
- **座標系の違い**: 数学（Y軸上向き）vs 画面（Y軸下向き）

### 2. Paint プロパティの使い分け

```dart
// 線描画用のPaint設定
final Paint strokePaint = Paint()
  ..style = PaintingStyle.stroke  // 線のみ
  ..strokeWidth = 16              // 線の太さ
  ..strokeCap = StrokeCap.round   // 端を丸くする
  ..color = Colors.blue;

// 塗りつぶし用のPaint設定
final Paint fillPaint = Paint()
  ..style = PaintingStyle.fill    // 塗りつぶし
  ..color = Colors.blue;

// グロー効果用のPaint設定
final Paint glowPaint = Paint()
  ..color = Colors.blue.withValues(alpha: 0.3)
  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
```

**Paint設定の指針:**
- **stroke**: 輪郭線、進捗リング
- **fill**: 塗りつぶし、ドット、アイコン
- **blur**: グロー効果、影、発光表現

**参考リンク:** 
- [Flutter公式: Paint class](https://api.flutter.dev/flutter/dart-ui/Paint-class.html)

### 3. 三角関数を活用した座標計算

```dart
// 円周上の座標計算
double x = center.dx + radius * math.cos(angle);
double y = center.dy + radius * math.sin(angle);

// 角度の変換
double radians = degrees * (math.pi / 180);
double degrees = radians * (180 / math.pi);

// 進捗に応じた角度計算
double progressAngle = 2 * math.pi * progress; // 0-1 → 0-2π
```

**実用的な計算例:**
- **50%進捗**: 2π × 0.5 = π ラジアン（180度）
- **75%進捗**: 2π × 0.75 = 1.5π ラジアン（270度）
- **100%進捗**: 2π × 1.0 = 2π ラジアン（360度）

## アニメーションパフォーマンス最適化

### 1. フレームレートの監視

```dart
void debugAnimationPerformance() {
  WidgetsBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
    for (FrameTiming timing in timings) {
      final double frameTime = timing.totalSpan.inMilliseconds;
      if (frameTime > 16.67) { // 60FPSを下回る場合
        debugPrint('Slow frame detected: ${frameTime}ms');
      }
    }
  });
}
```

### 2. 描画処理の最適化テクニック

```dart
// ✅ 良い例: 重い処理を事前計算
@override
void paint(Canvas canvas, Size size) {
  // 描画中に毎回計算するのではなく、事前に計算しておく
  final double radius = _cachedRadius ?? (size.width / 2 - 20);
  final Offset center = _cachedCenter ?? Offset(size.width / 2, size.height / 2);
  
  // 実際の描画処理
  _drawOptimized(canvas, center, radius);
}

// ❌ 悪い例: 描画中に重い計算
@override
void paint(Canvas canvas, Size size) {
  // 毎フレーム複雑な計算を実行すると重い
  for (int i = 0; i < 100; i++) {
    final double angle = (i / 100) * 2 * math.pi;
    final Offset point = Offset(
      size.width / 2 + math.cos(angle) * (size.width / 2 - 20),
      size.height / 2 + math.sin(angle) * (size.height / 2 - 20),
    );
    canvas.drawCircle(point, 2, Paint());
  }
}
```

## 実装上の注意点

### 1. メモリ管理

```dart
class DonutAnimationState {
  AnimationController? progressController;
  bool _isDisposed = false;

  void dispose() {
    if (!_isDisposed && progressController != null) {
      progressController!.dispose();
      _isDisposed = true;
    }
  }
}
```

**重要ポイント:**
- **dispose済みチェック**: 二重解放を防ぐ
- **null安全**: AnimationControllerのnullチェック
- **リークの防止**: 確実なリソース解放

### 2. 数値の境界チェック

```dart
double _calculateProgress(ReadingBookValueObject value) {
  if (value.totalPages <= 0) {
    return 0; // ゼロ除算を防ぐ
  }
  return (value.readingPageNum / value.totalPages).clamp(0, 1); // 0-1に制限
}
```

**防御的プログラミング:**
- **ゼロ除算の回避**: 分母が0の場合の処理
- **範囲制限**: clamp()で有効な値範囲を保証
- **異常値の処理**: 負の値や無効な値への対処

### 3. 非同期処理の制御

```dart
void animateToProgress(double progress) {
  if (targetProgress != progress && progressController != null) {
    targetProgress = progress;
    
    progressController!.reset();
    unawaited(progressController!.forward()); // 完了を待たない
  }
}
```

**非同期設計の考慮:**
- **unawaited**: 完了を待たずに次の処理を実行
- **条件分岐**: 必要な時のみアニメーション開始
- **状態の一貫性**: targetProgressで重複実行を防ぐ

## 学習の進め方

### 1. 段階的な実装アプローチ

#### レベル1: 基本的な円描画
```dart
// シンプルな円から始める
@override
void paint(Canvas canvas, Size size) {
  final Paint paint = Paint()..color = Colors.blue;
  final Offset center = Offset(size.width / 2, size.height / 2);
  canvas.drawCircle(center, 50, paint);
}
```

#### レベル2: アーク描画の追加
```dart
// 部分的な円弧を描画
canvas.drawArc(
  Rect.fromCircle(center: center, radius: 50),
  0, // 開始角度
  math.pi, // 描画角度（180度）
  false, // useCenter（true=扇形、false=弧）
  paint,
);
```

#### レベル3: アニメーション統合
```dart
// AnimationBuilderでアニメーション追加
AnimatedBuilder(
  animation: controller,
  builder: (context, child) {
    return CustomPaint(
      painter: MyPainter(progress: controller.value),
    );
  },
)
```

#### レベル4: インタラクション追加
```dart
// GestureDetectorでタップ処理
GestureDetector(
  onTap: () => triggerAnimation(),
  child: CustomPaint(painter: MyPainter()),
)
```

### 2. 実践的な課題

- [ ] **基礎課題**: 静的なドーナツチャートを実装
- [ ] **応用課題**: 複数の進捗を表示するマルチリングチャート
- [ ] **発展課題**: データに応じて色が変化するチャート
- [ ] **上級課題**: 3Dエフェクト付きの立体的なチャート

### 3. デバッグと検証

```dart
// デバッグ用の描画補助
void _debugDrawGuides(Canvas canvas, Size size) {
  final Paint guidePaint = Paint()
    ..color = Colors.red.withValues(alpha: 0.3)
    ..style = PaintingStyle.stroke;
  
  // 中心線の描画
  canvas.drawLine(
    Offset(0, size.height / 2),
    Offset(size.width, size.height / 2),
    guidePaint,
  );
  
  // 半径ガイドの描画
  canvas.drawCircle(
    Offset(size.width / 2, size.height / 2),
    radius,
    guidePaint,
  );
}
```

## まとめ

インタラクティブドーナツチャートの実装は、Flutterの高度な描画技術を学習する優れた教材です：

- **CustomPainter**: 低レベルな描画APIの活用
- **数学的知識**: 三角関数と座標変換の実践
- **アニメーション**: 滑らかで自然な動きの実現
- **最適化**: パフォーマンスを考慮した効率的な実装
- **インタラクション**: ユーザー操作への応答

これらの技術は、データ可視化やゲーム開発、創造的なUIデザインなど、幅広い分野で応用できる基盤となります。

## 参考資料

### 公式ドキュメント
- [Flutter CustomPainter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)
- [Flutter Canvas](https://api.flutter.dev/flutter/dart-ui/Canvas-class.html)
- [Flutter Paint](https://api.flutter.dev/flutter/dart-ui/Paint-class.html)

### 数学リソース
- [Trigonometry for Game Programming](https://docs.flutter.dev/cookbook/animation/animated-container)
- [Coordinate Systems in Computer Graphics](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial)

### パフォーマンス最適化
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Measuring Performance](https://docs.flutter.dev/perf/ui-performance)