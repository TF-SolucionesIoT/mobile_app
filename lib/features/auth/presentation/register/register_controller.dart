import 'package:app_alerta_vital/core/services/session_provider.dart';
import 'package:app_alerta_vital/features/auth/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'register_state.dart';

class RegisterController extends Notifier<RegisterState> 
{
  @override
  RegisterState build() {
    return RegisterState.initial();
  }

  Future<void> register(String firstName, String lastName, String email, String gender, String username, String password, String confirmPassword) async {
    
    if (password != confirmPassword) {
    state = state.copyWith(error: "Las contraseñas no coinciden");
    return;
    }

    final registerUser = ref.read(registerUserProvider);
    final session = ref.read(sessionServiceProvider);

    state = state.copyWith(loading: true, error: null);

    try {
      final tokens = await registerUser(firstName, lastName, email, gender, username, password, "2000-01-01");
      await session.saveTokens(tokens.accessToken, tokens.refreshToken);

      state = state.copyWith(loading: false, tokens: tokens);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
    
  }
}