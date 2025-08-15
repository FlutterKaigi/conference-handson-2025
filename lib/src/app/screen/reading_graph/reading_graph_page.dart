import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/reading_book_value_object.dart';
import '../../../presentation/model/view_model_packages.dart';

class ReadingGraphPage extends ConsumerWidget {
  /// コンストラクタ
  const ReadingGraphPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ReadingBookValueObject value = ref
        .read(readingBooksProvider.notifier)
        .currentEditReadingBook!;

    final int totalPages = value.totalPages;
    final int readPages = value.readingPageNum;
    double progress = 0;
    if (totalPages > 0 && readPages > 0) {
      progress = (readPages / totalPages).clamp(0.0, 1.0);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('読書進捗グラフ'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '総ページ数: $totalPages',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '読了ページ数: $readPages',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: PieChartPainter(progress: progress),
                  child: Center(
                    child: Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (progress == 1.0)
                Text(
                  '読了おめでとうございます！',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double progress; // 0.0 から 1.0

  PieChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width / 2, size.height / 2);

    // 背景の円（薄いグレー）
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20; // 円の線の太さ
    canvas.drawCircle(center, radius, backgroundPaint);

    // 進捗の円弧
    final Paint progressPaint = Paint()
      ..color = Colors.blue // 進捗の色
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round // 線の端を丸くする
      ..strokeWidth = 20; // 円の線の太さ

    // -90度（12時の方向）から進捗分の角度を描画
    const double startAngle = -math.pi / 2;
    final double sweepAngle = 2 * math.pi * progress;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
