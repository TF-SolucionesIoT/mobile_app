import 'dart:async';
import 'package:app_alerta_vital/core/services/location_provider.dart';
import 'package:app_alerta_vital/features/locations/data/access_provider.dart';
import 'package:app_alerta_vital/features/locations/model/patient_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_alerta_vital/core/services/session_provider.dart';

class CaregiverMapPage extends ConsumerStatefulWidget {
  const CaregiverMapPage({super.key});

  @override
  ConsumerState<CaregiverMapPage> createState() => _CaregiverMapPageState();
}

class _CaregiverMapPageState extends ConsumerState<CaregiverMapPage> {
  GoogleMapController? _mapController;
  final Map<String, StreamSubscription<DocumentSnapshot>> _subscriptions = {};
  final Map<String, PatientLocation> _patientLocations = {};
  Set<Marker> _markers = {};

  bool _isLoading = true;
  String? _errorMessage;

  // Ubicación inicial (Lima, Perú como ejemplo)
  static const LatLng _initialPosition = LatLng(-12.0464, -77.0428);

  @override
  void initState() {
    super.initState();
    _loadLinkedPatients();
  }

  Future<void> _loadLinkedPatients() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = ref.read(sessionServiceProvider);
      final token = await session.getAccessToken();

      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final accessService = ref.read(accessApiServiceProvider);
      final patientUserIds = await accessService.getLinkedPatients(token);

      print('👥 Pacientes vinculados: $patientUserIds');
      print('📊 Total: ${patientUserIds.length}');

      if (patientUserIds.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'No tienes pacientes vinculados';
        });
        return;
      }

      // Suscribirse a las ubicaciones de cada paciente
      final locationService = ref.read(locationServiceProvider);

      for (final patientUserId in patientUserIds) {
        print('🔔 Suscribiéndose a: $patientUserId');

        _subscriptions[patientUserId] = locationService
            .locationStream(patientUserId)
            .listen(
              (snapshot) {
                print('📡 Snapshot recibido para $patientUserId');

                try {
                  if (snapshot.exists && snapshot.data() != null) {
                    final data = snapshot.data() as Map<String, dynamic>;
                    print('📦 Data: $data');

                    final location = PatientLocation.fromFirestore(
                      patientUserId,
                      data,
                    );

                    print(
                      '✅ Ubicación parseada: ${location.lat}, ${location.lng}',
                    );

                    if (!mounted) return;

                    setState(() {
                      _patientLocations[patientUserId] = location;
                      _updateMarkers();
                    });

                    print('🗺️ Marcadores totales: ${_markers.length}');

                    // Centrar el mapa en la primera ubicación
                    if (_patientLocations.length == 1 &&
                        _mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(location.lat, location.lng),
                          14,
                        ),
                      );
                    }
                  } else {
                    print('⚠️ Snapshot vacío para $patientUserId');
                  }
                } catch (e, stackTrace) {
                  print('❌ Error procesando snapshot: $e');
                  print('Stack trace: $stackTrace');
                }
              },
              onError: (error) {
                print('❌ Error en stream de $patientUserId: $error');
              },
            );
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('💥 Error en _loadLinkedPatients: $e');
      print('Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar pacientes: ${e.toString()}';
      });
    }
  }

  void _updateMarkers() {
    _markers = _patientLocations.entries.map((entry) {
      final location = entry.value;

      return Marker(
        markerId: MarkerId(location.patientUserId),
        position: LatLng(location.lat, location.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          location.isRecent
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: 'Paciente ${location.patientUserId}',
          snippet:
              '${location.getTimeAgo()} • ${location.accuracy?.toStringAsFixed(0) ?? "?"}m de precisión',
        ),
        onTap: () => _showPatientDetails(location),
      );
    }).toSet();
  }

  void _showPatientDetails(PatientLocation location) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: location.isRecent
                      ? Colors.green
                      : Colors.red,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paciente ${location.patientUserId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      location.isRecent
                          ? 'Ubicación reciente'
                          : 'Ubicación desactualizada',
                      style: TextStyle(
                        color: location.isRecent ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 30),

            _detailRow(
              icon: Icons.access_time,
              label: 'Última actualización',
              value: location.getTimeAgo(),
            ),
            const SizedBox(height: 12),
            _detailRow(
              icon: Icons.location_on,
              label: 'Coordenadas',
              value:
                  '${location.lat.toStringAsFixed(6)}, ${location.lng.toStringAsFixed(6)}',
            ),
            const SizedBox(height: 12),
            _detailRow(
              icon: Icons.my_location,
              label: 'Precisión',
              value: '${location.accuracy?.toStringAsFixed(1) ?? "?"} metros',
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(location.lat, location.lng),
                    16,
                  ),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Centrar en el mapa'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Ubicación de Pacientes'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadLinkedPatients,
          tooltip: 'Recargar',
        ),
      ],
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadLinkedPatients,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            : SafeArea(  // 👈 Agregar SafeArea
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (controller) {
                        print('🗺️ Mapa creado');
                        _mapController = controller;
                      },
                      initialCameraPosition: const CameraPosition(
                        target: _initialPosition,
                        zoom: 12,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      mapType: MapType.normal,
                      zoomControlsEnabled: true,  // 👈 Agregar controles
                    ),

                    // Leyenda
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Pacientes: ${_patientLocations.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (_patientLocations.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('Ubicación reciente (<5 min)'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('Ubicación desactualizada'),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
  );
}
}
