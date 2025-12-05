import 'package:app_alerta_vital/features/alerts/domain/model/reading_alert.dart';

class ReadingAlertsState {
  final bool isLoading;
  final List<ReadingAlert> alerts;
  final String? errorMessage;

  ReadingAlertsState({
    this.isLoading = false,
    this.alerts = const [],
    this.errorMessage,
  });

  ReadingAlertsState copyWith({
    bool? isLoading,
    List<ReadingAlert>? alerts,
    String? errorMessage,
  }) {
    return ReadingAlertsState(
      isLoading: isLoading ?? this.isLoading,
      alerts: alerts ?? this.alerts,
      errorMessage: errorMessage,
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasAlerts => alerts.isNotEmpty;
}