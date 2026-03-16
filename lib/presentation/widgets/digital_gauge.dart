import 'package:flutter/material.dart';
import '../../domain/models/gauge_config.dart';

class DigitalGauge extends StatelessWidget {
  final double value;
  final String label;
  final String unit;
  final Color accentColor;
  final double glowIntensity;
  final GaugeVariant variant;

  const DigitalGauge({
    super.key,
    required this.value,
    required this.label,
    required this.unit,
    required this.accentColor,
    this.glowIntensity = 0.5,
    this.variant = GaugeVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == GaugeVariant.classic) {
      return _buildClassic(context);
    }
    if (variant == GaugeVariant.neon) {
      return _buildMatrix(context);
    }
    return _buildStandard(context);
  }

  Widget _buildStandard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.2 + glowIntensity * 0.3)),
        boxShadow: [
          BoxShadow(color: accentColor.withOpacity(0.1 * glowIntensity), blurRadius: 20 * glowIntensity, spreadRadius: 5 * glowIntensity)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  shadows: [
                    Shadow(color: accentColor.withOpacity(0.8), blurRadius: glowIntensity * 15),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  unit,
                  style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: 100,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, accentColor, Colors.transparent]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrix(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: accentColor.withOpacity(0.5), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value.toInt().toString(),
            style: TextStyle(
              color: accentColor,
              fontSize: 54,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(color: accentColor.withOpacity(0.5), blurRadius: 2, offset: const Offset(1, 1))
              ],
            ),
          ),
          Text(unit, style: TextStyle(color: accentColor.withOpacity(0.7), fontSize: 10, letterSpacing: 3)),
        ],
      ),
    );
  }

  Widget _buildClassic(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value.toInt().toString(),
          style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w300, letterSpacing: -2),
        ),
        Text(unit, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
