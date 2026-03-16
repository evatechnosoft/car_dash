import 'package:flutter/material.dart';
import '../painters/speed_particles_painter.dart';

class DynamicBackground extends StatefulWidget {
  final double speed;
  final Color accentColor;

  const DynamicBackground({
    super.key,
    required this.speed,
    this.accentColor = Colors.cyanAccent,
  });

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground>
    with SingleTickerProviderStateMixin {
  late List<Particle> _particles;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(100, (index) => Particle());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      })..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: SpeedParticlesPainter(
        speed: widget.speed,
        particles: _particles,
        accentColor: widget.accentColor,
      ),
    );
  }
}
