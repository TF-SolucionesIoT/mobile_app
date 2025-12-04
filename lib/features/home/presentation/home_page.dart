import 'package:app_alerta_vital/core/services/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _currentUserId;
  bool _isInitialized = false;
  late final HomeController _controller;

  // Colores del tema (igual al primer código)
  final Color primaryColor = const Color(0xFF5A9DE0);
  final Color secondaryColor = const Color(0xFF7B68EE);
  final Color accentColor = const Color(0xFF00D4AA);

  @override
  void initState() {
    super.initState();
    _controller = ref.read(homeControllerProvider.notifier);
    _initializeMonitoring();
  }

  Future<void> _initializeMonitoring() async {
    final session = ref.read(sessionServiceProvider);
    final type = await session.getUserType();
    final userId = await session.getUserId();

    if (type != null && userId != null) {
      final userIdStr = userId.toString();
      if (_currentUserId != userIdStr || !_isInitialized) {
        _controller.initMonitoring(type, userIdStr);
        if (mounted) {
          setState(() {
            _currentUserId = userIdStr;
            _isInitialized = true;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.disposeSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    if (state.patients.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final p = state.patients.first;

    bool riesgo = (p.bpm < 50 || p.bpm > 120 || p.spo2 < 92 || p.bpSystolic > 130 || p.bpDiastolic > 90);

    Color bpmColor = (p.bpm < 50 || p.bpm > 120) ? const Color(0xFFFF5252) : accentColor;
    Color spo2Color = (p.spo2 < 92) ? const Color(0xFFFF5252) : accentColor;
    Color bpColor = (p.bpSystolic > 130 || p.bpDiastolic > 90) ? const Color(0xFFFF9800) : primaryColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.08),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monitor_heart_rounded, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        "Paciente ${p.patientId}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Tarjeta principal
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Métricas
                      _metricTile(
                        icon: Icons.favorite_rounded,
                        label: "Frecuencia Cardiaca",
                        value: "${p.bpm}",
                        unit: "BPM",
                        color: bpmColor,
                        isAlert: (p.bpm < 50 || p.bpm > 120),
                      ),
                      const SizedBox(height: 16),
                      _metricTile(
                        icon: Icons.air_rounded,
                        label: "Oxigenación (SpO₂)",
                        value: "${p.spo2}",
                        unit: "%",
                        color: spo2Color,
                        isAlert: p.spo2 < 92,
                      ),
                      const SizedBox(height: 16),
                      _metricTile(
                        icon: Icons.monitor_heart_outlined,
                        label: "Presión Arterial",
                        value: "${p.bpSystolic}/${p.bpDiastolic}",
                        unit: "mmHg",
                        color: bpColor,
                        isAlert: (p.bpSystolic > 130 || p.bpDiastolic > 90),
                      ),
                      const SizedBox(height: 25),

                      // Estado de riesgo
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: riesgo
                              ? const Color(0xFFFFF3F3)
                              : const Color(0xFFF0FFF8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: riesgo ? const Color(0xFFFF5252) : accentColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              riesgo ? Icons.warning_rounded : Icons.check_circle_rounded,
                              color: riesgo ? const Color(0xFFFF5252) : accentColor,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              riesgo ? "Riesgo Detectado" : "Paciente Estable",
                              style: TextStyle(
                                color: riesgo ? const Color(0xFFFF5252) : accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Nota de tiempo real
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi, color: Colors.blue),
                          const SizedBox(width: 6),
                          const Text("Datos en tiempo real"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
    required bool isAlert,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isAlert)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }
}
