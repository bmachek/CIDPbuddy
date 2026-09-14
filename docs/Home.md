# CIDPbuddy

CIDPbuddy ist eine Flutter-App zur Verwaltung von Infusionstherapien für Patienten mit **Chronisch Inflammatorischer Demyelinisierender Polyneuropathie (CIDP)**. Die App läuft auf Android, iOS, macOS, Windows, Linux und Web.

## Funktionen

- **Dashboard & Tagebuch** — Übersicht über anstehende Behandlungen, Symptomerfassung, Vitalwerte und Verlaufsstatistiken
- **Infusions-Timer** — Vormedikations-Timer mit Audio-Signalen (Glocke und Ping)
- **Behandlungsplanung** — Automatische 90-Tage-Planung aus wiederkehrenden Schedules (täglich, intervallbasiert, wöchentlich, Wochentage)
- **Inventar & Bestandsverwaltung** — Medikamente und Zubehör mit Mindestbestand-Warnungen, QR-Scan und OCR
- **Einkaufsassistent** — Berechnet automatisch den genauen Bestellbedarf auf Basis des Plans und des aktuellen Lagerbestands
- **Erinnerungen & Benachrichtigungen** — Lokale Alarme für Behandlungen, Vormedikation und Mindestbestand
- **Datensicherung** — ZIP-basiertes Backup in einen lokalen Ordner oder einen per Android SAF gewählten Ordner (automatisch, frühestens alle 6 Stunden)

## Schnellstart

| Befehl | Zweck |
|--------|-------|
| `flutter pub get` | Abhängigkeiten installieren |
| `dart run build_runner build --delete-conflicting-outputs` | Drift-Datenbankcode neu generieren |
| `/opt/homebrew/bin/flutter analyze` | Lint prüfen (muss fehlerfrei sein) |
| `flutter run` | App starten |
| `flutter build apk --release --build-name=X.X.X --build-number=N` | Release-APK bauen |

## Wiki-Inhalte

- [Screenshots & Rundgang](Screenshots) — Geführter Bildschirm-Rundgang durch die App
- [Architektur](Architecture) — State Management, Hintergrundservices, Navigation, Theme
- [Datenbankschema](Database-Schema) — Alle Tabellen, Felder und Migrationen
- [Features](Features) — Detailbeschreibung der Feature-Module
- [Backup & Wiederherstellung](Backup-and-Restore) — Backup-System, Ziele, Auto-Backup-Logik
- [Bauen & Veröffentlichen](Building-and-Releasing) — Build-Befehle, Release-Prozess

## Technischer Stack

- **Flutter** / Dart SDK ^3.11.4, Material 3
- **Drift ORM** (SQLite, reaktive Streams)
- **Provider** (State Management)
- **RxDart** (Stream-Komposition)
- **saf_util + saf_stream** (Android Storage Access Framework als Backup-Ziel)
- **archive** (ZIP-Erzeugung für Backups)
- **WorkManager** (periodische Hintergrundaufgaben, Android)
- **flutter_background_service** (Vormedikations-Timer)
- **flutter_local_notifications** (Alarme)
- **audioplayers** (Timer-Audio)
- **fl_chart** (Verlaufscharts)
- **mobile_scanner + google_mlkit_text_recognition** (QR-Scan, OCR)

## App-Identifikation

| Plattform | ID |
|-----------|-----|
| Android Package | `de.fokuspunk.cidpbuddy` |
| iOS Bundle ID | `de.fokuspunk.cidpbuddy` |
| Version | `0.99.0-dev+17` (siehe `pubspec.yaml`; CI-Releases setzen Name/Nummer aus dem Git-Tag) |

## Lokalisierung & Theme

Die App ist **ausschließlich auf Deutsch** (`Locale('de', 'DE')`). Alle UI-Texte müssen auf Deutsch sein.

Primärfarben: Blau `#0066FF`, Smaragd `#00BFA6`, Gold `#FFB300`

Es gibt ein helles und ein dunkles Design (`AppTheme.lightTheme` / `AppTheme.darkTheme`). Die Umschaltung liegt in den Einstellungen unter „Erscheinungsbild".
