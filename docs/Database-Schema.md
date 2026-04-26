# Datenbankschema

CIDPbuddy verwendet **Drift ORM** mit SQLite. Die aktuelle Schemaversion ist **13**. Alle Migrationen sind explizit in `lib/core/database/app_database.dart` mit `onUpgrade`-Schritten hinterlegt.

## Tabellenübersicht

### `Medications`

Medikamente und Infusionslösungen.

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `id` | INTEGER PK | Auto-increment |
| `name` | TEXT | Handelsname des Medikaments |
| `dosage` | REAL | Standarddosis (in `unit`) |
| `pzn` | TEXT? | Pharmazentralnummer |
| `stock` | REAL | Aktueller Bestand |
| `minStock` | REAL | Mindestbestand (Alarm-Schwelle) |
| `unit` | TEXT | Einheit (z.B. „g", „ml", „Stk.") |
| `type` | TEXT | `infusion` oder `pill` |
| `packageSize` | REAL | Inhalt pro Packung |
| `trackBatchNumber` | BOOLEAN | Chargennummer bei Infusionslog erfassen? |
| `trackWeight` | BOOLEAN | Körpergewicht bei Infusionslog erfassen? |
| `useTimer` | BOOLEAN | Vormedikations-Timer aktivieren? |
| `createdAt` | DATETIME | Erstellungszeitpunkt |
| `discontinuedAt` | DATETIME? | Gesetzt wenn abgesetzt (Soft-Delete) |

### `Accessories`

Medizinisches Verbrauchsmaterial (Nadeln, Spritzen, Schläuche).

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `id` | INTEGER PK | Auto-increment |
| `name` | TEXT | Bezeichnung |
| `stock` | REAL | Aktueller Bestand |
| `minStock` | REAL | Mindestbestand |
| `unit` | TEXT | Einheit |
| `packageSize` | REAL | Inhalt pro Packung |

### `MedicationAccessories`

Stückliste (BOM): Welches Zubehör gehört zu welchem Medikament?

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `id` | INTEGER PK | Auto-increment |
| `medicationId` | INTEGER FK → Medications | Eltern-Medikament |
| `accessoryId` | INTEGER FK → Accessories | Zugehöriges Zubehör |
| `defaultQuantity` | REAL | Standardmenge pro Infusion |
| `isMandatory` | BOOLEAN | Pflichtmaterial? |

### `InfusionLog`

Protokoll abgeschlossener Infusionen (Ist-Daten).

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `id` | INTEGER PK | Auto-increment |
| `date` | DATETIME | Zeitpunkt der Infusion |
| `medicationId` | INTEGER FK → Medications | Verwendetes Medikament |
| `dosage` | REAL | Tatsächlich gegebene Dosis |
| `batchNumber` | TEXT? | Chargennummer |
| `notes` | TEXT? | Freitext-Notizen |
| `bodyWeight` | REAL? | Körpergewicht in kg |
| `photoPath` | TEXT? | Pfad zur Infusionsfotos |

Beim Einfügen eines Logs wird der Bestand in `Medications` und allen zugehörigen `Accessories` automatisch in einer Transaktion dekrementiert.

### `InfusionSchedules`

Wiederkehrende Behandlungspläne (Soll-Daten).

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `id` | INTEGER PK | Auto-increment |
| `medicationId` | INTEGER FK → Medications | Zugeordnetes Medikament |
| `dosage` | REAL | Geplante Dosis |
| `frequencyType` | TEXT | `daily`, `interval`, `weekly`, `weekdays` |
| `intervalValue` | INTEGER? | Für `interval`: Tage zwischen Infusionen |
| `selectedWeekdays` | TEXT? | Für `weekly`: kommagetrennte Wochentage (`'1,3,5'` = Mo/Mi/Fr) |
| `startDate` | DATE | Beginn des Plans |
| `isActive` | BOOLEAN | Plan aktiv? |
| `intakeTimes` | TEXT? | Kommagetrennte Uhrzeiten (`'08:00,20:00'`) |

### `PlannedInfusions`

Automatisch generierte Termine aus `InfusionSchedules` (90-Tage-Vorschau).

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `id` | INTEGER PK | Auto-increment |
| `date` | DATETIME | Geplanter Infusionstermin |
| `medicationId` | INTEGER FK → Medications | Medikament |
| `dosage` | REAL | Geplante Dosis |
| `notes` | TEXT? | Notizen |
| `isCompleted` | BOOLEAN | Abgeschlossen oder übersprungen? |
| `scheduleId` | INTEGER? FK → InfusionSchedules | Quell-Plan (nullable für manuelle Termine) |
| `bodyWeight` | REAL? | Geplantes Körpergewicht |

Bei Änderung oder Löschung eines Schedules werden alle verknüpften geplanten Termine automatisch gelöscht.

### `PendingOrders`

Bestellungen in Bearbeitung.

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `id` | INTEGER PK | Auto-increment |
| `medicationId` | INTEGER FK → Medications | Bestelltes Medikament |
| `medicationQty` | REAL | Bestellmenge (Medikament) |
| `deliveryDate` | DATE? | Erwartetes Lieferdatum |
| `isConfirmed` | BOOLEAN | Bestellung bestätigt? |

### `PendingOrderItems`

Einzelpositionen einer Bestellung.

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `id` | INTEGER PK | Auto-increment |
| `orderId` | INTEGER FK → PendingOrders | Zugehörige Bestellung |
| `medicationId` | INTEGER? FK → Medications | Medikament (nullable) |
| `accessoryId` | INTEGER? FK → Accessories | Zubehör (nullable) |
| `quantity` | REAL | Bestellmenge |

### `DiaryEntries`

Gesundheitstagebuch: Vitalwerte und CIDP-Symptomscores.

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `id` | INTEGER PK | Auto-increment |
| `date` | DATETIME | Erfassungszeitpunkt |
| `systolicBP` | INTEGER? | Systolischer Blutdruck (mmHg) |
| `diastolicBP` | INTEGER? | Diastolischer Blutdruck (mmHg) |
| `heartRate` | INTEGER? | Herzfrequenz (bpm) |
| `temperature` | REAL? | Körpertemperatur (°C) |
| `weight` | REAL? | Körpergewicht (kg) |
| `strengthScore` | INTEGER? | Muskelkraft (0–10) |
| `sensoryScore` | INTEGER? | Sensibilität (0–10) |
| `fatigueScore` | INTEGER? | Fatigue (0–10) |
| `painScore` | INTEGER? | Schmerz (0–10) |
| `balanceScore` | INTEGER? | Balance/Koordination (0–10) |
| `notes` | TEXT? | Freitext |

## Migrationen

Explizite `onUpgrade`-Schritte von Version 1 bis 13 gewährleisten Rückwärtskompatibilität. Jeder Schritt fügt nur das hinzu, was die neue Version benötigt (neue Spalten, neue Tabellen, Datenmigration).

Wann immer das Schema geändert wird:

1. Schemaversion in `@DriftDatabase(tables: [...])` erhöhen
2. `onUpgrade`-Schritt hinzufügen
3. Code neu generieren:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
