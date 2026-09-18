import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cidpbuddy/core/database/database.dart';
import 'package:cidpbuddy/core/l10n/locale_provider.dart';
import 'package:cidpbuddy/core/services/medication_service.dart';
import 'package:cidpbuddy/core/theme/app_theme.dart';
import 'package:cidpbuddy/core/theme/theme_provider.dart';
import 'package:cidpbuddy/features/diary/providers/diary_provider.dart';
import 'package:cidpbuddy/features/inventory/providers/inventory_provider.dart';
import 'package:cidpbuddy/l10n/generated/app_localizations.dart';

/// Everything a page needs to render outside the real app: an in-memory
/// database with the production schema, the provider tree from `main.dart`,
/// the app theme and the localizations.
///
/// Usage in a test file:
///
/// ```dart
/// void main() {
///   final app = AppHarness();
///   setUpAll(app.setUpAll);
///   setUp(app.setUp);
///   tearDown(app.tearDown);
///
///   testWidgets('dashboard', (tester) async {
///     await app.pumpPage(tester, const DashboardPage());
///     ...
///   });
/// }
/// ```
class AppHarness {
  late AppDatabase db;

  /// Ids of the seeded rows, for pages that need one to be constructed.
  late SeededData seeded;

  /// Registers the plugin doubles. Runs once per test file.
  Future<void> setUpAll() async {
    // Outfit is fetched from Google at runtime in the app; tests have no
    // network and no bundled copy, so let google_fonts fail fast and fall
    // back to the test font instead of waiting on a socket.
    GoogleFonts.config.allowRuntimeFetching = false;
    // Every test opens its own in-memory database; drift's "created the
    // database class multiple times" warning is noise here.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    PackageInfo.setMockInitialValues(
      appName: 'CIDPbuddy',
      packageName: 'de.fokuspunk.cidpbuddy',
      version: '0.0.0-test',
      buildNumber: '0',
      buildSignature: '',
    );
  }

  /// Opens a fresh, seeded in-memory database before each test.
  Future<void> setUp() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    seeded = await seedDatabase(db);
  }

  /// Drops the test database. Closing it waits for in-flight queries, and a
  /// query scheduled inside the widget test's fake-async zone never
  /// completes once the test body has returned — so the wait is bounded, or
  /// one leaked stream would stall the whole run.
  Future<void> tearDown() => AppDatabase.resetForTesting().timeout(
    const Duration(seconds: 2),
    onTimeout: () {},
  );

  /// Renders [page] as the home of a fully wired `MaterialApp`.
  ///
  /// [size] is the logical screen size, [textScale] the user's font-size
  /// setting (1.0 = default, 1.3 = "large", 2.0 = the top of the Android
  /// accessibility range). The view is reset after the test.
  Future<void> pumpPage(
    WidgetTester tester,
    Widget page, {
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    Size size = phoneSize,
    double textScale = 1.0,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final localeProvider = LocaleProvider();
    final themeProvider = ThemeProvider()..setThemeMode(themeMode);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: db),
          Provider<MedicationService>(create: (_) => MedicationService(db)),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ChangeNotifierProvider<InventoryProvider>(
            create: (_) => InventoryProvider(db),
          ),
          ChangeNotifierProvider<DiaryProvider>(
            create: (_) => DiaryProvider(db),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: page,
        ),
      ),
    );
    await settle(tester);
  }

  /// Pumps frames until nothing is scheduled any more, or [maxFrames] have
  /// passed. Unlike `pumpAndSettle` this never throws on a page that keeps
  /// an animation running (progress spinners, pulsing highlights).
  static Future<void> settle(WidgetTester tester, {int maxFrames = 30}) async {
    for (var i = 0; i < maxFrames; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (!tester.binding.hasScheduledFrame) return;
    }
  }

  /// iPhone 14 / Pixel 7 class screen, in logical pixels.
  static const Size phoneSize = Size(390, 844);

  /// The narrowest phone still in common use (iPhone SE 1st gen, small
  /// Android devices). Anything that fits here fits everywhere.
  static const Size smallPhoneSize = Size(320, 568);

  /// A tablet in portrait, to catch layouts that only work at phone widths.
  static const Size tabletSize = Size(800, 1280);

  /// Every locale the app ships, in the order of `supportedLocales`.
  static List<Locale> get locales => AppLocalizations.supportedLocales;
}

/// Row ids created by [seedDatabase].
class SeededData {
  const SeededData({
    required this.infusionMedicationId,
    required this.pillMedicationId,
    required this.discontinuedMedicationId,
    required this.accessoryId,
    required this.scheduleId,
    required this.plannedInfusionId,
    required this.pendingOrderId,
    required this.diaryEntryId,
  });

