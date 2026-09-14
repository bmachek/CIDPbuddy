# CIDPbuddy

CIDPbuddy is a Flutter app for managing infusion therapy for patients with **chronic inflammatory demyelinating polyneuropathy (CIDP)**. It runs on Android, iOS, macOS, Windows, Linux and web.

## Features

- **Dashboard & diary** — overview of upcoming treatments, symptom logging, vital signs and trend statistics
- **Infusion timer** — premedication timer with audio cues (bell and ping)
- **Treatment planning** — automatic 90-day planning from recurring schedules (daily, interval-based, weekly, specific weekdays)
- **Inventory & stock management** — medications and supplies with low-stock warnings, QR scanning and OCR
- **Shopping assistant** — works out exactly what to order from the plan and the current stock level
- **Reminders & notifications** — local alarms for treatments, premedication and low stock
- **Backup** — ZIP-based backup to a local folder or a folder picked through Android's Storage Access Framework (automatic, at most once every 6 hours)

## Quick start

| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install dependencies |
| `dart run build_runner build --delete-conflicting-outputs` | Regenerate the Drift database code |
| `flutter gen-l10n` | Regenerate the localizations from the ARB files |
| `/opt/homebrew/bin/flutter analyze` | Lint (must be error-free) |
| `tool/verify.sh` | Everything CI checks: generated code, translations, lint, tests |
| `flutter run` | Run the app |
| `flutter build apk --release --build-name=X.X.X --build-number=N` | Build a release APK |

## Wiki contents

- [Screenshots & tour](Screenshots) — a guided walkthrough of the app's screens
- [Architecture](Architecture) — state management, background services, navigation, theme
- [Database schema](Database-Schema) — every table, field and migration
- [Features](Features) — detailed description of the feature modules
- [Localization](Localization) — supported languages, the ARB workflow, how to add a language
- [Backup & restore](Backup-and-Restore) — the backup system, destinations, auto-backup logic
- [Building & releasing](Building-and-Releasing) — build commands, release process
- [Continuous integration](Continuous-Integration) — the workflows, `tool/verify.sh`, CodeQL, Dependabot

## Technical stack

- **Flutter** / Dart SDK ^3.11.4, Material 3
- **Drift ORM** (SQLite, reactive streams)
- **Provider** (state management)
- **RxDart** (stream composition)
- **flutter_localizations + intl** (localization, ARB-based code generation)
- **saf_util + saf_stream** (Android Storage Access Framework as a backup destination)
- **archive** (ZIP creation for backups)
- **WorkManager** (periodic background tasks, Android)
- **flutter_background_service** (premedication timer)
- **flutter_local_notifications** (alarms)
- **audioplayers** (timer audio)
- **fl_chart** (trend charts)
- **mobile_scanner + google_mlkit_text_recognition** (QR scanning, OCR)

## App identifiers

| Platform | ID |
|----------|-----|
| Android package | `de.fokuspunk.cidpbuddy` |
| iOS bundle ID | `de.fokuspunk.cidpbuddy` |
| Version | `0.99.0-dev+17` (see `pubspec.yaml`; CI releases take name and number from the git tag) |

## Localization & theme

The app ships in **English, German, French, Italian and Spanish**. It follows the device language and falls back to English; the settings screen has an explicit language picker. See [Localization](Localization) for the full workflow.

Primary colours: blue `#0066FF`, emerald `#00BFA6`, gold `#FFB300`.

There is a light and a dark theme (`AppTheme.lightTheme` / `AppTheme.darkTheme`), toggled in the settings under "Appearance".

## Licence

Apache License 2.0 — see [LICENSE](../LICENSE) and [NOTICE](../NOTICE).
