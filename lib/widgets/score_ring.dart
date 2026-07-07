import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Animated circular quality-score gauge with count-up + elastic easing.
class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.score, this.size = 180});

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forScore(score);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: score.toDouble()),
      duration: const Duration(milliseconds: 1400),
      curve: const Cubic(.34, 1.56, .64, 1),
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(value: value, color: color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.round().toString(),
                    style: AppTheme.ui(
                      size: size * 0.28,
                      weight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: AppTheme.ui(
                      size: size * 0.09,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 18) / 2;
    final stroke = 14.0;

    final bgPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final sweep = (value / 100) * 2 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [color, AppColors.cyanBright, color],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color;
}