  final int infusionMedicationId;
  final int pillMedicationId;
  final int discontinuedMedicationId;
  final int accessoryId;
  final int scheduleId;
  final int plannedInfusionId;
  final int pendingOrderId;
  final int diaryEntryId;
}

/// Fills [db] with one of everything, so every list, card and chart on every
/// page has content to lay out. Names are deliberately long: a layout that
/// survives them survives real medication names in German.
Future<SeededData> seedDatabase(AppDatabase db) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final infusionMedId = await db
      .into(db.medications)
      .insert(
        MedicationsCompanion.insert(
          name: 'Immunglobulin subkutan 20 % (Hizentra) 4 g/20 ml',
          dosage: const Value('4 g'),
          pzn: const Value('12345678'),
          stock: const Value(2),
          minStock: const Value(4),
          unit: 'Flasche',
          type: const Value(MedicationType.infusion),
          packageSize: const Value(1),
          useTimer: const Value(true),
        ),
      );
  final pillMedId = await db
      .into(db.medications)
      .insert(
        MedicationsCompanion.insert(
          name: 'Paracetamol 500 mg Filmtabletten',
          dosage: const Value('500 mg'),
          stock: const Value(30),
          minStock: const Value(10),
          unit: 'Stk',
          type: const Value(MedicationType.pill),
          packageSize: const Value(20),
          trackBatchNumber: const Value(false),
          trackWeight: const Value(false),
        ),
      );
  final discontinuedMedId = await db
      .into(db.medications)
      .insert(
        MedicationsCompanion.insert(
          name: 'Prednisolon 5 mg (abgesetzt)',
          unit: 'Stk',
          type: const Value(MedicationType.pill),
          discontinuedAt: Value(today.subtract(const Duration(days: 40))),
        ),
      );
  final accessoryId = await db
      .into(db.accessories)
      .insert(
        AccessoriesCompanion.insert(
          name: 'Subkutan-Infusionsset 9 mm, 2-fach',
          stock: const Value(3),
          minStock: const Value(5),
          unit: 'Stk',
          packageSize: const Value(10),
        ),
      );
  await db
      .into(db.medicationAccessories)
      .insert(
        MedicationAccessoriesCompanion.insert(
          medicationId: infusionMedId,
          accessoryId: accessoryId,
          defaultQuantity: const Value(1),
          isMandatory: const Value(true),
        ),
      );

  final scheduleId = await db
      .into(db.infusionSchedules)
      .insert(
        InfusionSchedulesCompanion.insert(
          medicationId: infusionMedId,
          dosage: 4,
          frequencyType: 'weekly',
          intervalValue: const Value(1),
          selectedWeekdays: const Value('1,4'),
          startDate: today.subtract(const Duration(days: 30)),
          intakeTimes: const Value('08:00'),
        ),
      );
  await db
      .into(db.infusionSchedules)
      .insert(
        InfusionSchedulesCompanion.insert(
          medicationId: pillMedId,
          dosage: 1,
          frequencyType: 'daily',
          startDate: today.subtract(const Duration(days: 30)),
          intakeTimes: const Value('08:00,20:00'),
        ),
      );

  final plannedId = await db
      .into(db.plannedInfusions)
      .insert(
        PlannedInfusionsCompanion.insert(
          date: today.add(const Duration(hours: 8)),
          medicationId: infusionMedId,
          dosage: 4,
          scheduleId: Value(scheduleId),
        ),
      );
  // Overdue and upcoming rows exercise the dashboard's past/future sections.
  await db
      .into(db.plannedInfusions)
      .insert(
        PlannedInfusionsCompanion.insert(
          date: today.subtract(const Duration(days: 2, hours: -8)),
          medicationId: pillMedId,
          dosage: 1,
        ),
      );
  await db
      .into(db.plannedInfusions)
      .insert(
        PlannedInfusionsCompanion.insert(
          date: today.add(const Duration(days: 3, hours: 8)),
          medicationId: infusionMedId,
          dosage: 4,
          scheduleId: Value(scheduleId),
        ),
      );

  for (var weeksAgo = 1; weeksAgo <= 6; weeksAgo++) {
    await db
        .into(db.infusionLog)
        .insert(
          InfusionLogCompanion.insert(
            date: today.subtract(Duration(days: 7 * weeksAgo, hours: -9)),
            medicationId: infusionMedId,
            dosage: 4,
            batchNumber: Value('LOT-2026-0$weeksAgo'),
            bodyWeight: Value(72.5 - weeksAgo * 0.2),
            notes: weeksAgo == 1
                ? const Value(
                    'Leichte Kopfschmerzen danach, sonst gut vertragen.',
                  )
                : const Value.absent(),
          ),
        );
  }

  final orderId = await db
      .into(db.pendingOrders)
      .insert(
        PendingOrdersCompanion.insert(
          medicationId: infusionMedId,
          medicationQty: 4,
          deliveryDate: Value(today.add(const Duration(days: 5))),
        ),
      );
  await db
      .into(db.pendingOrderItems)
      .insert(
        PendingOrderItemsCompanion.insert(
          orderId: orderId,
          accessoryId: Value(accessoryId),
          quantity: 10,
        ),
      );

  var diaryEntryId = 0;
  for (var daysAgo = 0; daysAgo < 14; daysAgo += 2) {
    diaryEntryId = await db
        .into(db.diaryEntries)
        .insert(
          DiaryEntriesCompanion.insert(
            date: today.subtract(Duration(days: daysAgo, hours: -19)),
            systolicBP: const Value(128),
            diastolicBP: const Value(82),
            heartRate: const Value(68),
            temperature: const Value(36.7),
            weight: const Value(72.4),
            strengthScore: Value(4 + daysAgo % 4),
            sensoryScore: Value(3 + daysAgo % 5),
            fatigueScore: Value(6 - daysAgo % 3),
            painScore: Value(2 + daysAgo % 4),
            balanceScore: Value(5 + daysAgo % 3),
            notes: daysAgo == 0
                ? const Value('Taubheitsgefühl in beiden Füßen morgens.')
                : const Value.absent(),
          ),
        );
  }

  return SeededData(
    infusionMedicationId: infusionMedId,
    pillMedicationId: pillMedId,
    discontinuedMedicationId: discontinuedMedId,
    accessoryId: accessoryId,
    scheduleId: scheduleId,
    plannedInfusionId: plannedId,
    pendingOrderId: orderId,
    diaryEntryId: diaryEntryId,
  );
}

