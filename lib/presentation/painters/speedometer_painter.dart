import 'dart:math';
import 'package:flutter/material.dart';
import 'base_gauge_painter.dart';

class SpeedometerPainter extends BaseGaugePainter {
  SpeedometerPainter({
    required super.value,
    super.min = 0,
    super.max = 240,
    super.accentColor = const Color(0xFF00E5FF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Draw background arc
    final bgPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      150 * (pi / 180),
      240 * (pi / 180),
      false,
      bgPaint,
    );

    // Draw active value arc (Neon Glow)
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [accentColor.withOpacity(0.1), accentColor],
        stops: const [0.0, 1.0],
        startAngle: 150 * (pi / 180),
        endAngle: (150 + 240) * (pi / 180),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      150 * (pi / 180),
      angle,
      false,
      progressPaint,
    );

    drawScale(canvas, size);
    drawNeedle(canvas, size);
  }

  @override
  void drawScale(Canvas canvas, Size size, {int segments = 8}) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    for (int i = 0; i <= segments; i++) {
        final tickAngle = (150 + (i * 240 / segments)) * (pi / 180);
        final start = Offset(
            center.dx + (radius - 15) * cos(tickAngle),
            center.dy + (radius - 15) * sin(tickAngle),
        );
        final end = Offset(
            center.dx + (radius - 5) * cos(tickAngle),
            center.dy + (radius - 5) * sin(tickAngle),
        );

        final tickPaint = Paint()
            ..color = i / segments * 240 <= value ? accentColor : Colors.white24
            ..strokeWidth = 2;
        
        canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  void drawNeedle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final needleAngle = (150 * (pi / 180)) + angle;

    final needlePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final needleEnd = Offset(
      center.dx + (radius - 20) * cos(needleAngle),
      center.dy + (radius - 20) * sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);
    
    // Needle center point
    canvas.drawCircle(center, 8, Paint()..color = Colors.black);
    canvas.drawCircle(center, 5, Paint()..color = accentColor);
  }

  @override
  void drawValue(Canvas canvas, Size size) {}
}
