# Screenshots & tour

This page is a guided tour through CIDPbuddy — from an empty first launch to a fully set-up app. The order follows the typical onboarding path: add a first medication, create an infusion schedule, log treatments, and set up the backup.

> The screenshots were taken on the German Android build, so the UI text in them is German;
> the app itself ships in English, German, French, Italian and Spanish. The image files live in
> the repository under [`screenshots/`](../screenshots/), and their filenames are German for
> the same historical reason.

## 1. First launch (empty state)

Right after installation the app is empty. The dashboard greets you with "All done!" and the medication list has no entries yet.

| Dashboard (empty) | Medication (empty) |
|---|---|
| ![Empty dashboard](../screenshots/01_dashboard_leer.png) | ![Empty medication list](../screenshots/02_medikation_leer.png) |

The empty dashboard shows the "Your overview" welcome state with a note that there are no pending tasks. Setup starts via **+ Schedule appointment**.

## 2. Add the first medication

| New item | Medication filled in | Create infusion schedule |
|---|---|---|
| ![New item form](../screenshots/03_neues_element_formular.png) | ![Medication filled in](../screenshots/04_medikament_ausgefuellt.png) | ![Create infusion schedule](../screenshots/05_infusionsplan_erstellen.png) |

The form creates a new medication (here *Hizentra*) with master data such as name, dose and unit. Next comes an **infusion schedule** with a frequency (daily, interval-based, weekly, or specific weekdays), from which `SchedulerService` generates the 90-day plan.

## 3. Dashboard with data

| Dashboard | Dashboard (scrolled) | Schedule appointment |
|---|---|---|
| ![Dashboard with data](../screenshots/06_dashboard.png) | ![Dashboard scrolled](../screenshots/07_dashboard_scrolled.png) | ![Schedule appointment dialog](../screenshots/08_termin_planen_dialog.png) |

Once a medication and a schedule exist, the dashboard fills up:

- **Missed/upcoming infusion** with the quick action **Log infusion now**
- **No backup enabled** — a prompt to set up backups
- **Order recommended** — a warning when stock is low
- **Planned later** — an expandable list of upcoming appointments from the 90-day plan

## 4. Diary

| Diary | Diary (scrolled) |
|---|---|
| ![Diary](../screenshots/09_tagebuch.png) | ![Diary scrolled](../screenshots/10_tagebuch_scrolled.png) |

The diary is a chronological timeline of events that have already happened (prescriptions and discontinuations, logged infusions, diary entries, delivered orders — planned appointments live on the dashboard). The quick actions let you record **vitals & symptoms** or **log an infusion**.

## 5. Record vitals & symptoms

| Vitals form | Vitals (scrolled) |
|---|---|
| ![Vitals form](../screenshots/11_vitalwerte_formular.png) | ![Vitals scrolled](../screenshots/12_vitalwerte_formular_scrolled.png) |

This records blood pressure (systolic/diastolic), heart rate, temperature and weight, plus the CIDP symptom scores (0–10 each): muscle strength, sensation, fatigue, pain and balance.

## 6. Log an infusion

| Log infusion | Infusion filled in |
|---|---|
| ![Log infusion](../screenshots/13_infusion_erfassen.png) | ![Infusion filled in](../screenshots/14_infusion_ausgefuellt.png) |

Logging an infusion records date, time and the dose (pre-filled from the plan) — optionally also batch number, body weight, a photo and notes. On save, stock and linked supplies are deducted transactionally.

## 7. Medication & inventory

| Medication | Hizentra details | Details (scrolled) |
|---|---|---|
| ![Medication list](../screenshots/15_medikation.png) | ![Hizentra details](../screenshots/16_hizentra_details.png) | ![Details scrolled](../screenshots/17_hizentra_details_scrolled.png) |

The medication list shows a colour-coded stock indicator with coverage and the next appointment. The detail views let you maintain master data, options (batch numbers/weight/timer) and the supply bill of materials.

| Discontinued medications | Supply item form | Medication, fully set up |
|---|---|---|
| ![Discontinued medications](../screenshots/18_abgesetzte_medikamente.png) | ![Supply item form](../screenshots/19_verbrauchsmaterial_formular.png) | ![Complete medication list](../screenshots/20_medikation_komplett.png) |

Alongside active medications you can review discontinued ones separately and manage standalone supplies (swabs, for example) with their own stock.

## 8. Settings & backup

| Settings | Settings (scrolled) |
|---|---|
| ![Settings](../screenshots/21_einstellungen.png) | ![Settings scrolled](../screenshots/22_einstellungen_scrolled.png) |

Settings cover appearance (light/dark theme), language, **automatic backup** (choose a destination, restore a backup) and reminders (snooze). For the backup logic in detail, see [Backup & restore](Backup-and-Restore).

## 9. Fully set up

![Final dashboard](../screenshots/23_dashboard_final.png)

The finished dashboard with an active plan, maintained stock and a configured backup.
