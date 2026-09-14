# Localization

CIDPbuddy ships in **English, German, French, Italian and Spanish**. English is the template language and the fallback.

## How a language is chosen

```
LocaleProvider.locale == null  →  follow the device
                               →  localeListResolutionCallback matches the device
                                  languages against supportedLocales
                               →  no match? → English
LocaleProvider.locale != null  →  use that language
```

`LocaleProvider` (`lib/core/l10n/locale_provider.dart`) holds the choice and persists it in `SharedPreferences` under the key `app_locale`. It is loaded in `main()` *before* `runApp`, so the very first frame already renders in the right language instead of visibly switching.

> Flutter's default resolution falls back to `supportedLocales.first`, and `gen-l10n` orders
> that list alphabetically — which would put German first. `main.dart` therefore supplies an
> explicit `localeListResolutionCallback` that falls back to English.

The settings screen has a language picker with six options: *System language*, then the five languages, each written in its own language ("Deutsch", "Français", …) so it is recognisable whatever language the UI is currently in.

## File layout

| Path | Role |
|------|------|
| `l10n.yaml` | Generator configuration |
| `lib/l10n/app_en.arb` | Template — holds the English text **and** all metadata (descriptions, placeholders) |
| `lib/l10n/app_de.arb`, `_fr`, `_it`, `_es` | Translations, keys only |
| `lib/l10n/generated/` | Generated Dart, committed to the repo |
| `lib/core/l10n/l10n_ext.dart` | `context.l10n` shorthand and `AppDateFormat` |
| `lib/core/l10n/locale_provider.dart` | Language choice, persistence, background lookup |

Generated code is committed (like `database.g.dart`) so the analyzer works on a fresh clone without a build step. `pubspec.yaml` sets `flutter: generate: true`, so `flutter run` and `flutter build` regenerate it automatically; `flutter gen-l10n` does it on demand.

## Using translations in widgets

```dart
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';

Text(context.l10n.diaryTitle)
Text(context.l10n.dashboardMarkedDone(med.name))   // with a placeholder
```

**No user-visible string literals in Dart.** `flutter analyze` will not catch these, so it is a review rule rather than a lint.

## Using translations without a BuildContext

Notifications, the background timer, the scheduler and the backup service all run in isolates that have no widget tree. They resolve the language from storage instead:

```dart
final l10n = await LocaleProvider.l10nForBackground();
notification.title = l10n.reminderDueTitle;
```

`l10nForBackground()` reads the stored choice, falls back to the platform locale via `PlatformDispatcher.instance.locale` (not `WidgetsBinding`, which may not exist in an isolate), loads the matching `intl` date symbols, and returns the `AppLocalizations` object.

`BackupDestination.displayLabel` is the one deliberate exception: it takes `AppLocalizations` as a parameter, because its only callers are widgets that already have it and a getter cannot await.

## Dates and numbers

Date patterns are **never** hard-coded. `AppDateFormat` (`lib/core/l10n/l10n_ext.dart`) wraps `intl` skeletons so formats follow the active language:

| Helper | English | German | French |
|--------|---------|--------|--------|
| `AppDateFormat.date` | 9/14/2026 | 14.09.2026 | 14/09/2026 |
| `AppDateFormat.dateTime` | 9/14/2026, 2:30 PM | 14.09.2026, 14:30 | 14/09/2026 14:30 |
| `AppDateFormat.longDate` | September 14, 2026 | 14. September 2026 | 14 septembre 2026 |
| `AppDateFormat.time` | 2:30 PM | 14:30 | 14:30 |

There are `…In(localeTag, …)` variants for isolates with no context. `main()` calls `initializeDateFormatting()` before the first frame so month and weekday names are available for every shipped language.

Weekday chips in the schedule form come from `DateFormat.E(locale)` rather than a hard-coded list.

## Editing and adding strings

The five ARB files are the source of truth — edit them directly. Adding a string means adding the key to **all five**: `app_en.arb` (with metadata) plus the four translations.

Each key in `app_en.arb` carries a `description` explaining where it appears — translators read that, so keep it meaningful:

```json
"dashboardMarkedDone": "{name} done!",
"@dashboardMarkedDone": {
  "description": "Snackbar after confirming a dose",
  "placeholders": { "name": { "type": "String", "example": "Hyqvia" } }
}
```

After editing, run `flutter gen-l10n` and `flutter analyze`.

`l10n.yaml` sets `untranslated-messages-file: l10n-untranslated.json`, so any key missing from a translation is reported there after generation. The file is gitignored; an empty `{}` means everything is translated — check it after adding keys, since a forgotten translation is otherwise silent (the generator falls back to English at runtime).

## Adding a sixth language

1. Copy `lib/l10n/app_en.arb` to `lib/l10n/app_<code>.arb`, drop the `@`-prefixed metadata entries and translate the values
2. Run `flutter gen-l10n` — `supportedLocales` picks the new file up automatically
3. Add the language to the picker: the `codes` list and `_languageName` in `lib/features/settings/pages/settings_page.dart`, plus a `language<Name>` key for its native name
4. Extend the locale assertions in `test/widget_test.dart`
5. Run `flutter analyze` and `flutter test`

## What is *not* translated

- **Stored enum keys** — `frequencyType` values (`daily`, `interval`, `weekly`, `weekdays`) and `MedicationType` live in the database and must stay stable. The UI translates them for display only.
- **User data** — anything the user typed.
- **Text the app wrote into user data** — a unit seeded from a translated default, or a `[Skipped via notification]` marker appended to a note, is stored verbatim in the language that was active at the time and is not re-translated later.
- **Android notification channel names** update only when the channel is re-created with the same ID, which happens on `NotificationService.init()`. A language change therefore reaches them on the next app start.

## Translation quality

The French, Italian and Spanish translations were produced alongside the English and German ones and have **not** been reviewed by native speakers. The medical vocabulary in particular — *infusion*, *premedication*, *subcutaneous*, *batch number*, *supply item* — is worth a review pass by someone who uses the terms clinically before a store release.
