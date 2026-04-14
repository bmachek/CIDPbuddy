import 'package:drift/drift.dart';
import '../database/database.dart';

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
        // Robust existence check: check for any entry within this day in local time.
        // Drift converts these local DateTimes to UTC ranges correctly in the SQL query.
        final dayEnd = date.add(const Duration(hours: 23, minutes: 59, seconds: 59));
        
        final existingEvents = await (db.select(db.plannedInfusions)
          ..where((t) => t.scheduleId.equals(schedule.id) & 
                         t.date.isBetweenValues(date, dayEnd)))
          .get();

        if (existingEvents.isEmpty) {
          await db.insertPlannedInfusion(PlannedInfusionsCompanion.insert(
            date: date,
            medicationId: schedule.medicationId,
            dosage: schedule.dosage,
            scheduleId: Value(schedule.id),
          ));
        } else if (existingEvents.length > 1) {
          // Cleanup logic: If we have multiple entries for the same day and schedule,
          // keep one and remove the others (as long as they aren't completed).
          // We keep the first one found.
          for (int i = 1; i < existingEvents.length; i++) {
            if (!existingEvents[i].isCompleted) {
              await db.deletePlannedInfusion(existingEvents[i].id);
            }
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
          dates.add(current);
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
