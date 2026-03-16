import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/models/gauge_config.dart';

class GaugeMiniSettings extends StatefulWidget {
  final GaugeConfig config;
  final Function(GaugeConfig) onConfigChanged;
  final VoidCallback onDelete;

  const GaugeMiniSettings({
    super.key,
    required this.config,
    required this.onConfigChanged,
    required this.onDelete,
  });

  @override
  State<GaugeMiniSettings> createState() => _GaugeMiniSettingsState();
}

class _GaugeMiniSettingsState extends State<GaugeMiniSettings> {
  late GaugeConfig _localConfig;

  @override
  void initState() {
    super.initState();
    _localConfig = widget.config;
  }

  void _update(GaugeConfig newConfig) {
    setState(() => _localConfig = newConfig);
    widget.onConfigChanged(newConfig);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 350,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0D101A).withOpacity(0.95),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
          border: Border.all(color: _localConfig.accentColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: Colors.black87, blurRadius: 40, spreadRadius: 10)
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                     _buildStyleSelector(),
                     const SizedBox(height: 30),
                     _buildVariantSelector(),
                     if (_localConfig.style == GaugeStyle.analog) ...[
                       const SizedBox(height: 30),
                       _buildInnerDisplaySelector(),
                     ],
                     const SizedBox(height: 30),
                    _buildSizeAdjuster(),
                    const SizedBox(height: 30),
                    _buildColorPicker(),
                    const SizedBox(height: 40),
                    _buildDeleteButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("EDITOR", style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 3)),
            const SizedBox(height: 5),
            Text(_localConfig.label, style: TextStyle(color: _localConfig.accentColor, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("GUI STYLE", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 15),
        Row(
          children: [
            _styleOption("ANALOG", GaugeStyle.analog),
            const SizedBox(width: 10),
            _styleOption("DIGITAL", GaugeStyle.digital),
            const SizedBox(width: 10),
            _styleOption("BAR", GaugeStyle.bar),
          ],
        ),
      ],
    );
  }

  Widget _styleOption(String label, GaugeStyle style) {
    bool isSelected = _localConfig.style == style;
    return Expanded(
      child: GestureDetector(
        onTap: () => _update(_localConfig.copyWith(style: style, variant: GaugeVariant.standard)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _localConfig.accentColor.withOpacity(0.15) : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? _localConfig.accentColor : Colors.white.withOpacity(0.05)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVariantSelector() {
    List<_VariantItem> variants = [];
    if (_localConfig.style == GaugeStyle.analog) {
      variants = [
        _VariantItem("FUTURISTIC", GaugeVariant.standard),
        _VariantItem("CLASSIC", GaugeVariant.classic),
        _VariantItem("NEON", GaugeVariant.neon),
      ];
    } else if (_localConfig.style == GaugeStyle.digital) {
      variants = [
        _VariantItem("MODERN", GaugeVariant.standard),
        _VariantItem("MINIMAL", GaugeVariant.classic),
        _VariantItem("MATRIX", GaugeVariant.neon),
      ];
    } else if (_localConfig.style == GaugeStyle.bar) {
      variants = [
        _VariantItem("GRADIENT", GaugeVariant.standard),
        _VariantItem("BLOCKS", GaugeVariant.segmented),
      ];
    }

    if (variants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("VISUAL MODEL", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: variants.map((v) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _variantOption(v.label, v.variant),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _variantOption(String label, GaugeVariant variant) {
    bool isSelected = _localConfig.variant == variant;
    return GestureDetector(
      onTap: () => _update(_localConfig.copyWith(variant: variant)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _localConfig.accentColor.withOpacity(0.1) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? _localConfig.accentColor : Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white38,
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSizeAdjuster() {
    return _sectionWrapper(
      title: "SCALING",
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Size Factor", style: TextStyle(color: Colors.white60)),
              Text("${(_localConfig.scale * 100).toInt()}%", style: TextStyle(color: _localConfig.accentColor, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _localConfig.scale,
            min: 0.5,
            max: 2.0,
            activeColor: _localConfig.accentColor,
            onChanged: (val) => _update(_localConfig.copyWith(scale: val)),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return _sectionWrapper(
      title: "ADVANCED COLOR SYSTEM",
      child: Column(
        children: [
          _RadialHuePicker(
            color: _localConfig.accentColor,
            onChanged: (hue) {
              final hsv = HSVColor.fromColor(_localConfig.accentColor);
              _update(_localConfig.copyWith(accentColor: hsv.withHue(hue).toColor()));
            },
          ),
          const SizedBox(height: 30),
          _AdvancedColorSliders(
            color: _localConfig.accentColor,
            glowIntensity: _localConfig.glowIntensity,
            onChanged: (color, glow) => _update(_localConfig.copyWith(
              accentColor: color,
              glowIntensity: glow,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerDisplaySelector() {
    final metrics = [
      (null, "NONE"),
      (GaugeType.speed, "SPEED"),
      (GaugeType.soc, "BATTERY"),
      (GaugeType.range, "RANGE"),
      (GaugeType.temp, "MOTOR"),
      (GaugeType.power, "POWER"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("INNER DISPLAY METRIC", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: metrics.map((m) {
              bool isSelected = _localConfig.innerMetric == m.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _update(_localConfig.copyWith(
                    innerMetric: m.$1,
                    clearInnerMetric: m.$1 == null,
                    // Default inner style if selecting for first time
                    innerStyle: _localConfig.innerStyle ?? GaugeStyle.digital,
                  )),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? _localConfig.accentColor.withOpacity(0.1) : Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? _localConfig.accentColor : Colors.white10),
                    ),
                    child: Text(
                      m.$2,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white38,
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_localConfig.innerMetric != null) ...[
          const SizedBox(height: 25),
          const Text("INNER GUI STYLE", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(height: 15),
          Row(
            children: GaugeStyle.values.map((s) {
              bool isSelected = _localConfig.innerStyle == s;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _update(_localConfig.copyWith(innerStyle: s)),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? _localConfig.accentColor.withOpacity(0.1) : Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? _localConfig.accentColor : Colors.white.withOpacity(0.05)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      s.name.toUpperCase(),
                      style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text("INNER VISUAL MODEL", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(height: 15),
          _buildInnerVariantSelector(),
        ],
      ],
    );
  }

  Widget _buildInnerVariantSelector() {
    List<GaugeVariant> available;
    switch (_localConfig.innerStyle) {
      case GaugeStyle.analog:
        available = [GaugeVariant.standard, GaugeVariant.classic, GaugeVariant.neon];
        break;
      case GaugeStyle.digital:
        available = [GaugeVariant.standard, GaugeVariant.gradient];
        break;
      case GaugeStyle.bar:
        available = [GaugeVariant.standard, GaugeVariant.segmented];
        break;
      default:
        available = [GaugeVariant.standard];
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: available.map((v) {
          bool isSelected = _localConfig.innerVariant == v;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => _update(_localConfig.copyWith(innerVariant: v)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _localConfig.accentColor.withOpacity(0.1) : Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? _localConfig.accentColor : Colors.white.withOpacity(0.05)),
                ),
                child: Text(
                  v.name.toUpperCase(),
                  style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 8),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionWrapper({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.01),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton.icon(
        onPressed: widget.onDelete,
        icon: const Icon(Icons.delete_sweep_outlined),
        label: const Text("UNINSTALL MODULE", style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}

class _VariantItem {
  final String label;
  final GaugeVariant variant;
  _VariantItem(this.label, this.variant);
}

class _RadialHuePicker extends StatelessWidget {
  final Color color;
  final ValueChanged<double> onChanged;

  const _RadialHuePicker({required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final hsv = HSVColor.fromColor(color);
    return Center(
      child: GestureDetector(
        onPanUpdate: (details) => _handleGesture(details.localPosition, context.size!),
        onTapDown: (details) => _handleGesture(details.localPosition, context.size!),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(180, 180),
              painter: _HueWheelPainter(),
            ),
            // Selection Indicator
            Transform.rotate(
              angle: (hsv.hue - 90) * (3.14159 / 180),
              child: Container(
                width: 170,
                height: 170,
                alignment: Alignment.centerRight,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.8), blurRadius: 15, spreadRadius: 2)
                    ],
                  ),
                ),
              ),
            ),
            // Center Color Display
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(1.0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)
                ],
              ),
              child: Center(
                child: Text(
                  "${hsv.hue.toInt()}°",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGesture(Offset localPos, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Simpler angle calculation
    double rad = (localPos - Offset(centerX, centerY)).direction;
    double hue = (rad * 180 / 3.14159 + 90) % 360;
    if (hue < 0) hue += 360;
    
    onChanged(hue);
  }
}

class _HueWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sweepGradient = SweepGradient(
      colors: List.generate(360, (index) => HSVColor.fromAHSV(1.0, index.toDouble(), 1.0, 1.0).toColor()),
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    canvas.drawArc(rect.deflate(15), 0, 2 * 3.14159, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AdvancedColorSliders extends StatelessWidget {
  final Color color;
  final double glowIntensity;
  final Function(Color, double) onChanged;

  const _AdvancedColorSliders({
    required this.color,
    required this.glowIntensity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSlider(
          context: context,
          label: "GLOW (BLOOM)",
          value: glowIntensity,
          onChanged: (val) => onChanged(color, val),
        ),
        const SizedBox(height: 15),
        _buildSlider(
          context: context,
          label: "OPACITY",
          value: color.opacity,
          onChanged: (val) => onChanged(color.withOpacity(val), glowIntensity),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required String label,
    required double value,
    double max = 1.0,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
            Text("${(value * 100).toInt()}%",
                style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 5),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: max,
            activeColor: color.withOpacity(0.8),
            inactiveColor: Colors.white.withOpacity(0.05),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
