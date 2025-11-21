import 'package:app_alerta_vital/features/auth/presentation/register/register_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/session_provider.dart';
import '../../features/auth/presentation/login/login_page.dart';
import '../../features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final container = ProviderScope.containerOf(context);
      final session = container.read(sessionServiceProvider);

      final logged = await session.isLogged();
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';

      if (!logged && !(isLogin || isRegister)) {
        return '/login';
      }

      if (logged && (isLogin || isRegister)) {
        return '/home';
      }
      return null;
    },

    routes: [
      // ---------- ROUTES SIN APPBAR (LOGIN/REGISTER) ----------
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => RegisterPage(),
      ),

      // ---------- RUTAS QUE COMPARTEN APPBAR ----------
      ShellRoute(
        builder: (context, state, child) {
          final title = _getTitleFor(state.matchedLocation);

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (_, __) => const HomePage(),
          ),
        ],
      ),
    ],
  );
});

// Helper para títulos
String _getTitleFor(String location) {
  switch (location) {
    case '/home':
      return 'Home';
    default:
      return '';
  }
}
