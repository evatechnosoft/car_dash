import 'package:flutter/material.dart';
import 'presentation/widgets/futuristic_gauge.dart';
import 'presentation/widgets/dynamic_background.dart';
import 'presentation/widgets/vertical_info_bar.dart';
import 'presentation/widgets/power_flow_monitor.dart';
import 'presentation/controllers/dashboard_controller.dart';

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
                // Dynamic Background Layer
                Positioned.fill(
                  child: DynamicBackground(
                    speed: data.speed,
                    accentColor: Colors.cyanAccent,
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
                      _statusIcon(Icons.bluetooth_connected, "CONNECTED"),
                      _statusIcon(Icons.wifi, "4G LTE"),
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

                // Main Gauge Center
                Center(
                  child: FuturisticGauge(
                    value: data.speed,
                    label: "SPEED",
                    unit: "km/h",
                    accentColor: const Color(0xFF00E5FF),
                  ),
                ),

                // Left Sidebar: Battery & Range
                Positioned(
                  left: 40,
                  bottom: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      VerticalInfoBar(
                        value: data.soc,
                        label: "BATTERY",
                        unit: "%",
                        accentColor: Colors.greenAccent,
                      ),
                      const SizedBox(width: 40),
                      VerticalInfoBar(
                        value: data.range,
                        max: 500,
                        label: "RANGE",
                        unit: "km",
                        accentColor: Colors.orangeAccent,
                      ),
                    ],
                  ),
                ),

                // Right Sidebar: Motor Temp
                Positioned(
                  right: 40,
                  bottom: 100,
                  child: VerticalInfoBar(
                    value: data.motorTemp,
                    max: 120,
                    label: "MOTOR TEMP",
                    unit: "°C",
                    accentColor: Colors.redAccent,
                  ),
                ),

                // Bottom: Power Flow
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          data.powerFlow > 0 ? "POWER DRAW" : "REGENERATION",
                          style: TextStyle(
                            color: data.powerFlow > 0 ? Colors.orangeAccent : Colors.greenAccent,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        PowerFlowMonitor(power: data.powerFlow),
                      ],
                    ),
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
