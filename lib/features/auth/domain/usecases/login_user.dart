import '../models/auth_tokens.dart';
import '../../data/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;
  LoginUser(this.repository);

  Future<AuthTokens> call(String username, String password) async {
    return await repository.login(username, password); // devuelve AuthTokens
  }
}

