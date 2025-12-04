import 'package:app_alerta_vital/core/services/location_provider.dart';
import 'package:app_alerta_vital/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_alerta_vital/core/services/session_provider.dart';

class PatientLocationPage extends ConsumerStatefulWidget {
  const PatientLocationPage({super.key});

  @override
  ConsumerState<PatientLocationPage> createState() => _PatientLocationPageState();
}

class _PatientLocationPageState extends ConsumerState<PatientLocationPage> {
  bool _isTracking = false;
  Position? _currentPosition;
  String? _errorMessage;
  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _locationService = ref.read(locationServiceProvider);
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    
    final hasPermission = await _locationService.checkAndRequestPermissions();
    
    if (!hasPermission && mounted) {
      setState(() {
        _errorMessage = 'Se requieren permisos de ubicación para usar esta función';
      });
    }
  }

  Future<void> _toggleTracking() async {
    
    final session = ref.read(sessionServiceProvider);
    final userId = await session.getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no identificado')),
      );
      return;
    }

    if (_isTracking) {
      // Detener seguimiento
      _locationService.stopLocationTracking();
      setState(() {
        _isTracking = false;
        _errorMessage = null;
      });
    } else {
      // Iniciar seguimiento
      try {
        await _locationService.startLocationTracking(userId.toString());
        
        // Obtener ubicación actual para mostrar
        final position = await _locationService.getCurrentLocation();
        
        setState(() {
          _isTracking = true;
          _currentPosition = position;
          _errorMessage = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Compartiendo ubicación en tiempo real'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isTracking = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_isTracking) {
      _locationService.stopLocationTracking();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Ubicación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icono de ubicación
            Icon(
              _isTracking ? Icons.location_on : Icons.location_off,
              size: 100,
              color: _isTracking ? Colors.green : Colors.grey,
            ),

            const SizedBox(height: 20),

            // Estado
            Text(
              _isTracking 
                  ? 'Compartiendo ubicación' 
                  : 'Ubicación no compartida',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isTracking ? Colors.green : Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            // Descripción
            Text(
              _isTracking
                  ? 'Tus cuidadores pueden ver tu ubicación en tiempo real'
                  : 'Activa el seguimiento para compartir tu ubicación',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 30),

            // Coordenadas actuales
            if (_currentPosition != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Latitud:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_currentPosition!.latitude.toStringAsFixed(6)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Longitud:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_currentPosition!.longitude.toStringAsFixed(6)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Precisión:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${_currentPosition!.accuracy.toStringAsFixed(1)} m'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Mensaje de error
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Botón principal
            ElevatedButton.icon(
              onPressed: _toggleTracking,
              icon: Icon(_isTracking ? Icons.location_off : Icons.location_on),
              label: Text(
                _isTracking 
                    ? 'Detener Seguimiento' 
                    : 'Iniciar Seguimiento',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La ubicación se actualiza automáticamente cada 10 metros',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}