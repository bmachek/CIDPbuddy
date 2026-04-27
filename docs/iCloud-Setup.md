# iCloud Drive Backup – Einrichtung

Diese Anleitung beschreibt die einmaligen Schritte, um das iCloud-Backup in der App zu aktivieren. Im Gegensatz zum Google-Drive-Backup ist kein OAuth-Flow und kein externer Cloud-Account nötig — iCloud nutzt automatisch die Apple ID des Geräts.

## Voraussetzungen

- Xcode (aktuell, mit iOS-SDK)
- Apple Developer Account (kostenpflichtig, für Entitlements auf echtem Gerät erforderlich)
- Gerät mit aktiviertem iCloud-Account (Simulator unterstützt kein iCloud)

---

## Schritt 1: iCloud-Capability in Xcode aktivieren

1. `ios/Runner.xcworkspace` in Xcode öffnen
2. Im Projektnavigator das **Runner**-Target auswählen
3. Tab **Signing & Capabilities** öffnen
4. **+ Capability** klicken und **iCloud** hinzufügen
5. Im iCloud-Capability-Block **nur „iCloud Documents"** ankreuzen (kein CloudKit)
6. Container hinzufügen: **`iCloud.de.gbs-cidp.cidpbuddy`**

> Xcode trägt die Entitlements automatisch in die Datei `ios/Runner/Runner.entitlements` ein und aktualisiert `Runner.xcodeproj`. Diese Datei liegt bereits im Repository — Xcode wird sie beim Öffnen erkennen.

---

## Schritt 2: Apple Developer Console prüfen

Xcode registriert den iCloud-Container automatisch im Apple Developer Portal (Certificates, Identifiers & Profiles), falls du mit dem richtigen Team angemeldet bist.

Zur manuellen Kontrolle:
1. [developer.apple.com/account](https://developer.apple.com/account) → **Identifiers**
2. App-ID `de.gbs-cidp.cidpbuddy` auswählen
3. Unter **Capabilities**: **iCloud** muss aktiviert sein, Container `iCloud.de.gbs-cidp.cidpbuddy` muss gelistet sein

---

## Schritt 3: Auf echtem Gerät testen

> Der iOS-Simulator unterstützt kein iCloud — Tests zwingend auf echtem Gerät.

1. App auf Gerät bauen (`flutter run` oder Xcode)
2. **Einstellungen → Backup-Ziel → iCloud Drive** wählen
3. „Backup-Ziel verbunden" erscheint, wenn `verifyAccess()` erfolgreich ist
4. **„Backup jetzt testen"** ausführen
5. In der **Files.app** → **iCloud Drive** → **CIDP Buddy** prüfen, ob die `.zip`-Datei erscheint
6. **Sicherung wiederherstellen**: ZIP im Restore-Dialog auswählen und Wiederherstellung bestätigen

---

## Technische Details

### Container

| Schlüssel | Wert |
|---|---|
| Container-ID | `iCloud.de.gbs-cidp.cidpbuddy` |
| Sichtbarkeit | Files.app → iCloud Drive → CIDP Buddy |
| Dateiformat | `igkeeper_backup_YYYYMMDD_HHmmss.zip` |
| Aufbewahrung | 5 neueste Backups (ältere werden automatisch gelöscht) |

### Datei-Transfer-Verhalten

Das `icloud_storage`-Plugin schreibt Dateien in den lokalen Ubiquity-Container. Der Sync zu Apples iCloud-Servern übernimmt das Betriebssystem asynchron:

- **Upload:** Future resolved, sobald die Datei lokal im Container liegt. iCloud-Sync erfolgt im Hintergrund.
- **Download/Restore:** Die App wartet aktiv auf `onDone` des Progress-Streams (Timeout: 2 Minuten).

### Hintergrund-Backup

Periodische Hintergrundaufgaben laufen auf iOS **nicht** über WorkManager (Android-only). Automatische Backups werden ausgelöst durch:
- Datenbankänderungen (Debounce 30 s, nur wenn App im Vordergrund)
- Manuellen Trigger aus den Einstellungen

Ein echter iOS-Hintergrund-Scheduler (via `BGTaskScheduler`) ist aktuell nicht implementiert.

### Relevante Dateien

| Datei | Zweck |
|---|---|
| `lib/features/settings/services/cloud/icloud_destination.dart` | Implementierung aller Backup-Operationen |
| `lib/features/settings/services/backup_service.dart` | `pickICloudBackup()` |
| `lib/features/settings/pages/settings_page.dart` | UI-Integration |
| `ios/Runner/Runner.entitlements` | iCloud-Entitlements |

---

## Fehlerbehebung

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| `verifyAccess()` schlägt fehl | iCloud am Gerät nicht angemeldet oder deaktiviert | iOS Einstellungen → Apple ID → iCloud → CIDP Buddy aktivieren |
| Capability-Fehler beim Build | Entitlement nicht in Developer Console registriert | Schritt 2 wiederholen; in Xcode „Automatically manage signing" aktivieren |
| Datei erscheint nicht in Files.app | iCloud-Sync noch ausstehend | Gerät mit WLAN verbinden und kurz warten |
| Simulator-Fehler | iCloud auf Simulator nicht unterstützt | Auf echtem Gerät testen |
