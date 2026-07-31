import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import '../../../core/services/scheduler_service.dart';
import 'package:drift/drift.dart' show Value;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // iOS registers notification actions via a category attached to the
  // request, unlike Android where actions are inlined per-notification.
  static const String treatmentReminderCategoryId = 'treatment_reminder_actions';

  Future<void> init({bool isBackground = false}) async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('notification_icon');
    final DarwinInitializationSettings darwinSettings = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          treatmentReminderCategoryId,
          actions: [
            DarwinNotificationAction.plain('complete_infusion', 'Erledigt'),
            DarwinNotificationAction.plain('skip_infusion', 'Überspringen'),
          ],
        ),
      ],
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    tz.initializeTimeZones();
    
    // Create the background service channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'background_service',
      'Hintergrunddienst',
      description: 'Wird für den Timer und Hintergrund-Tasks verwendet',
      importance: Importance.min,
    );
    
    const AndroidNotificationChannel stockChannel = AndroidNotificationChannel(
      'stock_warnings',
      'Bestands-Warnungen',
      description: 'Benachrichtigt dich, wenn Medikamente oder Zubehör zur Neige gehen',
      importance: Importance.high,
    );

    const AndroidNotificationChannel missedChannel = AndroidNotificationChannel(
      'missed_treatments',
      'Verpasste Einnahmen',
      description: 'Hinweise auf nicht bestätigte oder verpasste Einnahmen',
      importance: Importance.high,
    );

    const AndroidNotificationChannel backupFailureChannel = AndroidNotificationChannel(
      'backup_failures',
      'Backup-Fehler',
      description: 'Benachrichtigungen bei Problemen mit der automatischen Datensicherung',
      importance: Importance.high,
    );
    const AndroidNotificationChannel backupWarningChannel = AndroidNotificationChannel(
      'backup_warnings',
      'Backup-Warnungen',
      description: 'Hinweise zur Einrichtung der Datensicherung',
      importance: Importance.defaultImportance,
    );

    const AndroidNotificationChannel medRemindersChannel = AndroidNotificationChannel(
      'med_reminders',
      'Medikamenten Erinnerungen',
      description: 'Erinnerungen für geplante Einnahmen und Infusionen',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel premedTimerChannel = AndroidNotificationChannel(
      'premed_timer',
      'Vormedikation Timer',
      description: 'Laufender Timer für die Vormedikation',
      importance: Importance.high,
    );

    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      await androidPlugin.createNotificationChannel(stockChannel);
      await androidPlugin.createNotificationChannel(missedChannel);
      await androidPlugin.createNotificationChannel(backupFailureChannel);
      await androidPlugin.createNotificationChannel(backupWarningChannel);
      await androidPlugin.createNotificationChannel(medRemindersChannel);
      await androidPlugin.createNotificationChannel(premedTimerChannel);
    }

    if (!isBackground) {
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        String timeZoneName = timeZoneInfo.identifier;
        
        // Handle weird results like "TimezoneInfo" or null
        if (timeZoneName.isEmpty || timeZoneName == "TimezoneInfo") {
          debugPrint('NotificationService: Received invalid timezone string "$timeZoneName". Using fallback.');
          timeZoneName = "Europe/Berlin";
        }

        try {
          tz.setLocalLocation(tz.getLocation(timeZoneName));
          debugPrint('NotificationService: Timezone set to $timeZoneName');
        } catch (e) {
          debugPrint('NotificationService: Location "$timeZoneName" not found, falling back to UTC: $e');
          tz.setLocalLocation(tz.getLocation('UTC'));
        }
      } catch (e) {
        debugPrint('NotificationService: Error getting local timezone: $e. Falling back to UTC.');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } else {
      // In background isolate, just default to UTC or keep existing
      // We don't need to query FlutterTimezone here as it might lead to plugin isolate errors
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
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
    String? payload,
    bool showAction = true,
  }) async {
    try {
      final scheduleMode = await _getScheduleMode();
      
      final List<AndroidNotificationAction>? actions = showAction ? [
        const AndroidNotificationAction(
          'complete_infusion',
          'Erledigt',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'skip_infusion',
          'Überspringen',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ] : null;

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'med_reminders',
            'Medikamenten Erinnerungen',
            importance: Importance.max,
            priority: Priority.high,
            visibility: NotificationVisibility.public,
            showWhen: true,
            enableVibration: true,
            fullScreenIntent: false,
            actions: actions,
            // Re-using the same ID updates the notification. 
            // We use 'onlyAlertOnce: false' to ensure it makes sound again when replaced.
            onlyAlertOnce: false, 
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: showAction ? treatmentReminderCategoryId : null,
          ),
          macOS: DarwinNotificationDetails(
            categoryIdentifier: showAction ? treatmentReminderCategoryId : null,
          ),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('NotificationService: Failed to schedule notification $id: $e');
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint('NotificationService: Notification tapped: ${response.payload}');
    if (response.payload != null) {
      final id = int.tryParse(response.payload!);
      if (id != null) {
        if (response.actionId == 'complete_infusion') {
          _handleCompleteInfusion(id);
        } else if (response.actionId == 'skip_infusion') {
          _handleSkipInfusion(id);
        }
      } else if (response.payload == 'open_backup_settings') {
        // This is handled in the UI usually, but we can log it
        debugPrint('NotificationService: Backup settings requested via notification');
      }
    }
  }

  static Future<void> _handleCompleteInfusion(int treatmentId) async {
    try {
      await NotificationService()._notificationsPlugin.cancel(treatmentId * 100);
      final db = AppDatabase();
      // 1. Mark as completed
      await db.completePlannedInfusion(treatmentId);
      
      // 2. Log infusion if possible (pills or no extra tracking)
      // Note: For background isolation, we use a simple DB update.
      // Full logging with stock deduction is better done when the app is open
      // or via a dedicated service that doesn't rely on Provider.
      
      // We'll fetch the medication details first
      final treatment = await (db.select(db.plannedInfusions)..where((t) => t.id.equals(treatmentId))).getSingle();
      final med = await (db.select(db.medications)..where((t) => t.id.equals(treatment.medicationId))).getSingle();
      
      if (!med.trackBatchNumber && !med.trackWeight && !med.useTimer) {
        // Automatic logging for simple items
        await db.transaction(() async {
          // Reduce stock
          await db.updateMedication(med.copyWith(stock: med.stock - treatment.dosage));
          
          // Reduce accessory stock
          final accessories = await db.getAccessoriesForMedication(med.id);
          for (final link in accessories) {
            final acc = await (db.select(db.accessories)..where((t) => t.id.equals(link.accessoryId))).getSingle();
            await db.updateAccessory(acc.copyWith(stock: acc.stock - link.defaultQuantity));
          }

          // Insert log
          await db.insertInfusionLog(InfusionLogCompanion.insert(
            date: treatment.date,
            medicationId: med.id,
            dosage: treatment.dosage,
            notes: const Value('Via Benachrichtigung erledigt'),
          ));
        });
      }
      
      // Cancel other reminders for this treatment and refresh the "verpasst"
      // summary so it does not keep listing a treatment that is now done.
      await NotificationService().cancelTreatmentReminders(treatmentId);
      await SchedulerService(db).checkMissedTreatments();
      debugPrint('NotificationService: Treatment $treatmentId marked as completed via notification action.');
    } catch (e) {
      debugPrint('NotificationService: Error handling complete infusion: $e');
    }
  }

  static Future<void> _handleSkipInfusion(int treatmentId) async {
    try {
      await NotificationService()._notificationsPlugin.cancel(treatmentId * 100);
      final db = AppDatabase();
      // Mark as completed but with a note that it was skipped
      final treatment = await (db.select(db.plannedInfusions)..where((t) => t.id.equals(treatmentId))).getSingle();
      await db.updatePlannedInfusion(treatment.copyWith(
        isCompleted: true,
        notes: Value('${treatment.notes ?? ''} [Übersprungen via Benachrichtigung]'.trim()),
      ));
      
      // Cancel other reminders
      await NotificationService().cancelTreatmentReminders(treatmentId);
      await SchedulerService(db).checkMissedTreatments();
      debugPrint('NotificationService: Treatment $treatmentId skipped via notification action.');
    } catch (e) {
      debugPrint('NotificationService: Error handling skip infusion: $e');
    }
  }

  Future<void> scheduleTreatmentReminders(PlannedInfusion treatment) async {
    final now = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    final quietStart = prefs.getInt('quiet_hours_start') ?? 22;
    final quietEnd = prefs.getInt('quiet_hours_end') ?? 6;

    bool isQuiet(DateTime time) {
      final hour = time.hour;
      if (quietStart > quietEnd) {
        return hour >= quietStart || hour < quietEnd;
      } else {
        return hour >= quietStart && hour < quietEnd;
      }
    }

    // Each follow-up gets its own ID in the per-treatment block [baseId, baseId+99].
    // Using the same ID would cause zonedSchedule to overwrite earlier alarms,
    // so only the last-scheduled reminder would ever fire.
    final int baseId = _getBaseId(treatment.id);

    // Always cancel the whole block first so a re-schedule cleans up stale entries.
    await cancelTreatmentReminders(treatment.id);

    // 1. Initial notification at the treatment time.
    if (treatment.date.isAfter(now) && !isQuiet(treatment.date)) {
      await scheduleNotification(
        id: baseId,
        title: 'Erinnerung: Medikament fällig',
        body: 'Es ist Zeit für deine Einnahme von ${_getMedName(treatment)}.',
        scheduledTime: treatment.date,
        payload: treatment.id.toString(),
      );
    }

    final snoozeEnabled = prefs.getBool('reminder_snooze') ?? true;
    final hourlyEnabled = prefs.getBool('reminder_hourly') ?? true;
    final snoozeIntervalMin = prefs.getInt('reminder_snooze_interval') ?? 15;

    // 2. Snooze follow-ups (3 reminders at the configured interval) — distinct
    // IDs so they coexist. Default 15 min → 15/30/45 min after the treatment.
    if (snoozeEnabled) {
      for (int i = 1; i <= 3; i++) {
        final time = treatment.date.add(Duration(minutes: i * snoozeIntervalMin));
        if (time.isAfter(now) && !isQuiet(time)) {
          await scheduleNotification(
            id: baseId + i,
            title: 'Erinnerung (Wiederholung)',
            body: 'Du hast deine Einnahme noch nicht als erledigt markiert.',
            scheduledTime: time,
            payload: treatment.id.toString(),
          );
        }
      }
    }

    // 3. Hourly follow-ups (+1h / +2h / +3h) — distinct IDs so they coexist.
    if (hourlyEnabled) {
      for (int i = 1; i <= 3; i++) {
        final time = treatment.date.add(Duration(hours: i));
        if (time.isAfter(now) && !isQuiet(time)) {
          await scheduleNotification(
            id: baseId + 10 + i,
            title: 'Erinnerung (Stündlich)',
            body: 'Bitte vergiss deine Einnahme nicht.',
            scheduledTime: time,
            payload: treatment.id.toString(),
          );
        }
      }
    }
  }

  Future<void> cancelTreatmentReminders(int treatmentId) async {
    final baseId = _getBaseId(treatmentId);
    // Main slot + 3 snooze slots + 3 hourly slots.
    await _notificationsPlugin.cancel(baseId);
    for (int i = 1; i <= 3; i++) {
      await _notificationsPlugin.cancel(baseId + i);
      await _notificationsPlugin.cancel(baseId + 10 + i);
    }
  }

  /// Cancels all scheduled notifications.
  /// Note: This is a heavy operation but useful during full resync.
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Number of currently pending (scheduled but not yet delivered) requests.
  /// Used to stay under iOS's undocumented ~64-pending-request ceiling,
  /// which Android has no equivalent of.
  Future<int> getPendingNotificationCount() async {
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    return pending.length;
  }

  // Offsets within a treatment's reminder block [baseId, baseId+13]:
  // baseId (initial), +1..+3 (snooze), +11..+13 (hourly).
  static const Set<int> _treatmentReminderOffsets = {0, 1, 2, 3, 11, 12, 13};

  /// Cancels orphaned treatment-reminder alarms whose backing PlannedInfusion
  /// no longer exists (e.g. left over after a medication was discontinued or
  /// deleted while the OS alarms were still pending). [validTreatmentIds] are
  /// the ids of planned infusions that should keep their reminders.
  Future<void> cancelOrphanTreatmentReminders(Set<int> validTreatmentIds) async {
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      for (final req in pending) {
        final id = req.id;
        if (id < 100) continue; // reserved/system ids live below the treatment range
        final offset = id % 100;
        if (!_treatmentReminderOffsets.contains(offset)) continue;
        final treatmentId = id ~/ 100;
        if (!validTreatmentIds.contains(treatmentId)) {
          await _notificationsPlugin.cancel(id);
          debugPrint('NotificationService: Cancelled orphaned reminder $id (treatment $treatmentId).');
        }
      }
    } catch (e) {
      debugPrint('NotificationService: Failed to sweep orphaned reminders: $e');
    }
  }

  int _getBaseId(int treatmentId) {
    // Ensure treatment IDs don't collide with timer IDs (which are 999+)
    return treatmentId * 100;
  }

  static const int _timerCompletionId = 9998;

  Future<void> scheduleTimerCompletionNotification(DateTime endTime) async {
    await cancelTimerCompletionNotification();
    try {
      final scheduleMode = await _getScheduleMode();
      await _notificationsPlugin.zonedSchedule(
        _timerCompletionId,
        'Vormedikation abgeschlossen',
        'Der Timer ist abgelaufen — Infusion kann beginnen.',
        // Use UTC explicitly: the background isolate sets tz.local = UTC,
        // so fromMillisecondsSinceEpoch with tz.UTC is always correct
        tz.TZDateTime.fromMillisecondsSinceEpoch(
          tz.UTC,
          endTime.millisecondsSinceEpoch,
        ),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'premed_timer',
            'Vormedikation Timer',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('NotificationService: Failed to schedule timer completion: $e');
    }
  }

  Future<void> cancelTimerCompletionNotification() async {
    await _notificationsPlugin.cancel(_timerCompletionId);
  }

  Future<void> cancelPremedicationTimer() async {
    // Cancel IDs in the timer range
    for (int i = 1; i <= 60; i++) {
      for (int repeat = 0; repeat < 3; repeat++) {
        await _notificationsPlugin.cancel(999 + (i * 10) + repeat);
      }
    }
    await cancelTimerProgress();
    await cancelTimerCompletionNotification();
  }

  Future<void> showTimerProgress(int minutes, int seconds) async {
    final title = 'Vormedikation Timer';
    final content = 'Verbleibend: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    await _notificationsPlugin.show(
      9999, // Specific ID for timer progress
      title,
      content,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'premed_timer',
          'Vormedikation Timer',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
          showWhen: false,
          onlyAlertOnce: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelTimerProgress() async {
    await _notificationsPlugin.cancel(9999);
  }

  Future<void> showMissedTreatmentsNotification(List<String> items) async {
    const int missedId = 5555;
    if (items.isEmpty) {
      await _notificationsPlugin.cancel(missedId);
      return;
    }

    final summary = items.length == 1
        ? items.first
        : '${items.length} Einnahmen nicht bestätigt';
    final body = items.join('\n');

    await _notificationsPlugin.show(
      missedId,
      'Verpasste Einnahmen',
      summary,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'missed_treatments',
          'Verpasste Einnahmen',
          channelDescription: 'Hinweise auf nicht bestätigte oder verpasste Einnahmen',
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: 'Verpasste Einnahmen',
            summaryText: '${items.length} offen',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelMissedTreatmentsNotification() async {
    await _notificationsPlugin.cancel(5555);
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

  String _getMedName(PlannedInfusion treatment) {
    // Return a generic name if med details aren't passed
    return 'deines Medikaments';
  }

  Future<void> scheduleBackupReminder() async {
    const int backupReminderId = 7777;
    
    // Schedule for 10:00 AM every day
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      backupReminderId,
      'Datensicherung einrichten',
      'Deine Daten sind noch nicht automatisch gesichert. Tippe hier, um das Backup zu konfigurieren.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'backup_warnings',
          'Backup-Warnungen',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'open_backup_settings',
    );
    debugPrint('NotificationService: Daily backup reminder scheduled for 10:00.');
  }

  Future<void> cancelBackupReminder() async {
    await _notificationsPlugin.cancel(7777);
  }

  Future<void> showBackupFailureNotification(String error) async {
    await _notificationsPlugin.show(
      6666, // Constant ID for backup failure
      'Backup fehlgeschlagen',
      'Das automatische Backup konnte nicht erstellt werden: $error',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'backup_failures',
          'Backup-Fehler',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.red,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'open_backup_settings',
    );
  }

  Future<void> cancelBackupFailureNotification() async {
    await _notificationsPlugin.cancel(6666);
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint('NotificationService: Background action triggered: ${response.actionId}');
  if (response.payload != null) {
    final id = int.tryParse(response.payload!);
    if (id != null) {
      if (response.actionId == 'complete_infusion') {
        _handleCompleteInfusionInBackground(id);
      } else if (response.actionId == 'skip_infusion') {
        _handleSkipInfusionInBackground(id);
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> _cancelTreatmentBlock(
    FlutterLocalNotificationsPlugin plugin, int treatmentId) async {
  final baseId = treatmentId * 100;
  await plugin.cancel(baseId);
  for (int i = 1; i <= 3; i++) {
    await plugin.cancel(baseId + i);
    await plugin.cancel(baseId + 10 + i);
  }
}

@pragma('vm:entry-point')
Future<void> _handleSkipInfusionInBackground(int treatmentId) async {
  try {
    final notifPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('notification_icon');
    await notifPlugin.initialize(const InitializationSettings(android: androidSettings));
    await _cancelTreatmentBlock(notifPlugin, treatmentId);
    final db = AppDatabase();
    final treatment = await (db.select(db.plannedInfusions)..where((t) => t.id.equals(treatmentId))).getSingle();
    await db.updatePlannedInfusion(treatment.copyWith(
      isCompleted: true,
      notes: Value('${treatment.notes ?? ''} [Übersprungen via Benachrichtigung]'.trim()),
    ));
    await SchedulerService(db).checkMissedTreatments();

    debugPrint('NotificationService: Background: Treatment $treatmentId skipped.');
  } catch (e) {
    debugPrint('NotificationService: Background: Error skipping: $e');
  }
}

@pragma('vm:entry-point')
Future<void> _handleCompleteInfusionInBackground(int treatmentId) async {
  try {
    final notifPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('notification_icon');
    await notifPlugin.initialize(const InitializationSettings(android: androidSettings));
    await _cancelTreatmentBlock(notifPlugin, treatmentId);
    final db = AppDatabase();
    // 1. Mark as completed
    await db.completePlannedInfusion(treatmentId);
    
    // We'll fetch the medication details
    final treatment = await (db.select(db.plannedInfusions)..where((t) => t.id.equals(treatmentId))).getSingle();
    final med = await (db.select(db.medications)..where((t) => t.id.equals(treatment.medicationId))).getSingle();
    
    if (!med.trackBatchNumber && !med.trackWeight && !med.useTimer) {
      // Automatic logging for simple items
      await db.transaction(() async {
        // Reduce stock
        await db.updateMedication(med.copyWith(stock: med.stock - treatment.dosage));
        
        // Reduce accessory stock
        final accessories = await db.getAccessoriesForMedication(med.id);
        for (final link in accessories) {
          final acc = await (db.select(db.accessories)..where((t) => t.id.equals(link.accessoryId))).getSingle();
          await db.updateAccessory(acc.copyWith(stock: acc.stock - link.defaultQuantity));
        }

        // Insert log
        await db.insertInfusionLog(InfusionLogCompanion.insert(
          date: treatment.date,
          medicationId: med.id,
          dosage: treatment.dosage,
          notes: const Value('Via Benachrichtigung erledigt'),
        ));
      });
    }
    await SchedulerService(db).checkMissedTreatments();

    debugPrint('NotificationService: Background: Treatment $treatmentId processed.');
  } catch (e) {
    debugPrint('NotificationService: Background: Error: $e');
  }
}
