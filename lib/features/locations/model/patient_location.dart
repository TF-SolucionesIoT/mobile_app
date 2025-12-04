import 'package:cloud_firestore/cloud_firestore.dart';


class PatientLocation {
  final String patientUserId;
  final double lat;
  final double lng;
  final double? accuracy;
  final DateTime? updatedAt;

  PatientLocation({
    required this.patientUserId,
    required this.lat,
    required this.lng,
    this.accuracy,
    this.updatedAt,
  });

  factory PatientLocation.fromFirestore(
    String userId,
    Map<String, dynamic> data,
  ) {
    try {
      print('🔍 Parseando ubicación de $userId con data: $data');
      
      // Validar campos requeridos
      if (!data.containsKey('lat') || !data.containsKey('lng')) {
        throw Exception('Faltan campos lat/lng en los datos');
      }
      
      final lat = (data['lat'] is int) 
          ? (data['lat'] as int).toDouble() 
          : (data['lat'] as num).toDouble();
          
      final lng = (data['lng'] is int) 
          ? (data['lng'] as int).toDouble() 
          : (data['lng'] as num).toDouble();
      
      final accuracy = data['accuracy'] != null 
          ? (data['accuracy'] is int)
              ? (data['accuracy'] as int).toDouble()
              : (data['accuracy'] as num).toDouble()
          : null;
      
      DateTime? updatedAt;
      if (data['updatedAt'] != null) {
        if (data['updatedAt'] is Timestamp) {
          updatedAt = (data['updatedAt'] as Timestamp).toDate();
        } else if (data['updatedAt'] is String) {
          updatedAt = DateTime.parse(data['updatedAt'] as String);
        }
      }
      
      print('✅ Ubicación parseada correctamente');
      
      return PatientLocation(
        patientUserId: userId,
        lat: lat,
        lng: lng,
        accuracy: accuracy,
        updatedAt: updatedAt,
      );
    } catch (e, stackTrace) {
      print('❌ Error parseando PatientLocation: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'patientUserId': patientUserId,
      'lat': lat,
      'lng': lng,
      'accuracy': accuracy,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String getTimeAgo() {
    if (updatedAt == null) return 'Desconocido';

    final now = DateTime.now();
    final difference = now.difference(updatedAt!);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }

  bool get isRecent {
    if (updatedAt == null) return false;
    final difference = DateTime.now().difference(updatedAt!);
    return difference.inMinutes < 5;
  }
}