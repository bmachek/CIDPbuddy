import 'package:drift/drift.dart';
import '../database/database.dart';

class MedicationService {
  final AppDatabase db;
  MedicationService(this.db);

  Future<double> getDailyRequirement(int medicationId) async {
    final activeSchedules = await (db.select(db.infusionSchedules)
          ..where((t) => t.medicationId.equals(medicationId) & t.isActive.equals(true)))
        .get();

    double dailyReq = 0;
    for (var s in activeSchedules) {
      final intakeCount = s.intakeTimes?.split(',').where((t) => t.isNotEmpty).length ?? 1;
      final dosagePerDay = s.dosage * intakeCount;

      switch (s.frequencyType) {
        case 'daily':
          dailyReq += dosagePerDay;
          break;
        case 'interval':
          dailyReq += dosagePerDay / (s.intervalValue ?? 1);
          break;
        case 'weekly':
          dailyReq += dosagePerDay / (7 * (s.intervalValue ?? 1));
          break;
        case 'weekdays':
          final weekdayCount = s.selectedWeekdays?.split(',').where((t) => t.isNotEmpty).length ?? 0;
          dailyReq += (dosagePerDay * weekdayCount) / 7.0;
          break;
      }
    }
    return dailyReq;
  }

  Future<DateTime?> calculateReachDate(Medication med, {double additionalStock = 0}) async {
    final dailyReq = await getDailyRequirement(med.id);
    if (dailyReq <= 0) return null;

    final days = (med.stock + additionalStock) / dailyReq;
    if (days.isInfinite || days.isNaN) return null;
    
    return DateTime.now().add(Duration(days: days.floor()));
  }
}
