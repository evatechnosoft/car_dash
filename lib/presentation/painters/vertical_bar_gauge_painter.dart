import 'package:flutter/material.dart';
import '../../domain/models/gauge_config.dart';

class VerticalBarGaugePainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color accentColor;
  final String label;
  final double glowIntensity;
  final GaugeVariant variant;

  VerticalBarGaugePainter({
    required this.value,
    this.min = 0,
    this.max = 100,
    this.accentColor = Colors.cyanAccent,
    required this.label,
    this.glowIntensity = 0.5,
    this.variant = GaugeVariant.standard,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (variant == GaugeVariant.segmented) {
      _paintSegmented(canvas, size);
      return;
    }
    _paintStandard(canvas, size);
  }

  void _paintStandard(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.fill;

    // Background bar
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);

    // Fill bar
    final fillHeight = ((value - min) / (max - min)).clamp(0.0, 1.0) * size.height;
    final fillRect = Rect.fromLTWH(0, size.height - fillHeight, size.width, fillHeight);
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [accentColor.withOpacity(0.5), accentColor],
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 + glowIntensity * 15);

    canvas.drawRRect(RRect.fromRectAndRadius(fillRect, const Radius.circular(4)), fillPaint);

    // Scale ticks
    final tickPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
        final y = size.height - (i / 5 * size.height);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), tickPaint);
    }
  }

  void _paintSegmented(Canvas canvas, Size size) {
    const int totalSegments = 10;
    final segmentHeight = (size.height - (totalSegments - 1) * 2) / totalSegments;
    final activeSegments = (((value - min) / (max - min)).clamp(0.0, 1.0) * totalSegments).floor();

    for (int i = 0; i < totalSegments; i++) {
      final y = size.height - (i + 1) * segmentHeight - i * 2;
      final rect = Rect.fromLTWH(0, y, size.width, segmentHeight);
      final isActive = i < activeSegments;

      final paint = Paint()
        ..color = isActive ? accentColor : Colors.white10
        ..maskFilter = isActive ? MaskFilter.blur(BlurStyle.normal, 2 + glowIntensity * 5) : null;

      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant VerticalBarGaugePainter oldDelegate) => 
    oldDelegate.value != value || oldDelegate.variant != variant || oldDelegate.accentColor != accentColor;
}
