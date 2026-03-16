import 'package:flutter/material.dart';

enum GaugeType {
  speed,
  soc,
  range,
  temp, // Motor Temp
  powerFlow,
  rpm,
  current,
  voltage,
  controllerTemp,
  power,
}

enum GaugeStyle {
  analog,
  digital,
  bar,
}

enum GaugeVariant {
  standard,
  classic,
  neon,
  segmented,
  gradient,
}

class GaugeConfig {
  final String id;
  final GaugeType type;
  final GaugeStyle style;
  Offset position;
  double scale;
  Color accentColor;
  double glowIntensity;
  final String label;
  final String unit;
  final double maxValue;
  final GaugeVariant variant;
  final GaugeType? innerMetric; // For hybrid gauges, which metric to show in center
  final GaugeStyle? innerStyle; // Style for the nested gauge
  final GaugeVariant? innerVariant; // Variant for the nested gauge

  GaugeConfig({
    required this.id,
    required this.type,
    this.style = GaugeStyle.analog,
    required this.position,
    this.scale = 1.0,
    required this.accentColor,
    this.glowIntensity = 0.5,
    required this.label,
    required this.unit,
    required this.maxValue,
    this.variant = GaugeVariant.standard,
    this.innerMetric,
    this.innerStyle,
    this.innerVariant,
  });

  GaugeConfig copyWith({
    GaugeStyle? style,
    Offset? position,
    double? scale,
    Color? accentColor,
    double? glowIntensity,
    GaugeVariant? variant,
    GaugeType? innerMetric,
    bool clearInnerMetric = false,
    GaugeStyle? innerStyle,
    GaugeVariant? innerVariant,
  }) {
    return GaugeConfig(
      id: id,
      type: type,
      style: style ?? this.style,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      accentColor: accentColor ?? this.accentColor,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      label: label,
      unit: unit,
      maxValue: maxValue,
      variant: variant ?? this.variant,
      innerMetric: clearInnerMetric ? null : (innerMetric ?? this.innerMetric),
      innerStyle: innerStyle ?? this.innerStyle,
      innerVariant: innerVariant ?? this.innerVariant,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'style': style.index,
      'dx': position.dx,
      'dy': position.dy,
      'scale': scale,
      'color': accentColor.value,
      'glow': glowIntensity,
      'label': label,
      'unit': unit,
      'max': maxValue,
      'variant': variant.index,
      'innerMetric': innerMetric?.index,
      'innerStyle': innerStyle?.index,
      'innerVariant': innerVariant?.index,
    };
  }

  factory GaugeConfig.fromJson(Map<String, dynamic> json) {
    return GaugeConfig(
      id: json['id'],
      type: GaugeType.values[(json['type'] as num).toInt()],
      style: GaugeStyle.values[(json['style'] as num).toInt()],
      position: Offset((json['dx'] as num).toDouble(), (json['dy'] as num).toDouble()),
      scale: (json['scale'] as num).toDouble(),
      accentColor: Color((json['color'] as num).toInt()),
      glowIntensity: (json['glow'] as num?)?.toDouble() ?? 0.5,
      label: json['label'],
      unit: json['unit'],
      maxValue: (json['max'] as num).toDouble(),
      variant: json['variant'] != null ? GaugeVariant.values[json['variant'] as int] : GaugeVariant.standard,
      innerMetric: json['innerMetric'] != null ? GaugeType.values[json['innerMetric'] as int] : null,
      innerStyle: json['innerStyle'] != null ? GaugeStyle.values[json['innerStyle'] as int] : null,
      innerVariant: json['innerVariant'] != null ? GaugeVariant.values[json['innerVariant'] as int] : null,
    );
  }
}
