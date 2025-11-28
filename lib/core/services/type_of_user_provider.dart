import 'package:app_alerta_vital/core/services/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userTypeProvider = FutureProvider<String?>((ref) async {
  final session = ref.read(sessionServiceProvider);
  return session.getUserType();
});
