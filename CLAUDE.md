# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

**CIDPbuddy** is a Flutter healthcare app for patients with Chronic Inflammatory Demyelinating Polyneuropathy (CIDP). It manages infusion schedules, medication inventory, diary entries, and treatment reminders. Targets Android, iOS, macOS, Windows, Linux, and Web.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Regenerate Drift database code (required after schema changes)
dart run build_runner build --delete-conflicting-outputs

# Regenerate localizations (required after editing lib/l10n/*.arb)
flutter gen-l10n

# Lint (must pass before finishing any task)
/opt/homebrew/bin/flutter analyze

# Run app
flutter run

# Build release APK
flutter build apk --release --build-name=X.X.X --build-number=N
```

`test/widget_test.dart` covers the localization setup (locale coverage, lookup per language, placeholder substitution, widget rendering). Beyond that, no meaningful test suite exists yet.

## Architecture

### State Management
- **Provider pattern** (`ChangeNotifier` + `ChangeNotifierProxyProvider`) for UI state
- **Drift streams** (reactive SQLite) as the data source — providers wrap `watchXxx()` streams
- **RxDart `combineLatest`** merges multiple streams (see `DiaryProvider.combinedEntriesStream` — infusion logs, diary entries, *delivered* orders, and medication create/discontinue events; planned infusions are deliberately not in the diary)

### Database (`lib/core/database/`)
- **Drift ORM** with schema version 14 and explicit migration steps (no step 8 — the number was skipped)
- Tables: `Medications`, `Accessories`, `MedicationAccessories`, `InfusionLog`, `InfusionSchedules`, `PlannedInfusions`, `PendingOrders`, `PendingOrderItems`, `DiaryEntries`
- **Singleton pattern** (`AppDatabase`) — critical for backup/restore to avoid connection leaks
- Auto-backup triggers from `tableUpdates().debounceTime(30s)`

### Feature Modules (`lib/features/`)
- **diary/** — health tracking, symptom logging, dashboard, infusion timer with audio
- **inventory/** — medication/accessory management, QR scanning, shopping wizard, OCR
- **reminders/** — `NotificationService`; only the next 7 days get alarms registered (the window lives in `SchedulerService.notificationLookAhead`), keeping the count of concurrently registered exact alarms small
- **settings/** — ZIP-based backup/restore via SAF, reliability checks

### Background & Scheduling (`lib/core/services/`)
- **`SchedulerService`** — generates 90-day rolling treatment schedule; `_calculateDates` handles frequency rules (daily, interval, weekly, weekdays)
- **`BackgroundService`** — premedication timers and a 24h periodic sync. Android runs it as a real foreground service; on iOS the isolate is starved while backgrounded, so the countdown derives its remaining time from a persisted absolute end timestamp instead of decrementing
- **`MedicationService`** — low-stock calculation: `stock ÷ daily-requirement` vs `minStock`

### Navigation
`main_screen.dart` — `IndexedStack` bottom-nav with 4 tabs (Dashboard, Diary, Inventory, Settings)

### Theme & Localization
- Material3 with custom colors: Blue `#0066FF`, Emerald `#00BFA6`, Gold `#FFB300`
- Light and dark themes (`AppTheme.lightTheme` / `darkTheme`) via `ThemeProvider`; defaults to `ThemeMode.system` and is not persisted
- **Five languages** — English, German, French, Italian, Spanish. Generated from ARB files (`lib/l10n/*.arb`) by `flutter gen-l10n`; generated code is committed
- **No user-visible string literals in Dart** — everything goes through `context.l10n` (`lib/core/l10n/l10n_ext.dart`)
- Follows the device language, falls back to English; explicit picker in Settings, persisted by `LocaleProvider`
- Dates/numbers are locale-aware via `AppDateFormat` — never hard-code patterns like `dd.MM.yyyy`
- Background isolates (notifications, backup, scheduler) use `LocaleProvider.l10nForBackground()` since they have no `BuildContext`
- Premium gradient backgrounds; glassmorphic bottom nav (`BackdropFilter`)

### Platform IDs
Android `applicationId` and iOS bundle ID are both `de.fokuspunk.cidpbuddy`.

## Code Rules (from AI_GUIDELINES.md)

1. **Always run `flutter analyze`** after changes — zero errors policy
2. **Never** use `const Theme.of(context)` — `Theme.of(context)` is not a constant expression
3. **Use `color.withValues(alpha: 0.5)`** instead of deprecated `color.withOpacity(0.5)`
4. **Pass `BuildContext context`** as first argument to `StatelessWidget` helper methods
5. **Check `mounted`** before using `context` after any `async` gap in `StatefulWidget`
6. **No hard-coded UI text** — add a key to `lib/l10n/app_en.arb` (with a `description`), translate it in the other four ARB files, then use `context.l10n.<key>`
7. **Run `flutter gen-l10n`** after touching any ARB file
