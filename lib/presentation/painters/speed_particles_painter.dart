import 'dart:math';
import 'package:flutter/material.dart';

class SpeedParticlesPainter extends CustomPainter {
  final double speed;
  final List<Particle> particles;
  final Color accentColor;

  SpeedParticlesPainter({
    required this.speed,
    required this.particles,
    this.accentColor = Colors.cyanAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var particle in particles) {
      final speedFactor = 1.0 + (speed / 100.0);
      particle.update(speedFactor, size);

      final opacity = (1.0 - (particle.z / 1000.0)).clamp(0.0, 1.0);
      paint.color = accentColor.withOpacity(opacity * 0.5);
      paint.strokeWidth = 1.0 + (1.0 - opacity) * 3.0;

      final x = center.dx + (particle.x / particle.z) * 1000;
      final y = center.dy + (particle.y / particle.z) * 1000;

      final tailX = center.dx + (particle.x / (particle.z + 20 * speedFactor)) * 1000;
      final tailY = center.dy + (particle.y / (particle.z + 20 * speedFactor)) * 1000;

      if (x > 0 && x < size.width && y > 0 && y < size.height) {
        canvas.drawLine(Offset(x, y), Offset(tailX, tailY), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SpeedParticlesPainter oldDelegate) => true;
}

class Particle {
  double x, y, z;

  Particle()
      : x = (Random().nextDouble() - 0.5) * 2000,
        y = (Random().nextDouble() - 0.5) * 2000,
        z = Random().nextDouble() * 1000;

  void update(double speedFactor, Size size) {
    z -= 5 * speedFactor;
    if (z <= 1) {
      z = 1000;
      x = (Random().nextDouble() - 0.5) * 2000;
      y = (Random().nextDouble() - 0.5) * 2000;
    }
  }
}
