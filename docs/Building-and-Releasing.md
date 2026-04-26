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

Für Release-Builds muss ein Keystore konfiguriert sein. In `android/key.properties` (nicht im Git):

```properties
storePassword=<passwort>
keyPassword=<passwort>
keyAlias=<alias>
storeFile=<pfad-zum-keystore>
```

In `android/app/build.gradle.kts` ist bereits der Verweis auf `key.properties` vorbereitet.

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

```bash
flutter build ios --release
```

Anschließend in Xcode archivieren und via Xcode Organizer in den App Store hochladen.

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
