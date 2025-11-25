import 'package:app_alerta_vital/features/auth/presentation/register/register_page.dart';
import 'package:app_alerta_vital/features/invitecode/presentation/generatecode/invite_page.dart';
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
      // ---------- RUTAS SIN APPBAR ----------
      GoRoute(path: '/login', name: 'login', builder: (_, __) => LoginPage()),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => RegisterPage(),
      ),

      // ---------- RUTAS CON APPBAR + DRAWER ----------
      ShellRoute(
        builder: (context, state, child) {
          final title = _getTitleFor(state.matchedLocation);

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            ),

            // -------- DRAWER GLOBAL --------
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text(
                      "☰ Menú",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text("Inicio"),
                    onTap: () => context.go('/home'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Perfil"),
                    onTap: () => context.go('/profile'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.sensors),
                    title: const Text("Sensores"),
                    onTap: () => context.go('/sensors'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text("Historial"),
                    onTap: () => context.go('/history'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Configuración"),
                    onTap: () => context.go('/settings'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.key),
                    title: const Text("Generar Código"),
                    onTap: () => context.go('/invite'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Cerrar sesión"),
                    onTap: () async {
                      final session = ref.read(sessionServiceProvider);
                      await session.logout();

                      if (!context.mounted) return;
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),

            body: child,
          );
        },

        // ---------- RUTAS HIJAS DE SHELLROUTE ----------
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: '/invite',
            name: 'invite',
            builder: (_, __) => const InvitePage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (_, __) => const PlaceholderWidget("Perfil"),
          ),
          GoRoute(
            path: '/sensors',
            name: 'sensors',
            builder: (_, __) => const PlaceholderWidget("Sensores"),
          ),
        ],
      ),
    ],
  );
});

// -------- TITULOS DE CADA RUTA --------
String _getTitleFor(String location) {
  switch (location) {
    case '/home':
      return 'Inicio';
    case '/invite':
      return 'Generar Código';
    case '/profile':
      return 'Perfil';
    case '/sensors':
      return 'Sensores';

    default:
      return '';
  }
}

// -------- WIDGET TEMPORAL PARA RUTAS QUE AÚN NO HICISTE --------
class PlaceholderWidget extends StatelessWidget {
  final String text;
  const PlaceholderWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: const TextStyle(fontSize: 22)));
  }
}
