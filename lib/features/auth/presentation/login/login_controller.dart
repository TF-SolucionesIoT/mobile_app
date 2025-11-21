import 'package:app_alerta_vital/core/services/session_provider.dart';
import 'package:app_alerta_vital/features/auth/auth.dart';
import 'package:app_alerta_vital/features/auth/presentation/login/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class LoginController extends Notifier<LoginState> {
  
  @override
  LoginState build() {

    return LoginState.initial();
  }

  Future<void> login(String username, String password) async {

    final session = ref.read(sessionServiceProvider);
    final loginUser = ref.read(loginUserProvider);

    state = state.copyWith(loading: true, error: null);

    try {
      final tokens = await loginUser(username, password);
      await session.saveTokens(tokens.accessToken, tokens.refreshToken);
      state = state.copyWith(loading: false, tokens: tokens);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final session = ref.read(sessionServiceProvider);
    await session.logout();
    state = LoginState.initial();
  }
}
