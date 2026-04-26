import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../../features/reminders/services/notification_service.dart';

class SchedulerService {
  final AppDatabase db;

  SchedulerService(this.db);

  /// Synchronizes planned infusions from active schedules.
  /// Generates missing entries for the next 90 days.
  /// Notifications are scheduled only for the next 7 days to avoid Android alarm limits.
  Future<void> syncPlannedInfusions() async {
    final activeSchedules = await db.getAllActiveSchedules();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lookAhead = today.add(const Duration(days: 90));
    final notificationLookAhead = today.add(const Duration(days: 7));

    // Phase 1: Generate missing entries
    // Bulk fetch existing entries for efficiency
    final existingEntries = await (db.select(db.plannedInfusions)
          ..where((t) => t.date.isBetweenValues(today, lookAhead)))
        .get();

    // Create a lookup for efficiency
    final existingSet = existingEntries
        .map((e) => '${e.scheduleId}_${e.date.toIso8601String()}')
        .toSet();

    for (final schedule in activeSchedules) {
      final dates = _calculateDates(schedule, today, lookAhead);
      for (final date in dates) {
        final key = '${schedule.id}_${date.toIso8601String()}';
        
        if (!existingSet.contains(key)) {
          final id = await db.insertPlannedInfusion(PlannedInfusionsCompanion.insert(
            date: date,
            medicationId: schedule.medicationId,
            dosage: schedule.dosage,
            scheduleId: Value(schedule.id),
          ));
          
          // Schedule notifications for this specific treatment if it's within the notification window
          if (date.isAfter(now) && date.isBefore(notificationLookAhead)) {
            final treatment = PlannedInfusion(
              id: id,
              date: date,
              medicationId: schedule.medicationId,
              dosage: schedule.dosage,
              scheduleId: schedule.id,
              isCompleted: false,
              notes: null,
              bodyWeight: null,
            );
            await NotificationService().scheduleTreatmentReminders(treatment);
          }
        }
      }
    }

    // Phase 2: Ensure all upcoming UNCOMPLETED entries within the notification window have reminders
    // First, clear all existing notifications to avoid hitting the 500 limit with stale/duplicate alarms
    await NotificationService().cancelAllNotifications();

    final upcomingTreatments = await (db.select(db.plannedInfusions)
          ..where((t) => 
              t.date.isBiggerThanValue(now) & 
              t.date.isSmallerThanValue(notificationLookAhead) &
              t.isCompleted.equals(false)))
        .get();
        
    for (final treatment in upcomingTreatments) {
      await NotificationService().scheduleTreatmentReminders(treatment);
    }
  }

  /// Surfaces past-due Einnahmen that were never confirmed or skipped.
  /// Defensive fallback for cases where scheduled alarms get lost
  /// (e.g. after an OS update or boot before the BootReceiver runs).
  Future<void> checkMissedTreatments() async {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 7));

    final missed = await (db.select(db.plannedInfusions)
          ..where((t) =>
              t.date.isSmallerThanValue(now) &
              t.date.isBiggerThanValue(cutoff) &
              t.isCompleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();

    if (missed.isEmpty) {
      await NotificationService().cancelMissedTreatmentsNotification();
      return;
    }

    final medIds = missed.map((t) => t.medicationId).toSet().toList();
    final meds = await (db.select(db.medications)
          ..where((m) => m.id.isIn(medIds)))
        .get();
    final medNames = {for (final m in meds) m.id: m.name};

    final dateFmt = DateFormat('dd.MM. HH:mm');
    final items = missed
        .map((t) => '${dateFmt.format(t.date)} – ${medNames[t.medicationId] ?? 'Medikament'}')
        .toList();

    await NotificationService().showMissedTreatmentsNotification(items);
  }

  List<DateTime> _calculateDates(InfusionSchedule schedule, DateTime start, DateTime end) {
    List<DateTime> dates = [];
    // Ensure we start from midnight of the set start date
    DateTime current = DateTime(schedule.startDate.year, schedule.startDate.month, schedule.startDate.day);

    // Safety check to prevent infinite loops
    int iterations = 0;
    const int maxIterations = 5000;

    while (current.isBefore(end) && iterations < maxIterations) {
      iterations++;
      
      // Only include if date is not in the past relative to 'start' (today)
      final bool isTooOld = current.isBefore(start);

      if (!isTooOld) {
        bool matches = false;
        switch (schedule.frequencyType) {
          case 'daily':
          case 'interval':
          case 'weekly':
            matches = true;
            break;
          case 'weekdays':
            final weekdays = schedule.selectedWeekdays?.split(',').map(int.tryParse).whereType<int>().toList() ?? [];
            if (weekdays.contains(current.weekday)) {
              matches = true;
            }
            break;
        }
        if (matches) {
          // Add entries for each intake time if specified, otherwise just midnight
          if (schedule.intakeTimes != null && schedule.intakeTimes!.isNotEmpty) {
            final times = schedule.intakeTimes!.split(',');
            for (final tStr in times) {
              final parts = tStr.trim().split(':');
              if (parts.length == 2) {
                final hh = int.tryParse(parts[0]) ?? 8;
                final mm = int.tryParse(parts[1]) ?? 0;
                dates.add(DateTime(current.year, current.month, current.day, hh, mm));
              }
            }
          } else {
            dates.add(current);
          }
        }
      }

      // Increment logic - using DateTime constructor is safer for DST transitions than Duration(days: X)
      switch (schedule.frequencyType) {
        case 'daily':
        case 'weekdays':
          current = DateTime(current.year, current.month, current.day + 1);
          break;
        case 'interval':
          final interval = schedule.intervalValue ?? 1;
          current = DateTime(current.year, current.month, current.day + interval);
          break;
        case 'weekly':
          final weeks = schedule.intervalValue ?? 1;
          current = DateTime(current.year, current.month, current.day + (7 * weeks));
          break;
        default:
          return dates;
      }
    }
    return dates;
  }
}
