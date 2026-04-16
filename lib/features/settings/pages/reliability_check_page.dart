import 'package:flutter/material.dart';
import '../services/reliability_service.dart';
import 'dart:io';

class ReliabilityCheckPage extends StatefulWidget {
  const ReliabilityCheckPage({super.key});

  @override
  State<ReliabilityCheckPage> createState() => _ReliabilityCheckPageState();
}

class _ReliabilityCheckPageState extends State<ReliabilityCheckPage> with WidgetsBindingObserver {
  final ReliabilityService _service = ReliabilityService();
  
  bool _notificationsOk = true;
  bool _alarmsOk = true;
  bool _batteryOk = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAll();
    }
  }

  Future<void> _checkAll() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _service.isNotificationPermissionGranted(),
      _service.isExactAlarmPermissionGranted(),
      _service.isBatteryOptimizationDisabled(),
    ]);

    if (mounted) {
      setState(() {
        _notificationsOk = results[0];
        _alarmsOk = results[1];
        _batteryOk = results[2];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zuverlässigkeits-Check')),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildCheckItem(
                icon: Icons.notifications_active_outlined,
                title: 'Benachrichtigungen',
                description: 'Wichtig für Medikamenten-Erinnerungen und Timer-Abschluss.',
                isOk: _notificationsOk,
                onFix: () => _service.requestNotificationPermission(),
              ),
              if (Platform.isAndroid) ...[
                const SizedBox(height: 20),
                _buildCheckItem(
                  icon: Icons.alarm_on_rounded,
                  title: 'Exakte Alarme',
                  description: 'Erlaubt es der App, Erinnerungen auf die Sekunde genau auszulösen.',
                  isOk: _alarmsOk,
                  onFix: () => _service.requestExactAlarmPermission(),
                ),
                const SizedBox(height: 20),
                _buildCheckItem(
                  icon: Icons.battery_charging_full_rounded,
                  title: 'Akku-Optimierung',
                  description: 'Verhindert, dass Android die App im Hintergrund beendet.',
                  isOk: _batteryOk,
                  onFix: () => _service.openBatteryOptimizationSettings(),
                ),
              ],
              const SizedBox(height: 40),
              _buildFooter(),
            ],
          ),
    );
  }

  Widget _buildHeader() {
    final bool allOk = _notificationsOk && _alarmsOk && _batteryOk;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (allOk ? Colors.green : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (allOk ? Colors.green : Colors.orange).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            allOk ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            size: 64,
            color: allOk ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            allOk ? 'Alles bestens!' : 'Handlungsbedarf',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            allOk 
              ? 'Deine Einstellungen sind optimal für maximale Zuverlässigkeit.'
              : 'Einige Einstellungen schränken die Zuverlässigkeit der Erinnerungen ein.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isOk,
    required VoidCallback onFix,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isOk ? Colors.green : Colors.red).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOk ? Icons.check : Icons.close,
              color: isOk ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                if (!isOk) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onFix,
                      child: const Text('Einstellung korrigieren'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'Hinweis: Die Einstellungen werden automatisch aktualisiert, wenn du von den Systemeinstellungen zurückkehrst.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _checkAll,
          icon: const Icon(Icons.refresh),
          label: const Text('Status jetzt aktualisieren'),
        ),
      ],
    );
  }
}
