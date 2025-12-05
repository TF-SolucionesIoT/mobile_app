import 'package:app_alerta_vital/core/services/dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingAlertsApi {
  final Dio dio;
  
  ReadingAlertsApi(this.dio);

  Future<List<Map<String, dynamic>>> getAllReadingAlerts() async {
    final response = await dio.get('/device/reading-alerts/all');

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      throw Exception("Error ${response.statusCode}: ${response.data}");
    }
  }
}

// Provider de ReadingAlertsApi
final readingAlertsApiProvider = Provider<ReadingAlertsApi>((ref) {
  final dio = ref.read(dioProvider);
  return ReadingAlertsApi(dio);
});
