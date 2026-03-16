import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/models/gauge_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DashboardData {
  final double speed;
  final double soc;
  final double range;
  final double motorTemp;
  final double controllerTemp;
  final double powerFlow;
  final double voltage;

  DashboardData({
    required this.speed,
    required this.soc,
    required this.range,
    required this.motorTemp,
    required this.controllerTemp,
    required this.powerFlow,
    required this.voltage,
  });
}

class DashboardController extends ChangeNotifier {
  Timer? _simulationTimer;
  DashboardData _currentData = DashboardData(
    speed: 0,
    soc: 85,
    range: 420,
    motorTemp: 35,
    controllerTemp: 30,
    powerFlow: 0,
    voltage: 400,
  );

  DashboardData get data => _currentData;

  bool _isLocked = false; 
  String? _selectedGaugeId;
  String? _editingGaugeId;

  bool get isLocked => _isLocked;
  String? get selectedGaugeId => _selectedGaugeId;
  String? get editingGaugeId => _editingGaugeId;

  void toggleLock() {
    _isLocked = !_isLocked;
    if (_isLocked) {
      _selectedGaugeId = null; // Deselect on lock
    }
    notifyListeners();
  }

  void selectGauge(String? id) {
    if (_isLocked) return;
    _selectedGaugeId = id;
    _editingGaugeId = null; // Close settings when selection changes
    notifyListeners();
  }

  void setEditingGauge(String? id) {
    if (_isLocked) return;
    _editingGaugeId = id;
    notifyListeners();
  }

  List<GaugeConfig> _gauges = [
    GaugeConfig(
      id: 'main_speed',
      type: GaugeType.speed,
      position: const Offset(450, 100), // Reasonable default for web/desktop
      accentColor: const Color(0xFF00E5FF),
      label: 'SPEED',
      unit: 'km/h',
      maxValue: 240,
    ),
    GaugeConfig(
      id: 'left_battery',
      type: GaugeType.soc,
      position: const Offset(40, 500),
      accentColor: Colors.greenAccent,
      label: 'BATTERY',
      unit: '%',
      maxValue: 100,
    ),
    GaugeConfig(
      id: 'left_range',
      type: GaugeType.range,
      position: const Offset(110, 500),
      accentColor: Colors.orangeAccent,
      label: 'RANGE',
      unit: 'km',
      maxValue: 500,
    ),
    // Right Sidebar: Motor Temp
    GaugeConfig(
      id: 'right_temp',
      type: GaugeType.temp,
      position: const Offset(1000, 500), // Adjusted in layout
      accentColor: Colors.redAccent,
      label: 'MOTOR TEMP',
      unit: '°C',
      maxValue: 120,
    ),
  ];

  List<GaugeConfig> _availableGauges = [
    GaugeConfig(
      id: 'gauge_rpm',
      type: GaugeType.rpm,
      position: const Offset(100, 100),
      accentColor: Colors.purpleAccent,
      label: 'RPM',
      unit: 'rpm',
      maxValue: 8000,
    ),
    GaugeConfig(
      id: 'gauge_voltage',
      type: GaugeType.voltage,
      position: const Offset(100, 100),
      accentColor: Colors.blueAccent,
      label: 'VOLTAGE',
      unit: 'V',
      maxValue: 500,
    ),
    GaugeConfig(
      id: 'gauge_controller_temp',
      type: GaugeType.controllerTemp,
      position: const Offset(100, 100),
      accentColor: Colors.orangeAccent,
      label: 'CTRL TEMP',
      unit: '°C',
      maxValue: 100,
    ),
  ];

  List<GaugeConfig> get gauges => _gauges;
  List<GaugeConfig> get availableGauges => _availableGauges;

  void updateGauge(GaugeConfig updated) {
    final index = _gauges.indexWhere((g) => g.id == updated.id);
    if (index != -1) {
      _gauges[index] = updated;
      _saveLayout();
      notifyListeners();
    }
  }

  void updateGaugePosition(String id, Offset newPosition) {
    final index = _gauges.indexWhere((g) => g.id == id);
    if (index != -1) {
      _gauges[index] = _gauges[index].copyWith(position: newPosition);
      _saveLayout();
      notifyListeners();
    }
  }

  void addGaugeFromAvailable(GaugeConfig config) {
    _availableGauges.removeWhere((g) => g.id == config.id);
    _gauges.add(config);
    _saveLayout();
    notifyListeners();
  }

  void addGauge(GaugeType type, String label, Color color) {
    _gauges.add(GaugeConfig(
      id: "gauge_${DateTime.now().millisecondsSinceEpoch}",
      type: type,
      position: const Offset(100, 100),
      accentColor: color,
      label: label,
      unit: type == GaugeType.rpm ? "rpm" : "A",
      maxValue: type == GaugeType.rpm ? 8000 : 400,
    ));
    _saveLayout();
    notifyListeners();
  }

  void removeGauge(String id) {
    final index = _gauges.indexWhere((g) => g.id == id);
    if (index != -1) {
      _availableGauges.add(_gauges[index]);
      _gauges.removeAt(index);
      _saveLayout();
      notifyListeners();
    }
  }

  DashboardController() {
    _loadLayout();
    startSimulation();
  }

  Future<void> _saveLayout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_gauges.map((g) => g.toJson()).toList());
      await prefs.setString('dashboard_layout', encoded);
    } catch (e) {
      debugPrint("Error saving layout: $e");
    }
  }

  Future<void> _loadLayout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString('dashboard_layout');
      if (encoded != null) {
        final List<dynamic> decoded = jsonDecode(encoded);
        _gauges = decoded.map((item) => GaugeConfig.fromJson(item)).toList();
        
        // Remove loaded gauges from available list to prevent duplicates
        final activeIds = _gauges.map((g) => g.id).toSet();
        _availableGauges.removeWhere((g) => activeIds.contains(g.id));
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading layout: $e");
    }
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
    final controllerTemp = 30 + (speed / 15.0) + (Random().nextDouble() * 1.0);

    // Power Flow (Negative for regen, Positive for draw)
    final powerFlow = 50 * cos(t * 0.5) + (Random().nextDouble() - 0.5) * 10;
    
    // Voltage sags slightly under load
    final voltage = 400 - (powerFlow.abs() / 10.0) + (Random().nextDouble() * 0.5);

    _currentData = DashboardData(
      speed: speed,
      soc: soc,
      range: range,
      motorTemp: motorTemp,
      controllerTemp: controllerTemp,
      powerFlow: powerFlow,
      voltage: voltage,
    );
    
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
