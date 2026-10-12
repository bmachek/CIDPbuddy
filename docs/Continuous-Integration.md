# Continuous integration

Everything automated lives in `.github/workflows/`. All of it runs on GitHub-hosted runners and is free for this public repository.

## One command, locally and on CI

```bash
tool/verify.sh
```

That script is the single quality gate, and CI runs the same script — a green run locally means a green run on GitHub. In order it:

1. `flutter pub get`
2. `dart run build_runner build --delete-conflicting-outputs` — the Drift code
3. `flutter gen-l10n` — the localizations
4. checks that `l10n-untranslated.json` is `{}`, i.e. every key exists in all five ARB files
5. `dart format --set-exit-if-changed` over every tracked `.dart` file
6. `flutter analyze --fatal-infos` — zero errors *and* zero infos, which includes every `flutter_lints` rule
7. `dart run tool/ui_lint.dart` — the UI rules the analyzer cannot express (see below)
8. `flutter test` — the localization tests and the UI suites under `test/ui/`

Sub-command output is captured and only printed when a step fails, so the summary stays short.

`tool/verify.sh --check-generated` additionally fails when the regenerated Drift or l10n code differs from what is committed. CI always passes that flag (it is implied whenever `$CI` is `true`); locally it is off by default, because mid-change the generated files legitimately differ from HEAD.

If `flutter` is not on your `PATH`, the script falls back to `/opt/homebrew/bin/flutter`; `FLUTTER_BIN=/path/to/flutter tool/verify.sh` overrides both.

## Workflows

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| **CI** (`ci.yml`) | push to `main`, every PR, manual, and called by Release | `tool/verify.sh --check-generated`, then a debug APK build |
| **Release** (`release.yml`) | `v*` tags | Runs CI first, then builds and publishes the signed release APK |
| **CodeQL** (`codeql.yml`) | push to `main`, PRs, weekly (Mon 05:17 UTC), manual | Static security analysis of the workflows and the Android sources |
| **OSV-Scanner** (`osv-scanner.yml`) | push to `main`, PRs, weekly (Tue 06:23 UTC), manual | Known vulnerabilities in `pubspec.lock` |
| **Publish Wiki** (`publish-wiki.yml`) | push to `main` touching `docs/**` | Mirrors `docs/*.md` into this wiki |

### CI

Two jobs. `verify` runs the script above. `build-android` then compiles a debug APK — the analyzer does not exercise the Gradle/Kotlin side, and a release build has broken on exactly that before (tag `v1.8.1`). CI is also a reusable workflow (`workflow_call`) with a `skip-android-build` input, which is how Release reuses it without building the app twice. The input is phrased as a *skip* flag deliberately: for `push` and `pull_request` the `inputs` context is null, and GitHub coerces both `null` and `false` to `0`, so a `build-android != false` guard would silently skip the job on every PR.

On pull requests, a new push cancels the in-flight run (`concurrency`). On `main` and on tags, runs are never cancelled.

### Release

The tag drives the version: `v1.9.7` → build name `1.9.7`, build number from the run number; `v1.9.7+42` sets both explicitly. The `verify` gate runs first, so a tag cannot publish a build that fails to analyze, translate or test.

The iOS job is present but disabled (`if: false`) until the App Store Connect secrets are restored. See [Building & releasing](Building-and-Releasing) for the full release procedure and the required secrets.

> **Signing:** the workflow does not create `android/key.properties`, so `android/app/build.gradle.kts` falls back to the **debug** signing config. Release APKs built by CI are therefore debug-signed. To publish upgradable, properly signed builds, add the keystore as repository secrets and write `key.properties` before the build step.

### CodeQL

Two languages in a matrix:

- `actions` — the workflow files themselves: script injection, over-broad permissions, unpinned actions. Needs no build.
- `java-kotlin` — `android/app/src/main/kotlin`. Kotlin cannot be analyzed without a build, so this job sets up Java and Flutter and compiles a debug APK between `init` and `analyze` (`build-mode: manual`).

Dart is not a CodeQL-supported language, so the Flutter code itself is not covered; the analyzer and the tests are what guard it.

Findings appear under the repository's **Security → Code scanning** tab.

### OSV-Scanner

