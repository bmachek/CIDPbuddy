import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:igkeeper/core/database/database.dart';
import 'package:igkeeper/features/inventory/providers/inventory_provider.dart';
import 'package:igkeeper/features/diary/providers/diary_provider.dart';
import 'package:igkeeper/core/theme/app_theme.dart';
import 'package:igkeeper/core/theme/theme_provider.dart';
import 'package:igkeeper/features/reminders/services/notification_service.dart';
import 'package:igkeeper/core/services/scheduler_service.dart';
import 'package:igkeeper/core/services/medication_service.dart';
import 'package:igkeeper/core/services/background_service.dart';
import 'package:igkeeper/features/settings/services/backup_service.dart';
import 'package:igkeeper/features/settings/services/backup_worker.dart';
import 'package:igkeeper/features/settings/services/cloud/google_drive_auth.dart';
import 'package:igkeeper/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final db = AppDatabase();
    await NotificationService().init();
    await BackgroundService.initialize();
    await BackupScheduler.init();
    await BackupScheduler.syncFromPrefs();
    // Initialize Google Sign-In once for the foreground process. The
    // WorkManager isolate calls ensureInitialized() separately on first use.
    if (GoogleDriveAuth.instance.isPlatformSupported) {
      // Best-effort — must not block app startup if it fails.
      // ignore: discarded_futures
      GoogleDriveAuth.instance.tryRestore();
    }
    
    // Initialize and sync infusion schedules
    final scheduler = SchedulerService(db);
    await scheduler.syncPlannedInfusions();
    // Surface any past-due Einnahmen that weren't confirmed or skipped —
    // covers cases where alarms got dropped after an OS update or reboot.
    await scheduler.checkMissedTreatments();

    // Check backup setup and schedule reminder if needed
    final prefs = await SharedPreferences.getInstance();
    final autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? false;
    if (!autoBackupEnabled) {
      await NotificationService().scheduleBackupReminder();
    } else {
      await NotificationService().cancelBackupReminder();
      // Proactively detect lost SAF/pCloud permissions without blocking startup.
      // ignore: discarded_futures
      BackupService().checkSafAccessOnStartup();
    }
    
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
