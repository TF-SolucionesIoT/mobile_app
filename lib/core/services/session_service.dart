import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class SessionService {
  static const _storage = FlutterSecureStorage();

  Future<void> saveTokens(
    String accessToken,
    String refreshToken,
    int userId,
    String typeOfUser,
  ) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
    await _storage.write(key: 'userId', value: userId.toString());
    await _storage.write(key: 'typeOfUser', value: typeOfUser);
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

  Future<int?> getUserId() async {
    final id = await _storage.read(key: 'userId');
    return id != null ? int.tryParse(id) : null;
  }

  Future<String?> getUserType() => _storage.read(key: 'typeOfUser');
}
