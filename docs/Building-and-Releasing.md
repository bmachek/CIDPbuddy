# Building & releasing

> The automated side of this — what runs on every push, PR and tag — is described in [Continuous integration](Continuous-Integration).

## Prerequisites

- Flutter SDK with Dart ^3.11.4 installed and on the PATH
- Android Studio / Xcode (depending on the target platform)
- Java 21 (for Android builds — the same version CI uses)
- macOS: Homebrew Flutter at `/opt/homebrew/bin/flutter`

## Development setup

```bash
# Install dependencies
flutter pub get

# Generate the Drift database code (required after schema changes)
dart run build_runner build --delete-conflicting-outputs

# Generate the localizations (required after editing the ARB files)
flutter gen-l10n

# Everything CI checks: generated code, translations, lint, tests
tool/verify.sh

# Lint only (must be error-free before every commit)
/opt/homebrew/bin/flutter analyze

# Run the app in debug mode
flutter run
```

## Regenerating the database code

Drift uses code generation. After **every change** to table definitions or queries in `lib/core/database/`, run the generator:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated files end in `.g.dart` and should not be edited by hand.

## Regenerating the localizations

`pubspec.yaml` sets `flutter: generate: true`, so `flutter run` and `flutter build` regenerate the localizations automatically from `lib/l10n/*.arb`. To run it on its own:

```bash
flutter gen-l10n
```

The output lands in `lib/l10n/generated/` and is committed, so the analyzer works on a fresh clone without a build step. See [Localization](Localization) for the full workflow.

## Lint rules

The app follows a **zero-error policy**: `flutter analyze` must report no errors. Warnings should be fixed too.

Key rules:
- No `const Theme.of(context)` (it is not a constant expression)
- `color.withValues(alpha: 0.5)` instead of `color.withOpacity(0.5)`
- Check `mounted` after every `async` gap in StatefulWidgets
- Pass `BuildContext` as the first argument to StatelessWidget helper methods
- No user-visible string literals in Dart — route them through `context.l10n`

## Building an Android release APK

```bash
flutter build apk --release \
  --build-name=1.0.0 \
  --build-number=1
```

The APK then sits at `build/app/outputs/flutter-apk/app-release.apk`.

> Without `--build-name`/`--build-number` the version from `pubspec.yaml` applies — it
> deliberately carries the `-dev` suffix so local builds are distinguishable from CI releases.

### Configuring signing

#### Local development build

Release builds need a keystore. Create one once:

```bash
keytool -genkey -v \
  -keystore android/cidpbuddy-release.jks \
  -keyalg RSA -keysize 4096 -validity 10000 \
  -alias cidpbuddy
```

Then create `android/key.properties` (it is not checked into git):

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=cidpbuddy
storeFile=../cidpbuddy-release.jks
```

That is all: `android/app/build.gradle.kts` already reads `key.properties` and picks the signing config automatically:

```kotlin
// android/app/build.gradle.kts
signingConfigs {
    create("release") {
        if (keystorePropertiesFile.exists()) {
            keyAlias = keystoreProperties["keyAlias"] as String
            // … keyPassword, storeFile, storePassword
        }
    }
}

buildTypes {
    release {
        signingConfig = if (keystorePropertiesFile.exists())
            signingConfigs.getByName("release")
        else
            signingConfigs.getByName("debug")
        // …
    }
}
```

**If `key.properties` is missing, the release build silently falls back to the debug key.**
An APK signed that way cannot be uploaded to the Play Store and cannot be installed over an
update previously signed with the release key. When in doubt, check:

```bash
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

#### CI/CD signing via GitHub Actions secrets

The `android-build` job in `.github/workflows/release.yml` decodes the keystore from repository
secrets, writes `android/key.properties` and builds with `requireReleaseSigning` set, so Gradle
refuses to fall back to the debug key. **Without the secrets below the release job fails on
purpose** — a debug-signed release carries a different key every time and cannot be installed
over the previous one, which forces users to uninstall and lose their local database. After the
build, the job also checks the APK's certificate and fails if it is the debug one.

**Store the keystore as a base64 secret:**

```bash
base64 -i android/cidpbuddy-release.jks | pbcopy   # macOS: copies to the clipboard
```

Under **GitHub → Repository → Settings → Secrets → Actions**, create these secrets:

| Secret name         | Contents                                |
|---------------------|-----------------------------------------|
| `KEYSTORE_BASE64`   | Base64-encoded keystore (see above)     |
| `KEYSTORE_ALIAS`    | Key alias (e.g. `cidpbuddy`)            |
| `KEY_PASSWORD`      | Password of the key                     |
| `STORE_PASSWORD`    | Password of the keystore                |

The workflow writes `android/key.properties` from these secrets itself (see the
"Configure release signing" step). Keep using the **same** keystore for every release: an APK
signed with a different key is rejected by Android as an update.

**Important:** never commit the keystore or `key.properties` (both are git-ignored), do not cache
the decoded keystore, and do not upload it as an artefact.

### ProGuard / R8