/// A framework error captured while the widget tree that raised it was
/// still alive, so it can be described after the tree is gone.
class CapturedError {
  CapturedError(FlutterErrorDetails details)
    : message = details.exceptionAsString().split('\n').first.trim(),
      culprit = _culprit(details);

  /// The first line of the exception, e.g.
  /// `A RenderFlex overflowed by 27 pixels on the right.`
  final String message;

  /// The widget the framework blames, with its source location — the same
  /// `Row file:///…/page.dart:123:45` line the console prints.
  final String culprit;

  bool get isOverflow => message.contains('overflowed by');

  /// Errors the framework raises *because* an earlier one left the tree
  /// half laid out. They carry no information of their own.
  bool get isCascade =>
      message.startsWith('RenderBox was not laid out') ||
      message.contains('Failed assertion') ||
      message.contains('parentDataDirty');

  static String _culprit(FlutterErrorDetails details) {
    final info = details.informationCollector?.call();
    if (info == null) return '';
    for (final node in debugTransformDebugCreator(info)) {
      if (node is DiagnosticsBlock &&
          node.name == 'The relevant error-causing widget was') {
        return node
            .getChildren()
            .map((c) => c.toString().trim())
            .join(' ')
            .replaceAll(RegExp(r'\s+'), ' ');
      }
    }
    return '';
  }

  @override
  String toString() => culprit.isEmpty ? message : '$message — $culprit';
}

/// Collects every framework error raised while [body] runs — layout
/// overflows in particular, which Flutter reports through
/// `FlutterError.onError` rather than by throwing — and hands them back so a
/// test can assert on all of them, not just the first one `takeException`
/// would return.
Future<List<CapturedError>> collectFlutterErrors(
  Future<void> Function() body,
) async {
  final collected = <CapturedError>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) => collected.add(CapturedError(details));
  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }
  return collected;
}

/// The errors worth reading: cascades dropped when a root cause is present,
/// duplicates collapsed to one line with a count.
List<String> summarizeErrors(Iterable<CapturedError> errors) {
  final list = errors.toList();
  final roots = list.where((e) => !e.isCascade).toList();
  final relevant = roots.isEmpty ? list : roots;
  final counts = <String, int>{};
  for (final e in relevant) {
    counts.update(e.toString(), (n) => n + 1, ifAbsent: () => 1);
  }
  return [
    for (final entry in counts.entries)
      entry.value == 1 ? entry.key : '${entry.key} (×${entry.value})',
  ];
}

/// One line per distinct error, for failure output that can be read
/// without the full dump.
String describeErrors(Iterable<CapturedError> errors) =>
    summarizeErrors(errors).map((line) => '  • $line').join('\n');
