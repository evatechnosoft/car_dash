import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/models/gauge_config.dart';
import 'base_gauge_painter.dart';

class SpeedometerPainter extends BaseGaugePainter {
  final GaugeVariant variant;
  final double hollowRadius; // radius to leave empty for nested gauge

  SpeedometerPainter({
    required super.value,
    super.min = 0,
    super.max = 240,
    super.accentColor = const Color(0xFF00E5FF),
    super.glowIntensity = 0.5,
    this.variant = GaugeVariant.standard,
    this.hollowRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (variant == GaugeVariant.classic) {
      _paintClassic(canvas, size);
      return;
    }
    if (variant == GaugeVariant.neon) {
      _paintNeon(canvas, size);
      return;
    }
    _paintPremium(canvas, size);
  }

  void _paintPremium(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // 1. Outer Glow Ring (Subtle)
    final outerRingPaint = Paint()
      ..color = accentColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerRingPaint);

    // 2. Main Gauge Track (Layered)
    final trackRect = Rect.fromCircle(center: center, radius: radius - 10);
    
    // Background Arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(trackRect, 150 * (pi / 180), 240 * (pi / 180), false, bgPaint);

    // 3. Active Progress (Glassy/Neon)
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [accentColor.withOpacity(0.1), accentColor],
        stops: const [0.0, 1.0],
        startAngle: 150 * (pi / 180),
        endAngle: (150 + 240) * (pi / 180),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + glowIntensity * 12);

    canvas.drawArc(trackRect, 150 * (pi / 180), angle, false, progressPaint);

    // 4. Multi-level Ticks
    _drawPremiumTicks(canvas, center, radius);

