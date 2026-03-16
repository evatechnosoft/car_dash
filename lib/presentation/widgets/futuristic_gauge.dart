import 'package:flutter/material.dart';
import '../../domain/models/gauge_config.dart';
import '../painters/speedometer_painter.dart';

class FuturisticGauge extends StatelessWidget {
  final double value;
  final String label;
  final String unit;
  final Color accentColor;
  final double glowIntensity;
  final GaugeVariant variant;
  
  // Concentric Nested Gauge support
  final Widget? innerGauge;
  final double? innerValue;
  final String? innerUnit;
  final String? innerLabel;

  const FuturisticGauge({
    super.key,
    required this.value,
    this.label = "SPEED",
    this.unit = "km/h",
    this.accentColor = const Color(0xFF00E5FF),
    this.glowIntensity = 0.5,
    this.variant = GaugeVariant.standard,
    this.innerGauge,
    this.innerValue,
    this.innerUnit,
    this.innerLabel,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 200;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 1. Primary Gauge Ring
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: SpeedometerPainter(
                  value: value,
                  accentColor: accentColor,
                  glowIntensity: glowIntensity,
                  variant: variant,
                  // If we have an inner gauge, we might want to hide the central needle hub
                  hollowRadius: innerGauge != null ? size * 0.4 : 0,
                ),
              ),
            ),
            
            // 2. Nested Content / Gauge
            if (innerGauge != null)
              // Center the nested gauge and scale it down
              SizedBox(
                width: size * 1.0, // Container is full size but we scale inner
                height: size * 1.0,
                child: Center(
                  child: Transform.scale(
                    scale: 0.6, // Concentric scale
                    child: innerGauge,
                  ),
                ),
              )
            else if (variant != GaugeVariant.classic)
              // Only show digital text if NOT "Classic" OR if no inner gauge is present
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (innerValue ?? value).toInt().toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: variant == GaugeVariant.neon ? 32 : (innerValue != null ? 38 : 48),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                      shadows: [
                        Shadow(color: accentColor.withOpacity(0.8), blurRadius: glowIntensity * 20),
                      ],
                    ),
                  ),
                  Text(
                    innerUnit ?? unit,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: innerValue != null ? 12 : 14,
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
