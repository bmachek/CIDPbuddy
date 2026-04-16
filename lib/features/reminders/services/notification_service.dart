import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../core/database/database.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init({bool isBackground = false}) async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('notification_icon');
    const DarwinInitializationSettings darwinSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    tz.initializeTimeZones();
    
    // Create the background service channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'background_service',
      'Hintergrunddienst',
      description: 'Wird für den Timer und Hintergrund-Tasks verwendet',
      importance: Importance.low,
    );
    
    const AndroidNotificationChannel stockChannel = AndroidNotificationChannel(
      'stock_warnings',
      'Bestands-Warnungen',
      description: 'Benachrichtigt dich, wenn Medikamente oder Zubehör zur Neige gehen',
      importance: Importance.high,
    );

    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      await androidPlugin.createNotificationChannel(stockChannel);
    }

    try {
      final timeZoneNameValue = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timeZoneNameValue.toString();
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('NotificationService: Timezone set to $timeZoneName');
      } catch (e) {
        debugPrint('NotificationService: Invalid timezone name "$timeZoneName", falling back to UTC: $e');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      debugPrint('NotificationService: Could not get local timezone, falling back to UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    
    // Request permission for Android 13+ notifications
    // IMPORTANT: Only request permission in the main UI app, not in background isolate
    if (androidPlugin != null && !isBackground) {
      try {
        final status = await androidPlugin.requestNotificationsPermission();
        debugPrint('NotificationService: Android notifications permission status: $status');
        
        // For Android 14+, exact alarms need explicit permission or it will fallback to inexact
        final exactStatus = await androidPlugin.requestExactAlarmsPermission();
        debugPrint('NotificationService: Android exact alarms permission status: $exactStatus');
      } catch (e) {
        debugPrint('NotificationService: Failed to request permissions: $e');
      }
    }
  }

  Future<AndroidScheduleMode> _getScheduleMode() async {
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return AndroidScheduleMode.inexactAllowWhileIdle;
    
    final bool? canScheduleExact = await androidPlugin.canScheduleExactNotifications();
    return (canScheduleExact ?? false) 
        ? AndroidScheduleMode.exactAllowWhileIdle 
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final scheduleMode = await _getScheduleMode();
      
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
            visibility: NotificationVisibility.public,
            showWhen: true,
            enableVibration: true,
            fullScreenIntent: false,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('NotificationService: Failed to schedule notification $id: $e');
      // If we hit the alarm limit, we shouldn't crash the whole app
    }
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

  /// Cancels all scheduled notifications. 
  /// Note: This is a heavy operation but useful during full resync.
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
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
            
        final scheduleMode = await _getScheduleMode();
            
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
          androidScheduleMode: scheduleMode,
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

  Future<void> showStockWarningNotification(List<String> lowItems) async {
    if (lowItems.isEmpty) return;
    
    final itemsText = lowItems.join(", ");
    
    await _notificationsPlugin.show(
      8888, // Constant ID for stock warning to overwrite previous ones
      'Bestellung empfohlen',
      'Niedriger Bestand: $itemsText',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'stock_warnings',
          'Bestands-Warnungen',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }
}
