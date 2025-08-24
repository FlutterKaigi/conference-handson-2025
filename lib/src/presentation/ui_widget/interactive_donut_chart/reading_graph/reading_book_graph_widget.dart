import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/model/reading_book_value_object.dart';
import '../../../../fundamental/ui_widget/consumer_staged_widget.dart';

class ReadingBookGraphWidget
    extends ConsumerStagedWidget<ReadingBookValueObject, ProgressDonutState> {
  const ReadingBookGraphWidget({
    required super.provider,
    super.builders,
    super.selectBuilder,
    super.key,
  });

  @override
  ProgressDonutState? createWidgetState() {
    return ProgressDonutState();
  }

  @override
  void disposeState(ProgressDonutState? state) {
    // disposeは_ProgressDonutWidgetStateで行う
    super.disposeState(state);
  }

  void _onDonutTap(ProgressDonutState state) {
    state.triggerPulseAnimation();
    unawaited(HapticFeedback.lightImpact());
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ReadingBookValueObject value,
    ProgressDonutState? state,
  ) {
    final ProgressDonutState controllers = state!;
    final double progress = value.totalPages > 0
        ? (value.readingPageNum / value.totalPages).clamp(0.0, 1.0)
        : 0.0;

    // Start progress animation on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controllers.animateToProgress(progress);
    });

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Title Section
          Text(
            value.name.isNotEmpty ? value.name : '読書進捗',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% 完了',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),

          // Main Progress Donut Chart
          _ProgressDonutWidget(
            state: controllers,
            value: value,
            onTap: () => _onDonutTap(controllers),
          ),

          const SizedBox(height: 32),

          // Progress Statistics
          _buildProgressInfo(context, value, progress),
        ],
      ),
    );
  }

  Widget _buildProgressInfo(
    BuildContext context,
    ReadingBookValueObject value,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildStatItem(
            context,
            '${value.readingPageNum}',
            '読了ページ',
            Icons.book_outlined,
            Theme.of(context).colorScheme.primary,
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            context,
            '${value.totalPages}',
            '総ページ',
            Icons.menu_book_outlined,
            Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Progress Donut Widget with proper animations
class _ProgressDonutWidget extends StatefulWidget {
  const _ProgressDonutWidget({
    required this.state,
    required this.value,
    required this.onTap,
  });

  final ProgressDonutState state;
  final ReadingBookValueObject value;
  final VoidCallback onTap;

  @override
  State<_ProgressDonutWidget> createState() => _ProgressDonutWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
    properties.add(DiagnosticsProperty<ReadingBookValueObject>('value', value));
    properties.add(DiagnosticsProperty<ProgressDonutState>('state', state));
  }
}

class _ProgressDonutWidgetState extends State<_ProgressDonutWidget>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.state.initializeAnimations(this);
  }

  @override
  void dispose() {
    widget.state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          widget.state.progressController ??
          const AlwaysStoppedAnimation<double>(0),
      builder: (BuildContext context, Widget? child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Background glow effect
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Main donut chart
                CustomPaint(
                  size: const Size(280, 280),
                  painter: ProgressDonutPainter(
                    progress: widget.state.animatedProgress,
                    pulseValue: widget.state.pulseValue,
                    colorScheme: Theme.of(context).colorScheme,
                  ),
                ),

                // Center content
                _buildCenterContent(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterContent() {
    final double progress = widget.state.animatedProgress;
    final bool isCompleted = progress >= 1.0;
    final int remainingPages =
        widget.value.totalPages - widget.value.readingPageNum;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Container(
        key: ValueKey<bool>(isCompleted),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isCompleted) ...<Widget>[
              Icon(
                Icons.celebration_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                '完読達成！',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...<Widget>[
              Text(
                '残り',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$remainingPages',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                  height: 1,
                ),
              ),
              Text(
                'ページ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Progress Donut State with proper progress animation
class ProgressDonutState {
  AnimationController? progressController;
  Animation<double>? progressAnimation;
  bool _isDisposed = false;

  double targetProgress = 0;
  double progressValue = 0;
  double pulseValue = 0;

  double get animatedProgress => progressAnimation?.value ?? progressValue;

  void initializeAnimations(TickerProvider vsync) {
    progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );

    progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: progressController!, curve: Curves.easeOutCubic),
    );
  }

  void animateToProgress(double progress) {
    if (targetProgress != progress && progressController != null) {
      targetProgress = progress;

      // Create new animation from current value to target
      progressAnimation = Tween<double>(begin: animatedProgress, end: progress)
          .animate(
            CurvedAnimation(
              parent: progressController!,
              curve: Curves.easeOutCubic,
            ),
          );

      progressController!.reset();
      unawaited(progressController!.forward());
    }
  }

  void triggerPulseAnimation() {
    pulseValue = 1;
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        pulseValue = 0;
      }),
    );
  }

  void dispose() {
    if (!_isDisposed && progressController != null) {
      progressController!.dispose();
      _isDisposed = true;
    }
  }
}

// Custom Painter for the progress donut
class ProgressDonutPainter extends CustomPainter {
  ProgressDonutPainter({
    required this.progress,
    required this.pulseValue,
    required this.colorScheme,
  });

  final double progress;
  final double pulseValue;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2 - 20;
    const double strokeWidth = 16;

    // Background circle
    final Paint backgroundPaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 進捗アーク（単色）
    if (progress > 0) {
      final Paint progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + (pulseValue * 4)
        ..strokeCap = StrokeCap.round
        ..color = colorScheme.primary;

      // 進捗グロー効果
      final Paint glowPaint = Paint()
        ..color = colorScheme.primary.withValues(alpha: 0.3 + pulseValue * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Draw glow first
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );

      // Draw main progress arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );

      // 進捗インジケーター（ドット）
      final double endAngle = -math.pi / 2 + 2 * math.pi * progress;
      final Offset dotPosition = Offset(
        center.dx + math.cos(endAngle) * radius,
        center.dy + math.sin(endAngle) * radius,
      );

      final Paint dotPaint = Paint()
        ..color = colorScheme.primary
        ..style = PaintingStyle.fill;

      canvas.drawCircle(dotPosition, 6 + pulseValue * 2, dotPaint);

      // ドットグロー効果
      final Paint dotGlowPaint = Paint()
        ..color = colorScheme.primary.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(dotPosition, 8 + pulseValue * 3, dotGlowPaint);
    }
  }

  @override
  bool shouldRepaint(ProgressDonutPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        pulseValue != oldDelegate.pulseValue;
  }
}
