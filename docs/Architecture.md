# Architektur

## Überblick

CIDPbuddy folgt einem reaktiven Daten-First-Ansatz: Die SQLite-Datenbank (via Drift) ist die einzige Quelle der Wahrheit. UI-State wird nicht manuell gehalten, sondern aus Datenbankstreams abgeleitet.

```
Datenbank (Drift Streams)
    └─► Provider (ChangeNotifier)
            └─► Widgets (rebuild on notify)
```

## State Management

### Provider-Pattern

Die App verwendet `ChangeNotifier` + `ChangeNotifierProxyProvider` aus dem `provider`-Paket.

- **`DiaryProvider`** — Kombiniert Infusions-Logs, Tagebucheinträge und ausstehende Bestellungen zu einem einheitlichen Timeline-Stream via `RxDart.combineLatest`
- **`InventoryProvider`** — Streams für aktive Medikamente, abgesetzte Medikamente und Zubehör

Providers werden in `main.dart` mit `MultiProvider` registriert und erhalten Zugriff auf die `AppDatabase`-Singleton-Instanz.

### Drift-Streams als Datenquelle

```dart
// Beispiel: Reaktiver Stream aus der DB
Stream<List<Medication>> watchActiveMedications() =>
    (select(medications)..where((m) => m.discontinuedAt.isNull()))
        .watch();
```

Jede `watch*()`-Methode emittiert bei jeder relevanten Tabellenänderung. Der Provider abonniert den Stream im Konstruktor und ruft `notifyListeners()` bei jedem Emit auf.

### RxDart-Komposition

Wenn mehrere Streams zu einem kombinierten State zusammengeführt werden (z.B. im Diary-Dashboard):

```dart
combinedEntriesStream = Rx.combineLatest4(
  db.watchInfusionLogs(),
  db.watchDiaryEntries(),
  db.watchPlannedInfusions(),
  db.watchPendingOrders(),
  (logs, entries, planned, orders) => _merge(logs, entries, planned, orders),
);
```

## Datenbankarchitektur

### Singleton-Pattern

`AppDatabase` ist eine App-weite Singleton-Instanz. Das ist kritisch für Backup/Restore: Beim Wiederherstellen wird die DB-Datei ersetzt und die Singleton-Verbindung neu aufgebaut — ohne Singleton könnten Verbindungslecks entstehen.

```dart
// lib/core/database/app_database.dart
static AppDatabase? _instance;
static AppDatabase get instance => _instance ??= AppDatabase._internal();
```

### Auto-Backup-Trigger

Der Backup-Service registriert sich auf alle Tabellenänderungen und debounced diese auf 30 Sekunden:

```dart
db.tableUpdates()
    .debounceTime(const Duration(seconds: 30))
    .listen((_) => autoBackup());
```

## Hintergrundservices

### BackgroundService (24/7-Dienst)

`lib/core/services/background_service.dart` läuft als Flutter-Foreground-Service dauerhaft im Hintergrund.

**Aufgaben:**
1. **Vormedikations-Timer** — Countdown mit minütlichen Audio-Glocken (`bell.mp3`) und abschließendem Ping (`ping.mp3`); Foreground-Notification zeigt laufenden Countdown
2. **24h-Synchronisation** — Regeneriert den 90-Tage-Behandlungsplan (via `SchedulerService`) und aktualisiert Benachrichtigungen

Hintergrundisolate-Zugriff auf Flutter-Plugins wird durch `DartPluginRegistrant.ensureInitialized()` sichergestellt.

### WorkManager (Periodisch)

`lib/features/settings/services/backup_worker.dart` verwendet Android WorkManager für periodische Backup-Tasks, die Geräteneustarts überstehen. Der Worker wird bei App-Start registriert und nach Boot neu gestartet.

## SchedulerService

`lib/core/services/scheduler_service.dart` generiert den 90-Tage-Behandlungsplan:

| Frequenztyp | Logik |
|-------------|-------|
| `daily` | Jeden Tag ab startDate |
| `interval` | Alle N Tage (intervalValue) |
| `weekly` | Bestimmte Wochentage (selectedWeekdays: `'1,3,5'`) |
| `weekdays` | Mo–Fr |

`checkMissedTreatments()` prüft 7 Tage rückwirkend auf nicht bestätigte/übersprungene Behandlungen und erstellt Benachrichtigungen.

## Navigation

`lib/main_screen.dart` verwendet `IndexedStack` mit einer glassmorphischen Bottom-Navigation (4 Tabs):

1. **Dashboard** — `DashboardPage`
2. **Tagebuch** — `DiaryPage`
3. **Inventar** — `InventoryPage`
4. **Einstellungen** — `SettingsPage`

Der `IndexedStack` erhält alle Widgets immer am Leben, sodass Scrollposition und State beim Tab-Wechsel erhalten bleiben.

## Theme & Lokalisierung

- Material 3 mit Premium-Gradient-Hintergründen und Glassmorphic-Navigation (`BackdropFilter`)
- Farbpalette: Blau `#0066FF`, Smaragd `#00BFA6`, Gold `#FFB300`
- **Nur Deutsch** (`Locale('de', 'DE')`) — alle UI-Strings müssen auf Deutsch sein
- Datumsformat: deutsches Format (z.B. `dd.MM. HH:mm`)

## Wichtige Code-Regeln

1. `flutter analyze` muss nach jeder Änderung fehlerfrei durchlaufen
2. **Niemals** `const Theme.of(context)` verwenden — ist kein konstanter Ausdruck
3. **`color.withValues(alpha: 0.5)`** statt deprecated `color.withOpacity(0.5)`
4. `BuildContext context` als erstes Argument in `StatelessWidget`-Hilfsmethoden übergeben
5. **`mounted`-Check** vor `context`-Zugriff nach jedem `async`-Gap in `StatefulWidget`
