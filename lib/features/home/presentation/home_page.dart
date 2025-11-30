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
  late final HomeController _controller; // 👈 Guardar referencia aquí

  @override
  void initState() {
    super.initState();
    _controller = ref.read(homeControllerProvider.notifier); // 👈 Guardar al inicio
    _initializeMonitoring();
  }

  Future<void> _initializeMonitoring() async {
    final session = ref.read(sessionServiceProvider);
    final type = await session.getUserType();
    final userId = await session.getUserId();

    if (type != null && userId != null) {
      final userIdStr = userId.toString();
      
      // Solo inicializar si es un usuario diferente o primera vez
      if (_currentUserId != userIdStr || !_isInitialized) {
        print("🔄 Inicializando monitoreo para usuario: $userIdStr");
        
        // Resetear el estado
        _controller.resetState();
        
        // Esperar un frame para que el reset se aplique
        await Future.delayed(Duration.zero);
        
        // Iniciar monitoreo
        _controller.initMonitoring(type, userIdStr);
        
        if (mounted) { // 👈 Verificar que el widget sigue montado
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
    _controller.disposeSocket(); // 👈 Usar la referencia guardada
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    if (state.patients.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final p = state.patients.first;

    Color bpmColor = (p.bpm < 50 || p.bpm > 120) ? Colors.red : Colors.green;
    Color spo2Color = (p.spo2 < 92) ? Colors.red : Colors.green;
    bool riesgo = (p.bpm < 50 || p.bpm > 120 || p.spo2 < 92);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paciente monitoreado"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, size: 60),
            ),

            const SizedBox(height: 15),

            Text(
              "Paciente ${p.patientId}",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 32),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Frecuencia Cardiaca",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              "${p.bpm} BPM",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: bpmColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        const Icon(Icons.bloodtype, size: 32),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Oxigenación (SpO₂)",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              "${p.spo2}%",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: spo2Color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: riesgo
                    ? Colors.red.withOpacity(0.15)
                    : Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: riesgo ? Colors.red : Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    riesgo ? Icons.warning : Icons.check_circle,
                    color: riesgo ? Colors.red : Colors.green,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    riesgo ? "Riesgo Detectado" : "Paciente Estable",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: riesgo ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.wifi, color: Colors.blue),
                SizedBox(width: 6),
                Text("Datos en tiempo real"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}