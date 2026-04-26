# Google Drive Backup – GCP-Projekt einrichten

Diese Anleitung beschreibt, wie das Google Cloud Project (GCP) für die Google-Drive-Backup-Funktion konfiguriert wird. Die Funktion nutzt OAuth 2.0 und speichert Backups im privaten App-Data-Ordner des Benutzers.

## Voraussetzungen

- Google-Account mit Zugriff auf die [Google Cloud Console](https://console.cloud.google.com)
- Zugriff auf den Quellcode der App (für iOS-Konfiguration)
- Android: SHA-1-Fingerabdruck des Signing-Zertifikats

---

## Schritt 1: GCP-Projekt erstellen

1. [Google Cloud Console](https://console.cloud.google.com) öffnen
2. Oben auf **Projekt auswählen** → **Neues Projekt** klicken
3. Name eingeben (z.B. `CIDPbuddy`) und erstellen
4. Das neue Projekt im Dropdown oben auswählen

---

## Schritt 2: Google Drive API aktivieren

1. Im linken Menü: **APIs & Dienste → Bibliothek**
2. Nach **Google Drive API** suchen
3. Auf **Aktivieren** klicken

---

## Schritt 3: OAuth-Zustimmungsbildschirm konfigurieren

1. **APIs & Dienste → OAuth-Zustimmungsbildschirm**
2. Benutzertyp **Extern** auswählen → **Erstellen**
3. Pflichtfelder ausfüllen:
   - **App-Name:** `CIDPbuddy`
   - **Support-E-Mail:** eigene E-Mail-Adresse
   - **E-Mail-Adresse des Entwicklers:** eigene E-Mail-Adresse
4. **Speichern und fortfahren**

### Scopes hinzufügen

5. Auf **Bereiche hinzufügen oder entfernen** klicken
6. In das Suchfeld eingeben: `drive.appdata`
7. Den Scope **`https://www.googleapis.com/auth/drive.appdata`** auswählen → **Aktualisieren**
8. **Speichern und fortfahren**

> **Warum `drive.appdata`?** Dieser eingeschränkte Scope erlaubt nur den Zugriff auf den App-eigenen versteckten Ordner. Die App kann keine anderen Drive-Dateien des Benutzers sehen oder ändern.

### Testnutzer hinzufügen

Solange die App nicht veröffentlicht ist, können nur explizit gelistete Testnutzer den OAuth-Flow durchlaufen.

9. **Testnutzer → Nutzer hinzufügen**
10. Google-Konten der Tester eintragen (z.B. eigene E-Mail)
11. **Speichern und fortfahren**

---

## Schritt 4: OAuth-Client-IDs erstellen

### Android

1. **APIs & Dienste → Anmeldedaten → Anmeldedaten erstellen → OAuth-Client-ID**
2. Anwendungstyp: **Android**
3. Felder ausfüllen:
   - **Name:** z.B. `CIDPbuddy Android`
   - **Paketname:** `de.gbs-cidp.cidpbuddy`
   - **SHA-1-Zertifikatsfingerabdruck:** (siehe unten)
4. **Erstellen**

> **Kein Code-Änderung nötig:** Android-Apps registrieren sich automatisch anhand von Paketname + SHA-1. Es muss kein `clientId` in den Code eingetragen werden.

#### SHA-1-Fingerabdruck ermitteln

**Debug-Keystore (Entwicklung):**
```bash
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android
```

**Release-Keystore (Produktion):**
```bash
keytool -list -v \
  -keystore /pfad/zum/release.keystore \
  -alias <alias-name>
```

Den ausgegebenen **SHA1**-Wert in das GCP-Formular eintragen.

> **Wichtig:** Für Debug- und Release-Builds jeweils eine eigene OAuth-Client-ID anlegen, da die SHA-1-Fingerabdrücke unterschiedlich sind.

---

### iOS

1. **APIs & Dienste → Anmeldedaten → Anmeldedaten erstellen → OAuth-Client-ID**
2. Anwendungstyp: **iOS**
3. Felder ausfüllen:
   - **Name:** z.B. `CIDPbuddy iOS`
   - **Bundle-ID:** `de.gbs-cidp.cidpbuddy`
4. **Erstellen**
5. Die erzeugte **Client-ID** kopieren (Format: `XXXXXX.apps.googleusercontent.com`)

#### App-Code konfigurieren

Die iOS-Client-ID in `lib/features/settings/services/google_drive/google_drive_config.dart` eintragen:

```dart
static const String? iosClientId =
    'XXXXXX.apps.googleusercontent.com'; // Hier eintragen
```

#### Info.plist URL-Schema eintragen

Die **umgekehrte Client-ID** (reversed client ID) muss als URL-Schema in `ios/Runner/Info.plist` hinterlegt werden, damit der OAuth-Redirect nach dem Sign-In funktioniert.

Die umgekehrte Client-ID ergibt sich, indem die Client-ID umgekehrt wird:

| Client-ID | Reversed Client-ID (URL-Schema) |
|-----------|--------------------------------|
| `123456-abc.apps.googleusercontent.com` | `com.googleusercontent.apps.123456-abc` |

In `ios/Runner/Info.plist` einfügen:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.XXXXXX-abc</string>
    </array>
  </dict>
</array>
```

> Den Platzhalter `com.googleusercontent.apps.XXXXXX-abc` durch die tatsächliche reversed Client-ID ersetzen.

---

## Schritt 5: Integration testen

1. App auf einem Gerät oder Emulator starten
2. **Einstellungen → Backup-Ziel hinzufügen → Google Drive**
3. Mit einem der konfigurierten Testnutzer anmelden
4. Manuellen Backup-Test durchführen
5. Erfolg prüfen: **Zuverlässigkeitscheck** zeigt letzten erfolgreichen Backup-Zeitpunkt

### Fehlerbehebung

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| `sign_in_failed` (Android) | SHA-1 stimmt nicht überein | SHA-1 des aktuell verwendeten Keystores mit GCP vergleichen |
| `access_denied` | Testnutzer nicht eingetragen | Google-Konto unter „Testnutzer" im GCP-Projekt hinzufügen |
| `invalid_client` (iOS) | Client-ID oder URL-Schema falsch | `iosClientId` und `Info.plist`-Eintrag prüfen |
| `scope_not_authorized` | Drive-Scope nicht akzeptiert | Scope-Bestätigungs-Dialog beim nächsten Sign-In erneut zeigen |

---

## App veröffentlichen (Produktion)

Sobald die App im Play Store / App Store veröffentlicht werden soll:

1. In der GCP-Console: **OAuth-Zustimmungsbildschirm → Veröffentlichen**
2. Für Produktions-Apps mit sensiblen Scopes: Google führt ggf. eine Sicherheitsprüfung durch
3. `drive.appdata` gilt als **nicht-sensitiv** und benötigt in der Regel keine Prüfung

---

## Zusammenfassung: Wo was konfiguriert wird

| Konfiguration | Ort |
|---------------|-----|
| GCP-Projekt, API, OAuth-Screen | Google Cloud Console |
| Android Client-ID (Paketname + SHA-1) | GCP Console, kein Code-Change |
| iOS Client-ID | `google_drive_config.dart` → `iosClientId` |
| iOS URL-Schema (Redirect) | `ios/Runner/Info.plist` → `CFBundleURLSchemes` |
| OAuth-Scope | Fest kodiert: `drive.appdata` |
| Backup-Ziel-Konto | Gespeichert in SharedPreferences durch die App |
