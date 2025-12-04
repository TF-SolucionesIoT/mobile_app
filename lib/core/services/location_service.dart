import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionSubscription;

  /// Verifica y solicita permisos de ubicación
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Inicia el seguimiento de ubicación para un paciente
  Future<void> startLocationTracking(String patientUserId) async {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      throw Exception('No se tienen permisos de ubicación');
    }

    // Configuración para actualizaciones de ubicación
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualizar cada 10 metros
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _updateLocationInFirestore(patientUserId, position);
    });
  }

  /// Actualiza la ubicación en Firestore
  Future<void> _updateLocationInFirestore(
    String patientUserId,
    Position position,
  ) async {
    try {
      await _firestore.collection('locations').doc(patientUserId).set({
        'lat': position.latitude,
        'lng': position.longitude,
        'accuracy': position.accuracy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('📍 Ubicación actualizada: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ Error al actualizar ubicación: $e');
    }
  }

  /// Obtiene la ubicación actual sin seguimiento continuo
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      print('❌ Error al obtener ubicación: $e');
      return null;
    }
  }

  /// Detiene el seguimiento de ubicación
  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    print('🛑 Seguimiento de ubicación detenido');
  }

  /// Stream para escuchar cambios de ubicación de un paciente específico
  Stream<DocumentSnapshot> locationStream(String patientUserId) {
    return _firestore
        .collection('locations')
        .doc(patientUserId)
        .snapshots();
  }

  /// Obtiene la última ubicación conocida de un paciente
  Future<Map<String, dynamic>?> getLastKnownLocation(String patientUserId) async {
    try {
      final doc = await _firestore
          .collection('locations')
          .doc(patientUserId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error al obtener ubicación: $e');
      return null;
    }
  }
}