    // 5. Tapered Premium Needle (Only if not hollow or specific logic)
    if (hollowRadius < radius * 0.4) {
      _drawPremiumNeedle(canvas, center, radius);
    }
  }

  void _drawPremiumTicks(Canvas canvas, Offset center, double radius) {
    const int mainSegments = 10;
    const int subSegments = 50;

    for (int i = 0; i <= subSegments; i++) {
        final tickAngle = (150 + (i * 240 / subSegments)) * (pi / 180);
        final isMain = i % (subSegments / mainSegments) == 0;
        
        final length = isMain ? 12.0 : 6.0;
        final startDist = radius - 18;
        final start = Offset(center.dx + startDist * cos(tickAngle), center.dy + startDist * sin(tickAngle));
        final end = Offset(center.dx + (startDist + length) * cos(tickAngle), center.dy + (startDist + length) * sin(tickAngle));

        final tickColor = (i / subSegments * (this.max - this.min) + this.min <= value) 
            ? accentColor.withOpacity(0.8) 
            : Colors.white24;

        canvas.drawLine(start, end, Paint()..color = tickColor..strokeWidth = isMain ? 2 : 1);
    }
  }

  void _drawPremiumNeedle(Canvas canvas, Offset center, double radius) {
    final needleAngle = (150 * (pi / 180)) + angle;
    final needleRadius = radius - 15;

    // Hub
    canvas.drawCircle(center, 12, Paint()..color = Colors.black);
    canvas.drawCircle(center, 12, Paint()..color = accentColor.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 2);
    
    // Needle Path (Tapered)
    final Path path = Path();
    final double baseWidth = 6.0;

    final double perpAngle = needleAngle + (pi / 2);
    final Offset p1 = Offset(center.dx + cos(perpAngle) * baseWidth, center.dy + sin(perpAngle) * baseWidth);
    final Offset p2 = Offset(center.dx - cos(perpAngle) * baseWidth, center.dy - sin(perpAngle) * baseWidth);
    final Offset tip = Offset(center.dx + cos(needleAngle) * needleRadius, center.dy + sin(needleAngle) * needleRadius);

    path.moveTo(p1.dx, p1.dy);
    path.lineTo(tip.dx, tip.dy);
    path.lineTo(p2.dx, p2.dy);
    path.close();

    final needlePaint = Paint()
      ..shader = LinearGradient(
        colors: [accentColor.withOpacity(0.4), accentColor, Colors.white],
        stops: const [0.0, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 + glowIntensity * 5);

    canvas.drawPath(path, needlePaint);
    
    canvas.drawCircle(center, 5, Paint()..color = Colors.white..maskFilter = MaskFilter.blur(BlurStyle.normal, 2));
  }

  void _paintClassic(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Classic background (Matte black/grey)
    canvas.drawCircle(center, radius - 2, Paint()..color = const Color(0xFF1A1A1A)..style = PaintingStyle.fill);
    
    // Chrome bezel
    final bezelPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.grey.shade400, Colors.grey.shade800, Colors.grey.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius - 2, bezelPaint);

    // Precise Scale
    const double startAngle = 150;
    const double sweepAngle = 240;
    for (int i = 0; i <= 60; i++) {
        final tickAngle = (startAngle + (i * sweepAngle / 60)) * (pi / 180);
        final isMajor = i % 5 == 0;
        
        final length = isMajor ? 15.0 : 8.0;
        final start = Offset(center.dx + (radius - 10 - length) * cos(tickAngle), center.dy + (radius - 10 - length) * sin(tickAngle));
        final end = Offset(center.dx + (radius - 10) * cos(tickAngle), center.dy + (radius - 10) * sin(tickAngle));
        
        canvas.drawLine(start, end, Paint()..color = Colors.white70..strokeWidth = isMajor ? 2.5 : 1.2);
    }

    // Classic Matte Needle (NO NEON)
    if (hollowRadius < radius * 0.4) {
      _drawClassicNeedle(canvas, center, radius);
    }
  }

  void _drawClassicNeedle(Canvas canvas, Offset center, double radius) {
    final needleAngle = (150 * (pi / 180)) + angle;
    final needleRadius = radius - 15;

    // Hub
    canvas.drawCircle(center, 15, Paint()..color = const Color(0xFF222222));
    canvas.drawCircle(center, 15, Paint()..color = Colors.white10..style = PaintingStyle.stroke..strokeWidth = 1);

    // Needle - Matte Red/Orange
    final Path path = Path();
    final double baseWidth = 4.0;
    final double perpAngle = needleAngle + (pi / 2);
    
    final Offset p1 = Offset(center.dx + cos(perpAngle) * baseWidth, center.dy + sin(perpAngle) * baseWidth);
    final Offset p2 = Offset(center.dx - cos(perpAngle) * baseWidth, center.dy - sin(perpAngle) * baseWidth);
    final Offset tip = Offset(center.dx + cos(needleAngle) * needleRadius, center.dy + sin(needleAngle) * needleRadius);

    path.moveTo(p1.dx, p1.dy);
    path.lineTo(tip.dx, tip.dy);
    path.lineTo(p2.dx, p2.dy);
    path.close();

    canvas.drawPath(path, Paint()..color = const Color(0xFFFF3D00)..style = PaintingStyle.fill);
    
    // Hub pin
    canvas.drawCircle(center, 3, Paint()..color = Colors.grey.shade400);
  }

  void _paintNeon(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final neonPaint = Paint()
      ..color = accentColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * glowIntensity);
    
    canvas.drawCircle(center, radius - 10, neonPaint);

    final activePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * glowIntensity);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 10), 150 * (pi / 180), angle, false, activePaint);
    
    final dotX = center.dx + (radius - 10) * cos((150 * (pi / 180)) + angle);
    final dotY = center.dy + (radius - 10) * sin((150 * (pi / 180)) + angle);
    canvas.drawCircle(Offset(dotX, dotY), 8, Paint()..color = accentColor..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * glowIntensity));
    canvas.drawCircle(Offset(dotX, dotY), 4, Paint()..color = Colors.white);
  }

  @override
  void drawScale(Canvas canvas, Size size, {int segments = 8}) {}
  @override
  void drawNeedle(Canvas canvas, Size size) {}
  @override
  void drawValue(Canvas canvas, Size size) {}
}
