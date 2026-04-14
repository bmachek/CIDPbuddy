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
    final lookAhead = now.add(const Duration(days: 90));

    for (final schedule in activeSchedules) {
      final dates = _calculateDates(schedule, now, lookAhead);
      for (final date in dates) {
        // We use year, month, day comparison to avoid time-of-day mismatches
        final exists = await (db.select(db.plannedInfusions)
          ..where((t) => t.scheduleId.equals(schedule.id) & 
                         t.date.year.equals(date.year) & 
                         t.date.month.equals(date.month) & 
                         t.date.day.equals(date.day)))
          .getSingleOrNull();

        if (exists == null) {
          await db.insertPlannedInfusion(PlannedInfusionsCompanion.insert(
            date: date,
            medicationId: schedule.medicationId,
            dosage: schedule.dosage,
            scheduleId: Value(schedule.id),
          ));
        }
      }
    }
  }

  List<DateTime> _calculateDates(InfusionSchedule schedule, DateTime start, DateTime end) {
    List<DateTime> dates = [];
    DateTime current = schedule.startDate;

    // Safety check to prevent infinite loops
    int iterations = 0;
    const int maxIterations = 5000;

    while (current.isBefore(end) && iterations < maxIterations) {
      iterations++;
      
      // Only include if date is not in the past (relative to 'start')
      // but we allow today.
      final bool isTooOld = current.isBefore(DateTime(start.year, start.month, start.day));

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
          dates.add(DateTime(current.year, current.month, current.day));
        }
      }

      // Fixed increment logic
      switch (schedule.frequencyType) {
        case 'daily':
        case 'weekdays':
          current = current.add(const Duration(days: 1));
          break;
        case 'interval':
          current = current.add(Duration(days: schedule.intervalValue ?? 1));
          break;
        case 'weekly':
          current = current.add(Duration(days: 7 * (schedule.intervalValue ?? 1)));
          break;
        default:
          return dates;
      }
    }
    return dates;
  }
}
