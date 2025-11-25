import 'package:app_alerta_vital/core/network/auth_interceptor.dart';
import 'package:app_alerta_vital/core/services/session_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String baseUrl = dotenv.env['API_URL'] ?? "http://10.0.2.2:8081/api";

final dioProvider = Provider<Dio>((ref) {
  final session = ref.read(sessionServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {"Content-Type": "application/json"},
    ),
  );

  dio.interceptors.add(AuthInterceptor(session));
  return dio;
});
