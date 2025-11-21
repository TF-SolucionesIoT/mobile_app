import '../domain/models/auth_tokens.dart';
import 'auth_api.dart';

class AuthRepository {
  final AuthApi api;

  AuthRepository(this.api);

  Future<AuthTokens> login(String username, String password) async {
    final json = await api.login(username, password);
    return AuthTokens.fromJson(json);
  }

  Future<AuthTokens> register(String firstName, String lastName, String email, String gender, String username, String password, String birthday) async {
    final json = await api.register(firstName, lastName, email, gender, username, password, birthday);
    return AuthTokens.fromJson(json);
  }

}
