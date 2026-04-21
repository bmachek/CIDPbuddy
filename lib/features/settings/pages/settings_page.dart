import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backup_service.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/constants/build_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'reliability_check_page.dart';
import 'package:intl/intl.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final backupService = BackupService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
          _buildSectionHeader('Erscheinungsbild'),
          SwitchListTile(
            title: const Text('Dunkles Design'),
            subtitle: const Text('Wechsle zwischen hellem und dunklem Modus'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (val) => themeProvider.toggleTheme(),
            secondary: const Icon(Icons.brightness_4),
          ),
          const Divider(),
          _buildSectionHeader('Datensicherung'),
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('Daten exportieren'),
            subtitle: const Text('Erstelle eine Sicherung deiner Datenbank'),
            onTap: () async {
              await backupService.exportDatabase();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup wird bereitgestellt...'))
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text('Daten importieren'),
            subtitle: const Text('Stelle eine Sicherung wieder her (Überschreibt aktuelle Daten)'),
            onTap: () => _confirmImport(context, backupService),
          ),
          const Divider(),
          _buildSectionHeader('Automatisches Backup'),
          FutureBuilder<Map<String, dynamic>>(
            future: _getAutoBackupSettings(),
            builder: (context, snapshot) {
              final settings = snapshot.data ?? {
                'enabled': false,
                'path': null,
                'last_time': null
              };
              
              final bool enabled = settings['enabled'];
              final String? path = settings['path'];
              final String? lastTime = settings['last_time'];

              return Column(
                children: [
                  SwitchListTile(
                    title: const Text('Automatisches Backup aktivieren'),
                    subtitle: const Text('Sichert die Datenbank automatisch gezippt bei Änderungen'),
                    value: enabled,
                    onChanged: (val) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(BackupService.kAutoBackupEnabled, val);
                      setState(() {});
                    },
                    secondary: const Icon(Icons.backup_outlined),
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_open_outlined),
                    title: const Text('Backup-Verzeichnis'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(path != null 
                            ? (path.startsWith('Error') ? 'Zugriff verweigert (Bitte neu wählen)' : path) 
                            : 'Verzeichnis wählen...'),
                        if (path?.startsWith('Error') == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final safePath = await backupService.getSafeBackupDirectory();
                                await backupService.setBackupDirectory(safePath);
                                setState(() {});
                              },
                              icon: const Icon(Icons.security, size: 16),
                              label: const Text('Sicheres Verzeichnis verwenden'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: (path != null && !path.startsWith('Error')) 
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 16) 
                        : (path?.startsWith('Error') == true ? const Icon(Icons.error_outline, color: Colors.red, size: 16) : null),
                    onTap: () async {
                      final selected = await backupService.selectBackupDirectory();
                      if (selected != null) {
                        setState(() {});
                        if (selected.startsWith('Error') && context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Zugriff auf Cloud-Ordner'),
                              content: const Text(
                                'Android erlaubt es Apps technisch nicht, automatisiert in Cloud-Verzeichnisse (wie pDrive, Google Drive oder OneDrive) zu schreiben, da diese kein echtes lokales Dateisystem nutzen.\n\n'
                                'Empfehlung:\n'
                                '1. Nutzen Sie das "Sichere Verzeichnis" für automatische Backups.\n'
                                '2. Nutzen Sie "Sicherung jetzt exportieren" (oben), um manuell in pCloud zu speichern.\n'
                                '3. Oder nutzen Sie eine Sync-App (wie FolderSync), die das sichere Verzeichnis mit pCloud synchronisiert.'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Verstanden'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                  ),
                  if (path != null && !path.startsWith('Error'))
                    ListTile(
                      leading: const Icon(Icons.play_circle_outline),
                      title: const Text('Backup jetzt testen'),
                      onTap: () async {
                        final success = await backupService.performZippedBackup(path);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'Test-Backup erfolgreich!' : 'Test-Backup fehlgeschlagen.'),
                              backgroundColor: success ? Colors.green : Colors.red,
                            )
                          );
                        }
                        setState(() {});
                      },
                    ),
                  if (lastTime != null)
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Zuletzt gesichert'),
                      subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(lastTime))),
                    ),
                ],
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('Erinnerungen'),
          FutureBuilder<Map<String, dynamic>>(
            future: _getReminderSettings(),
            builder: (context, snapshot) {
              final settings = snapshot.data ?? {'snooze': true, 'hourly': true, 'quiet_start': 22, 'quiet_end': 7};
              return Column(
                children: [
                  SwitchListTile(
                    title: const Text('Schlummer-Funktion'),
                    subtitle: const Text('Erneut erinnern alle 15 Minuten'),
                    value: settings['snooze'],
                    onChanged: (val) => _updateReminderSetting('snooze', val),
                    secondary: const Icon(Icons.snooze_rounded),
                  ),
                  SwitchListTile(
                    title: const Text('Stündliche Erinnerung'),
                    subtitle: const Text('Erinnern zur vollen Stunde'),
                    value: settings['hourly'],
                    onChanged: (val) => _updateReminderSetting('hourly', val),
                    secondary: const Icon(Icons.hourglass_bottom_rounded),
                  ),
                  ListTile(
                    leading: const Icon(Icons.nightlight_round),
                    title: const Text('Nachtruhe'),
                    subtitle: Text('Keine Erinnerungen von ${settings['quiet_start']}:00 bis ${settings['quiet_end']}:00'),
                    onTap: () => _showQuietHoursPicker(context, settings['quiet_start'], settings['quiet_end']),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('System & Zuverlässigkeit'),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: const Text('Zuverlässigkeits-Check'),
            subtitle: const Text('Prüfe Berechtigungen & Akku-Einstellungen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const ReliabilityCheckPage())
            ),
          ),
          const Divider(),
          _buildSectionHeader('Hyqvia Timer'),
          FutureBuilder<bool>(
            future: SharedPreferences.getInstance().then((p) => p.getBool('hyqvia_timer_enabled') ?? true),
            builder: (context, snapshot) {
              final enabled = snapshot.data ?? true;
              return SwitchListTile(
                title: const Text('Timer automatisch vorschlagen'),
                subtitle: const Text('Bei Hyqvia-Infusionen den Premedikation-Timer anbieten'),
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
                title: const Text('Premedikation-Dauer'),
                subtitle: Text('Aktuell: $duration Minuten'),
                onTap: () => _showDurationPicker(context, duration),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader('Über CIDP Buddy'),
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
                              const Text('Version', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              const Text('Build-Zeitstempel', style: TextStyle(fontWeight: FontWeight.bold)),
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
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Datenschutz'),
            subtitle: Text('Alle Daten werden lokal auf diesem Gerät gespeichert.'),
          ),
          const SizedBox(height: 100), // Padding for bottom bar
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

  Future<Map<String, dynamic>> _getReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'snooze': prefs.getBool('reminder_snooze') ?? true,
      'hourly': prefs.getBool('reminder_hourly') ?? true,
      'quiet_start': prefs.getInt('quiet_hours_start') ?? 22,
      'quiet_end': prefs.getInt('quiet_hours_end') ?? 7,
    };
  }

  Future<Map<String, dynamic>> _getAutoBackupSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(BackupService.kAutoBackupEnabled) ?? false,
      'path': prefs.getString(BackupService.kBackupDirectoryPath),
      'last_time': prefs.getString(BackupService.kLastBackupTime),
    };
  }

  void _updateReminderSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool('reminder_$key', value);
    } else if (value is int) {
      await prefs.setInt('quiet_hours_$key', value);
    }
    setState(() {});
  }

  void _showQuietHoursPicker(BuildContext context, int currentStart, int currentEnd) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nachtruhe einstellen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeColumn('Beginn', currentStart, (val) => _updateReminderSetting('start', val)),
                const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                _buildTimeColumn('Ende', currentEnd, (val) => _updateReminderSetting('end', val)),
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

  void _confirmImport(BuildContext context, BackupService service) async {
    // ... existing ...
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup wiederherstellen?'),
        content: const Text('Warnung: Die aktuellen Daten werden durch das Backup überschrieben. Dies kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Wiederherstellen'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await service.importDatabase();
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Daten erfolgreich wiederhergestellt. Bitte App neu starten.'))
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Import abgebrochen.'))
          );
        }
      }
    }
  }

  void _showDurationPicker(BuildContext context, int current) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Standard-Dauer festlegen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
}
