# Features

## Dashboard (`lib/features/diary/pages/dashboard_page.dart`)

The dashboard is the app's entry point and shows at a glance:

- **Upcoming treatments** — appointments over the next few days, from the 90-day plan
- **Premedication timer** — starts a countdown with audio alarms; foreground notification with a live display
- **Low-stock warnings** — colour-coded list of every medication and supply below its threshold
- **Quick statistics** — last infusion, next planned infusion, current stock coverage

### Premedication timer

The timer (`premedication_timer_modal.dart`) runs through `BackgroundService` and survives the app being minimised:

- Every minute: 3 × `bell.mp3`
- On expiry: `ping.mp3`
- A foreground notification shows the remaining time in real time

---

## Diary (`lib/features/diary/pages/diary_page.dart`)

A chronological timeline of events that have already happened:

- Completed infusions (from `InfusionLog`)
- Diary entries (from `DiaryEntries`)
- Delivered orders (from `PendingOrders`, filtered on `isConfirmed`)
- Prescriptions and discontinuations (`MedicationEvent`, derived from `Medications.createdAt` / `discontinuedAt`)

The four streams are merged in `DiaryProvider.combinedEntriesStream` via `Rx.combineLatest4` and sorted by date, newest first.

> Planned appointments (`PlannedInfusions`) and still-open orders do **not** appear in the
> diary — they live on the dashboard and the planning page.

### Log an infusion (`add_infusion_page.dart`)

- Date and time
- Dose (pre-filled from the plan)
- Optional: batch number, body weight, photo, notes
- On save: stock and linked supplies are deducted automatically (transactionally)

### Diary entry (`add_diary_entry_page.dart`)

Records:
- Vital signs: blood pressure (systolic/diastolic), heart rate, temperature, weight
- CIDP symptom scores (0–10 each): muscle strength, sensation, fatigue, pain, balance
- Free-text notes

### Treatment schedule (`add_schedule_page.dart`)

Schedules can be created with:

| Frequency type | Description |
|----------------|-------------|
| `daily` | Every day |
| `interval` | Every N days |
| `weekly` | Specific weekdays |
| `weekdays` | Mon–Fri |

Optionally several intake times per day. `SchedulerService` expands these into 90 days ahead.

Weekday chips take their abbreviations from `intl`, so they follow the active language rather than a hard-coded list.

### Statistics (`statistics_page.dart`)

Trend charts for vital signs and symptom scores over time, built with `fl_chart`.

---

## Inventory (`lib/features/inventory/`)

### Inventory overview (`inventory_page.dart`)

- List of all active medications and supplies
- Colour-coded stock indicator: green (plenty) → amber (running low) → red (below minimum)
- QR code scanning for quickly adding new items
- OCR (Google ML Kit) for reading label text

### Medication details (`medication_details_page.dart`)

A full editor for one medication:

- Master data: name, dose, PZN, unit, package size
- Options: track batch numbers, track body weight, use timer
- Supply bill of materials: which supplies, and how many per infusion?
- Price info, notes
- History of every infusion of this medication

### Shopping assistant (`shopping_wizard_dialog.dart`)

The assistant analyses:
1. Current stock of every medication and supply
2. Consumption implied by the 90-day plan
3. Existing outstanding orders

and works out **exact order quantities** (in whole packages) for every item that would run out before the end of the plan or fall below its minimum.

The result is stored as a `PendingOrder` with individual line items.

---

## Reminders (`lib/features/reminders/`)

### NotificationService

Manages all local notifications via `flutter_local_notifications`:

| Type | Trigger |
|------|---------|
| Treatment reminder | Planned infusion (7-day look-ahead, set by `SchedulerService`) |
| Premedication | From BackgroundService |
| Low stock | `MedicationService.getLowStockItemsSummary()` |
| Missed treatment | `SchedulerService.checkMissedTreatments()` |

**7-day window**: `SchedulerService` plans 90 days of appointments but only registers
notifications for the next 7 days (`notificationLookAhead` in `scheduler_service.dart`). That
keeps the number of concurrently registered alarms small — Android caps exact alarms per app.
The `BackgroundService` 24 h sync advances the window daily.

Notification text is localized without a `BuildContext`: the service resolves the stored language through `LocaleProvider.l10nForBackground()`, so alarms fired from a background isolate use the same language as the UI. Android notification *channel* names are translated too; because a channel's name can only be updated by re-creating it with the same ID, a language change takes effect on the next app start.

Android 13+ permissions: `POST_NOTIFICATIONS` and `SCHEDULE_EXACT_ALARM` are requested at runtime.

---

## Settings & backup (`lib/features/settings/`)

See [Backup & restore](Backup-and-Restore) for the backup logic in detail.

The settings page lets you:
- Switch appearance (light/dark theme)
- Pick the app language (system, English, German, French, Italian, Spanish) — see [Localization](Localization)
- Choose or clear the backup destination (a local folder or a SAF folder; exactly one is active at a time)
- Enable or disable auto-backup
- Run a manual backup test
- List backups and start a restore
- Run the reliability check: last success, last errors, failure counter
