import 'package:drift/drift.dart';
import '../database/database.dart';
import '../../features/reminders/services/notification_service.dart';

class SchedulerService {
  final AppDatabase db;

  SchedulerService(this.db);

  /// Synchronizes planned infusions from active schedules.
  /// Generates missing entries for the next 90 days.
  Future<void> syncPlannedInfusions() async {
    final activeSchedules = await db.getAllActiveSchedules();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lookAhead = today.add(const Duration(days: 90));

    for (final schedule in activeSchedules) {
      final dates = _calculateDates(schedule, today, lookAhead);
      for (final date in dates) {
        // Find existing entries for this EXACT time
        final existingEvents = await (db.select(db.plannedInfusions)
          ..where((t) => t.scheduleId.equals(schedule.id) & 
                         t.date.equals(date)))
          .get();

        if (existingEvents.isEmpty) {
          final id = await db.insertPlannedInfusion(PlannedInfusionsCompanion.insert(
            date: date,
            medicationId: schedule.medicationId,
            dosage: schedule.dosage,
            scheduleId: Value(schedule.id),
          ));
          
          // Schedule notifications for this specific treatment
          if (date.isAfter(now)) {
            final treatment = await (db.select(db.plannedInfusions)..where((t) => t.id.equals(id))).getSingle();
            await NotificationService().scheduleTreatmentReminders(treatment);
          }
        }
      }
    }
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
