import 'package:flutter/material.dart';
import '../painters/speedometer_painter.dart';

class FuturisticGauge extends StatelessWidget {
  final double value;
  final String label;
  final String unit;
  final Color accentColor;

  const FuturisticGauge({
    super.key,
    required this.value,
    this.label = "SPEED",
    this.unit = "km/h",
    this.accentColor = const Color(0xFF00E5FF),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: SpeedometerPainter(
                  value: value,
                  accentColor: accentColor,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier', // Futuristic fallback
                    shadows: [
                      Shadow(color: accentColor, blurRadius: 10),
                    ],
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: accentColor.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
