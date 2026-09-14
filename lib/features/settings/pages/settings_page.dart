import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backup_service.dart';
import '../services/backup_worker.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/constants/build_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'reliability_check_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_links.dart';
import '../../../core/database/database.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final BackupService backupService = BackupService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          _buildSectionHeader(l10n.settingsSectionAppearance),
          SwitchListTile(
            title: Text(l10n.settingsDarkMode),
            subtitle: Text(l10n.settingsDarkModeHint),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (val) => themeProvider.toggleTheme(),
            secondary: const Icon(Icons.brightness_4),
          ),
          ListTile(
            leading: const Icon(Icons.translate_rounded),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(localeProvider.followsSystem
                ? l10n.settingsLanguageSystem
                : _languageName(l10n, localeProvider.locale!.languageCode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context, localeProvider),
          ),
          const Divider(),
          _buildSectionHeader(l10n.settingsSectionAutoBackup),
          FutureBuilder<BackupStatus>(
            future: backupService.getStatus(),
            builder: (context, snapshot) {
              final status = snapshot.data;
              final dest = status?.destination;
              final hasError = (status?.lastError != null) ||
                  ((status?.consecutiveFailures ?? 0) > 0);

              return Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.settingsEnableAutoBackup),
                    subtitle: Text(l10n.settingsEnableAutoBackupHint),
                    value: status?.enabled ?? false,
                    onChanged: (val) async {
                      await backupService.setEnabled(val);
                      await BackupScheduler.syncFromPrefs();
                      if (mounted) setState(() {});
                    },
                    secondary: const Icon(Icons.backup_outlined),
                  ),
                  if (hasError && dest != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.settingsBackupNotPossible,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  status?.lastError ?? l10n.settingsUnknownError,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                FilledButton.tonal(
                                  onPressed: _pickDestination,
                                  child: Text(l10n.settingsPickFolderAgain),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  // App-internal backups are deleted together with the app, so
                  // they are no protection against a reinstall — the one case
                  // where a backup matters most. Say so instead of showing a
                  // green check and letting the user assume they are covered.
                  if (dest != null && !dest.isDurable && !hasError)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.settingsBackupsInsideAppTitle,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.settingsBackupsInsideAppBody,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ListTile(
                    leading: Icon(dest != null
                        ? Icons.folder
                        : Icons.folder_open_outlined),
                    title: Text(l10n.settingsBackupDestination),
                    subtitle: Text(
                      dest == null ? l10n.settingsPickDestination : dest.displayLabel(l10n),
                    ),
                    trailing: dest != null
                        ? const Icon(Icons.check_circle,
                            color: Colors.green, size: 16)
                        : null,
                    onTap: Platform.isIOS
                        ? () => _showIosStorageInfo(context)
                        : _pickDestination,
                  ),
                  if (dest != null)
                    ListTile(
                      leading: const Icon(Icons.play_circle_outline),
                      title: Text(l10n.settingsRunBackupNow),
                      onTap: () async {
                        final result =
                            await backupService.runBackup(manual: true);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.success
                                ? l10n.settingsBackupSucceeded
                                : l10n.settingsBackupFailed('${result.error}')),
                            backgroundColor:
                                result.success ? Colors.green : Colors.red,
                          ),
                        );
                        if (mounted) setState(() {});
                      },
                    ),
                  if (dest != null)
                    ListTile(
                      leading: const Icon(Icons.ios_share),
                      title: Text(l10n.settingsExportBackup),
                      subtitle: Text(l10n.settingsExportBackupHint),
                      onTap: () async {
                        final box = context.findRenderObject() as RenderBox?;
                        final origin = box != null
                            ? box.localToGlobal(Offset.zero) & box.size
                            : null;
                        final ok = await backupService.shareLatestBackup(
                          sharePositionOrigin: origin,
                        );
                        if (!context.mounted || ok) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.settingsNoBackupToExport),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    ),
                  if (status?.lastSuccess != null)
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(l10n.settingsLastSuccess),
                      subtitle: Text(
                        AppDateFormat.dateTime(context, status!.lastSuccess!),
                      ),
                    ),
                  if (status?.lastAttempt != null &&
                      (status?.lastSuccess == null ||
                          status!.lastAttempt!
                              .isAfter(status.lastSuccess!)))
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(l10n.settingsLastAttempt),
                      subtitle: Text(
                        AppDateFormat.dateTime(context, status!.lastAttempt!),
                      ),
                    ),
                  ListTile(
                    leading: const Icon(Icons.settings_backup_restore),
                    title: Text(l10n.settingsRestoreBackup),
                    subtitle: Text(l10n.settingsRestoreBackupHint),
                    onTap: () => _showRestoreBackupDialog(context),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(l10n.settingsSectionReminders),
          FutureBuilder<Map<String, dynamic>>(
            future: _getReminderSettings(),
            builder: (context, snapshot) {
              final settings = snapshot.data ?? {'snooze': true, 'hourly': true, 'snooze_interval': 15, 'quiet_start': 22, 'quiet_end': 6};
              final snoozeInterval = settings['snooze_interval'] as int;
              return Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.settingsSnooze),
                    subtitle: Text(l10n.settingsSnoozeHint(snoozeInterval)),
                    value: settings['snooze'],
                    onChanged: (val) => _updateReminderSetting('snooze', val),
                    secondary: const Icon(Icons.snooze_rounded),
                  ),
                  if (settings['snooze'] == true)
                    ListTile(
                      leading: const Icon(Icons.timelapse_rounded),
                      title: Text(l10n.settingsSnoozeInterval),
                      subtitle: Text(l10n.settingsSnoozeIntervalCurrent(snoozeInterval)),
                      onTap: () => _showSnoozeIntervalPicker(context, snoozeInterval),
                    ),
                  SwitchListTile(
                    title: Text(l10n.settingsHourlyReminder),
                    subtitle: Text(l10n.settingsHourlyReminderHint),
                    value: settings['hourly'],
                    onChanged: (val) => _updateReminderSetting('hourly', val),
                    secondary: const Icon(Icons.hourglass_bottom_rounded),
                  ),
                  ListTile(
                    leading: const Icon(Icons.nightlight_round),
                    title: Text(l10n.settingsQuietHours),
                    subtitle: Text(l10n.settingsQuietHoursHint(
                        '${settings['quiet_start']}:00', '${settings['quiet_end']}:00')),
                    onTap: () => _showQuietHoursPicker(context, settings['quiet_start'], settings['quiet_end']),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(l10n.settingsSectionSystem),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text(l10n.reliabilityTitle),
            subtitle: Text(l10n.reliabilitySubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const ReliabilityCheckPage())
            ),
          ),
          const Divider(),
          _buildSectionHeader(l10n.settingsSectionHyqviaTimer),
          FutureBuilder<bool>(
            future: SharedPreferences.getInstance().then((p) => p.getBool('hyqvia_timer_enabled') ?? true),
            builder: (context, snapshot) {
              final enabled = snapshot.data ?? true;
              return SwitchListTile(
                title: Text(l10n.settingsSuggestTimer),
                subtitle: Text(l10n.settingsSuggestTimerHint),
                value: enabled,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('hyqvia_timer_enabled', val);
                  setState(() {});
                },
                secondary: const Icon(Icons.av_timer_rounded),
              );
            },
          ),
          FutureBuilder<int>(
            future: SharedPreferences.getInstance().then((p) => p.getInt('hyqvia_timer_duration') ?? 10),
            builder: (context, snapshot) {
              final duration = snapshot.data ?? 10;
              return ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l10n.settingsPremedDuration),
                subtitle: Text(l10n.settingsCurrentMinutes(duration)),
                onTap: () => _showDurationPicker(context, duration),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(l10n.settingsSectionLegal),
          ListTile(
            leading: const Icon(Icons.warning_amber_rounded),
            title: Text(l10n.legalLiabilityTitle),
            subtitle: Text(l10n.legalLiabilitySubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showLegalText(
              context,
              l10n.legalLiabilityTitle,
              l10n.legalLiabilityBody,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_2_rounded),
            title: Text(l10n.legalBatchDocumentationTitle),
            subtitle: Text(l10n.legalBatchDocumentationSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showLegalText(
              context,
              l10n.legalBatchDocumentationTitle,
              l10n.legalBatchDocumentationLong,
            ),
          ),
          if (AppLinks.impressumUrl != null || AppLinks.datenschutzUrl != null) ...[
            if (AppLinks.impressumUrl != null)
              ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: Text(l10n.legalImprint),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => launchUrl(
                  Uri.parse(AppLinks.impressumUrl!),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            if (AppLinks.datenschutzUrl != null)
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.legalPrivacyPolicy),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => launchUrl(
                  Uri.parse(AppLinks.datenschutzUrl!),
                  mode: LaunchMode.externalApplication,
                ),
              ),
          ],
          const Divider(),
          _buildSectionHeader(l10n.settingsSectionAbout),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '...';
              final buildNumber = snapshot.data?.buildNumber ?? '...';
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.settingsVersion, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('$version ($buildNumber)', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.settingsBuildTimestamp, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(BuildConfig.buildTimestamp, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(l10n.settingsPrivacy),
            subtitle: Text(l10n.settingsPrivacyHint),
          ),
          const SizedBox(height: 100), // Padding for bottom bar
        ],
      ),
    );
  }

  void _showLegalText(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(body, style: const TextStyle(height: 1.45)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.actionUnderstood),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, letterSpacing: 1.1),
      ),
    );
  }

  /// Native name of a shipped language, so the option reads the same whatever
  /// language the app currently renders in.
  String _languageName(AppLocalizations l10n, String code) {
    switch (code) {
      case 'de': return l10n.languageGerman;
      case 'fr': return l10n.languageFrench;
      case 'it': return l10n.languageItalian;
      case 'es': return l10n.languageSpanish;
      default: return l10n.languageEnglish;
    }
  }

  void _showLanguagePicker(BuildContext context, LocaleProvider provider) {
    final l10n = context.l10n;
    // null = follow the device; the rest mirror AppLocalizations.supportedLocales.
    const codes = <String?>[null, 'en', 'de', 'fr', 'it', 'es'];
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.settingsLanguage,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...codes.map((code) {
              final selected = code == null
                  ? provider.followsSystem
                  : provider.locale?.languageCode == code;
              return ListTile(
                title: Text(code == null
                    ? l10n.settingsLanguageSystem
                    : _languageName(l10n, code)),
                trailing: selected
                    ? Icon(Icons.check_rounded,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  provider.setLocale(code == null ? null : Locale(code));
                  Navigator.pop(sheetContext);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'snooze': prefs.getBool('reminder_snooze') ?? true,
      'hourly': prefs.getBool('reminder_hourly') ?? true,
      'snooze_interval': prefs.getInt('reminder_snooze_interval') ?? 15,
      'quiet_start': prefs.getInt('quiet_hours_start') ?? 22,
      'quiet_end': prefs.getInt('quiet_hours_end') ?? 6,
    };
  }

  void _showIosStorageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsBackupDestination),
        content: Text(context.l10n.settingsIosStorageInfo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.actionOk),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDestination() async {
    final dest = await backupService.pickLocalBackupDirectory();

    if (!mounted) return;
    if (dest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.settingsDestinationConnectFailed),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Ensure WorkManager registration matches new state.
      await BackupScheduler.syncFromPrefs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.settingsDestinationConnected),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    if (mounted) setState(() {});
  }

  void _updateReminderSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool('reminder_$key', value);
    } else if (value is int) {
      if (key == 'snooze_interval') {
        await prefs.setInt('reminder_snooze_interval', value);
      } else {
        await prefs.setInt('quiet_hours_$key', value);
      }
    }
    setState(() {});
  }

  void _showSnoozeIntervalPicker(BuildContext context, int current) {
    const options = [5, 10, 15, 20, 30, 45, 60];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.l10n.settingsSnoozeInterval,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...options.map((min) => ListTile(
                  title: Text(context.l10n.settingsEveryNMinutes(min)),
                  trailing: min == current
                      ? Icon(Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    _updateReminderSetting('snooze_interval', min);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showQuietHoursPicker(BuildContext context, int currentStart, int currentEnd) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.settingsQuietHoursTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeColumn(context.l10n.settingsQuietHoursStart, currentStart,
                    (val) => _updateReminderSetting('start', val)),
                const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                _buildTimeColumn(context.l10n.settingsQuietHoursEnd, currentEnd,
                    (val) => _updateReminderSetting('end', val)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String label, int current, Function(int) onSelected) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        DropdownButton<int>(
          value: current,
          items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('$i:00'))),
          onChanged: (val) {
            if (val != null) {
              onSelected(val);
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  void _showDurationPicker(BuildContext context, int current) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.settingsSetDefaultDuration, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              children: [5, 10, 15, 20, 30].map((m) => ChoiceChip(
                label: Text('$m min'),
                selected: current == m,
                onSelected: (selected) async {
                  if (selected) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('hyqvia_timer_duration', m);
                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  }
                },
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRestoreBackupDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (sheetContext, scrollController) {
          return StatefulBuilder(
            builder: (ctx, setSheetState) {
              Future<void> pickAndReload() async {
                final dest = await _pickRestoreSource(ctx);
                if (dest == null) return;
                setSheetState(() {}); // re-trigger FutureBuilder
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                    child: Row(
                      children: [
                        Text(context.l10n.settingsPickBackup,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _pickAndRestoreZipDirectly();
                          },
                          icon: const Icon(Icons.folder_zip_outlined, size: 18),
                          label: Text(context.l10n.settingsPickZip),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: FutureBuilder<_RestoreListState>(
                      future: _loadRestoreState(context.l10n),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text(context.l10n.genericError('${snapshot.error}')));
                        }
                        final state = snapshot.data!;
                        if (!state.hasDestination) {
                          return _restoreEmptyState(
                            icon: Icons.folder_off_outlined,
                            title: context.l10n.restoreNoFolderTitle,
                            body: context.l10n.restoreNoFolderBody,
                            buttonLabel: context.l10n.restorePickFolder,
                            onPressed: pickAndReload,
                          );
                        }
                        if (state.errorMessage != null) {
                          final pathHint = state.destinationLabel != null
                              ? '\n\n${context.l10n.restoreCurrentFolder('${state.destinationLabel}')}'
                              : '';
                          return _restoreEmptyState(
                            icon: Icons.lock_outline,
                            title: context.l10n.restoreAccessLostTitle,
                            body: '${state.errorMessage}$pathHint\n\n'
                                '${context.l10n.restoreAccessLostBody}',
                            buttonLabel: context.l10n.settingsPickFolderAgain,
                            onPressed: pickAndReload,
                          );
                        }
                        if (state.backups.isEmpty) {
                          final pathHint = state.destinationLabel != null
                              ? '\n\n${context.l10n.restoreCurrentFolder('${state.destinationLabel}')}'
                              : '';
                          return _restoreEmptyState(
                            icon: Icons.folder_open,
                            title: context.l10n.restoreNoBackupsTitle,
                            body: '${context.l10n.restoreNoBackupsBody}$pathHint\n\n'
                                '${context.l10n.restoreNoBackupsHint}',
                            buttonLabel: context.l10n.restorePickOtherFolder,
                            onPressed: pickAndReload,
                          );
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: state.backups.length,
                          itemBuilder: (context, index) {
                            final b = state.backups[index];
                            return ListTile(
                              leading: const Icon(Icons.inventory_2_outlined),
                              title: Text(b.name),
                              subtitle: Text(
                                  '${AppDateFormat.dateTime(context, b.date)}  •  ${(b.size / 1024 / 1024).toStringAsFixed(2)} MB'),
                              onTap: () {
                                Navigator.pop(ctx);
                                _confirmZippedRestore(b);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<_RestoreListState> _loadRestoreState(AppLocalizations l10n) async {
    final dest = await BackupDestination.load();
    if (dest == null) {
      return const _RestoreListState(hasDestination: false, backups: []);
    }
    final label = dest.displayLabel(l10n);
    // verifyAccess catches the common "SAF/iCloud grant revoked" case
    // (e.g. after reinstall) — without it, listBackups silently returns an
    // empty list and we'd wrongly tell the user there are no backups.
    final verifyError = await dest.verifyAccess();
    if (verifyError != null) {
      return _RestoreListState(
        hasDestination: true,
        backups: const [],
        errorMessage: verifyError,
        destinationLabel: label,
      );
    }
    try {
      final list = await dest.listBackups();
      return _RestoreListState(
        hasDestination: true,
        backups: list,
        destinationLabel: label,
      );
    } catch (e) {
      return _RestoreListState(
        hasDestination: true,
        backups: const [],
        errorMessage: l10n.restoreReadFailed('$e'),
        destinationLabel: label,
      );
    }
  }

  Widget _restoreEmptyState({
    required IconData icon,
    required String title,
    required String body,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.folder_open),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  Future<BackupDestination?> _pickRestoreSource(BuildContext sheetCtx) async {
    final dest = await backupService.pickLocalBackupDirectory();
    if (dest == null && sheetCtx.mounted) {
      ScaffoldMessenger.of(sheetCtx).showSnackBar(
        SnackBar(
          content: Text(sheetCtx.l10n.restoreFolderConnectFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
    return dest;
  }

  void _pickAndRestoreZipDirectly() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    final name = result.files.single.name;

    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.restoreConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.restoreConfirmFile(name)),
            const SizedBox(height: 16),
            Text(
              context.l10n.restoreOverwriteWarning,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.actionCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionRestore),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await AppDatabase().close();
    final success = await backupService.restoreFromZipPath(path);

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        await _restartAfterRestore(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.restoreFailed),
            duration: const Duration(seconds: 10),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmZippedRestore(BackupFile backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.restoreConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.restoreConfirmDated(
                AppDateFormat.dateTime(context, backup.date))),
            const SizedBox(height: 16),
            Text(
              context.l10n.restoreOverwriteWarning,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.actionCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionRestore),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;

      // Show progress
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await AppDatabase().close();

      final success = await backupService.restoreFromZippedBackup(backup);
      
      if (mounted) {
        Navigator.pop(context); // Close progress

        if (success) {
          await _restartAfterRestore(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.restoreFailed),
              backgroundColor: Colors.red,
            )
          );
        }
      }
    }
  }

  /// Restarts the app after a successful restore. The DB connection was closed
  /// during restore, so a full process restart is needed to reopen it cleanly.
  /// On platforms where a native restart isn't available we fall back to a hint
  /// asking the user to restart manually.
  Future<void> _restartAfterRestore(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.restoreSucceeded),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
    // Give the snackbar a moment to show before the process is killed.
    await Future.delayed(const Duration(seconds: 2));
    try {
      await Restart.restartApp();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.restoreRestartManually),
            duration: const Duration(seconds: 10),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}


class _RestoreListState {
  final bool hasDestination;
  final List<BackupFile> backups;
  final String? errorMessage;
  final String? destinationLabel;
  const _RestoreListState({
    required this.hasDestination,
    required this.backups,
    this.errorMessage,
    this.destinationLabel,
  });
}

