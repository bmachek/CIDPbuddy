# Bauen & Veröffentlichen

## Voraussetzungen

- Flutter SDK ^3.11.4 installiert und im PATH
- Android Studio / Xcode (je nach Zielplattform)
- Java 17 (für Android-Builds)
- macOS: Homebrew-Flutter unter `/opt/homebrew/bin/flutter`

## Entwicklungssetup

```bash
# Abhängigkeiten installieren
flutter pub get

# Drift-Datenbankcode generieren (nach Schema-Änderungen erforderlich)
dart run build_runner build --delete-conflicting-outputs

# Lint prüfen (muss fehlerfrei sein vor jedem Commit)
/opt/homebrew/bin/flutter analyze

# App im Debug-Modus starten
flutter run
```

## Datenbankcode neu generieren

Drift verwendet Code-Generierung. Nach **jeder Änderung** an Tabellendefinitionen oder Queries in `lib/core/database/` muss der Generator ausgeführt werden:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generierte Dateien enden auf `.g.dart` und sollten nicht manuell bearbeitet werden.

## Lint-Regeln

Die App folgt einer **Zero-Error-Policy**: `flutter analyze` darf keine Fehler ausgeben. Warnungen sollten ebenfalls behoben werden.

Wichtige Regeln:
- Kein `const Theme.of(context)` (kein konstanter Ausdruck)
- `color.withValues(alpha: 0.5)` statt `color.withOpacity(0.5)`
- `mounted`-Check nach jedem `async`-Gap in StatefulWidgets
- `BuildContext` als erstes Argument in StatelessWidget-Hilfsmethoden

## Android Release-APK bauen

```bash
flutter build apk --release \
  --build-name=1.0.0 \
  --build-number=1
```

Die APK liegt anschließend unter `build/app/outputs/flutter-apk/app-release.apk`.

### Signing konfigurieren

#### Lokaler Entwicklungsbuild

Für Release-Builds muss ein Keystore vorhanden sein. Einmalige Erstellung:

```bash
keytool -genkey -v \
  -keystore android/cidpbuddy-release.jks \
  -keyalg RSA -keysize 4096 -validity 10000 \
  -alias cidpbuddy
```

Dann `android/key.properties` anlegen (wird nicht ins Git eingecheckt):

```properties
storePassword=<passwort>
keyPassword=<passwort>
keyAlias=cidpbuddy
storeFile=../cidpbuddy-release.jks
```

Und `android/app/build.gradle.kts` anpassen — **Signing-Konfiguration hinzufügen** (aktuell fehlt das noch):

```kotlin
// Vor dem android { … }-Block:
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties().also {
    if (keystorePropertiesFile.exists()) it.load(keystorePropertiesFile.inputStream())
}

android {
    // …
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // … isMinifyEnabled, proguardFiles bleiben wie gehabt
        }
    }
}
```

#### CI/CD-Signing via GitHub Actions Secrets

Der Release-Workflow (`release.yml`) baut aktuell mit Debug-Keys — das muss für einen produktionsfähigen Build auf echte Keystore-Secrets umgestellt werden.

**Schritt 1 — Keystore als Base64-Secret hinterlegen:**

```bash
base64 -i android/cidpbuddy-release.jks | pbcopy   # macOS: kopiert in Clipboard
```

Unter **GitHub → Repository → Settings → Secrets → Actions** folgende Secrets anlegen:

| Secret-Name         | Inhalt                                  |
|---------------------|-----------------------------------------|
| `KEYSTORE_BASE64`   | Base64-kodierter Keystore (s. o.)       |
| `KEYSTORE_ALIAS`    | Key-Alias (z. B. `cidpbuddy`)           |
| `KEY_PASSWORD`      | Passwort des Schlüssels                 |
| `STORE_PASSWORD`    | Passwort des Keystores                  |

**Schritt 2 — `release.yml` erweitern:**

Den Build-APK-Step in `.github/workflows/release.yml` ersetzen durch:

```yaml
- name: Decode Keystore
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode \
      > android/cidpbuddy-release.jks

- name: Build APK
  env:
    KEY_ALIAS: ${{ secrets.KEYSTORE_ALIAS }}
    KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
    STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
    STORE_FILE: cidpbuddy-release.jks
  run: |
    cat > android/key.properties <<EOF
    keyAlias=$KEY_ALIAS
    keyPassword=$KEY_PASSWORD
    storePassword=$STORE_PASSWORD
    storeFile=../$STORE_FILE
    EOF
    flutter build apk --release \
      --build-name=${{ steps.get_version.outputs.build_name }} \
      --build-number=${{ steps.get_version.outputs.build_number }}
```

**Wichtig:** Den dekodierten Keystore und `key.properties` nicht cachen oder als Artefakt hochladen.

#### SHA-1-Fingerprint für Google Sign-In ermitteln

Google Sign-In auf Android funktioniert über Package-Name + SHA-1 des Signing-Zertifikats. Der Fingerprint des Release-Keystores muss in der **Google Cloud Console** unter dem Android-OAuth-Client registriert werden.

```bash
# SHA-1 des Release-Keystores ausgeben:
keytool -list -v \
  -keystore android/cidpbuddy-release.jks \
  -alias cidpbuddy \
  | grep "SHA1:"
```

