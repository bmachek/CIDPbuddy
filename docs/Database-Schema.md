# Database schema

CIDPbuddy uses **Drift ORM** with SQLite. The current schema version is **14**. All migrations are declared explicitly as `onUpgrade` steps in `lib/core/database/database.dart`.

## Table overview

### `Medications`

Medications and infusion solutions.

| Field | Type | Description |
|-------|------|-------------|
| `id` | INTEGER PK | Auto-increment |
| `name` | TEXT | Trade name of the medication |
| `dosage` | TEXT | Standard dose as free text (default `''`) |
| `pzn` | TEXT? | Pharmaceutical central number |
| `stock` | REAL | Current stock |
| `minStock` | REAL | Minimum stock (warning threshold) |
| `unit` | TEXT | Unit (e.g. "g", "ml", "pcs") |
| `type` | INTEGER | `MedicationType` enum index: `0` = `infusion`, `1` = `pill` |
| `packageSize` | REAL | Contents per package |
| `trackBatchNumber` | BOOLEAN | Ask for a batch number when logging an infusion? |
| `trackWeight` | BOOLEAN | Ask for body weight when logging an infusion? |
| `useTimer` | BOOLEAN | Enable the premedication timer? |
| `createdAt` | DATETIME | Creation time |
| `discontinuedAt` | DATETIME? | Set when discontinued (soft delete) |

### `Accessories`

Medical supplies (needles, syringes, tubing).

| Field | Type | Description |
|-------|------|-------------|
| `id` | INTEGER PK | Auto-increment |
| `name` | TEXT | Name |
| `stock` | REAL | Current stock |
| `minStock` | REAL | Minimum stock |
| `unit` | TEXT | Unit |
| `packageSize` | REAL | Contents per package |

### `MedicationAccessories`

Bill of materials: which supply belongs to which medication?

| Field | Type | Description |
|-------|------|-------------|
| `id` | INTEGER PK | Auto-increment |
| `medicationId` | INTEGER FK → Medications | Parent medication |
| `accessoryId` | INTEGER FK → Accessories | Associated supply |
| `defaultQuantity` | REAL | Default amount per infusion |
| `isMandatory` | BOOLEAN | Always required? |

### `InfusionLog`

Record of completed infusions (actuals).

| Field | Type | Description |
|-------|------|-------------|
| `id` | INTEGER PK | Auto-increment |
| `date` | DATETIME | Time of the infusion |
| `medicationId` | INTEGER FK → Medications | Medication used |
| `dosage` | REAL | Dose actually administered |
| `batchNumber` | TEXT? | Batch number |
| `notes` | TEXT? | Free-text notes |
| `bodyWeight` | REAL? | Body weight in kg |
| `photoPath` | TEXT? | Path to the infusion photo |

Inserting a log automatically decrements the stock in `Medications` and in every associated `Accessories` row, inside one transaction.

### `InfusionSchedules`

Recurring treatment schedules (targets).

| Field | Type | Description |
|-------|------|-------------|
| `id` | INTEGER PK | Auto-increment |
| `medicationId` | INTEGER FK → Medications | Associated medication |
| `dosage` | REAL | Planned dose |
| `frequencyType` | TEXT | `daily`, `interval`, `weekly`, `weekdays` |
| `intervalValue` | INTEGER? | For `interval`: days between infusions; for `weekly`: week spacing (e.g. 2 = every other week) |
| `selectedWeekdays` | TEXT? | For `weekly`: comma-separated weekdays (`'1,3,5'` = Mon/Wed/Fri) |
| `startDate` | DATETIME | Start of the schedule |
| `isActive` | BOOLEAN | Schedule active? |
| `intakeTimes` | TEXT? | Comma-separated times (`'08:00,20:00'`) |

> `frequencyType` values are stored enum keys and must stay in English — the UI translates
> them for display only.

### `PlannedInfusions`

