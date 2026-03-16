import 'package:flutter/material.dart';

class VerticalBarGaugePainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color accentColor;
  final String label;

  VerticalBarGaugePainter({
    required this.value,
    this.min = 0,
    this.max = 100,
    this.accentColor = Colors.cyanAccent,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.fill;

    // Background bar
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);

    // Fill bar
    final fillHeight = (value - min) / (max - min) * size.height;
    final fillRect = Rect.fromLTWH(0, size.height - fillHeight, size.width, fillHeight);
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [accentColor.withOpacity(0.5), accentColor],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

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

  @override
  bool shouldRepaint(covariant VerticalBarGaugePainter oldDelegate) => oldDelegate.value != value;
}
