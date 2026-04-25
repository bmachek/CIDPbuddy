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

# Lint (must pass before finishing any task)
/opt/homebrew/bin/flutter analyze

# Run app
flutter run

# Build release APK
flutter build apk --release --build-name=X.X.X --build-number=N
```

There is a basic smoke test at `test/widget_test.dart` — no meaningful test suite exists yet.

## Architecture

### State Management
- **Provider pattern** (`ChangeNotifier` + `ChangeNotifierProxyProvider`) for UI state
- **Drift streams** (reactive SQLite) as the data source — providers wrap `watchXxx()` streams
- **RxDart `combineLatest`** merges multiple streams (see `DiaryProvider.combinedEntriesStream`)

### Database (`lib/core/database/`)
- **Drift ORM** with schema version 13 and explicit migration steps
- Core tables: `Medications`, `Accessories`, `InfusionLog`, `InfusionSchedules`, `PlannedInfusions`, `PendingOrders`, `DiaryEntries`
- **Singleton pattern** (`AppDatabase`) — critical for backup/restore to avoid connection leaks
- Auto-backup triggers from `tableUpdates().debounceTime(30s)`

### Feature Modules (`lib/features/`)
- **diary/** — health tracking, symptom logging, dashboard, infusion timer with audio
- **inventory/** — medication/accessory management, QR scanning, shopping wizard, OCR
- **reminders/** — `NotificationService` (7-day window to stay within Android's 500-alarm limit)
- **settings/** — ZIP-based backup/restore via SAF, reliability checks

### Background & Scheduling (`lib/core/services/`)
- **`SchedulerService`** — generates 90-day rolling treatment schedule; `_calculateDates` handles frequency rules (daily, interval, weekly, weekdays)
- **`BackgroundService`** — runs 24/7 for premedication timers and 24h periodic sync
- **`MedicationService`** — low-stock calculation: `stock ÷ daily-requirement` vs `minStock`

### Navigation
`main_screen.dart` — `IndexedStack` bottom-nav with 4 tabs (Dashboard, Diary, Inventory, Settings)

### Theme & Localization
- Material3 with custom colors: Blue `#0066FF`, Emerald `#00BFA6`, Gold `#FFB300`
- **German only** (`Locale('de', 'DE')`) — all UI strings must be in German
- Premium gradient backgrounds; glassmorphic bottom nav (`BackdropFilter`)

## Code Rules (from .cursorrules and AI_GUIDELINES.md)

1. **Always run `flutter analyze`** after changes — zero errors policy
2. **Never** use `const Theme.of(context)` — `Theme.of(context)` is not a constant expression
3. **Use `color.withValues(alpha: 0.5)`** instead of deprecated `color.withOpacity(0.5)`
4. **Pass `BuildContext context`** as first argument to `StatelessWidget` helper methods
5. **Check `mounted`** before using `context` after any `async` gap in `StatefulWidget`
6. All UI text in **German**
