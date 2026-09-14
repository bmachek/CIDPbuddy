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
5. `flutter analyze --fatal-infos` — zero errors *and* zero infos
6. `flutter test`

Sub-command output is captured and only printed when a step fails, so the summary stays short.

`tool/verify.sh --check-generated` additionally fails when the regenerated Drift or l10n code differs from what is committed. CI always passes that flag (it is implied whenever `$CI` is `true`); locally it is off by default, because mid-change the generated files legitimately differ from HEAD.

If `flutter` is not on your `PATH`, the script falls back to `/opt/homebrew/bin/flutter`; `FLUTTER_BIN=/path/to/flutter tool/verify.sh` overrides both.

## Workflows

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| **CI** (`ci.yml`) | push to `main`, every PR, manual, and called by Release | `tool/verify.sh --check-generated`, then a debug APK build |
| **Release** (`release.yml`) | `v*` tags | Runs CI first, then builds and publishes the signed release APK |
| **CodeQL** (`codeql.yml`) | push to `main`, PRs, weekly (Mon 05:17 UTC), manual | Static security analysis of the workflows and the Android sources |
| **Publish Wiki** (`publish-wiki.yml`) | push to `main` touching `docs/**` | Mirrors `docs/*.md` into this wiki |

### CI

Two jobs. `verify` runs the script above. `build-android` then compiles a debug APK — the analyzer does not exercise the Gradle/Kotlin side, and a release build has broken on exactly that before (tag `v1.8.1`). CI is also a reusable workflow (`workflow_call`) with a `build-android` input, which is how Release reuses it without building the app twice.

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

The repository is **not** `dart format`-clean, and CI deliberately does not check formatting. Reformatting the tree would rewrite 33 of 47 files and bury real changes in diff noise. Format what you touch if you like; do not reformat files you are not otherwise changing.

## Recommended branch protection

Not configurable from the repository, so set it under **Settings → Branches → `main`**:

- require the **Analyze & test** and **Build Android (debug)** checks to pass
- require branches to be up to date before merging

Leave CodeQL out of the required checks — the weekly schedule and the longer Android build make it a poor merge gate; read its findings in the Security tab instead.
