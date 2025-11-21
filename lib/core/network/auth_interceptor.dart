
import 'package:app_alerta_vital/core/services/session_service.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final SessionService session;

  AuthInterceptor(this.session);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await session.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
