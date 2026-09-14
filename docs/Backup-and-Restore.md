# Backup & restore

## Overview

CIDPbuddy backs up the entire SQLite database as a ZIP file. Backups are created automatically after database changes and periodically in the background.

## Backup destinations

Exactly **one** destination is active at any time. It is stored in `SharedPreferences` and loaded for each backup via `BackupDestination.load()`.

| Destination | `DestinationKind` | Platform | Description |
|-------------|-------------------|----------|-------------|
| Folder | `local` | All | A directory in the file system. On iOS always the app-internal `Documents/Backups` folder (no folder picker is available) |
| SAF folder | `saf` | Android | A folder picked through the Storage Access Framework, e.g. on the SD card or inside a cloud provider |

> There is **no** direct cloud backup to Google Drive or iCloud. To back up to the cloud, pick
> a SAF folder on Android that a cloud client keeps in sync.

**iOS note:** the app-internal destination does not outlive the app (`isDurable == false`) — iOS
deletes the container along with the app. iOS also reassigns the container UUID on *every* app
update, which is why the portable marker `app-documents:Backups` is persisted instead of an
absolute path and resolved against the current container on each load.

## Backup flow

### Auto-backup

```
DB change
  → debounce(30s)
  → auto-backup disabled? → abort
  → last successful backup < 6 hours ago? → skip
  → verifyAccess() on the destination (write/read/delete a token file)
  → build a ZIP of the SQLite file
  → write it to the configured destination
  → keep the 5 newest, delete older ones
```

### File name

```
cidpbuddy_backup_YYYYMMDD_HHmmss.zip
```

> Note: when listing and restoring, the older `igkeeper_backup_` prefix is also recognised as a fallback.

### Background backup (Android)

WorkManager runs `BackupWorker` periodically. The worker survives device reboots (it is re-registered at boot).

## Error handling

| Setting | Value |
|---------|-------|
| Failure threshold | 2 consecutive failures |
| Failure storage | SharedPreferences: `backup_last_error`, `backup_consecutive_failures` |
| Notification | Once the failure threshold is reached |

The **reliability check** page (`reliability_check_page.dart`) shows:
- Backup status (enabled/disabled)
- Time of the last success
- Last error message
- Number of consecutive failures

Backup error messages are localized: `BackupService` and the `BackupDestination` implementations resolve the stored language through `LocaleProvider.l10nForBackground()`, because they run from background isolates that have no `BuildContext`. `BackupDestination.displayLabel` is the exception — it takes `AppLocalizations` as a parameter, since its only callers are widgets that already have it.

## Restore

1. Settings → pick a backup destination → show backups
2. Select a backup from the list → restore
3. The ZIP is read and unpacked
4. The local DB file (`igkeeper.sqlite`) is replaced — including the WAL/SHM side files, if the archive contains them
5. The `AppDatabase` singleton is rebuilt
6. The app shows the restored data

> **Important:** because `AppDatabase` is a singleton, the connection must be rebuilt in a
> controlled way during restore to avoid leaking connections.
