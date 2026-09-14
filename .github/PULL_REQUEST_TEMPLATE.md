## What this changes

<!-- One or two sentences. Link the issue with "Fixes #123" if there is one. -->

## Why

<!-- The user-visible problem or the reason the change is worth making. -->

## Checklist

- [ ] `tool/verify.sh` passes (analyze, tests, generated code, translations)
- [ ] Generated code is committed (`dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`)
- [ ] No hard-coded user-visible strings — new keys added to all five ARB files
- [ ] No hard-coded date or number formats — used the `AppDateFormat` helpers
- [ ] Database schema changes come with a migration step and a bumped schema version
- [ ] Tested on a real device or emulator where the change is user-visible

## Screenshots

<!-- For UI changes: before / after, light and dark theme if relevant. -->
