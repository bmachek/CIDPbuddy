import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restart_app/restart_app.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backup_service.dart';
import '../services/backup_worker.dart';
import '../../../core/theme/app_colors.dart';
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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final statusColors = AppStatusColors.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        // Explicit line height (Outfit's natural one is ~1.26, so this is
        // invisible) keeps some background inside the title's box: the
        // contrast checker samples what is painted behind the glyphs.
        title: Text(l10n.navSettings),
      ),
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
            subtitle: Text(
              localeProvider.followsSystem
                  ? l10n.settingsLanguageSystem
                  : _languageName(l10n, localeProvider.locale!.languageCode),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context, localeProvider),
          ),
          const Divider(),
          _buildSectionHeader(l10n.settingsSectionAutoBackup),
          FutureBuilder<BackupStatus>(
            future: backupService.getStatus(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return _loadErrorTile(context);
              final status = snapshot.data;
              // Never render "no destination" while the status is still being
              // read — a patient would take it for the truth.
              if (status == null) return _loadingPlaceholder();
              final dest = status.destination;
              final hasError =
                  status.lastError != null || status.consecutiveFailures > 0;

              return Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.settingsEnableAutoBackup),
                    subtitle: Text(l10n.settingsEnableAutoBackupHint),
                    value: status.enabled,
                    onChanged: (val) async {
                      await backupService.setEnabled(val);
                      await BackupScheduler.syncFromPrefs();
                      if (!mounted) return;
                      setState(() {});
                    },
                    secondary: const Icon(Icons.backup_outlined),
                  ),
                  if (hasError && dest != null)
                    _noticeCard(
                      context,
                      color: scheme.error,
                      icon: Icons.error_outline,
                      title: l10n.settingsBackupNotPossible,
                      body: status.lastError ?? l10n.settingsUnknownError,
                      action: FilledButton.tonal(
                        onPressed: Platform.isIOS
                            ? _pickIosDestination
                            : _pickDestination,
                        child: Text(l10n.settingsPickFolderAgain),
                      ),
                    ),
                  // App-internal backups are deleted together with the app, so
                  // they are no protection against a reinstall — the one case
                  // where a backup matters most. Say so instead of showing a
                  // green check and letting the user assume they are covered.
                  if (dest != null && !dest.isDurable && !hasError)
                    _noticeCard(
                      context,
                      color: statusColors.warning,
                      icon: Icons.warning_amber_rounded,
                      title: l10n.settingsBackupsInsideAppTitle,
                      body: l10n.settingsBackupsInsideAppBody,
                      // The warning is only fair if the way out is one tap
                      // away — on iOS that is picking a folder in Files.
                      action: Platform.isIOS
                          ? FilledButton.tonal(
                              onPressed: _pickIosDestination,
                              child: Text(l10n.settingsIosPickFolder),
                            )
                          : null,
                    ),
                  ListTile(
                    leading: Icon(
                      dest != null ? Icons.folder : Icons.folder_open_outlined,
                    ),
                    title: Text(l10n.settingsBackupDestination),
                    subtitle: Text(
                      dest == null
                          ? l10n.settingsPickDestination
                          : dest.displayLabel(l10n),
                    ),
                    trailing: dest != null
                        ? Icon(
                            Icons.check_circle,
                            color: statusColors.success,
                            size: 20,
                            semanticLabel: l10n.backupDestinationConfigured,
                          )
                        : null,
                    onTap: Platform.isIOS
                        ? _pickIosDestination
                        : _pickDestination,
                  ),
                  if (dest != null)
                    ListTile(
                      leading: const Icon(Icons.play_circle_outline),
                      title: Text(l10n.settingsRunBackupNow),
                      onTap: () async {
                        final result = await backupService.runBackup(
                          manual: true,
                        );
                        if (!mounted) return;
                        if (result.success) {
                          _showSuccessSnack(l10n.settingsBackupSucceeded);
                        } else {
                          _showErrorSnack(
                            l10n.settingsBackupFailed('${result.error}'),
                          );
                        }
                        setState(() {});
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
                        if (!mounted || ok) return;
                        _showErrorSnack(l10n.settingsNoBackupToExport);
                      },
                    ),
                  if (status.lastSuccess != null)
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(l10n.settingsLastSuccess),
                      subtitle: Text(
                        AppDateFormat.dateTime(context, status.lastSuccess!),
                      ),
                    ),
                  if (status.lastAttempt != null &&
                      (status.lastSuccess == null ||
                          status.lastAttempt!.isAfter(status.lastSuccess!)))
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(l10n.settingsLastAttempt),
                      subtitle: Text(
                        AppDateFormat.dateTime(context, status.lastAttempt!),
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
              if (snapshot.hasError) return _loadErrorTile(context);
              // Until the stored values are in, the tiles stay visible but
              // inert — a switch that shows a default and then flips is
              // worse than one that is briefly disabled.
              final loaded = snapshot.hasData;
              final settings =
                  snapshot.data ??
                  const {
                    'snooze': true,
                    'hourly': true,
                    'snooze_interval': 15,
                    'quiet_start': 22,
                    'quiet_end': 6,
                  };
              final snoozeInterval = settings['snooze_interval'] as int;
              final snoozeOn = settings['snooze'] == true;
              return Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.settingsSnooze),
                    subtitle: Text(l10n.settingsSnoozeHint(snoozeInterval)),
                    value: snoozeOn,
                    onChanged: loaded
                        ? (val) => _updateReminderSetting('snooze', val)
                        : null,
                    secondary: const Icon(Icons.snooze_rounded),
                  ),
                  if (snoozeOn)
                    ListTile(
                      enabled: loaded,
                      leading: const Icon(Icons.timelapse_rounded),
                      title: Text(l10n.settingsSnoozeInterval),
                      subtitle: Text(
                        l10n.settingsSnoozeIntervalCurrent(snoozeInterval),
                      ),
                      onTap: loaded
                          ? () => _showSnoozeIntervalPicker(
                              context,
                              snoozeInterval,
                            )
                          : null,
                    ),
                  SwitchListTile(
                    title: Text(l10n.settingsHourlyReminder),
                    subtitle: Text(l10n.settingsHourlyReminderHint),
                    value: settings['hourly'] == true,
                    onChanged: loaded
                        ? (val) => _updateReminderSetting('hourly', val)
                        : null,
                    secondary: const Icon(Icons.hourglass_bottom_rounded),
                  ),
                  ListTile(
                    enabled: loaded,
                    leading: const Icon(Icons.nightlight_round),
                    title: Text(l10n.settingsQuietHours),
                    subtitle: Text(
                      l10n.settingsQuietHoursHint(
                        _hourLabel(context, settings['quiet_start'] as int),
                        _hourLabel(context, settings['quiet_end'] as int),
                      ),
                    ),
                    onTap: loaded
                        ? () => _showQuietHoursPicker(
                            context,
                            settings['quiet_start'] as int,
                            settings['quiet_end'] as int,
                          )
                        : null,
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
              MaterialPageRoute(
                builder: (context) => const ReliabilityCheckPage(),
              ),
            ),
          ),
          const Divider(),
          _buildSectionHeader(l10n.settingsSectionHyqviaTimer),
          FutureBuilder<bool>(
            future: SharedPreferences.getInstance().then(
              (p) => p.getBool('hyqvia_timer_enabled') ?? true,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) return _loadErrorTile(context);
              final loaded = snapshot.hasData;
              final enabled = snapshot.data ?? true;
              return SwitchListTile(
                title: Text(l10n.settingsSuggestTimer),
                subtitle: Text(l10n.settingsSuggestTimerHint),
                value: enabled,
                onChanged: loaded
                    ? (val) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('hyqvia_timer_enabled', val);
                        if (!mounted) return;
                        setState(() {});
                      }
                    : null,
                secondary: const Icon(Icons.av_timer_rounded),
              );
            },
          ),
          FutureBuilder<int>(
            future: SharedPreferences.getInstance().then(
              (p) => p.getInt('hyqvia_timer_duration') ?? 10,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) return _loadErrorTile(context);
              final loaded = snapshot.hasData;
              final duration = snapshot.data ?? 10;
              return ListTile(
                enabled: loaded,
                leading: const Icon(Icons.timer_outlined),
                title: Text(l10n.settingsPremedDuration),
                subtitle: Text(l10n.settingsCurrentMinutes(duration)),
                onTap: loaded
                    ? () => _showDurationPicker(context, duration)
                    : null,
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
          if (AppLinks.impressumUrl != null ||
              AppLinks.datenschutzUrl != null) ...[
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _aboutRow(
                        context,
                        icon: Icons.info_outline,
                        label: l10n.settingsVersion,
                        value: '$version ($buildNumber)',
                      ),
                      const SizedBox(height: 12),
                      _aboutRow(
                        context,
                        icon: Icons.history,
                        label: l10n.settingsBuildTimestamp,
                        value: BuildConfig.buildTimestamp,
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
          // Clearance for the floating navigation bar, same as the other tabs.
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  /// One "label over value" line of the About card. The text column is
  /// [Expanded] so a long build timestamp wraps instead of overflowing.
  Widget _aboutRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: scheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  /// A tinted notice inside the list — backup errors, "backups live inside
  /// the app" — with the icon, border and fill all derived from [color].
  Widget _noticeCard(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required String body,
    Widget? action,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 13)),
                if (action != null) ...[const SizedBox(height: 8), action],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shown in place of a section while its stored values are being read.
  Widget _loadingPlaceholder() {
    return const SizedBox(
      height: 72,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  /// Shown in place of a section whose stored values could not be read.
  Widget _loadErrorTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(context.l10n.errorLoadingData),
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
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          // The brand blue at text-safe contrast; `colorScheme.primary` itself
          // does not reach WCAG AA at this size.
          color: AppStatusColors.of(context).accentText,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  /// Title line of a bottom sheet.
  Widget _sheetTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// `8:00 AM` or `08:00`, following the device's clock convention.
  String _hourLabel(BuildContext context, int hour) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: hour, minute: 0),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  /// Native name of a shipped language, so the option reads the same whatever
  /// language the app currently renders in.
  String _languageName(AppLocalizations l10n, String code) {
    switch (code) {
      case 'de':
        return l10n.languageGerman;
      case 'fr':
        return l10n.languageFrench;
      case 'it':
        return l10n.languageItalian;
      case 'es':
        return l10n.languageSpanish;
      default:
        return l10n.languageEnglish;
    }
  }

  void _showLanguagePicker(BuildContext context, LocaleProvider provider) {
    final l10n = context.l10n;
    // null = follow the device; the rest mirror AppLocalizations.supportedLocales.
    const codes = <String?>[null, 'en', 'de', 'fr', 'it', 'es'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetTitle(l10n.settingsLanguage),
              ...codes.map((code) {
                final selected = code == null
                    ? provider.followsSystem
                    : provider.locale?.languageCode == code;
                return ListTile(
                  title: Text(
                    code == null
                        ? l10n.settingsLanguageSystem
                        : _languageName(l10n, code),
                  ),
                  trailing: selected
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
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

  /// iOS has two kinds of destination and the difference decides whether a
  /// backup survives deleting the app, so the choice is spelled out rather
  /// than hidden behind a single "pick folder" tap.
  Future<void> _pickIosDestination() async {
    final choice = await showDialog<_IosDestination>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsBackupDestination),
        content: SingleChildScrollView(
          child: Text(context.l10n.settingsIosStorageInfo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _IosDestination.appFolder),
            child: Text(context.l10n.settingsIosUseAppFolder),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, _IosDestination.pickedFolder),
            child: Text(context.l10n.settingsIosPickFolder),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;

    if (choice == _IosDestination.appFolder) {
      await _pickDestination();
      return;
    }

    final result = await backupService.pickBookmarkBackupDirectory();
    if (!mounted) return;
    // A cancelled picker changed nothing; saying "could not connect" about it
    // would be both wrong and alarming.
    if (result.cancelled) return;
    if (result.destination == null) {
      _showErrorSnack(context.l10n.settingsDestinationConnectFailed);
    } else {
      await BackupScheduler.syncFromPrefs();
      if (!mounted) return;
      _showSuccessSnack(context.l10n.settingsDestinationConnected);
    }
    setState(() {});
  }

  Future<void> _pickDestination() async {
    final dest = await backupService.pickLocalBackupDirectory();

    if (!mounted) return;
    if (dest == null) {
      _showErrorSnack(context.l10n.settingsDestinationConnectFailed);
    } else {
      // Ensure WorkManager registration matches new state.
      await BackupScheduler.syncFromPrefs();
      if (!mounted) return;
      _showSuccessSnack(context.l10n.settingsDestinationConnected);
    }
    setState(() {});
  }

  Future<void> _updateReminderSetting(String key, Object value) async {
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
    if (!mounted) return;
    setState(() {});
  }

  void _showSnoozeIntervalPicker(BuildContext context, int current) {
    final l10n = context.l10n;
    const options = [5, 10, 15, 20, 30, 45, 60];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetTitle(l10n.settingsSnoozeInterval),
              ...options.map(
                (min) => ListTile(
                  title: Text(l10n.settingsEveryNMinutes(min)),
                  trailing: min == current
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    _updateReminderSetting('snooze_interval', min);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuietHoursPicker(
    BuildContext context,
    int currentStart,
    int currentEnd,
  ) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.settingsQuietHoursTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildTimeColumn(
                      sheetContext,
                      l10n.settingsQuietHoursStart,
                      currentStart,
                      (val) => _updateReminderSetting('start', val),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Theme.of(
                        sheetContext,
                      ).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: _buildTimeColumn(
                      sheetContext,
                      l10n.settingsQuietHoursEnd,
                      currentEnd,
                      (val) => _updateReminderSetting('end', val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(l10n.actionClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(
    BuildContext sheetContext,
    String label,
    int current,
    ValueChanged<int> onSelected,
  ) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<int>(
          value: current,
          isExpanded: true,
          items: List.generate(
            24,
            (i) => DropdownMenuItem(
              value: i,
              child: Text(_hourLabel(sheetContext, i)),
            ),
          ),
          onChanged: (val) {
            if (val == null) return;
            onSelected(val);
            Navigator.pop(sheetContext);
          },
        ),
      ],
    );
  }

  void _showDurationPicker(BuildContext context, int current) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.settingsSetDefaultDuration,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [5, 10, 15, 20, 30]
                    .map(
                      (m) => ChoiceChip(
                        label: Text(l10n.minutesShort(m)),
                        selected: current == m,
                        onSelected: (selected) async {
                          if (!selected) return;
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt('hyqvia_timer_duration', m);
                          if (sheetContext.mounted) Navigator.pop(sheetContext);
                          if (!mounted) return;
                          setState(() {});
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(l10n.actionClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestoreBackupDialog(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (sheetContext, scrollController) {
          return StatefulBuilder(
            builder: (ctx, setSheetState) {
              Future<void> pickAndReload() async {
                final dest = await _pickRestoreSource();
                if (dest == null || !ctx.mounted) return;
                setSheetState(() {}); // re-trigger FutureBuilder
              }

              return SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.settingsPickBackup,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.actionClose,
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    // On its own line so the label survives 320 dp and large
                    // text instead of fighting the title for the header row.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _pickAndRestoreZipDirectly();
                          },
                          icon: const Icon(Icons.folder_zip_outlined, size: 18),
                          label: Text(l10n.settingsPickZip),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: FutureBuilder<_RestoreListState>(
                        future: _loadRestoreState(l10n),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  l10n.genericError('${snapshot.error}'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          final state = snapshot.data!;
                          if (!state.hasDestination) {
                            return _restoreEmptyState(
                              context,
                              icon: Icons.folder_off_outlined,
                              title: l10n.restoreNoFolderTitle,
                              body: l10n.restoreNoFolderBody,
                              buttonLabel: l10n.restorePickFolder,
                              onPressed: pickAndReload,
                            );
                          }
                          if (state.errorMessage != null) {
                            final pathHint = state.destinationLabel != null
                                ? '\n\n${l10n.restoreCurrentFolder('${state.destinationLabel}')}'
                                : '';
                            return _restoreEmptyState(
                              context,
                              icon: Icons.lock_outline,
                              title: l10n.restoreAccessLostTitle,
                              body:
                                  '${state.errorMessage}$pathHint\n\n'
                                  '${l10n.restoreAccessLostBody}',
                              buttonLabel: l10n.settingsPickFolderAgain,
                              onPressed: pickAndReload,
                            );
                          }
                          if (state.backups.isEmpty) {
                            final pathHint = state.destinationLabel != null
                                ? '\n\n${l10n.restoreCurrentFolder('${state.destinationLabel}')}'
                                : '';
                            return _restoreEmptyState(
                              context,
                              icon: Icons.folder_open,
                              title: l10n.restoreNoBackupsTitle,
                              body:
                                  '${l10n.restoreNoBackupsBody}$pathHint\n\n'
                                  '${l10n.restoreNoBackupsHint}',
                              buttonLabel: l10n.restorePickOtherFolder,
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
                                  b.size > 0
                                      ? '${AppDateFormat.dateTime(context, b.date)}  •  ${_megabytes(context, b.size)}'
                                      : AppDateFormat.dateTime(context, b.date),
                                ),
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// `1.2 MB` / `1,2 MB` — the decimal separator follows the locale.
  String _megabytes(BuildContext context, int bytes) {
    final value = NumberFormat.decimalPatternDigits(
      locale: context.localeTag,
      decimalDigits: 1,
    ).format(bytes / 1024 / 1024);
    return context.l10n.megabytes(value);
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

  Widget _restoreEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: muted),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(color: muted),
          ),
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

  Future<BackupDestination?> _pickRestoreSource() async {
    // On iOS the folder holding the backups is picked in the Files app.
    // Routing this through pickLocalBackupDirectory would quietly point the
    // destination at the app's own folder instead — the one place the backups
    // being restored are guaranteed not to be.
    if (Platform.isIOS) {
      final result = await backupService.pickBookmarkBackupDirectory();
      if (!result.cancelled && result.destination == null && mounted) {
        _showErrorSnack(context.l10n.restoreFolderConnectFailed);
      }
      return result.destination;
    }
    final dest = await backupService.pickLocalBackupDirectory();
    if (dest == null && mounted) {
      _showErrorSnack(context.l10n.restoreFolderConnectFailed);
    }
    return dest;
  }

  Future<void> _pickAndRestoreZipDirectly() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    final name = result.files.single.name;

    if (!mounted) return;
    final confirmed = await _confirmRestore(
      context.l10n.restoreConfirmFile(name),
    );
    if (!confirmed || !mounted) return;
    await _runRestore(() => backupService.restoreFromZipPath(path));
  }

  Future<void> _confirmZippedRestore(BackupFile backup) async {
    if (!mounted) return;
    final confirmed = await _confirmRestore(
      context.l10n.restoreConfirmDated(
        AppDateFormat.dateTime(context, backup.date),
      ),
    );
    if (!confirmed || !mounted) return;
    await _runRestore(() => backupService.restoreFromZippedBackup(backup));
  }

  /// The "really overwrite everything?" dialog. Returns true when the patient
  /// confirmed. The destructive action is the filled, error-coloured one so it
  /// cannot be mistaken for the safe default.
  Future<bool> _confirmRestore(String question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = dialogContext.l10n;
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(l10n.restoreConfirmTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question),
                const SizedBox(height: 16),
                Text(
                  l10n.restoreOverwriteWarning,
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.actionRestore),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  /// Closes the database, runs [restore] behind a blocking progress dialog
  /// and restarts the app on success.
  Future<void> _runRestore(Future<bool> Function() restore) async {
    _showRestoreProgress();
    await AppDatabase().close();
    final success = await restore();
    if (!mounted) return;
    Navigator.pop(context); // the progress dialog
    if (success) {
      await _restartAfterRestore();
    } else {
      _showErrorSnack(
        context.l10n.restoreFailed,
        duration: const Duration(seconds: 10),
      );
    }
  }

  /// A progress dialog the patient cannot dismiss: the database is closed
  /// while a restore runs, so backing out half-way would leave the app in a
  /// broken state.
  void _showRestoreProgress() {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Center(
          child: Semantics(
            label: l10n.restoringPleaseWait,
            liveRegion: true,
            child: Card(
              margin: const EdgeInsets.all(32),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.restoringPleaseWait, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Restarts the app after a successful restore. The DB connection was closed
  /// during restore, so a full process restart is needed to reopen it cleanly.
  /// On platforms where a native restart isn't available we fall back to a hint
  /// asking the user to restart manually.
  Future<void> _restartAfterRestore() async {
    _showSuccessSnack(
      context.l10n.restoreSucceeded,
      duration: const Duration(seconds: 2),
    );
    // Give the snackbar a moment to show before the process is killed.
    await Future.delayed(const Duration(seconds: 2));
    try {
      await Restart.restartApp();
    } catch (_) {
      if (!mounted) return;
      _showSuccessSnack(
        context.l10n.restoreRestartManually,
        duration: const Duration(seconds: 10),
      );
    }
  }

  void _showErrorSnack(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final scheme = Theme.of(context).colorScheme;
    _showSnack(
      message,
      background: scheme.error,
      foreground: scheme.onError,
      duration: duration,
    );
  }

  void _showSuccessSnack(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final colors = AppStatusColors.of(context);
    _showSnack(
      message,
      background: colors.success,
      foreground: colors.onSuccess,
      duration: duration,
    );
  }

  /// Every caller checks [mounted] first. The text colour is set explicitly
  /// because the default snackbar text is tuned for the default background.
  void _showSnack(
    String message, {
    required Color background,
    required Color foreground,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: foreground)),
        backgroundColor: background,
        duration: duration,
      ),
    );
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

/// The two iOS backup destinations, as the chooser dialog offers them:
/// a folder picked in the Files app (durable, and the automatic export), or
/// the app's own folder (goes away with the app).
enum _IosDestination { pickedFolder, appFolder }
