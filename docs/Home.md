# CIDPbuddy

CIDPbuddy ist eine Flutter-App zur Verwaltung von Infusionstherapien für Patienten mit **Chronisch Inflammatorischer Demyelinisierender Polyneuropathie (CIDP)**. Die App läuft auf Android, iOS, macOS, Windows, Linux und Web.

## Funktionen

- **Dashboard & Tagebuch** — Übersicht über anstehende Behandlungen, Symptomerfassung, Vitalwerte und Verlaufsstatistiken
- **Infusions-Timer** — Vormedikations-Timer mit Audio-Signalen (Glocke und Ping)
- **Behandlungsplanung** — Automatische 90-Tage-Planung aus wiederkehrenden Schedules (täglich, intervallbasiert, wöchentlich, Wochentage)
- **Inventar & Bestandsverwaltung** — Medikamente und Zubehör mit Mindestbestand-Warnungen, QR-Scan und OCR
- **Einkaufsassistent** — Berechnet automatisch den genauen Bestellbedarf auf Basis des Plans und des aktuellen Lagerbestands
- **Erinnerungen & Benachrichtigungen** — Lokale Alarme für Behandlungen, Vormedikation und Mindestbestand
- **Datensicherung** — ZIP-basiertes Backup auf lokalem Speicher, Android SAF-Ordner oder Google Drive (automatisch, alle 6 Stunden)

## Schnellstart

| Befehl | Zweck |
|--------|-------|
| `flutter pub get` | Abhängigkeiten installieren |
| `dart run build_runner build --delete-conflicting-outputs` | Drift-Datenbankcode neu generieren |
| `/opt/homebrew/bin/flutter analyze` | Lint prüfen (muss fehlerfrei sein) |
| `flutter run` | App starten |
| `flutter build apk --release --build-name=X.X.X --build-number=N` | Release-APK bauen |

## Wiki-Inhalte

- [Architektur](Architecture) — State Management, Hintergrundservices, Navigation, Theme
- [Datenbankschema](Database-Schema) — Alle Tabellen, Felder und Migrationen
- [Features](Features) — Detailbeschreibung der Feature-Module
- [Backup & Wiederherstellung](Backup-and-Restore) — Backup-System, Ziele, Auto-Backup-Logik
- [Google-Drive-Einrichtung](Google-Drive-Setup) — Schritt-für-Schritt-Anleitung für das GCP-Projekt
- [Bauen & Veröffentlichen](Building-and-Releasing) — Build-Befehle, Release-Prozess

## Technischer Stack

- **Flutter** ^3.11.4, Dart, Material 3
- **Drift ORM** (SQLite, reaktive Streams)
- **Provider** (State Management)
- **RxDart** (Stream-Komposition)
- **Google Sign-In + googleapis** (Drive-Backup)
- **WorkManager** (Hintergrundaufgaben, Android)
- **flutter_local_notifications** (Alarme)
- **audioplayers** (Timer-Audio)

## App-Identifikation

| Plattform | ID |
|-----------|-----|
| Android Package | `de.gbs-cidp.cidpbuddy` |
| iOS Bundle ID | `de.gbs-cidp.cidpbuddy` |
| Version | 1.0.0+1 |

## Lokalisierung & Theme

Die App ist **ausschließlich auf Deutsch** (`Locale('de', 'DE')`). Alle UI-Texte müssen auf Deutsch sein.

Primärfarben: Blau `#0066FF`, Smaragd `#00BFA6`, Gold `#FFB300`
