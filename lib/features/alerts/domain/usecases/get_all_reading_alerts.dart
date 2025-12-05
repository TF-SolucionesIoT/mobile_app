import 'package:app_alerta_vital/features/alerts/data/reading_alerts_repository.dart';
import 'package:app_alerta_vital/features/alerts/domain/model/reading_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetAllReadingAlerts {
  final ReadingAlertsRepository repository;

  GetAllReadingAlerts(this.repository);

  Future<List<ReadingAlert>> call() async {
    return await repository.getAllReadingAlerts();
  }
}

// Provider del UseCase
final getAllReadingAlertsProvider = Provider<GetAllReadingAlerts>((ref) {
  final repository = ref.read(readingAlertsRepositoryProvider);
  return GetAllReadingAlerts(repository);
});