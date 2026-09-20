import 'package:flutter/material.dart';

import 'package:cidpbuddy/features/diary/pages/add_diary_entry_page.dart';
import 'package:cidpbuddy/features/diary/pages/add_infusion_page.dart';
import 'package:cidpbuddy/features/diary/pages/add_schedule_page.dart';
import 'package:cidpbuddy/features/diary/pages/statistics_page.dart';
import 'package:cidpbuddy/features/diary/widgets/premedication_timer_modal.dart';
import 'package:cidpbuddy/features/inventory/pages/add_item_page.dart';
import 'package:cidpbuddy/features/inventory/pages/discontinued_medications_page.dart';
import 'package:cidpbuddy/features/inventory/pages/medication_details_page.dart';
import 'package:cidpbuddy/features/inventory/pages/shopping_wizard_dialog.dart';
import 'package:cidpbuddy/main_screen.dart';

import 'app_harness.dart';

/// One screen the UI checks render. [build] gets the seeded row ids so
/// detail pages can point at a real medication.
class PageCase {
  const PageCase(this.name, this.build);

  final String name;
  final Widget Function(SeededData seeded) build;

  @override
  String toString() => name;
}

/// Every screen a patient can reach, in navigation order. New pages belong
/// here — the layout and accessibility suites iterate this list, so a page
/// that is missing is a page that is not checked.
///
/// Not listed: `ReliabilityCheckPage` — its `initState` queries OS
/// permissions through plugins that have no test double.
final List<PageCase> allPages = [
  // The four tabs draw on a transparent scaffold over the gradient that
  // `MainScreen` paints, so they are rendered through it — with the
  // navigation bar in place, exactly as the patient sees them.
  PageCase('Dashboard tab', (_) => const MainScreen(initialIndex: 0)),
  PageCase('Diary tab', (_) => const MainScreen(initialIndex: 1)),
  PageCase('Inventory tab', (_) => const MainScreen(initialIndex: 2)),
  PageCase('Settings tab', (_) => const MainScreen(initialIndex: 3)),
  PageCase('StatisticsPage', (_) => const StatisticsPage()),
  PageCase(
    'MedicationDetailsPage',
    (s) => MedicationDetailsPage(medicationId: s.infusionMedicationId),
  ),
  PageCase(
    'MedicationDetailsPage (pill)',
    (s) => MedicationDetailsPage(medicationId: s.pillMedicationId),
  ),
  PageCase(
    'DiscontinuedMedicationsPage',
    (_) => const DiscontinuedMedicationsPage(),
  ),
  PageCase('AddItemPage', (_) => const AddItemPage()),
  PageCase(
    'AddInfusionPage',
    (s) => AddInfusionPage(initialMedicationId: s.infusionMedicationId),
  ),
  PageCase(
    'AddSchedulePage',
    (s) => AddSchedulePage(preselectedMedicationId: s.infusionMedicationId),
  ),
  PageCase('AddDiaryEntryPage', (_) => const AddDiaryEntryPage()),
  PageCase(
    'ShoppingWizardDialog',
    (_) => const Scaffold(body: ShoppingWizardDialog()),
  ),
  // Not a route but a bottom sheet, and the screen a patient looks at for
  // the length of an infusion. It stayed out of this list while its controls
  // were invisible in both themes, so it is rendered here the way the sheet
  // does it: on a Material, which is what `Ink` needs to paint at all. The
  // background service does not exist in tests, so the controls render in
  // their disabled state.
  PageCase(
    'PremedicationTimerModal',
    (_) => const Scaffold(body: PremedicationTimerModal()),
  ),
];
