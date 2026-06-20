# Screenshots & Rundgang

Diese Seite zeigt einen geführten Rundgang durch CIDPbuddy — vom leeren Erststart bis zur vollständig eingerichteten App. Die Reihenfolge folgt dem typischen Onboarding-Pfad: ein erstes Medikament anlegen, einen Infusionsplan erstellen, Behandlungen erfassen und das Backup einrichten.

> Alle Screenshots stammen aus der deutschen Android-Version. Die Bilddateien liegen im Repository unter [`screenshots/`](../screenshots/).

## 1. Erster Start (leerer Zustand)

Direkt nach der Installation ist die App leer. Das Dashboard begrüßt mit „Alles erledigt!", die Medikationsliste ist noch ohne Einträge.

| Dashboard (leer) | Medikation (leer) |
|---|---|
| ![Leeres Dashboard](../screenshots/01_dashboard_leer.png) | ![Leere Medikationsliste](../screenshots/02_medikation_leer.png) |

Das leere Dashboard zeigt den Begrüßungszustand „Deine Übersicht" mit dem Hinweis, dass keine anstehenden Aufgaben vorliegen. Über **+ Termin planen** beginnt die Einrichtung.

## 2. Erstes Medikament anlegen

| Neues Element | Medikament ausgefüllt | Infusionsplan erstellen |
|---|---|---|
| ![Formular für neues Element](../screenshots/03_neues_element_formular.png) | ![Ausgefülltes Medikament](../screenshots/04_medikament_ausgefuellt.png) | ![Infusionsplan erstellen](../screenshots/05_infusionsplan_erstellen.png) |

Im Formular wird ein neues Medikament angelegt (hier *Hizentra*) — mit Grunddaten wie Name, Dosis und Einheit. Anschließend wird ein **Infusionsplan** mit Frequenz (täglich, intervallbasiert, wöchentlich oder Wochentage) hinterlegt, aus dem der `SchedulerService` die 90-Tage-Planung generiert.

## 3. Dashboard mit Daten

| Dashboard | Dashboard (gescrollt) | Termin planen |
|---|---|---|
| ![Dashboard mit Daten](../screenshots/06_dashboard.png) | ![Dashboard gescrollt](../screenshots/07_dashboard_scrolled.png) | ![Termin-planen-Dialog](../screenshots/08_termin_planen_dialog.png) |

Sobald Medikament und Plan vorhanden sind, füllt sich das Dashboard:

- **Verpasste/anstehende Infusion** mit Schnellaktion **Jetzt Infusion erfassen**
- **Kein Backup aktiviert** — Hinweisbanner zur Datensicherung
- **Bestellung empfohlen** — Warnung bei niedrigem Bestand
- **Später geplant** — ausklappbare Liste kommender Termine aus dem 90-Tage-Plan

## 4. Tagebuch

| Tagebuch | Tagebuch (gescrollt) |
|---|---|
| ![Tagebuch](../screenshots/09_tagebuch.png) | ![Tagebuch gescrollt](../screenshots/10_tagebuch_scrolled.png) |

Das Tagebuch ist eine chronologische Timeline aller Ereignisse (Verordnungen, erfasste Infusionen, Tagebucheinträge, geplante Termine, Bestellungen). Über die Schnellaktionen lassen sich **Vitalwerte & Symptome** sowie eine **Infusion erfassen**.

## 5. Vitalwerte & Symptome erfassen

| Vitalwerte-Formular | Vitalwerte (gescrollt) |
|---|---|
| ![Vitalwerte-Formular](../screenshots/11_vitalwerte_formular.png) | ![Vitalwerte gescrollt](../screenshots/12_vitalwerte_formular_scrolled.png) |

Erfasst werden Blutdruck (systolisch/diastolisch), Herzfrequenz, Temperatur und Gewicht sowie die CIDP-Symptomscores (je 0–10): Muskelkraft, Sensibilität, Fatigue, Schmerz und Balance.

## 6. Infusion erfassen

| Infusion erfassen | Infusion ausgefüllt |
|---|---|
| ![Infusion erfassen](../screenshots/13_infusion_erfassen.png) | ![Infusion ausgefüllt](../screenshots/14_infusion_ausgefuellt.png) |

Beim Erfassen einer Infusion werden Datum, Uhrzeit und die (aus dem Plan vorbelegte) Dosis eingetragen — optional Chargennummer, Körpergewicht, Foto und Notizen. Beim Speichern werden Bestand und verknüpftes Zubehör transaktional abgezogen.

## 7. Medikation & Inventar

| Medikation | Hizentra-Details | Details (gescrollt) |
|---|---|---|
| ![Medikationsliste](../screenshots/15_medikation.png) | ![Hizentra-Details](../screenshots/16_hizentra_details.png) | ![Details gescrollt](../screenshots/17_hizentra_details_scrolled.png) |

Die Medikationsliste zeigt eine farbcodierte Lagerampel mit Reichweite und nächstem Termin. In den Detailansichten lassen sich Grunddaten, Optionen (Chargennummern/Gewicht/Timer) und die Verbrauchsmaterial-BOM pflegen.

| Abgesetzte Medikamente | Verbrauchsmaterial-Formular | Medikation komplett |
|---|---|---|
| ![Abgesetzte Medikamente](../screenshots/18_abgesetzte_medikamente.png) | ![Verbrauchsmaterial-Formular](../screenshots/19_verbrauchsmaterial_formular.png) | ![Vollständige Medikation](../screenshots/20_medikation_komplett.png) |

Neben aktiven Medikamenten lassen sich abgesetzte Präparate getrennt einsehen und Standalone-Verbrauchsmaterial (z. B. Tupfer) mit eigenem Bestand verwalten.

## 8. Einstellungen & Backup

| Einstellungen | Einstellungen (gescrollt) |
|---|---|
| ![Einstellungen](../screenshots/21_einstellungen.png) | ![Einstellungen gescrollt](../screenshots/22_einstellungen_scrolled.png) |

Die Einstellungen umfassen Erscheinungsbild (helles/dunkles Design), **automatisches Backup** (Ziel wählen, Sicherung wiederherstellen) und Erinnerungen (Schlummer-Funktion). Details zur Backup-Logik unter [Backup & Wiederherstellung](Backup-and-Restore).

## 9. Fertig eingerichtet

![Fertiges Dashboard](../screenshots/23_dashboard_final.png)

Das fertig eingerichtete Dashboard mit aktivem Plan, gepflegtem Bestand und konfiguriertem Backup.
