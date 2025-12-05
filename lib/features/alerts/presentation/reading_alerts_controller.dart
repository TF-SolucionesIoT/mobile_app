import 'package:app_alerta_vital/features/alerts/domain/usecases/get_all_reading_alerts.dart';
import 'package:app_alerta_vital/features/alerts/presentation/reading_alert_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



final readingAlertsControllerProvider =
    NotifierProvider<ReadingAlertsController, ReadingAlertsState>(
  ReadingAlertsController.new,
);

class ReadingAlertsController extends Notifier<ReadingAlertsState> {
  @override
  ReadingAlertsState build() => ReadingAlertsState();

  Future<void> loadAlerts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final useCase = ref.read(getAllReadingAlertsProvider);
      final alerts = await useCase();
      
      state = state.copyWith(
        isLoading: false,
        alerts: alerts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Error al cargar alertas: $e",
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}