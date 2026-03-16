import 'dart:math';
import 'package:flutter/material.dart';

abstract class BaseGaugePainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color accentColor;

  BaseGaugePainter({
    required this.value,
    this.min = 0,
    this.max = 200,
    this.accentColor = Colors.cyanAccent,
  });

  double get angle => (value - min) / (max - min) * 240 * (pi / 180);

  void drawScale(Canvas canvas, Size size, {int segments = 10});
  void drawNeedle(Canvas canvas, Size size);
  void drawValue(Canvas canvas, Size size);

  @override
  bool shouldRepaint(covariant BaseGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.accentColor != accentColor;
  }
}
