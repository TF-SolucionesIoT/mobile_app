import 'package:app_alerta_vital/core/services/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final session = ref.read(sessionServiceProvider);
    
    return Scaffold(
      body: Center(child:
       Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           const Text("Bienvenido!"),
         ],
       ),
       ),
       
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
           final router = GoRouter.of(context); 
          await session.logout();
          router.go('/login');
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
