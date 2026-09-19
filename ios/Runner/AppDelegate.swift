import Flutter
import UIKit
import flutter_local_notifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Kept in sync with `kBackupPeriodicTaskUniqueName` in backup_worker.dart
  /// and with BGTaskSchedulerPermittedIdentifiers in Info.plist. On iOS the
  /// WorkManager *unique* name is the BGTask identifier; the task name never
  /// reaches this side.
  private static let backupTaskIdentifier = "cidpbuddy_periodic_backup_v1"
  private static let missedCheckTaskIdentifier = "cidpbuddy_missed_check_v1"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // iOS never delivers a *non-foreground* notification action ("Erledigt" /
    // "Überspringen") to the running app's isolate. It always spins up a
    // separate headless Flutter engine and runs the background handler there.
    // That engine starts with no plugins registered, so without this callback
    // the handler cannot reach the database or the notification plugin: the
    // intake was never marked done and none of its follow-up reminders were
    // cancelled, so they kept firing every 15/30/45 min and +1/2/3 h.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
      Self.registerAppChannels(with: registry)
    }

    // Same problem, same fix, for the WorkManager isolate: the backup task
    // needs path_provider, shared_preferences and sqlite3 to be registered
    // before it can zip anything — and the bookmark channel on top, or a
    // background backup into a picked folder dies with MissingPluginException.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
      Self.registerAppChannels(with: registry)
    }

    // BGTaskScheduler demands that every launch handler is registered before
    // the app finishes launching, so this cannot move into a later callback.
    // Without it the Dart side's registerPeriodicTask() submits a request for
    // an identifier nobody handles, and iOS silently drops it — which is why
    // the periodic backup never ran on iPhones while it worked on Android.
    //
    // The frequency is the *rescheduling* interval the plugin applies after
    // each run: unlike Android, iOS takes it from here rather than from the
    // Dart call. iOS treats it as a lower bound and decides on its own when
    // (and whether) to actually run the task.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: Self.backupTaskIdentifier,
      frequency: NSNumber(value: 6 * 60 * 60)
    )
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: Self.missedCheckTaskIdentifier,
      frequency: NSNumber(value: 2 * 60 * 60)
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    Self.registerAppChannels(with: engineBridge.pluginRegistry)
  }

  /// The channels this app implements itself, which the generated registrant
  /// knows nothing about. Every engine needs them, not just the one the UI
  /// runs in — see the WorkManager callback above.
  private static func registerAppChannels(with registry: FlutterPluginRegistry) {
    if let registrar = registry.registrar(forPlugin: "BackupBookmarkPlugin") {
      BackupBookmarkPlugin.register(with: registrar)
    }
  }
}