Den ausgegebenen SHA-1 unter **Google Cloud Console → APIs & Dienste → Anmeldedaten → Android-OAuth-Client** eintragen. Solange nur Debug-Keys verwendet werden, funktioniert Google Sign-In im Release-APK nicht.

Siehe auch: [`docs/Google-Drive-Setup.md`](Google-Drive-Setup.md)

### ProGuard / R8

Release-Builds verwenden Minifizierung und Resource-Shrinking. ProGuard-Regeln liegen in `android/app/proguard-rules.pro`.

## App Bundle für Play Store

```bash
flutter build appbundle --release \
  --build-name=1.0.0 \
  --build-number=1
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## iOS-Build

### Lokal

```bash
flutter build ipa --release \
  --build-name=1.0.0 \
  --build-number=1 \
  --export-options-plist=ios/ExportOptions.plist
```

Output: `build/ios/ipa/CIDPbuddy.ipa`

Anschließend entweder manuell via Xcode Organizer in den App Store hochladen oder mit `xcrun altool` (siehe CI/CD-Abschnitt unten).

### CI/CD via GitHub Actions

Der Release-Workflow (`.github/workflows/release.yml`) enthält einen parallelen `ios-build`-Job der automatisch bei jedem `v*`-Tag ausgeführt wird.

#### Benötigte GitHub Secrets

| Secret | Inhalt |
|--------|--------|
| `IOS_CERTIFICATE_P12` | Base64-kodiertes Distribution Certificate (`.p12`) |
| `IOS_CERTIFICATE_PASSWORD` | Passwort des `.p12`-Exports |
| `IOS_PROVISIONING_PROFILE` | Base64-kodiertes App Store Provisioning Profile (`.mobileprovision`) |
| `APPLE_TEAM_ID` | 10-stellige Apple Team ID (z.B. `ABCDE12345`) |
| `APP_STORE_CONNECT_API_KEY_ID` | *(optional)* Key ID für TestFlight-Upload |
| `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | *(optional)* Issuer ID für TestFlight-Upload |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | *(optional)* Base64-kodierter `.p8`-Private-Key |

Sind die drei `APP_STORE_CONNECT_*`-Secrets nicht gesetzt, wird der TestFlight-Upload übersprungen — die IPA wird trotzdem als GitHub-Release-Artefakt angehängt.

#### Zertifikat & Profil vorbereiten

**Distribution Certificate exportieren:**
1. Xcode → Settings → Accounts → Team auswählen → Manage Certificates
2. Apple Distribution Certificate → Rechtsklick → Export Certificate → als `.p12` speichern
3. Als Base64 enkodieren:
   ```bash
   base64 -i certificate.p12 | pbcopy   # kopiert direkt ins Clipboard
   ```

**Provisioning Profile herunterladen:**
1. [developer.apple.com](https://developer.apple.com/account) → Profiles → App Store-Profil für `de.gbs-cidp.cidpbuddy` erstellen/herunterladen
2. Als Base64 enkodieren:
   ```bash
   base64 -i profile.mobileprovision | pbcopy
   ```

**App Store Connect API Key:**
1. [App Store Connect](https://appstoreconnect.apple.com) → Benutzer & Zugriff → Integrations → App Store Connect API
2. Neuen Key erstellen (Rolle: App Manager)
3. Key ID und Issuer ID notieren, `.p8`-Datei herunterladen
4. `.p8` als Base64:
   ```bash
   base64 -i AuthKey_XXXXX.p8 | pbcopy
   ```

#### Team ID ermitteln

```bash
# Aus installiertem Provisioning Profile:
security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision \
  | plutil -extract TeamIdentifier.0 raw -
```

Oder in Xcode: Runner-Target → Signing & Capabilities → Team.

## Schemaversion erhöhen

Bei DB-Schemaänderungen:

1. Neue Tabellenfelder/-tabellen in `lib/core/database/tables/` definieren
2. Schemaversion in `@DriftDatabase` erhöhen
3. `onUpgrade`-Schritt in `lib/core/database/app_database.dart` hinzufügen
4. Code neu generieren:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. `flutter analyze` prüfen

## Abhängigkeiten aktualisieren

```bash
flutter pub upgrade
flutter pub get
dart run build_runner build --delete-conflicting-outputs
/opt/homebrew/bin/flutter analyze
```

## App-Version und Build-Nummer

Version und Build-Nummer werden in `pubspec.yaml` gepflegt:

```yaml
version: 1.0.0+1
#        ↑       ↑
#        |       Build-Nummer (versionCode auf Android)
#        Semantic version (versionName auf Android)
```

Beim Build-Befehl können sie überschrieben werden:

```bash
flutter build apk --build-name=1.2.3 --build-number=42
```

## Plattform-spezifische Konfiguration

| Datei | Inhalt |
|-------|--------|
| `android/app/build.gradle.kts` | App-ID, Min-SDK, Java-Version, Desugaring |
| `android/app/src/main/AndroidManifest.xml` | Berechtigungen, Intent-Filter, Background-Service |
| `ios/Runner/Info.plist` | Bundle-ID, Background-Modes, URL-Schemes (OAuth) |
| `pubspec.yaml` | Version, Abhängigkeiten, Assets |

## Assets

Audio-Dateien für den Vormedikations-Timer:

```
assets/
  audio/
    bell.mp3   # Minütliches Glockensignal
    ping.mp3   # Abschlusssignal
```

Assets müssen in `pubspec.yaml` unter `flutter.assets` deklariert sein.
