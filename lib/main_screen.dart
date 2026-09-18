import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cidpbuddy/core/database/database.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';
import 'package:cidpbuddy/core/services/scheduler_service.dart';
import 'package:cidpbuddy/features/diary/pages/dashboard_page.dart';
import 'package:cidpbuddy/features/inventory/pages/inventory_page.dart';
import 'package:cidpbuddy/features/diary/pages/diary_page.dart';
import 'package:cidpbuddy/features/settings/pages/settings_page.dart';

/// Lets any widget inside the shell switch the visible tab — the dashboard's
/// "no backup configured" card sends the patient to Settings this way.
///
/// ```dart
/// MainTabs.maybeOf(context)?.select(MainTabs.settings);
/// ```
class MainTabs extends InheritedWidget {
  const MainTabs({super.key, required this.select, required super.child});

  static const int dashboard = 0;
  static const int diary = 1;
  static const int inventory = 2;
  static const int settings = 3;

  /// Makes the tab at [index] visible.
  final void Function(int index) select;

  static MainTabs? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainTabs>();

  @override
  bool updateShouldNotify(MainTabs oldWidget) => select != oldWidget.select;
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});

  /// Which tab opens first: 0 dashboard, 1 diary, 2 inventory, 3 settings.
  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late int _selectedIndex = widget.initialIndex;

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
      // Re-evaluate the missed-intakes summary. It is a delivered
      // notification that otherwise only gets recomputed on a cold start, so
      // on iOS — where the periodic background sync never gets to run — it
      // would keep showing entries the user has since confirmed.
      final scheduler = SchedulerService(db);
      unawaited(scheduler.checkMissedTreatments());
      // Drop reminders for intakes that are already done. Confirmations made
      // outside this isolate (notification actions, the background sync) leave
      // their follow-up alarms pending here, and on iOS nothing else re-runs
      // the sweep between cold starts — so they would keep firing all day.
      unawaited(scheduler.sweepStaleReminders());
    }
  }

  void _selectTab(int index) {
    if (index == _selectedIndex || index < 0 || index >= _pages.length) return;
    setState(() => _selectedIndex = index);
  }

  /// How much taller than its 75 dp default the navigation bar has to be for
  /// the current text scale: 1.0 at the default font size, at most 1.5.
  static double _navBarScale(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.5);

  @override
  Widget build(BuildContext context) {
    return MainTabs(
      select: _selectTab,
      child: Scaffold(
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
                            Theme.of(
                              context,
                            ).colorScheme.surface, // Slate/Black
                          ]
                        : [
                            const Color(0xFFE3F2FD), // Very Light Azure
                            Theme.of(context).colorScheme.surface, // Off-white
                          ],
                  ),
                ),
              ),
            ),
            // Subtle texture overlay (optional, keeping it clean for now).
            // Purely decorative, so it must not reach the screen reader.
            Positioned.fill(
              child: ExcludeSemantics(
                child: Opacity(
                  opacity: 0.05,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/app_icon.png',
                        ), // Using logo as a subtle watermark pattern
                        repeat: ImageRepeat.repeat,
                        scale: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Main Content
            SafeArea(
              bottom: false,
              child: IndexedStack(index: _selectedIndex, children: _pages),
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
                // The labels do not wrap, so the bar grows with the system
                // font size instead of clipping them; capped so it never
                // swallows the screen.
                height: 75 * _navBarScale(context),
                elevation: 0,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectTab,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.grid_view_rounded),
                    label: context.l10n.navDashboard,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.history_edu_rounded),
                    label: context.l10n.navDiary,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.medication_liquid_rounded),
                    label: context.l10n.navMedication,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.tune_rounded),
                    label: context.l10n.navSettings,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
