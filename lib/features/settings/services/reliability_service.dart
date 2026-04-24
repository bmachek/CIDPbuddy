import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'backup_service.dart';

class ReliabilityService {
  static final ReliabilityService _instance = ReliabilityService._internal();
  factory ReliabilityService() => _instance;
  ReliabilityService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<bool> isNotificationPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  Future<bool> isExactAlarmPermissionGranted() async {
    if (!Platform.isAndroid) return true;
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    return await androidPlugin.canScheduleExactNotifications() ?? false;
  }

  Future<bool> isBatteryOptimizationDisabled() async {
    if (!Platform.isAndroid) return true;
    return await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;
  }

  Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
  }

  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // This will take the user to the system settings page for exact alarms
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  Future<void> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;
    await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
  }

  Future<bool> isBackupSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(BackupService.kAutoBackupEnabled) ?? false;
  }

  Future<bool> isLastBackupSuccessful() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTime = prefs.getString(BackupService.kLastBackupTime);
    if (lastTime == null) return false;
    
    // If it was setup but lastTime is older than 2 days, count as failed/outdated
    final lastDate = DateTime.parse(lastTime);
    return DateTime.now().difference(lastDate).inDays < 2;
  }
}
