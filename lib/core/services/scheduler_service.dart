import 'dart:io';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../../features/reminders/services/notification_service.dart';

class SchedulerService {
  final AppDatabase db;

  SchedulerService(this.db);

  /// Synchronizes planned infusions from active schedules.
  /// Generates missing entries for the next 90 days.
  /// Notifications are scheduled only for the next 7 days to avoid Android's
  /// alarm limits, and further capped on iOS to stay under its pending-request ceiling.
  Future<void> syncPlannedInfusions() async {
    // Self-heal: drop exact-duplicate active schedules from the old double-tap
    // bug and cancel their now-removed reminders. Without this, every duplicate
    // keeps generating its own valid planned infusions and alarms, so a single
    // medication can fire dozens of reminders at the same time.
    final removedReminderIds = await db.dedupeActiveSchedules();
    for (final id in removedReminderIds) {
      try {
        await NotificationService().cancelTreatmentReminders(id);
      } catch (e) {
        // Best-effort: a failed cancel must not abort the rest of the sync.
      }
    }

    final activeSchedules = await db.getAllActiveSchedules();
    // Skip schedules whose medication no longer exists (e.g. a restore whose
    // backup referenced an absent medication). Generating for them would
    // recreate orphaned planned infusions on every sync — actionless rows that
    // can neither be confirmed nor permanently removed.
    final existingMedIds = (await db.getAllMedications()).map((m) => m.id).toSet();
    final validSchedules =
        activeSchedules.where((s) => existingMedIds.contains(s.medicationId)).toList();
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

    for (final schedule in validSchedules) {
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

    // Phase 2: Ensure all uncompleted entries within the reminder window have reminders.
    // Snooze/hourly follow-ups extend up to 3h after treatment.date, so a sync that
    // runs shortly after the intake time must still re-schedule those follow-ups —
    // otherwise the user gets no reminder at all once treatment.date has passed.
    final reminderWindowStart = now.subtract(const Duration(hours: 3));

    // Cancel reminders for any treatment that might currently hold pending alarms
    // in our window. Reminders for completed treatments are also cleared.
    final allKnownTreatments = await (db.select(db.plannedInfusions)
          ..where((t) => t.date.isBiggerThanValue(reminderWindowStart)))
        .get();
    for (final t in allKnownTreatments) {
      await NotificationService().cancelTreatmentReminders(t.id);
    }

    // Re-schedule for everything still actionable. scheduleTreatmentReminders
    // skips individual slots whose time has already passed. Ordered soonest
    // first so the iOS budget below (if it runs out) drops the furthest-out
    // treatments rather than an arbitrary DB-order subset.
    final upcomingTreatments = await (db.select(db.plannedInfusions)
          ..where((t) =>
              t.date.isBiggerThanValue(reminderWindowStart) &
              t.date.isSmallerThanValue(notificationLookAhead) &
              t.isCompleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();

    // iOS silently drops any local notification scheduled once ~64 requests
    // are pending — with no error, just no alarm. Each treatment can add up
    // to 7 (initial + 3 snooze + 3 hourly), so a handful of multi-dose
    // medications in the 7-day window blow past that easily. Stop scheduling
    // once we'd risk hitting the ceiling instead of losing reminders at
    // random; Android has no such limit so it keeps its previous behavior.
    int? remainingIosBudget;
    if (Platform.isIOS) {
      const iosSafePendingLimit = 60;
      final pendingNow = await NotificationService().getPendingNotificationCount();
      remainingIosBudget = iosSafePendingLimit - pendingNow;
    }

    for (final treatment in upcomingTreatments) {
      if (remainingIosBudget != null) {
        if (remainingIosBudget <= 0) break;
        remainingIosBudget -= 7;
      }
      await NotificationService().scheduleTreatmentReminders(treatment);
    }

    // Phase 3: Sweep orphaned OS alarms. Reminders scheduled before a medication
    // was discontinued/deleted can outlive their PlannedInfusion rows and keep
    // firing. Cancel any pending treatment reminder that no longer maps to an
    // existing planned infusion. This self-heals devices that accumulated stale
    // alarms (e.g. from duplicate schedules created by a double-tap).
    final allPlanned = await db.select(db.plannedInfusions).get();
    final validIds = allPlanned.map((e) => e.id).toSet();
    await NotificationService().cancelOrphanTreatmentReminders(validIds);
  }

  /// Marks a planned treatment as done and clears everything the OS still
  /// holds for it: its own reminder block plus the "Verpasste Einnahmen"
  /// summary.
  ///
  /// Refreshing the summary here is what makes an in-app confirmation actually
  /// silence the notification. It is a plain `show()` notification that only
  /// gets recomputed by [checkMissedTreatments] — on startup, in the periodic
  /// background sync and in the backup worker. On iOS none of those run while
  /// the app is in the foreground (the background service's periodic timer is
  /// starved and `onIosBackground` is a no-op), so without this the stale
  /// "verpasst" banner sat in Notification Center until the next cold start.
  Future<void> completeTreatment(int treatmentId) async {
    await db.completePlannedInfusion(treatmentId);
    await NotificationService().cancelTreatmentReminders(treatmentId);
    await checkMissedTreatments();
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
