import 'package:app_alerta_vital/core/services/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_controller.dart';
import '../domain/models/realtime_data.dart';

class CaregiverHomePage extends ConsumerStatefulWidget {
  const CaregiverHomePage({super.key});

  @override
  ConsumerState<CaregiverHomePage> createState() => _CaregiverHomePageState();
}

class _CaregiverHomePageState extends ConsumerState<CaregiverHomePage> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = ref.read(homeControllerProvider.notifier);
    controller.resetState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = ref.read(sessionServiceProvider);

      final type = await session.getUserType();
      final userId = await session.getUserId();

      if (type != null && userId != null) {
        controller.initMonitoring(type, userId.toString());
      } else {
        debugPrint("❌ No se pudo obtener type o userId desde SessionService");
      }
    });
  }

  @override
  void dispose() {
    controller.disposeSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: state.patients.isEmpty
            ? const Center(
                child: Text(
                  "Esperando datos en tiempo real...",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: state.patients.length,
                itemBuilder: (_, i) => _PatientCard(patient: state.patients[i]),
              ),
      ),
    );
  }
}

/// ----------------------------
///   CARD DE PACIENTE
/// ----------------------------
class _PatientCard extends StatelessWidget {
  final RealtimeData patient;

  const _PatientCard({required this.patient});

  bool get isRisk =>
      (patient.bpm < 50 || patient.bpm > 120 || patient.spo2 < 92);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRisk ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRisk ? Colors.red : Colors.green,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    isRisk ? Colors.red.shade300 : Colors.green.shade300,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                "Paciente ${patient.patientId}",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isRisk ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isRisk ? "Riesgo" : "Estable",
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          ),

          const SizedBox(height: 16),

          /// BPM
          _metricRow(
            icon: Icons.favorite,
            label: "Frecuencia cardíaca",
            value: "${patient.bpm} bpm",
            color: (patient.bpm < 50 || patient.bpm > 120)
                ? Colors.red
                : Colors.green,
          ),

          const SizedBox(height: 10),

          /// SpO2
          _metricRow(
            icon: Icons.bloodtype,
            label: "Oxigenación",
            value: "${patient.spo2}%",
            color: patient.spo2 < 92 ? Colors.red : Colors.green,
          ),

          const SizedBox(height: 16),

          /// BUTTON DETAILS
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                // Aquí puedes navegar a una futura pantalla de detalles
              },
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              label: const Text("Ver detalles"),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// WIDGET DE MÉTRICA
  Widget _metricRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
