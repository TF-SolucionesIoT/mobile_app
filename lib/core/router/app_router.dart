import 'package:app_alerta_vital/core/services/type_of_user_provider.dart';
import 'package:app_alerta_vital/features/alerts/presentation/reading_alert_page.dart';
import 'package:app_alerta_vital/features/auth/presentation/register/register_page.dart';
import 'package:app_alerta_vital/features/home/presentation/caregiver_home_page.dart';
import 'package:app_alerta_vital/features/home/presentation/home_controller.dart';
import 'package:app_alerta_vital/features/invitecode/presentation/confirmcode/confirm_code_page.dart';
import 'package:app_alerta_vital/features/invitecode/presentation/generatecode/invite_page.dart';
import 'package:app_alerta_vital/features/locations/presentation/caregiver_map_page.dart';
import 'package:app_alerta_vital/features/locations/presentation/patient_location_page.dart';
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
      final session = ref.read(sessionServiceProvider);

      final logged = await session.isLogged();
      final userType = await session.getUserType();

      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';

      if (!logged && !(isLogin || isRegister)) {
        return '/login';
      }

      if (logged && (isLogin || isRegister)) {
        if (userType == "PATIENT") {
          return '/patient-home';
        }
        if (userType == "CAREGIVER") {
          return '/caregiver-home';
        }
      }

      if (userType == "PATIENT" && state.matchedLocation == '/home') {
        return '/patient-home';
      }

      if (userType == "CAREGIVER" && state.matchedLocation == '/home') {
        return '/caregiver-home';
      }

      if (userType == "PATIENT" && state.matchedLocation == '/caregiver-home') {
        return '/patient-home';
      }

      // Therapist no puede acceder a rutas de Legal
      if (userType == "CAREGIVER" && state.matchedLocation == '/patient-home') {
        return '/caregiver-home';
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
            ),

            body: child,

            // ---------- NUEVO NAVIGATION BAR ----------
            bottomNavigationBar: FutureBuilder(
              future: ref.read(sessionServiceProvider).getUserType(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(height: 65);
                }

                final role = snapshot.data;
                final items = <_NavItem>[];

                // ---- ITEMS OPCIONALES POR ROL ----
                if (role == "PATIENT") {
                  items.add(
                    _NavItem(
                      label: "Generar Código",
                      icon: Icons.group_add,
                      location: "/invite",
                    ),
                  );
                }

                if (role == "PATIENT") {
                  items.add(
                    _NavItem(
                      label: "Signos vitales",
                      icon: Icons.monitor_heart,
                      location: "/patient-home",
                    ),
                  );
                }

                if (role == "PATIENT") {
                  items.add(
                    _NavItem(
                      label: "Mi Ubicación",
                      icon: Icons.location_on,
                      location: "/patient-location",
                    ),
                  );
                }

                if (role == "PATIENT") {
                  items.add(
                    _NavItem(
                      label: "Alertas",
                      icon: Icons.crisis_alert,
                      location: "/patient-alerts",
                    ),
                  );
                }

                if (role == "CAREGIVER") {
                  items.add(
                    _NavItem(
                      label: "Signos Vitales",
                      icon: Icons.diversity_1,
                      location: "/caregiver-home",
                    ),
                  );
                }

                if (role == "CAREGIVER") {
                  items.add(
                    _NavItem(
                      label: "Usar Código",
                      icon: Icons.family_restroom,
                      location: "/confirm-code",
                    ),
                  );
                }

                if (role == "CAREGIVER") {
                  items.add(
                    _NavItem(
                      label: "Ver Ubicaciones",
                      icon: Icons.map,
                      location: "/caregiver-map",
                    ),
                  );
                }

                
                // ---- LOGOUT SIEMPRE AL FINAL ----
                items.add(
                  _NavItem(
                    label: "Salir",
                    icon: Icons.logout,
                    location: "/logout",
                  ),
                );

                final currentIndex = items.indexWhere(
                  (i) => i.location == state.matchedLocation,
                );

                return NavigationBar(
                  height: 65,
                  selectedIndex: currentIndex >= 0 ? currentIndex : 0,
                  backgroundColor: Colors.white,
                  indicatorColor: Colors.blue.shade100,
                  elevation: 12,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,

                  onDestinationSelected: (index) async {
                    final item = items[index];

                    if (item.location == "/logout") {
                      final s = ref.read(sessionServiceProvider);
                      await s.logout();

                      ref.invalidate(homeControllerProvider);
                      ref.invalidate(userTypeProvider);

                      if (!context.mounted) return;
                      context.go('/login');
                      return;
                    }

                    context.go(item.location);
                  },

                  destinations: [
                    for (final item in items)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        label: item.label,
                      ),
                  ],
                );
              },
            ),
          );
        },

        // ---------- RUTAS HIJAS DE SHELLROUTE ----------
        routes: [
          GoRoute(
            path: '/patient-home',
            name: 'Patient Home',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: '/caregiver-home',
            name: 'Caregiver Home',
            builder: (_, __) => const CaregiverHomePage(),
          ),
          GoRoute(
            path: '/invite',
            name: 'invite',
            builder: (_, __) => const InvitePage(),
          ),
          GoRoute(
            path: '/confirm-code',
            name: 'Confirm Code',
            builder: (_, __) => ConfirmCodePage(),
          ),
          GoRoute(
            path: '/sensors',
            name: 'sensors',
            builder: (_, __) => const PlaceholderWidget("Sensores"),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (_, __) => const PlaceholderWidget("Perfil"),
          ),
          GoRoute(
            path: '/patient-location',
            name: 'Patient Location',
            builder: (_, __) => const PatientLocationPage(),
          ),
          GoRoute(
            path: '/caregiver-map',
            name: 'Caregiver Map',
            builder: (_, __) => const CaregiverMapPage(),
          ),
          GoRoute(path: '/patient-alerts', 
            name: 'Patient Alerts',
            builder: (_, __) => const ReadingAlertsPage(),
          ),
        ],
      ),
    ],
  );
});

// -------- TITULOS DE CADA RUTA --------
String _getTitleFor(String location) {
  switch (location) {
    case '/patient-home':
      return 'Inicio';
    case '/caregiver-home':
      return 'Inicio';
    case '/invite':
      return 'Generar Código';
    case '/profile':
      return 'Perfil';
    case '/sensors':
      return 'Sensores';
    case '/confirm-code':
      return 'Confirmar Código';

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

class _NavItem {
  final String label;
  final IconData icon;
  final String location;

  _NavItem({required this.label, required this.icon, required this.location});
}
