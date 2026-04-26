# Features

## Dashboard (`lib/features/diary/pages/dashboard_page.dart`)

Das Dashboard ist der Einstiegspunkt der App und zeigt auf einen Blick:

- **Nächste Behandlungen** — Termine der nächsten Tage aus dem 90-Tage-Plan
- **Vormedikations-Timer** — Startet einen Countdown mit Audio-Alarmen; Foreground-Notification mit Live-Anzeige
- **Mindestbestand-Warnungen** — Farbcodierte Liste aller Medikamente und Zubehör unter Schwellenwert
- **Kurzstatistiken** — Letzte Infusion, nächste geplante Infusion, aktuelle Lagerreichweite

### Vormedikations-Timer

Der Timer (`premedication_timer_modal.dart`) läuft über den `BackgroundService` und übersteht App-Minimierungen:

- Jede Minute: 3 × `bell.mp3`
- Bei Ablauf: `ping.mp3`
- Foreground-Notification zeigt verbleibende Zeit in Echtzeit

---

## Tagebuch (`lib/features/diary/pages/diary_page.dart`)

Chronologische Timeline aller Ereignisse:

- Abgeschlossene Infusionen (aus `InfusionLog`)
- Tagebucheinträge (aus `DiaryEntries`)
- Geplante Termine (aus `PlannedInfusions`)
- Ausstehende Bestellungen (aus `PendingOrders`)

Die kombinierten Stream werden via `RxDart.combineLatest4` zusammengeführt und nach Datum sortiert.

### Infusion erfassen (`add_infusion_page.dart`)

- Datum und Uhrzeit
- Dosis (vorbelegt aus Plan)
- Optional: Chargennummer, Körpergewicht, Foto, Notizen
- Beim Speichern: Bestand und verknüpftes Zubehör werden automatisch abgezogen (transaktional)

### Tagebucheintrag (`add_diary_entry_page.dart`)

Erfasst:
- Vitalwerte: Blutdruck (systolisch/diastolisch), Herzfrequenz, Temperatur, Gewicht
- CIDP-Symptomscores (je 0–10): Muskelkraft, Sensibilität, Fatigue, Schmerz, Balance
- Freitext-Notizen

### Behandlungsplan (`add_schedule_page.dart`, `planning_page.dart`)

Pläne können erstellt werden mit:

| Frequenztyp | Beschreibung |
|-------------|--------------|
| `daily` | Täglich |
| `interval` | Alle N Tage |
| `weekly` | Bestimmte Wochentage |
| `weekdays` | Mo–Fr |

Optional mehrere Einnahmezeiten pro Tag. Der `SchedulerService` generiert daraus 90 Tage in die Zukunft.

### Statistiken (`statistics_page.dart`)

Verlaufscharts für Vitalwerte und Symptomscores über Zeit, gebaut mit `fl_chart`.

---

## Inventar (`lib/features/inventory/`)

### Inventarübersicht (`inventory_page.dart`)

- Liste aller aktiven Medikamente und Zubehör
- Farbcodierte Lagerampel: grün (ausreichend) → gelb (knapp) → rot (unter Mindestbestand)
- QR-Code-Scan zum Schnelleintrag neuer Artikel
- OCR (Google ML Kit) zum Einlesen von Etikettentext

### Medikament-Details (`medication_details_page.dart`)

Vollständiger Editor für ein Medikament:

- Grunddaten: Name, Dosis, PZN, Einheit, Packungsgröße
- Optionen: Chargennummern tracken, Körpergewicht tracken, Timer verwenden
- Verbrauchsmaterial-BOM: Welches Zubehör und in welcher Menge pro Infusion?
- Preisinfo, Notizen
- Verlauf aller Infusionen mit diesem Medikament

### Einkaufsassistent (`shopping_wizard_dialog.dart`)

Der Assistent analysiert:
1. Aktuellen Bestand aller Medikamente und Zubehör
2. Verbrauch aus dem 90-Tage-Plan
3. Bestehende ausstehende Bestellungen

Und berechnet: **Genaue Bestellmengen** (in ganzen Packungen) für alle Artikel, die vor Ende des Plans oder unter Mindestbestand fallen würden.

Das Ergebnis wird als `PendingOrder` mit Einzelpositionen gespeichert.

---

## Erinnerungen (`lib/features/reminders/`)

### NotificationService

Verwaltet alle lokalen Benachrichtigungen via `flutter_local_notifications`:

| Typ | Trigger |
|-----|---------|
| Behandlungserinnerung | Geplante Infusion (7 Tage Vorschau) |
| Vormedikation | Vom BackgroundService |
| Mindestbestand | `MedicationService.getLowStockItemsSummary()` |
| Verpasste Behandlung | `SchedulerService.checkMissedTreatments()` |

**7-Tage-Fenster**: Nur Benachrichtigungen der nächsten 7 Tage werden registriert, um das Android-500-Alarm-Limit nicht zu überschreiten. Täglich werden neue Alarme für den neu rollierenden Tag hinzugefügt.

Android 13+ Berechtigungen: `POST_NOTIFICATIONS` + `SCHEDULE_EXACT_ALARM` werden zur Laufzeit angefordert.

---

## Einstellungen & Backup (`lib/features/settings/`)

Siehe [Backup & Wiederherstellung](Backup-and-Restore) für Details zur Backup-Logik.

Die Einstellungsseite ermöglicht:
- Backup-Ziele hinzufügen/entfernen (lokal, SAF, Google Drive)
- Auto-Backup aktivieren/deaktivieren
- Manuellen Backup-Test durchführen
- Backups auflisten und Wiederherstellung starten
- Zuverlässigkeitscheck: letzter Erfolg, letzte Fehler, Fehlerzähler
