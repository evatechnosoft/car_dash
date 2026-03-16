import 'package:flutter/material.dart';
import '../painters/power_flow_painter.dart';

class PowerFlowMonitor extends StatefulWidget {
  final double power;

  const PowerFlowMonitor({super.key, required this.power});

  @override
  State<PowerFlowMonitor> createState() => _PowerFlowMonitorState();
}

class _PowerFlowMonitorState extends State<PowerFlowMonitor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 40),
          painter: PowerFlowPainter(
            power: widget.power,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}
