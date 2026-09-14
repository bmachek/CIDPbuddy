# Architecture

## Overview

CIDPbuddy follows a reactive, data-first approach: the SQLite database (via Drift) is the single source of truth. UI state is not held manually but derived from database streams.

```
Database (Drift streams)
    └─► Provider (ChangeNotifier)
            └─► Widgets (rebuild on notify)
```

## State management

### Provider pattern

The app uses `ChangeNotifier` + `ChangeNotifierProxyProvider` from the `provider` package.

- **`DiaryProvider`** — merges infusion logs, diary entries, delivered orders and medication events into one timeline stream via `RxDart.combineLatest`
- **`InventoryProvider`** — streams for active medications, discontinued medications and supplies
- **`ThemeProvider`** (`lib/core/theme/theme_provider.dart`) — holds the `ThemeMode` (light/dark/system)
- **`LocaleProvider`** (`lib/core/l10n/locale_provider.dart`) — holds the language choice and persists it; `null` means "follow the device"
- **`MedicationService`** — not a `ChangeNotifier`; registered as a plain `Provider`. Encapsulates stock and coverage calculations

Providers are registered in `main.dart` with `MultiProvider` and get access to the `AppDatabase` singleton.

### Drift streams as the data source

```dart
// Example: a reactive stream from the DB
Stream<List<Medication>> watchActiveMedications() =>
    (select(medications)..where((m) => m.discontinuedAt.isNull()))
        .watch();
```

Every `watch*()` method emits on each relevant table change. The provider subscribes in its constructor and calls `notifyListeners()` on every emit.

### RxDart composition

When several streams are merged into one combined state (e.g. in the diary dashboard):

```dart
// lib/features/diary/providers/diary_provider.dart
combinedEntriesStream = Rx.combineLatest4(
  _db.watchInfusionLogs(),
  _db.watchDiaryEntries(),
  _db.watchConfirmedOrders(),   // delivered orders only
  _db.watchAllMedications(),    // resolved into MedicationEvents
  (logs, entries, orders, meds) => _merge(logs, entries, orders, meds),
);
```

From each `Medication` row the provider derives up to two `MedicationEvent`s (`created` from `createdAt`, `discontinued` from `discontinuedAt`), so prescriptions and discontinuations appear as their own timeline entries.

> **Not included:** planned appointments (`PlannedInfusions`) and still-open orders do *not* flow
> through this stream — the diary shows the past only. Planned appointments appear on the
> dashboard and on the planning page.

## Database architecture

### Singleton pattern

`AppDatabase` is an app-wide singleton. This is critical for backup/restore: restoring replaces the DB file and rebuilds the singleton connection — without the singleton, connections would leak.

```dart
// lib/core/database/database.dart
static final AppDatabase _instance = AppDatabase._internal();

factory AppDatabase() => _instance;

AppDatabase._internal() : super(_openConnection()) {
  _setupAutoBackup();
}
```

So every `AppDatabase()` in the code yields the same instance — there is no separate `AppDatabase.instance` getter.

### Auto-backup trigger

In its own constructor (`_setupAutoBackup()`), `AppDatabase` registers a listener on all table changes and debounces them to 30 seconds:

```dart
tableUpdates().debounceTime(const Duration(seconds: 30)).listen((updates) {
  if (updates.isNotEmpty) {
    BackupService().autoBackup();
  }
});
```

Whether that actually produces a backup is then decided by `BackupService` — it skips automatic runs when the last successful backup is less than 6 hours old.

## Background services

### BackgroundService (24/7 service)

`lib/core/services/background_service.dart` runs in its own isolate via `flutter_background_service`.

**Responsibilities:**
1. **Premedication timer** — countdown with per-minute audio bells (`bell.mp3`, 3× spaced 1.5 s apart) and a closing ping (`ping.mp3`); a foreground notification shows the running countdown
2. **24 h sync** — regenerates the 90-day treatment plan (via `SchedulerService`) and refreshes notifications

Access to Flutter plugins from the background isolate is guaranteed by `DartPluginRegistrant.ensureInitialized()`.

> **Platform difference:** only Android has a real foreground service. On iOS the isolate is
> starved of CPU while backgrounded, so its per-second tick freezes. The countdown therefore
> does not decrement; on every tick it derives the remaining time from a persisted absolute end
> timestamp (`timerEndEpochKey`), so it self-corrects as soon as the app returns to the
> foreground. The completion notification is also scheduled in advance, in case the service
> cannot keep running in time.

### WorkManager (periodic)

`lib/features/settings/services/backup_worker.dart` uses Android WorkManager for periodic backup tasks that survive device reboots. The worker is registered at app start and re-registered after boot.

## SchedulerService

`lib/core/services/scheduler_service.dart` generates the 90-day treatment plan:

| Frequency type | Logic |
|----------------|-------|
| `daily` | Every day from startDate |
| `interval` | Every N days (intervalValue) |
| `weekly` | Specific weekdays (selectedWeekdays: `'1,3,5'`) |
| `weekdays` | Mon–Fri |

`checkMissedTreatments()` looks back 7 days for unconfirmed/unskipped treatments and raises notifications.

## Navigation

`lib/main_screen.dart` uses an `IndexedStack` with a glassmorphic bottom navigation (4 tabs):

1. **Dashboard** — `DashboardPage`
2. **Diary** — `DiaryPage`
3. **Inventory** — `InventoryPage`
4. **Settings** — `SettingsPage`

The `IndexedStack` keeps all widgets alive, so scroll position and state survive tab switches.

## Theme & localization

- Material 3 with premium gradient backgrounds and glassmorphic navigation (`BackdropFilter`)
- Colour palette: blue `#0066FF`, emerald `#00BFA6`, gold `#FFB300`
- **Light and dark theme**: `AppTheme.lightTheme` / `AppTheme.darkTheme`, driven by `ThemeProvider`. The initial value is `ThemeMode.system`; the "Dark theme" switch in the settings toggles between light and dark. That choice is currently **not** persisted and falls back to `ThemeMode.system` on every app start.
- **Five languages** — English, German, French, Italian and Spanish, generated from ARB files by `flutter gen-l10n`. See [Localization](Localization).
- Date and number formats follow the active locale via `AppDateFormat` (`lib/core/l10n/l10n_ext.dart`) — no hard-coded patterns.

## Key code rules

1. `flutter analyze` must pass with zero issues after every change
2. **Never** use `const Theme.of(context)` — it is not a constant expression
3. Use **`color.withValues(alpha: 0.5)`** instead of the deprecated `color.withOpacity(0.5)`
4. Pass `BuildContext context` as the first argument to `StatelessWidget` helper methods
5. **Check `mounted`** before touching `context` after any `async` gap in a `StatefulWidget`
6. No user-visible string literals in Dart — every one goes through `context.l10n` (see [Localization](Localization))
