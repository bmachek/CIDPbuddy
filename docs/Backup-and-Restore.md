# Backup & restore

## Overview

CIDPbuddy backs up the entire SQLite database as a ZIP file. Backups are created automatically after database changes and periodically in the background.

## Backup destinations

Exactly **one** destination is active at any time. It is stored in `SharedPreferences` and loaded for each backup via `BackupDestination.load()`.

| Destination | `DestinationKind` | Platform | Description |
|-------------|-------------------|----------|-------------|
| Folder | `local` | All | A directory in the file system. On iOS the app-internal `Documents/Backups` folder, used until a folder is picked |
| SAF folder | `saf` | Android | A folder picked through the Storage Access Framework, e.g. on the SD card or inside a cloud provider |
| Picked folder | `bookmark` | iOS | A folder picked in the Files app — iCloud Drive, Nextcloud, Dropbox, a connected drive — addressed through a security-scoped bookmark |

> There is **no** direct cloud backup through a provider SDK. To get backups into the cloud, pick
> a SAF folder on Android or a Files-app folder on iOS that the provider keeps in sync. That is
> also what makes backups leave the phone automatically: the share sheet needs a human, a picked
> folder does not.

**iOS, app-internal destination:** it does not outlive the app (`isDurable == false`) — iOS
deletes the container along with the app. iOS also reassigns the container UUID on *every* app
update, which is why the portable marker `app-documents:Backups` is persisted instead of an
absolute path and resolved against the current container on each load. The settings screen warns
about this destination and offers the folder picker next to the warning.

**iOS, picked folder:** `file_picker` cannot provide it — its document picker grants access only
for the duration of the pick. `ios/Runner/BackupBookmarkPlugin.swift` does: it presents
`UIDocumentPickerViewController` in folder mode, turns the picked URL into a security-scoped
bookmark and persists that (base64, in the usual `backup_directory_path` pref). Every later
read/write resolves the bookmark, brackets the access with
`startAccessingSecurityScopedResource()` and goes through `NSFileCoordinator`, because the folder
usually belongs to a file provider that syncs it behind the app's back. Two consequences worth
knowing:

- iOS may report a bookmark as **stale** (the folder moved). The native side then hands a
  refreshed token back with the reply and `BookmarkDestination` persists it on the spot; without
  that the destination would die the next time the folder moves.
- A file that iCloud has not downloaded to this phone exists only as a hidden `.name.zip.icloud`
  stub. It is listed under the name it stands for, with size `0` (the restore list then omits the
  size), and the coordinated read downloads it before restoring.

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

### Background backup

| | Android | iOS |
|---|---------|-----|
| Mechanism | WorkManager periodic work | `BGAppRefreshTask` via `BGTaskScheduler` |
| Interval | 6 h, from `BackupScheduler.enable()` | 6 h, from `AppDelegate.swift` — iOS ignores the Dart-side frequency |
| Guarantee | runs, survives reboot (re-registered at boot) | opportunistic: iOS decides when, or whether, based on how the app is used |

The identifier is the WorkManager **unique** name (`cidpbuddy_periodic_backup_v1`). On iOS that is
also the `BGTaskScheduler` identifier, so it has to appear in three places that must stay in sync:
`backup_worker.dart`, `BGTaskSchedulerPermittedIdentifiers` in `Info.plist`, and the
`WorkmanagerPlugin.registerPeriodicTask` call in `AppDelegate.swift`. Miss the plist entry and
iOS refuses the submission; miss the AppDelegate registration and nobody handles the wake-up.

Because iOS hands the *unique* name to the Dart callback where Android hands the *task* name,
`backupCallbackDispatcher` matches both — otherwise the missed-treatment check would run a backup
instead.

Both background engines are headless and start without plugins, so each registrant callback in
`AppDelegate.swift` registers the generated registrant **and**, through `registerAppChannels`,
the backup bookmark channel. Without the latter a background backup into a picked folder fails
with `MissingPluginException`.

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
