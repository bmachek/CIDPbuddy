import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cidpbuddy/core/database/database.dart';
import 'package:cidpbuddy/core/services/scheduler_service.dart';
import 'package:cidpbuddy/features/diary/pages/dashboard_page.dart';
import 'package:cidpbuddy/features/inventory/pages/inventory_page.dart';
import 'package:cidpbuddy/features/diary/pages/diary_page.dart';
import 'package:cidpbuddy/features/settings/pages/settings_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const DiaryPage(),
    const InventoryPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Picks up writes made by background isolates (notification actions,
      // the periodic sync service) while the app was backgrounded — those
      // isolates use their own database connection, so the tabs kept alive
      // in the IndexedStack below never receive drift's normal stream
      // update notification for them.
      final db = AppDatabase();
      db.refreshLiveQueries();
      // Re-evaluate the "Verpasste Einnahmen" summary. It is a delivered
      // notification that otherwise only gets recomputed on a cold start, so
      // on iOS — where the periodic background sync never gets to run — it
      // would keep showing entries the user has since confirmed.
      unawaited(SchedulerService(db).checkMissedTreatments());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Premium Blue & Slate Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          const Color(0xFF0D1B2A), // Deep Midnight
                          Theme.of(context).colorScheme.surface, // Slate/Black
                        ]
                      : [
                          const Color(0xFFE3F2FD), // Very Light Azure
                          Theme.of(context).colorScheme.surface, // Off-white
                        ],
                ),
              ),
            ),
          ),
          // Subtle texture overlay (optional, keeping it clean for now)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/app_icon.png'), // Using logo as a subtle watermark pattern
                    repeat: ImageRepeat.repeat,
                    scale: 4,
                  ),
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.6),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: NavigationBar(
              height: 75,
              elevation: 0,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_edu_rounded),
                  label: 'Tagebuch',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medication_liquid_rounded),
                  label: 'Medikation',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_rounded),
                  label: 'Einstellungen',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

