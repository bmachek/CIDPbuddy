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
import 'package:igkeeper/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await NotificationService().init();
  
  // Initialize and sync infusion schedules
  await SchedulerService(db).syncPlannedInfusions();
  
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: db),
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
      child: const IgKeeperApp(),
    ),
  );
}

class IgKeeperApp extends StatelessWidget {
  const IgKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'IgKeeper',
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
