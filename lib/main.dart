import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cidpbuddy/core/database/database.dart';
import 'package:cidpbuddy/features/inventory/providers/inventory_provider.dart';
import 'package:cidpbuddy/features/diary/providers/diary_provider.dart';
import 'package:cidpbuddy/core/theme/app_theme.dart';
import 'package:cidpbuddy/core/theme/theme_provider.dart';
import 'package:cidpbuddy/features/reminders/services/notification_service.dart';
import 'package:cidpbuddy/core/services/scheduler_service.dart';
import 'package:cidpbuddy/core/services/medication_service.dart';
import 'package:cidpbuddy/core/services/background_service.dart';
import 'package:cidpbuddy/features/settings/services/backup_service.dart';
import 'package:cidpbuddy/features/settings/services/backup_worker.dart';
import 'package:cidpbuddy/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'dart:async';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force Flutter to build & expose the semantics tree so UI-test tools
  // (Maestro) can find widgets by text/id without a screen reader running.
  SemanticsBinding.instance.ensureSemantics();

  try {
    final db = AppDatabase();
    // Notifications must be initialized before runApp so cold-launches from a
    // notification tap can route correctly. Everything else is deferred.
    await NotificationService().init();

    runApp(
      MultiProvider(
        providers: [
          Provider.value(value: db),
          Provider(create: (_) => MedicationService(db)),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProxyProvider<AppDatabase, InventoryProvider>(
            create: (context) => InventoryProvider(db),
            update: (context, database, previous) => InventoryProvider(database),
          ),
          ChangeNotifierProxyProvider<AppDatabase, DiaryProvider>(
            create: (context) => DiaryProvider(db),
            update: (context, database, previous) => DiaryProvider(database),
          ),
        ],
        child: const CIDPBuddyApp(),
      ),
    );

    // Defer heavy init (WorkManager, alarm rescheduling, battery-opt prompt,
    // missed-treatments scan) until after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initDeferred(db));
    });
  } catch (e, stack) {
    debugPrint('Initialization error: $e');
    debugPrint('Stack trace: $stack');
    // Fallback to minimal app to show error if possible
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('App konnte nicht initialisiert werden:\n$e'),
          ),
        ),
      ),
    ));
  }
}

/// Runs after the first frame. Each step is independently guarded so a
/// failure in one (e.g. WorkManager not available on the platform) does not
/// block the others.
Future<void> _initDeferred(AppDatabase db) async {
  Future<void> step(String name, Future<void> Function() body) async {
    try {
      await body();
    } catch (e, stack) {
      debugPrint('Deferred init "$name" failed: $e\n$stack');
    }
  }

  await step('BackgroundService', BackgroundService.initialize);
  await step('BackupScheduler.init', BackupScheduler.init);
  await step('BackupScheduler.syncFromPrefs', BackupScheduler.syncFromPrefs);
  await step('BackupScheduler.enableMissedCheck', BackupScheduler.enableMissedCheck);

  final scheduler = SchedulerService(db);
  await step('syncPlannedInfusions', scheduler.syncPlannedInfusions);
  await step('checkMissedTreatments', scheduler.checkMissedTreatments);

  if (Platform.isAndroid) {
    await step('batteryOptimization', () async {
      final disabled =
          await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;
      if (!disabled) {
        await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
      }
    });
  }

  await step('backupReminder', () async {
    final prefs = await SharedPreferences.getInstance();
    final autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? false;
    if (!autoBackupEnabled) {
      await NotificationService().scheduleBackupReminder();
    } else {
      await NotificationService().cancelBackupReminder();
      unawaited(BackupService().checkSafAccessOnStartup());
    }
  });
}

class CIDPBuddyApp extends StatelessWidget {
  const CIDPBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'CIDP Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de', 'DE'),
      ],
      locale: const Locale('de', 'DE'),
      home: const MainScreen(),
    );
  }
}