Release builds use minification and resource shrinking. ProGuard rules live in `android/app/proguard-rules.pro`.

## App bundle for the Play Store

```bash
flutter build appbundle --release \
  --build-name=1.0.0 \
  --build-number=1
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## iOS build

### Local

```bash
flutter build ipa --release \
  --build-name=1.0.0 \
  --build-number=1 \
  --export-options-plist=ios/ExportOptions.plist
```

Output: `build/ios/ipa/CIDPbuddy.ipa`

Then upload to the App Store either manually via Xcode Organizer or with `xcrun altool` (see the CI/CD section below).

### CI/CD via GitHub Actions

The release workflow (`.github/workflows/release.yml`) contains a parallel `ios-build` job that runs automatically on every `v*` tag.

#### Required GitHub secrets

| Secret | Contents |
|--------|----------|
| `IOS_CERTIFICATE_P12` | Base64-encoded distribution certificate (`.p12`) |
| `IOS_CERTIFICATE_PASSWORD` | Password of the `.p12` export |
| `IOS_PROVISIONING_PROFILE` | Base64-encoded App Store provisioning profile (`.mobileprovision`) |
| `APPLE_TEAM_ID` | 10-character Apple Team ID (e.g. `ABCDE12345`) |
| `APP_STORE_CONNECT_API_KEY_ID` | *(optional)* Key ID for the TestFlight upload |
| `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | *(optional)* Issuer ID for the TestFlight upload |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | *(optional)* Base64-encoded `.p8` private key |

If the three `APP_STORE_CONNECT_*` secrets are unset, the TestFlight upload is skipped — the IPA is still attached as a GitHub release artefact.

#### Preparing the certificate & profile

**Export the distribution certificate:**
1. Xcode → Settings → Accounts → select the team → Manage Certificates
2. Apple Distribution Certificate → right-click → Export Certificate → save as `.p12`
3. Encode as base64:
   ```bash
   base64 -i certificate.p12 | pbcopy   # copies straight to the clipboard
   ```

**Download the provisioning profile:**
1. [developer.apple.com](https://developer.apple.com/account) → Profiles → create/download an App Store profile for `de.fokuspunk.cidpbuddy`
2. Encode as base64:
   ```bash
   base64 -i profile.mobileprovision | pbcopy
   ```

**App Store Connect API key:**
1. [App Store Connect](https://appstoreconnect.apple.com) → Users and Access → Integrations → App Store Connect API
2. Create a new key (role: App Manager)
3. Note the Key ID and Issuer ID, download the `.p8` file
4. Encode the `.p8` as base64:
   ```bash
   base64 -i AuthKey_XXXXX.p8 | pbcopy
   ```

#### Finding the Team ID

```bash
# From an installed provisioning profile:
security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision \
  | plutil -extract TeamIdentifier.0 raw -
```

Or in Xcode: Runner target → Signing & Capabilities → Team.

## Raising the schema version

For DB schema changes:

1. Define the new fields/tables in `lib/core/database/database.dart` (add new tables to the `@DriftDatabase(tables: [...])` list as well)
2. Raise the `schemaVersion` getter in `AppDatabase` (currently **14**)
3. Add an `onUpgrade` step in `lib/core/database/database.dart`
4. Regenerate the code:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. Check with `flutter analyze`

## Updating dependencies

```bash
flutter pub upgrade
flutter pub get
dart run build_runner build --delete-conflicting-outputs
/opt/homebrew/bin/flutter analyze
```

## App version and build number

Version and build number are maintained in `pubspec.yaml`:

```yaml
version: 0.99.0-dev+17
#        ↑           ↑
#        |           Build number (versionCode on Android)
#        Semantic version (versionName on Android)
```

The `-dev` suffix is deliberate: local/manual builds should be visibly distinguishable from CI
release builds. The release workflow overwrites both with values from the `v*` git tag anyway.

They can be overridden on the build command:

```bash
flutter build apk --build-name=1.2.3 --build-number=42
```

## Platform-specific configuration

| File | Contents |
|------|----------|
| `android/app/build.gradle.kts` | App ID, min SDK, Java version, desugaring |
| `android/app/src/main/AndroidManifest.xml` | Permissions, intent filters, background service |
| `ios/Runner/Info.plist` | Bundle ID, background modes (`fetch`), camera permission text |
| `l10n.yaml` | Localization generator settings (ARB directory, template, output) |
| `pubspec.yaml` | Version, dependencies, assets |

## Assets

Audio files for the premedication timer:

```
assets/
  audio/
    bell.mp3   # Per-minute bell signal
    ping.mp3   # Completion signal
```

Assets must be declared in `pubspec.yaml` under `flutter.assets`.

## Store listings

The app is licensed under **Apache-2.0**, which is compatible with distribution through both the
Apple App Store and Google Play. (It was previously GPL-3.0; the App Store's terms of service
impose usage restrictions that are incompatible with that licence.) See [LICENSE](../LICENSE)
and [NOTICE](../NOTICE).

Store listings should be provided in all five shipped languages — English, German, French,
Italian and Spanish — so the listing language matches what the user sees after install.
