import 'package:flutter/material.dart';
import 'presentation/widgets/futuristic_gauge.dart';

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
  double _speed = 0;
  double _battery = 85;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF1A1D2D),
              Color(0xFF0A0B10),
            ],
          ),
        ),
        child: Stack(
          children: [
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
                  Text(
                    "21:45",
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
                value: _speed,
                label: "SPEED",
                unit: "km/h",
                accentColor: const Color(0xFF00E5FF),
              ),
            ),

            // Secondary Gauges
            Positioned(
              bottom: 100,
              left: 50,
              child: FuturisticGauge(
                value: _battery * 2, // Scale for display
                label: "BATTERY",
                unit: "%",
                accentColor: Colors.greenAccent,
              ),
            ),

            // Control Slider (Testing)
            Positioned(
              bottom: 40,
              left: 100,
              right: 100,
              child: Column(
                children: [
                  Slider(
                    value: _speed,
                    min: 0,
                    max: 240,
                    onChanged: (val) => setState(() => _speed = val),
                    activeColor: Colors.cyanAccent,
                  ),
                  const Text("DRAG TO TEST SPEED", style: TextStyle(color: Colors.white24, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
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
          style: const TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 1),
        ),
      ],
    );
  }
}
