import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../features/reminders/services/notification_service.dart';
import '../database/database.dart';
import 'scheduler_service.dart';
import 'package:audioplayers/audioplayers.dart';

@pragma('vm:entry-point')
class BackgroundService {
  static const String timerKey = 'timer_seconds_remaining';
  static const String timerRunningKey = 'timer_is_running';

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: false,
        notificationChannelId: 'background_service',
        initialNotificationTitle: 'Vormedikation Timer',
        initialNotificationContent: 'Timer wird vorbereitet...',
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

    Future<void> stopTimer() async {
      timer?.cancel();
      isRunning = false;
      await notifService.cancelPremedicationTimer();
      service.invoke('timerUpdate', {
        'secondsRemaining': secondsRemaining,
        'isRunning': isRunning,
      });
      
      if (service is AndroidServiceInstance) {
        await service.setAsBackgroundService();
      }
    }

    service.on('startTimer').listen((event) async {
      if (service is AndroidServiceInstance) {
        await service.setAsForegroundService();
      }
      final seconds = event?['seconds'] as int? ?? 15 * 60;
      secondsRemaining = seconds;
      isRunning = true;
      
      timer?.cancel();
      
      // Schedule notifications once as a backup
      await notifService.schedulePremedicationTimer(secondsRemaining ~/ 60);

      timer = Timer.periodic(const Duration(seconds: 1), (t) async {
        if (secondsRemaining > 0) {
          secondsRemaining--;
          
          if (secondsRemaining % 60 == 0 && secondsRemaining > 0) {
            // Minute ping
            try {
              for (int i = 0; i < 3; i++) {
                await audioPlayer.play(AssetSource('audio/ping.mp3'));
                if (i < 2) await Future.delayed(const Duration(milliseconds: 1500));
              }
            } catch (e) {
              debugPrint('Background Ping Error: $e');
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
          }
        } else {
          await stopTimer();
          // Final bell
          try {
            for (int i = 0; i < 4; i++) {
              await audioPlayer.play(AssetSource('audio/bell.mp3'));
              if (i < 3) await Future.delayed(const Duration(milliseconds: 2000));
            }
          } catch (e) {
            debugPrint('Background Bell Error: $e');
          }
        }
      });
    });

    service.on('stopTimer').listen((event) async {
      await stopTimer();
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
      await SchedulerService(db).syncPlannedInfusions();
      // Drift database should be closed after use in background isolates if not kept alive
      // but here we might want to keep it or let it be. AppDatabase() creates a new connection.
      debugPrint('BackgroundService: Periodic sync completed.');
    } catch (e) {
      debugPrint('BackgroundService: Periodic sync failed: $e');
    }
  }
}
