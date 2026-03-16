import 'package:flutter/material.dart';
import '../controllers/dashboard_controller.dart';
import '../../domain/models/gauge_config.dart';

class SettingsScreen extends StatelessWidget {
  final DashboardController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0B10),
      appBar: AppBar(
        title: const Text("DASHBOARD SETTINGS"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text("ACTIVE GAUGES", style: TextStyle(color: Colors.white38, letterSpacing: 2)),
              const SizedBox(height: 20),
              ...controller.gauges.map((gauge) => _gaugeTile(context, gauge)),
              const SizedBox(height: 40),
              const Text("AVAILABLE (UNSET) GAUGES", style: TextStyle(color: Colors.white38, letterSpacing: 2)),
              const SizedBox(height: 10),
              ...controller.availableGauges.map((gauge) => _availableGaugeTile(context, gauge)),
              const SizedBox(height: 40),
              const Text("CREATE NEW GAUGE", style: TextStyle(color: Colors.white38, letterSpacing: 2)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: [
                  _addGaugeButton(context, "RPM", GaugeType.rpm, Colors.purpleAccent),
                  _addGaugeButton(context, "CURRENT", GaugeType.current, Colors.yellowAccent),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _availableGaugeTile(BuildContext context, GaugeConfig gauge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(Icons.add_circle_outline, color: gauge.accentColor.withOpacity(0.5)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gauge.label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                Text(gauge.type.name.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white24)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => controller.addGaugeFromAvailable(gauge),
            style: ElevatedButton.styleFrom(
              backgroundColor: gauge.accentColor.withOpacity(0.1),
              foregroundColor: gauge.accentColor,
            ),
            child: const Text("ADD"),
          ),
        ],
      ),
    );
  }

  Widget _gaugeTile(BuildContext context, GaugeConfig gauge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gauge.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.dashboard, color: gauge.accentColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gauge.label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(gauge.id, style: const TextStyle(fontSize: 10, color: Colors.white24)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
            onPressed: () {
              controller.removeGauge(gauge.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _addGaugeButton(BuildContext context, String label, GaugeType type, Color color) {
    return ActionChip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
      onPressed: () {
        controller.addGauge(type, label, color);
      },
    );
  }
}
