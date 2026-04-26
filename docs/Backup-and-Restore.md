# Backup & Wiederherstellung

## Überblick

CIDPbuddy sichert die gesamte SQLite-Datenbank als ZIP-Datei. Backups werden automatisch nach Datenbankänderungen und periodisch im Hintergrund erstellt.

## Backup-Ziele

| Ziel | Plattform | Beschreibung |
|------|-----------|--------------|
| Lokal | Alle | App-interner Speicher (privates App-Verzeichnis) |
| SAF-Ordner | Android | Benutzerwählbarer Ordner via Storage Access Framework |
| Google Drive | Android, iOS | App-Data-Ordner (versteckt, nutzerspezifisch) |
| iCloud | iOS (geplant) | Reserviert, noch nicht implementiert |

## Backup-Ablauf

### Auto-Backup

```
DB-Änderung
  → debounce(30s)
  → letzte erfolgreiche Sicherung < 6 Stunden? → überspringen
  → ZIP der SQLite-Datei erstellen
  → an alle konfigurierten Ziele schreiben
  → 5 neueste behalten, ältere löschen
```

### Dateiname

```
igkeeper_backup_YYYY-MM-DD_HHmmss.zip
```

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
3. ZIP wird heruntergeladen und entpackt
4. Lokale DB-Datei wird ersetzt
5. `AppDatabase`-Singleton wird neu aufgebaut
6. App zeigt wiederhergestellte Daten

> **Wichtig:** Da `AppDatabase` ein Singleton ist, muss die Verbindung beim Restore kontrolliert neu aufgebaut werden, um Verbindungslecks zu vermeiden.

## SAF-Integration (Android)

Der SAF-Ordner wird vom Benutzer einmalig via System-Picker ausgewählt. Das persistierte URI wird in SharedPreferences gespeichert. `saf_util` und `saf_stream` übernehmen Lese- und Schreiboperationen auf persistierten Tree-URIs.

## Google Drive Integration

Backups landen im **App-Data-Ordner** von Google Drive (`appDataFolder`). Dieser Ordner ist:
- Für den Benutzer in der Drive-Oberfläche unsichtbar (aber in Einstellungen → Apps → Speicher einsehbar)
- Nur für diese App zugänglich (kein Zugriff durch andere Apps)
- Automatisch gelöscht, wenn die App deinstalliert wird

Für die Einrichtung des Google Cloud Projekts: siehe [Google-Drive-Einrichtung](Google-Drive-Setup).

### OAuth-Scope

```
https://www.googleapis.com/auth/drive.appdata
```

Dieser eingeschränkte Scope erlaubt nur den Zugriff auf den App-Data-Ordner — keine anderen Drive-Dateien des Benutzers.

### Token-Lebenszyklus

- `tryRestore()` beim App-Start: Stilles Token-Refresh ohne UI
- `signInAndAuthorize()`: Interaktiver Sign-In mit Scope-Bestätigung
- `authorizedClient()`: Gibt HTTP-Client mit automatisch erneutem Bearer-Token zurück
- Token-Management übernimmt vollständig `google_sign_in` — es werden keine Raw-Token gespeichert
