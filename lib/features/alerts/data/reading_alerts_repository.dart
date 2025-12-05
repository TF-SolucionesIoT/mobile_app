import 'package:app_alerta_vital/features/alerts/data/reading_alerts_api.dart';
import 'package:app_alerta_vital/features/alerts/domain/model/reading_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingAlertsRepository {
  final ReadingAlertsApi api;

  ReadingAlertsRepository(this.api);

  Future<List<ReadingAlert>> getAllReadingAlerts() async {
    try {
      final jsonList = await api.getAllReadingAlerts();
      return jsonList.map((json) => ReadingAlert.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Error al obtener las alertas: $e");
    }
  }
}

// Provider del Repository
final readingAlertsRepositoryProvider = Provider<ReadingAlertsRepository>((ref) {
  final api = ref.read(readingAlertsApiProvider);
  return ReadingAlertsRepository(api);
});