Appointments generated automatically from `InfusionSchedules` (90-day look-ahead).

| Field | Type | Description |
|-------|------|-------------|
| `id` | INTEGER PK | Auto-increment |
| `date` | DATETIME | Planned infusion time |
| `medicationId` | INTEGER FK → Medications | Medication |
| `dosage` | REAL | Planned dose |
| `notes` | TEXT? | Notes |
| `isCompleted` | BOOLEAN | Completed or skipped? |
| `scheduleId` | INTEGER? FK → InfusionSchedules | Source schedule (nullable for manual appointments) |
| `bodyWeight` | REAL? | Planned body weight |

When a schedule is changed or deleted, all linked planned appointments are deleted automatically.

### `PendingOrders`

Orders in progress.

| Field | Type | Description |
|-------|------|-------------|
| `id` | INTEGER PK | Auto-increment |
| `medicationId` | INTEGER FK → Medications | Medication ordered |
| `medicationQty` | REAL | Order quantity (medication) |
| `deliveryDate` | DATETIME? | Expected delivery date (optional — the assistant allows "right after confirmation") |
| `isConfirmed` | BOOLEAN | Order confirmed as delivered? |
| `confirmedAt` | DATETIME? | Time of confirmation (since schema 14) |

The diary sorts a delivered order by `deliveryDate ?? confirmedAt`. Without `confirmedAt`, an
order with no delivery date had no date at all and stayed pinned to the top of the timeline.

### `PendingOrderItems`

Individual line items of an order.

| Field | Type | Description |
|-------|------|-------------|
| `id` | INTEGER PK | Auto-increment |
| `orderId` | INTEGER FK → PendingOrders | Parent order |
| `medicationId` | INTEGER? FK → Medications | Medication (nullable) |
| `accessoryId` | INTEGER? FK → Accessories | Supply (nullable) |
| `quantity` | REAL | Order quantity |

### `DiaryEntries`

Health diary: vital signs and CIDP symptom scores.

| Field | Type | Description |
|-------|------|-------------|
| `id` | INTEGER PK | Auto-increment |
| `date` | DATETIME | Time of recording |
| `systolicBP` | REAL? | Systolic blood pressure (mmHg) |
| `diastolicBP` | REAL? | Diastolic blood pressure (mmHg) |
| `heartRate` | INTEGER? | Heart rate (bpm) |
| `temperature` | REAL? | Body temperature (°C) |
| `weight` | REAL? | Body weight (kg) |
| `strengthScore` | INTEGER? | Muscle strength (0–10) |
| `sensoryScore` | INTEGER? | Sensation (0–10) |
| `fatigueScore` | INTEGER? | Fatigue (0–10) |
| `painScore` | INTEGER? | Pain (0–10) |
| `balanceScore` | INTEGER? | Balance/coordination (0–10) |
| `notes` | TEXT? | Free text |

## A note on stored text and language

Some columns hold text the user sees but that is written by the app, not typed: `unit` is seeded from a translated default (`Bottle` / `Flasche` / `Flacon` …) when an item is created, and `notes` can receive an appended marker such as `[Skipped via notification]`. These are stored verbatim in whatever language was active at the time and are **not** re-translated when the language changes — they are user data, not UI strings.

## Migrations

Explicit `onUpgrade` steps run up to version **14** and preserve backwards compatibility.
Each step adds only what the new version needs (new columns, new tables, data migration).
There is no step for version **8** — the number was skipped.

The last migration (13 → 14) is the only one with real data migration: it creates
`pending_orders.confirmed_at`, copies `delivery_date` for orders that were already confirmed,
and for orders with no delivery date estimates the latest delivery date of an older order as a
lower bound.

Whenever the schema changes:

1. Increase the `schemaVersion` getter in `AppDatabase` (and add any new tables to `@DriftDatabase(tables: [...])`)
2. Add an `onUpgrade` step
3. Regenerate the code:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
