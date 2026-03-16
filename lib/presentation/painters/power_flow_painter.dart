import 'dart:math';
import 'package:flutter/material.dart';

class PowerFlowPainter extends CustomPainter {
  final double power; // Negative for regen, positive for draw
  final double animationValue;

  PowerFlowPainter({
    required this.power,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw flow path
    canvas.drawRect(Rect.fromLTWH(0, size.height / 2 - 5, size.width, 10), paint);

    // Flow particles
    final flowPaint = Paint()
      ..color = power > 0 ? Colors.orangeAccent : Colors.greenAccent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final direction = power > 0 ? 1 : -1;
    final speed = (power.abs() / 100).clamp(0.1, 1.0);
    
    for (int i = 0; i < 5; i++) {
      final offset = (animationValue * speed + (i / 5)) % 1.0;
      final x = direction > 0 ? offset * size.width : (1 - offset) * size.width;
      
      canvas.drawCircle(Offset(x, size.height / 2), 3, flowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PowerFlowPainter oldDelegate) => true;
}
