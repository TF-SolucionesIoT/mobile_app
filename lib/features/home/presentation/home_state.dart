import 'package:app_alerta_vital/features/home/domain/models/realtime_data.dart';

class HomeState {
  final List<RealtimeData> patients;

  const HomeState({
    required this.patients,
  });

  factory HomeState.initial() {
    return const HomeState(patients: []);
  }

  HomeState copyWith({
    List<RealtimeData>? patients,
  }) {
    return HomeState(
      patients: patients ?? this.patients,
    );
  }
}
