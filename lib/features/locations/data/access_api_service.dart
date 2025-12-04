import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccessApiService {
  final Dio _dio;

  AccessApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8081/api';
  }

  /// Obtiene la lista de userIds de pacientes vinculados al cuidador
  Future<List<String>> getLinkedPatients(String token) async {
    try {
      final response = await _dio.get(
        '/access/patients',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
       
        final List<dynamic> patients = response.data ?? [];
        return patients.map((p) => p.toString()).toList();
      }

      return [];
    } catch (e) {
      print('❌ Error al obtener pacientes vinculados: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
    }
      return [];
    }
  }
}
