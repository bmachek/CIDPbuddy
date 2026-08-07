import Flutter
import UIKit
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
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
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