Dart is not a CodeQL language, so the dependency side is where vulnerabilities in this app are actually detectable. OSV-Scanner checks `pubspec.lock` (185 packages) against the [OSV database](https://osv.dev) and reports into the same Code scanning tab.

The two `Podfile.lock`s are deliberately left out: OSV-Scanner has no CocoaPods extractor — it handles SwiftPM `Package.resolved` instead — and exits 127 on a file it cannot parse, which fails the whole scan rather than skipping that one file. iOS/macOS pods are therefore not covered.

Two modes:

- **Full scan** on `main` and weekly, with `fail-on-vuln: false` — an advisory in a transitive package is not a reason for `main` to go red, and the alert is mailed out regardless.
- **PR scan**, which compares against the base branch and reports only what the PR *newly* introduces. That one does fail, because it is a change someone is about to merge.

It complements Dependabot rather than duplicating it: Dependabot opens the upgrade PR, OSV-Scanner tells you what is exposed right now, including packages with no fix available yet.

### Publish Wiki

Copies `docs/*.md` into the wiki repository and removes wiki pages whose source file no longer exists, so renamed or deleted docs do not linger as orphans. Wiki page names are the file names without `.md` — `Database-Schema.md` becomes the *Database-Schema* page, which is why the in-repo links use that form.

## Flutter version

The version is pinned in `ci.yml` (`FLUTTER_VERSION`) and repeated in `release.yml` and `codeql.yml`. Raise all three together with the SDK, otherwise a release can be built with a different toolchain than the one CI verified.

## Dependabot

`.github/dependabot.yml` watches three ecosystems:

| Ecosystem | Directory | Schedule | Grouping |
|-----------|-----------|----------|----------|
| `github-actions` | `/` | weekly (Mon) | one PR for all actions |
| `pub` | `/` | weekly (Mon) | one PR for all minor/patch bumps; majors get their own |
| `gradle` | `/android` | monthly | one PR for minor/patch bumps |

Majors are deliberately left ungrouped — on a medical app they need a real look, and the pinned Flutter version means an SDK-coupled package can go out of step.

## Formatting

`dart format` is enforced. The whole tree was formatted in one commit so the check starts green; from there on, unformatted code fails CI with the list of offending files.

```bash
dart format .                         # fix everything
git ls-files -z '*.dart' | xargs -0 dart format   # only tracked files
```

Generated code (`lib/l10n/generated/`, `database.g.dart`) is already format-clean as produced by `gen-l10n` and `build_runner`, so the formatter and the generators do not fight each other.

## Linting

`flutter analyze` is the first linter. `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`, and CI runs the analyzer with `--fatal-infos`, so every lint in that set is a hard failure, not a suggestion. Adding a rule to `analysis_options.yaml` is all it takes to enforce it everywhere.

`tool/ui_lint.dart` is the second. It holds the rules that matter for this app's users — CIDP patients, often with reduced hand control and vision — and that the analyzer has no lint for:

| Rule | Fails on |
|---|---|
| `icon-button-tooltip` | an `IconButton` without `tooltip:` (what a screen reader announces) |
| `dead-handler` | `onPressed: () {}` and friends — a control that does nothing |
| `compact-icon-button` | `VisualDensity.compact`, which shrinks the 48 dp tap target |
| `tiny-font` | `fontSize` below 11 |
| `hardcoded-palette` | `Colors.grey/red/green/orange/blue` in the UI layer — they fail contrast in one of the two themes; use `colorScheme.*` or `AppStatusColors` |
| `hardcoded-text` | a string literal with letters in a user-visible slot (`Text('…')`, `label:`, `hintText:`, `tooltip:` …) instead of `context.l10n` |
| `date-format-literal` | a literal `DateFormat('…')` pattern instead of `AppDateFormat` |
| `deprecated-opacity`, `const-of-context`, `print` | the three classic analyzer blind spots from `AI_GUIDELINES.md` |

A line can opt out with a trailing `// ui-lint: allow <rule>` comment; say why in the same comment. `dart run tool/ui_lint.dart --explain` prints the rationale for every rule.

## UI test suites

`flutter test` includes three suites under `test/ui/` that render every screen listed in `test/support/page_catalog.dart` over an in-memory database seeded with one of everything:

- **`accessibility_test.dart`** — light and dark theme, against Flutter's own `androidTapTargetGuideline` (48 dp targets), `labeledTapTargetGuideline` (a label on every tappable node) and `textContrastGuideline` (WCAG AA on what is actually drawn).
- **`layout_robustness_test.dart`** — phone width in all five languages, a 320 dp phone, text scale 1.3, and a dark tablet; any `RenderFlex overflowed` or build exception fails, and the message names the widget and its `file:line`. The test font draws every glyph as a box as wide as the font size, so a layout that passes has margin in the real app.
- **`l10n_consistency_test.dart`** — the five ARB files against each other: placeholders, empty strings, orphan keys, ICU `other` branches, translations left identical to English (`gen-l10n` only reports keys that are missing outright).

A new page has to be added to the catalog or it is not checked.

## What is not covered

CodeQL has no Dart support, so the app's own Dart code gets no taint or data-flow analysis — the analyzer, the lints and the tests are what guard it. Dart *dependencies* are covered, by OSV-Scanner and Dependabot together; turning on Dependabot security updates under **Settings → Code security** adds automatic fix PRs on top.

## Recommended branch protection

Not configurable from the repository, so set it under **Settings → Branches → `main`**:

- require the **Analyze & test** and **Build Android (debug)** checks to pass
- require branches to be up to date before merging

Leave CodeQL out of the required checks — the weekly schedule and the longer Android build make it a poor merge gate; read its findings in the Security tab instead.
