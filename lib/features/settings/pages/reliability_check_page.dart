import 'package:flutter/material.dart';
import '../services/reliability_service.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:io';

class ReliabilityCheckPage extends StatefulWidget {
  const ReliabilityCheckPage({super.key});

  @override
  State<ReliabilityCheckPage> createState() => _ReliabilityCheckPageState();
}

class _ReliabilityCheckPageState extends State<ReliabilityCheckPage>
    with WidgetsBindingObserver {
  final ReliabilityService _service = ReliabilityService();

  bool _notificationsOk = true;
  bool _alarmsOk = true;
  bool _batteryOk = true;
  bool _backupOk = true;
  bool _lastBackupOk = true;
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
    if (!mounted) return;
    setState(() => _loading = true);
    final results = await Future.wait([
      _service.isNotificationPermissionGranted(),
      _service.isExactAlarmPermissionGranted(),
      _service.isBatteryOptimizationDisabled(),
      _service.isBackupSetup(),
      _service.isLastBackupSuccessful(),
    ]);

    if (!mounted) return;
    setState(() {
      _notificationsOk = results[0];
      _alarmsOk = results[1];
      _batteryOk = results[2];
      _backupOk = results[3];
      _lastBackupOk = results[4];
      _loading = false;
    });
  }

  /// Runs a permission request or settings deep-link and re-checks once it
  /// returns, so the row updates in place instead of waiting for the next
  /// app resume.
  Future<void> _runFix(Future<void> Function() fix) async {
    await fix();
    if (!mounted) return;
    await _checkAll();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reliabilityTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildCheckItem(
                  icon: Icons.notifications_active_outlined,
                  title: l10n.reliabilityNotifications,
                  description: l10n.reliabilityNotificationsDesc,
                  isOk: _notificationsOk,
                  fixLabel: l10n.reliabilityFix,
                  onFix: () => _runFix(_service.requestNotificationPermission),
                ),
                if (Platform.isAndroid) ...[
                  const SizedBox(height: 20),
                  _buildCheckItem(
                    icon: Icons.alarm_on_rounded,
                    title: l10n.reliabilityExactAlarms,
                    description: l10n.reliabilityExactAlarmsDesc,
                    isOk: _alarmsOk,
                    fixLabel: l10n.reliabilityFix,
                    onFix: () => _runFix(_service.requestExactAlarmPermission),
                  ),
                  const SizedBox(height: 20),
                  _buildCheckItem(
                    icon: Icons.battery_charging_full_rounded,
                    title: l10n.reliabilityBatteryOptimization,
                    description: l10n.reliabilityBatteryOptimizationDesc,
                    isOk: _batteryOk,
                    fixLabel: l10n.reliabilityFix,
                    onFix: () =>
                        _runFix(_service.openBatteryOptimizationSettings),
                  ),
                ],
                const SizedBox(height: 20),
                // The backup rows cannot be fixed from here: their button
                // sends the patient back to Settings, and says so.
                _buildCheckItem(
                  icon: Icons.backup_outlined,
                  title: l10n.settingsSectionAutoBackup,
                  description: l10n.reliabilityBackupDesc,
                  isOk: _backupOk,
                  fixLabel: l10n.navSettings,
                  onFix: () => Navigator.pop(context),
                ),
                if (_backupOk) ...[
                  const SizedBox(height: 20),
                  _buildCheckItem(
                    icon: Icons.cloud_done_outlined,
                    title: l10n.reliabilityBackupStatus,
                    description: _lastBackupOk
                        ? l10n.reliabilityBackupUpToDate
                        : l10n.reliabilityBackupStale,
                    isOk: _lastBackupOk,
                    fixLabel: l10n.navSettings,
                    onFix: () => Navigator.pop(context),
                  ),
                ],
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    final bool allOk =
        _notificationsOk &&
        _alarmsOk &&
        _batteryOk &&
        _backupOk &&
        _lastBackupOk;
    final statusColors = AppStatusColors.of(context);
    final tone = allOk ? statusColors.success : statusColors.warning;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tone.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            allOk ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            size: 64,
            color: tone,
          ),
          const SizedBox(height: 16),
          Text(
            allOk
                ? context.l10n.reliabilityAllGood
                : context.l10n.reliabilityActionNeeded,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            allOk
                ? context.l10n.reliabilityAllGoodBody
                : context.l10n.reliabilityActionNeededBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
    required String fixLabel,
    required VoidCallback onFix,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = isOk
        ? AppStatusColors.of(context).success
        : scheme.error;
    final statusText = isOk
        ? context.l10n.reliabilityStatusOk
        : context.l10n.reliabilityStatusFailed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          // Colour alone does not carry the result: the glyph is paired with
          // a word, and the pair reads as one item to a screen reader.
          Semantics(
            label: statusText,
            excludeSemantics: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOk ? Icons.check : Icons.close,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isOk) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: onFix, child: Text(fixLabel)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          context.l10n.reliabilityFooterHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _checkAll,
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.reliabilityRefresh),
        ),
      ],
    );
  }
}
