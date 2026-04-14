import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    tz.initializeTimeZones();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminders',
          'Medikamenten Erinnerungen',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> schedulePremedicationTimer(int minutes) async {
    // Schedule three notifications for each minute mark, spaced 5 seconds apart
    for (int i = 1; i <= minutes; i++) {
      for (int repeat = 0; repeat < 3; repeat++) {
        final scheduledTime = tz.TZDateTime.now(tz.local)
            .add(Duration(minutes: i, seconds: repeat * 5));
            
        await _notificationsPlugin.zonedSchedule(
          999 + (i * 10) + repeat, // Unique ID per minute and repeat
          'Vormedikation Timer',
          'Minute $i von ${minutes > 0 ? minutes : "?"} erreicht.',
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'premed_timer',
              'Vormedikation Timer',
              importance: Importance.max,
              priority: Priority.high,
              enableVibration: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> cancelPremedicationTimer() async {
    // Cancel IDs in the timer range
    for (int i = 1; i <= 60; i++) {
      for (int repeat = 0; repeat < 3; repeat++) {
        await _notificationsPlugin.cancel(999 + (i * 10) + repeat);
      }
    }
  }
}
