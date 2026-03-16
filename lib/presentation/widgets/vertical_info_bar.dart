import 'package:flutter/material.dart';
import '../../domain/models/gauge_config.dart';
import '../painters/vertical_bar_gauge_painter.dart';

class VerticalInfoBar extends StatelessWidget {
  final double value;
  final double max;
  final String label;
  final String unit;
  final Color accentColor;
  final double glowIntensity;

  final GaugeVariant variant;

  const VerticalInfoBar({
    super.key,
    required this.value,
    this.max = 100,
    required this.label,
    required this.unit,
    this.accentColor = Colors.cyanAccent,
    this.glowIntensity = 0.5,
    this.variant = GaugeVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 30,
          height: 120,
          child: CustomPaint(
            painter: VerticalBarGaugePainter(
              value: value,
              max: max,
              label: label,
              accentColor: accentColor,
              glowIntensity: glowIntensity,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${value.toInt()}",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(
          unit,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: accentColor.withOpacity(0.5), fontSize: 9, letterSpacing: 1),
        ),
      ],
    );
  }
}
