import 'package:app_alerta_vital/features/alerts/presentation/reading_alerts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ReadingAlertsPage extends ConsumerStatefulWidget {
  const ReadingAlertsPage({super.key});

  @override
  ConsumerState<ReadingAlertsPage> createState() => _ReadingAlertsPageState();
}

class _ReadingAlertsPageState extends ConsumerState<ReadingAlertsPage> {
  final Color primaryColor = const Color(0xFF5A9DE0);
  final Color secondaryColor = const Color(0xFF7B68EE);
  final Color accentColor = const Color(0xFF00D4AA);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(readingAlertsControllerProvider.notifier).loadAlerts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingAlertsControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [primaryColor, secondaryColor],
          ).createShader(bounds),
          child: const Text(
            "Reading Alerts",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor, size: 28),
            onPressed: () =>
                ref.read(readingAlertsControllerProvider.notifier).loadAlerts(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.08),
              Colors.white,
              accentColor.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(state) {
    if (state.isLoading) {
      return Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 4,
          ),
        ),
      );
    }

    if (state.hasError) {
      return _buildError(state.errorMessage!);
    }

    if (!state.hasAlerts) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () =>
          ref.read(readingAlertsControllerProvider.notifier).loadAlerts(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        itemCount: state.alerts.length,
        itemBuilder: (context, index) {
          final alert = state.alerts[index];
          final formattedDate =
              DateFormat('dd/MM/yyyy HH:mm:ss').format(alert.timestamp);

          return _buildAlertCard(alert.deviceId.toString(), alert.id.toString(), formattedDate, index);
        },
      ),
    );
  }

  // === UI COMPONENTS ===

  Widget _buildError(String errorMessage) {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        builder: (context, value, child) {
          return Opacity(opacity: value, child: child);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 70, color: Colors.red.shade400),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () =>
                  ref.read(readingAlertsControllerProvider.notifier).loadAlerts(),
              child: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.8, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none,
                size: 80, color: Colors.grey.shade500),
            const SizedBox(height: 20),
            Text(
              'No hay alertas disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
      String deviceId, String id, String date, int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 120)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: primaryColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
              ),
              child: const Icon(Icons.warning, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Device: $deviceId",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "ID: $id",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
