import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/database.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('notification_icon');
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

  Future<void> scheduleTreatmentReminders(PlannedInfusion treatment) async {
    final now = DateTime.now();
    if (treatment.date.isBefore(now)) return;

    final prefs = await SharedPreferences.getInstance();
    final quietStart = prefs.getInt('quiet_hours_start') ?? 22;
    final quietEnd = prefs.getInt('quiet_hours_end') ?? 7;

    bool isQuiet(DateTime time) {
      final hour = time.hour;
      if (quietStart > quietEnd) {
        return hour >= quietStart || hour < quietEnd;
      } else {
        return hour >= quietStart && hour < quietEnd;
      }
    }

    // 1. Initial notification
    if (!isQuiet(treatment.date)) {
      await scheduleNotification(
        id: _getBaseId(treatment.id),
        title: 'Erinnerung: Medikament fällig',
        body: 'Es ist Zeit für deine Einnahme.',
        scheduledTime: treatment.date,
      );
    }

    final snoozeEnabled = prefs.getBool('reminder_snooze') ?? true;
    final hourlyEnabled = prefs.getBool('reminder_hourly') ?? true;

    // 2. Snooze chain (15, 30, 45 mins)
    if (snoozeEnabled) {
      for (int i = 1; i <= 3; i++) {
        final snoozeTime = treatment.date.add(Duration(minutes: i * 15));
        if (!isQuiet(snoozeTime)) {
          await scheduleNotification(
            id: _getBaseId(treatment.id) + i,
            title: 'Erinnerung (Snooze)',
            body: 'Du hast deine Einnahme noch nicht als erledigt markiert.',
            scheduledTime: snoozeTime,
          );
        }
      }
    }

    // 3. Hourly pings (1, 2, 3 hours later)
    if (hourlyEnabled) {
      for (int i = 1; i <= 3; i++) {
        final hourlyTime = treatment.date.add(Duration(hours: i));
        if (!isQuiet(hourlyTime)) {
          await scheduleNotification(
            id: _getBaseId(treatment.id) + 10 + i,
            title: 'Erinnerung (Stündlich)',
            body: 'Bitte vergiss nicht deine Medikamente einzunehmen.',
            scheduledTime: hourlyTime,
          );
        }
      }
    }
  }

  Future<void> cancelTreatmentReminders(int treatmentId) async {
    final baseId = _getBaseId(treatmentId);
    // Cancel main + snoozes
    for (int i = 0; i <= 3; i++) {
      await _notificationsPlugin.cancel(baseId + i);
    }
    // Cancel hourlys
    for (int i = 1; i <= 3; i++) {
      await _notificationsPlugin.cancel(baseId + 10 + i);
    }
  }

  int _getBaseId(int treatmentId) {
    // Ensure treatment IDs don't collide with timer IDs (which are 999+)
    return treatmentId * 100;
  }

  Future<void> schedulePremedicationTimer(int minutes) async {
    // ... existing implementation ...
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
