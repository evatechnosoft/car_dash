import 'package:flutter/material.dart';
import '../../domain/models/gauge_config.dart';
import 'futuristic_gauge.dart';
import 'vertical_info_bar.dart';
import 'power_flow_monitor.dart';
import 'digital_gauge.dart';

class GenericGauge extends StatelessWidget {
  final GaugeConfig config;
  final double value;
  
  // Optional secondary metric data (extracted in parent)
  final double? secondaryValue;
  final String? secondaryUnit;
  final String? secondaryLabel;

  const GenericGauge({
    super.key,
    required this.config,
    required this.value,
    this.secondaryValue,
    this.secondaryUnit,
    this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Resolve Inner Gauge (Recursive support)
    Widget? nestedGauge;
    if (config.innerMetric != null && config.innerStyle != null && secondaryValue != null) {
      // Build a minimalist config for the inner nested gauge
      final innerConfig = GaugeConfig(
        id: "${config.id}_inner",
        type: config.innerMetric!,
        style: config.innerStyle!,
        variant: config.innerVariant ?? GaugeVariant.standard,
        position: Offset.zero,
        accentColor: config.accentColor,
        label: secondaryLabel ?? "",
        unit: secondaryUnit ?? "",
        maxValue: 100, // Normalized for inner display or we could pass it
      );

      nestedGauge = GenericGauge(
        config: innerConfig,
        value: secondaryValue!,
      );
    }

    // 2. Render current style
    if (config.style == GaugeStyle.digital) {
      return DigitalGauge(
        value: value,
        label: config.label,
        unit: config.unit,
        accentColor: config.accentColor,
        glowIntensity: config.glowIntensity,
        variant: config.variant,
      );
    }

    if (config.style == GaugeStyle.bar) {
      return VerticalInfoBar(
        value: value,
        max: config.maxValue,
        label: config.label,
        unit: config.unit,
        accentColor: config.accentColor,
        glowIntensity: config.glowIntensity,
        variant: config.variant,
      );
    }

    // Default or Analog
    switch (config.type) {
      case GaugeType.speed:
      case GaugeType.rpm:
        return FuturisticGauge(
          value: value,
          label: config.label,
          unit: config.unit,
          accentColor: config.accentColor,
          glowIntensity: config.glowIntensity,
          variant: config.variant,
          innerGauge: nestedGauge, // Pass the recursive widget!
          innerValue: secondaryValue,
          innerUnit: secondaryUnit,
          innerLabel: secondaryLabel,
        );
      case GaugeType.soc:
      case GaugeType.range:
      case GaugeType.temp:
      case GaugeType.controllerTemp:
      case GaugeType.voltage:
        return VerticalInfoBar(
          value: value,
          max: config.maxValue,
          label: config.label,
          unit: config.unit,
          accentColor: config.accentColor,
          glowIntensity: config.glowIntensity,
          variant: config.variant,
        );
      case GaugeType.powerFlow:
      case GaugeType.power:
        return PowerFlowMonitor(
          power: value,
        );
      case GaugeType.current:
        return VerticalInfoBar(
          value: value,
          max: config.maxValue,
          label: config.label,
          unit: config.unit,
          accentColor: config.accentColor,
          glowIntensity: config.glowIntensity,
          variant: config.variant,
        );
    }
  }
}
