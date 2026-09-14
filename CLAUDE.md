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

# Verify everything CI checks: generated code, translations, analyzer, tests
tool/verify.sh

# Lint only (must pass before finishing any task)
/opt/homebrew/bin/flutter analyze

# Run app
flutter run

# Build release APK
flutter build apk --release --build-name=X.X.X --build-number=N
```

`tool/verify.sh` is the single gate — it is what CI runs, so a green run locally means a green run on GitHub.

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

## Continuous Integration

Workflows live in `.github/workflows/`:

- **`ci.yml`** — on every push to `main` and every PR. Runs `tool/verify.sh --check-generated` (regenerates Drift and l10n code and fails if the committed output is stale, fails on any untranslated ARB key, checks `dart format`, then `flutter analyze --fatal-infos` and `flutter test`), followed by a debug APK build that catches Gradle/Kotlin breakage the analyzer cannot see. Also callable from other workflows.
- **`release.yml`** — on `v*` tags. Calls `ci.yml` first, so a tag cannot publish a release that does not verify, then builds and attaches the signed APK. The iOS job stays disabled until the App Store Connect secrets are restored.
- **`codeql.yml`** — CodeQL for `actions` (the workflows themselves) and `java-kotlin` (the Android sources, built with the Flutter toolchain). On push, PR and weekly.
- **`publish-wiki.yml`** — mirrors `docs/*.md` into the GitHub wiki, pruning pages whose source file was deleted.

The Flutter version is pinned (`FLUTTER_VERSION` in `ci.yml`, and the same literal in `release.yml`); raise both together. Dependabot watches pub, Gradle and the actions themselves.

`dart format` is enforced by CI. Run `dart format .` before committing; generated code is already format-clean, so the formatter and the generators do not conflict. Linting is not a separate step — `analysis_options.yaml` pulls in `package:flutter_lints`, and CI analyzes with `--fatal-infos`, so every lint is a hard failure.

## Subagents

`.claude/agents/` defines three project subagents. Delegating to them keeps large, low-value output out of the main context — a single `flutter` command re-prints a 115-line dependency banner, and the five ARB files together are thousands of lines:

- **`flutter-verifier`** (Haiku) — runs `tool/verify.sh` and reports only the failures. Use it instead of running `flutter analyze` or `flutter test` directly.
- **`l10n-translator`** (Sonnet) — adds or changes UI strings across all five ARB files and runs `gen-l10n`. Use it whenever a change touches user-visible text.
- **`drift-migrator`** — schema change plus migration step, version bump and regeneration. Use it for anything that alters the shape of the database; patients' infusion logs cannot be recreated.

Rules of thumb: delegate work whose *output* is large but whose *answer* is small (verification, searching, translating); do the actual feature edits yourself so the reasoning stays in one place. Agents report conclusions, not file dumps.

## Code Rules (from AI_GUIDELINES.md)

1. **Always run `flutter analyze`** after changes — zero errors policy
2. **Never** use `const Theme.of(context)` — `Theme.of(context)` is not a constant expression
3. **Use `color.withValues(alpha: 0.5)`** instead of deprecated `color.withOpacity(0.5)`
4. **Pass `BuildContext context`** as first argument to `StatelessWidget` helper methods
5. **Check `mounted`** before using `context` after any `async` gap in `StatefulWidget`
6. **No hard-coded UI text** — add a key to `lib/l10n/app_en.arb` (with a `description`), translate it in the other four ARB files, then use `context.l10n.<key>`
7. **Run `flutter gen-l10n`** after touching any ARB file
