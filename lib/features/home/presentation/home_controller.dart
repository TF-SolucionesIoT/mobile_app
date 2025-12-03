import 'package:app_alerta_vital/core/services/session_provider.dart';
import 'package:app_alerta_vital/core/services/websockets_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/realtime_data.dart';
import 'home_state.dart';
final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

class HomeController extends Notifier<HomeState> {
  WebSocketService? _ws;

  @override
  HomeState build() {
    ref.onDispose(() {
      _ws?.disconnect();
    });
    return HomeState.initial();
  }

  Future<void> initMonitoring(String typeOfUser, String loggedUserId) async {
    print("🚀 initMonitoring iniciado - tipo: $typeOfUser, userId: $loggedUserId");
    print("📊 Estado actual patients: ${state.patients.length}");
    
    print("🔄 Reseteando estado...");
    state = HomeState.initial();
    _ws?.disconnect();

    final session = ref.read(sessionServiceProvider);
    final token = await session.getAccessToken();

    if (token == null) {
      print("❌ No hay token, no se abre el WebSocket");
      return;
    }

    _ws = WebSocketService();

    _ws!.connect(
      token,
      (json) {
        print("📥 Datos recibidos por WebSocket: $json");
        final data = RealtimeData.fromJson(json);

        if (typeOfUser == "PATIENT") {
          // 👇 CAMBIO: Comparar con userId en lugar de patientId
          if (data.userId == loggedUserId) {
            print("✅ userId coincide! Actualizando estado...");
            print("   userId recibido: ${data.userId}");
            print("   userId logueado: $loggedUserId");
            state = HomeState(patients: [data]);
          } else {
            print("⚠️ userId no coincide: ${data.userId} != $loggedUserId");
          }
          return;
        }

        if (typeOfUser == "CAREGIVER") {
          final list = [...state.patients];
          // 👇 Para CAREGIVER, puedes seguir usando patientId o userId según tu lógica
          final index = list.indexWhere((p) => p.patientId == data.patientId);

          if (index >= 0) {
            list[index] = data;
            print("🔄 Paciente actualizado: ${data.patientId}");
          } else {
            list.add(data);
            print("➕ Nuevo paciente agregado: ${data.patientId}");
          }

          state = state.copyWith(patients: list);
          print("📊 Total pacientes monitoreados: ${list.length}");
        }
      },
      onError: (err) => print("❌ Error WS: $err"),
      onDone: () => print("🔌 WebSocket cerrado"),
    );
  }

  void disposeSocket() => _ws?.disconnect();
}