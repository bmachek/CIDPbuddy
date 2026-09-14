# Backup & Wiederherstellung

## Überblick

CIDPbuddy sichert die gesamte SQLite-Datenbank als ZIP-Datei. Backups werden automatisch nach Datenbankänderungen und periodisch im Hintergrund erstellt.

## Backup-Ziele

Es ist immer **genau ein** Ziel aktiv; es wird in `SharedPreferences` hinterlegt und beim
Backup über `BackupDestination.load()` geladen.

| Ziel | `DestinationKind` | Plattform | Beschreibung |
|------|-------------------|-----------|--------------|
| Ordner | `local` | Alle | Ein Verzeichnis im Dateisystem. Auf iOS immer der app-interne `Documents/Backups`-Ordner (kein Ordner-Picker verfügbar) |
| SAF-Ordner | `saf` | Android | Ein per Storage Access Framework gewählter Ordner, z. B. auf der SD-Karte oder in einem Cloud-Provider |

> Ein Cloud-Backup direkt in Google Drive oder iCloud gibt es **nicht**. Wer in die Cloud
> sichern will, wählt unter Android per SAF einen Ordner, den ein Cloud-Client synchronisiert.

**iOS-Hinweis:** Das app-interne Ziel überlebt die App nicht (`isDurable == false`) — iOS
löscht den Container mit der App. Außerdem vergibt iOS die Container-UUID bei *jedem*
App-Update neu, weshalb statt eines absoluten Pfads der portable Marker
`app-documents:Backups` persistiert und bei jedem Laden gegen den aktuellen Container
aufgelöst wird.

## Backup-Ablauf

### Auto-Backup

```
DB-Änderung
  → debounce(30s)
  → Auto-Backup deaktiviert? → abbrechen
  → letzte erfolgreiche Sicherung < 6 Stunden? → überspringen
  → verifyAccess() auf dem Ziel (Token-Datei schreiben/lesen/löschen)
  → ZIP der SQLite-Datei erstellen
  → ins konfigurierte Ziel schreiben
  → 5 neueste behalten, ältere löschen
```

### Dateiname

```
cidpbuddy_backup_YYYYMMDD_HHmmss.zip
```

> Hinweis: Beim Auflisten/Wiederherstellen wird zusätzlich das alte Präfix `igkeeper_backup_` als Fallback erkannt.

### Hintergrund-Backup (Android)

WorkManager führt periodisch `BackupWorker` aus. Der Worker übersteht Geräteneustarts (wird bei Boot neu registriert).

## Fehlerverwaltung

| Einstellung | Wert |
|-------------|------|
| Fehlerschwelle | 2 aufeinanderfolgende Fehler |
| Fehlerspeicherung | SharedPreferences: `backup_last_error`, `backup_consecutive_failures` |
| Benachrichtigung | Nach Erreichen der Fehlerschwelle |

Die Seite **Zuverlässigkeitscheck** (`reliability_check_page.dart`) zeigt:
- Backup-Status (aktiviert/deaktiviert)
- Letzter erfolgreicher Zeitpunkt
- Letzte Fehlermeldung
- Anzahl aufeinanderfolgender Fehler

## Wiederherstellung

1. Einstellungen → Backup-Ziel auswählen → Backups anzeigen
2. Backup aus der Liste auswählen → Wiederherstellen
3. ZIP wird gelesen und entpackt
4. Lokale DB-Datei (`igkeeper.sqlite`) wird ersetzt — inklusive der WAL-/SHM-Seitendateien, falls im Archiv enthalten
5. `AppDatabase`-Singleton wird neu aufgebaut
6. App zeigt wiederhergestellte Daten

> **Wichtig:** Da `AppDatabase` ein Singleton ist, muss die Verbindung beim Restore kontrolliert neu aufgebaut werden, um Verbindungslecks zu vermeiden.

