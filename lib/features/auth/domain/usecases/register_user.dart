import 'package:app_alerta_vital/features/auth/data/auth_repository.dart';
import 'package:app_alerta_vital/features/auth/domain/models/auth_tokens.dart';

class RegisterUser {
  final AuthRepository repository;
  RegisterUser(this.repository);

  Future<AuthTokens> call(String firstName, String lastName, String email, String gender, String username, String password, String birthday) async {
    return await repository.register(firstName, lastName, email, gender, username, password, birthday);
  }
}