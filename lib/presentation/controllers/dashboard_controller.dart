import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

class DashboardData {
  final double speed;
  final double soc;
  final double range;
  final double motorTemp;
  final double powerFlow;

  DashboardData({
    required this.speed,
    required this.soc,
    required this.range,
    required this.motorTemp,
    required this.powerFlow,
  });
}

class DashboardController extends ChangeNotifier {
  Timer? _simulationTimer;
  DashboardData _currentData = DashboardData(
    speed: 0,
    soc: 85,
    range: 420,
    motorTemp: 35,
    powerFlow: 0,
  );

  DashboardData get data => _currentData;

  DashboardController() {
    startSimulation();
  }

  void startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _simulate();
    });
  }

  void _simulate() {
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    // Smoothly varying mock speed (Sine wave with noise)
    final baseSpeed = 80 + 40 * sin(t * 0.5);
    final speed = (baseSpeed + Random().nextDouble() * 2).clamp(0.0, 240.0);
    
    // SOC slowly decreases (Simulation)
    final soc = (85 - (t / 100)).clamp(0.0, 100.0);
    
    // Range maps to SOC
    final range = soc * 5.2;

    // Motor temp rises with speed
    final motorTemp = 35 + (speed / 10.0) + (Random().nextDouble() * 1.5);

    // Power Flow (Negative for regen, Positive for draw)
    // Draw increases with speed acceleration
    final powerFlow = 50 * cos(t * 0.5) + (Random().nextDouble() - 0.5) * 10;

    _currentData = DashboardData(
      speed: speed,
      soc: soc,
      range: range,
      motorTemp: motorTemp,
      powerFlow: powerFlow,
    );
    
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
