import 'package:flutter/material.dart';
import 'presentation/widgets/dynamic_background.dart';
import 'presentation/widgets/generic_gauge.dart';
import 'presentation/widgets/gauge_layout_wrapper.dart';
import 'presentation/controllers/dashboard_controller.dart';
import 'domain/models/gauge_config.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/gauge_mini_settings.dart';

void main() {
  runApp(const CarDashApp());
}

class CarDashApp extends StatelessWidget {
  const CarDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'car_dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0B10),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _controller = DashboardController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final data = _controller.data;
          
          return Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF1A1D2D), Color(0xFF0A0B10)],
              ),
            ),
            child: Stack(
              children: [
                // 0. Background Tap Handler (Empty space deselects everything)
                GestureDetector(
                  onTap: () => _controller.selectGauge(null),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),
                // Dynamic Background Layer
                Positioned.fill(
                  child: DynamicBackground(
                    speed: data.speed,
                    accentColor: Colors.cyanAccent,
                  ),
                ),
                // Dynamic Gauges Layer
                ..._controller.gauges.map((config) {
                  // Helper to resolve data for any metric type
                  (double, String, String) resolve(GaugeType type) {
                    switch (type) {
                      case GaugeType.speed: return (data.speed, "SPEED", "km/h");
                      case GaugeType.soc: return (data.soc, "BATTERY", "%");
                      case GaugeType.range: return (data.range, "RANGE", "km");
                      case GaugeType.temp: return (data.motorTemp, "MOTOR", "°C");
                      case GaugeType.powerFlow: return (data.powerFlow, "FLOW", "kW");
                      case GaugeType.rpm: return (data.speed * 40, "RPM", "");
                      case GaugeType.current: return (data.powerFlow, "CURRENT", "A");
                      case GaugeType.voltage: return (data.voltage, "VOLTAGE", "V");
                      case GaugeType.controllerTemp: return (data.controllerTemp, "ESC", "°C");
                      case GaugeType.power: return ((data.voltage * data.powerFlow / 1000).abs(), "POWER", "kW");
                    }
                  }

                  final (val, _, _) = resolve(config.type);
                  
                  double? innerVal;
                  String? innerUnit;
                  String? innerLabel;
                  
                  if (config.innerMetric != null) {
                    final (v, l, u) = resolve(config.innerMetric!);
                    innerVal = v;
                    innerLabel = l;
                    innerUnit = u;
                  }

                  return DraggableGauge(
                    key: ValueKey(config.id),
                    config: config,
                    isSelected: _controller.selectedGaugeId == config.id,
                    isLocked: _controller.isLocked,
                    onSelect: () => _controller.selectGauge(config.id),
                    onDeselect: () => _controller.selectGauge(null),
                    onPositionChanged: (newPos) => _controller.updateGaugePosition(config.id, newPos),
                    onScaleChanged: (newScale) => _controller.updateGauge(config.copyWith(scale: newScale)),
                    onSettingsRequested: () => _controller.setEditingGauge(config.id),
                    child: GenericGauge(
                      config: config, 
                      value: val,
                      secondaryValue: innerVal,
                      secondaryUnit: innerUnit,
                      secondaryLabel: innerLabel,
                    ),
                  );
                }),

                // Floating Mini Settings Overlay (Closes when editingGaugeId is null)
                if (_controller.editingGaugeId != null)
                  Positioned.fill(
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: GaugeMiniSettings(
                          config: _controller.gauges.firstWhere((g) => g.id == _controller.editingGaugeId),
                          onConfigChanged: (newConfig) => _controller.updateGauge(newConfig),
                          onDelete: () => _controller.removeGauge(_controller.editingGaugeId!),
                        ),
                      ),
                    ),
                  ),

                // Top Status Bar
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _controller.toggleLock(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _controller.isLocked ? Colors.white.withOpacity(0.05) : Colors.cyanAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _controller.isLocked ? Colors.white10 : Colors.cyanAccent.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _controller.isLocked ? Icons.lock : Icons.lock_open,
                                    color: _controller.isLocked ? Colors.white30 : Colors.cyanAccent,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _controller.isLocked ? "DASHBOARD LOCKED" : "DASHBOARD UNLOCKED",
                                    style: TextStyle(
                                      color: _controller.isLocked ? Colors.white30 : Colors.cyanAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          _statusIcon(Icons.bluetooth_connected, "CONNECTED"),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsScreen(controller: _controller),
                            ),
                          );
                        },
                      ),
                      const Text(
                        "17:35",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.cyanAccent, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
