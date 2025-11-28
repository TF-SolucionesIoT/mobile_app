import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class SessionService {
  static const _storage = FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLogged() async {
    final t = await getAccessToken();
    return t != null;
  }

  Map<String, dynamic> decodeJwt(String token) {
    return Jwt.parseJwt(token);
  }

  Future<String?> getUserType() async {
    final token = await getAccessToken();
    if (token == null) return null;

    try {
      final payload = Jwt.parseJwt(token);
      return payload['typeOfUser']; // o 'role', depende de tu JWT
    } catch (e) {
      return null;
    }
  }
}
