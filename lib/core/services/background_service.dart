import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/reminders/services/notification_service.dart';
import '../database/database.dart';
import 'scheduler_service.dart';
import 'medication_service.dart';
import 'package:audioplayers/audioplayers.dart';

@pragma('vm:entry-point')
class BackgroundService {
  static const String timerKey = 'timer_seconds_remaining';
  static const String timerRunningKey = 'timer_is_running';
  // Persisted across service restarts so the timer survives a force-kill
  static const String timerEndEpochKey = 'timer_end_epoch_ms';

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true, // We use true but the channel importance is MIN, so it's silent but protected
        notificationChannelId: 'background_service',
        initialNotificationTitle: 'CIDP Buddy',
        initialNotificationContent: 'Dienst läuft im Hintergrund',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    final notifService = NotificationService();
    await notifService.init(isBackground: true);

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Timer logic
    Timer? timer;
    int secondsRemaining = 0;
    bool isRunning = false;
    final AudioPlayer audioPlayer = AudioPlayer();
    final prefs = await SharedPreferences.getInstance();

    Future<void> stopTimer() async {
      timer?.cancel();
      isRunning = false;
      await prefs.remove(timerEndEpochKey);
      await notifService.cancelPremedicationTimer();
      service.invoke('timerUpdate', {
        'secondsRemaining': secondsRemaining,
        'isRunning': isRunning,
      });

      if (service is AndroidServiceInstance) {
        await service.setAsBackgroundService();
      }
    }

    Future<void> startTimerWithSeconds(int seconds) async {
      if (service is AndroidServiceInstance) {
        await service.setAsForegroundService();
      }
      secondsRemaining = seconds;
      isRunning = true;
      timer?.cancel();

      // Persist the absolute end time so we can resume after a force-kill
      final endEpoch = DateTime.now().millisecondsSinceEpoch + seconds * 1000;
      await prefs.setInt(timerEndEpochKey, endEpoch);

      // Schedule an exact-alarm notification that fires when the timer ends;
      // this fires even if the service cannot restart in time
      await notifService.scheduleTimerCompletionNotification(
        DateTime.fromMillisecondsSinceEpoch(endEpoch),
      );

      timer = Timer.periodic(const Duration(seconds: 1), (t) async {
        if (secondsRemaining > 0) {
          secondsRemaining--;

          if (secondsRemaining % 60 == 0 && secondsRemaining > 0) {
            // Minute signal (bell sound, 3 times)
            try {
              for (int i = 0; i < 3; i++) {
                await audioPlayer.play(AssetSource('audio/bell.mp3'));
                if (i < 2) await Future.delayed(const Duration(milliseconds: 1500));
              }
            } catch (e) {
              debugPrint('Background Minute Signal Error: $e');
            }
          }

          service.invoke('timerUpdate', {
            'secondsRemaining': secondsRemaining,
            'isRunning': isRunning,
          });

          if (service is AndroidServiceInstance) {
            final mins = secondsRemaining ~/ 60;
            final secs = secondsRemaining % 60;
            service.setForegroundNotificationInfo(
              title: 'Vormedikation Timer',
              content: 'Verbleibend: ${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
            );
            await notifService.showTimerProgress(mins, secs);
          }
        } else {
          await stopTimer();
          // Final signal (ping sound) — the exact-alarm notification was already
          // cancelled by stopTimer so we don't double-alert
          try {
            await audioPlayer.play(AssetSource('audio/ping.mp3'));
          } catch (e) {
            debugPrint('Background Final Signal Error: $e');
          }
        }
      });
    }

    // Auto-resume a timer that was running before the service was force-killed
    final persistedEndEpoch = prefs.getInt(timerEndEpochKey);
    if (persistedEndEpoch != null) {
      final remaining = (persistedEndEpoch - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
      if (remaining > 0) {
        await startTimerWithSeconds(remaining);
      } else {
        // Timer already expired while service was dead; clean up
        await prefs.remove(timerEndEpochKey);
        await notifService.cancelPremedicationTimer();
      }
    }

    service.on('startTimer').listen((event) async {
      final seconds = event?['seconds'] as int? ?? 15 * 60;
      await startTimerWithSeconds(seconds);
    });

    service.on('stopTimer').listen((event) async {
      await stopTimer();
    });

    service.on('getTimerState').listen((event) {
      service.invoke('timerUpdate', {
        'secondsRemaining': secondsRemaining,
        'isRunning': isRunning,
        'hasActiveTimer': isRunning,
      });
    });

    // Periodic tasks (Schedule Sync)
    // Run sync every 24 hours or on start
    Timer.periodic(const Duration(hours: 24), (t) async {
      await _performSync();
    });
    
    // Also perform an initial sync after a short delay
    Future.delayed(const Duration(seconds: 10), () => _performSync());
  }

  static Future<void> _performSync() async {
    try {
      final db = AppDatabase();
      final scheduler = SchedulerService(db);
      await scheduler.syncPlannedInfusions();
      await scheduler.checkMissedTreatments();

      // Perform stock check
      final medService = MedicationService(db);
      final lowItems = await medService.getLowStockItemsSummary();
      if (lowItems.isNotEmpty) {
        await NotificationService().showStockWarningNotification(lowItems);
      }

      debugPrint('BackgroundService: Periodic sync and stock check completed.');
    } catch (e) {
      debugPrint('BackgroundService: Periodic sync failed: $e');
    }
  }
}
