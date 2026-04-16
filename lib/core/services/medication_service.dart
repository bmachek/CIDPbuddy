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

  Future<double?> calculateDaysRemaining(Medication med) async {
    final dailyReq = await getDailyRequirement(med.id);
    if (dailyReq <= 0) return null;
    return med.stock / dailyReq;
  }

  Future<List<Medication>> getLowStockMedications() async {
    final meds = await db.getAllMedications();
    // Filter out items that already have a pending order
    final pendingItems = await db.watchAllPendingOrderItems().first;
    final pendingMedIds = pendingItems.map((o) => o.medicationId).whereType<int>().toSet();

    List<Medication> lowMeds = [];
    for (var med in meds) {
      if (med.minStock <= 0 || pendingMedIds.contains(med.id)) continue;
      final days = await calculateDaysRemaining(med);
      if (days != null && days <= med.minStock) {
        lowMeds.add(med);
      }
    }
    return lowMeds;
  }

  Future<List<Accessory>> getLowStockAccessories() async {
    final allAccs = await db.getAllAccessories();
    final allLinks = await db.getAllMedicationAccessories();
    final pendingItems = await db.watchAllPendingOrderItems().first;
    final pendingAccIds = pendingItems.map((o) => o.accessoryId).whereType<int>().toSet();
    
    List<Accessory> lowAccs = [];
    for (var a in allAccs) {
      if (pendingAccIds.contains(a.id)) continue;

      // If user set a specific minStock > 0, use it
      if (a.minStock > 0) {
        if (a.stock <= a.minStock) {
          lowAccs.add(a);
        }
        continue;
      }
      
      // Fallback to Dashboard logic: 
      // check if this accessory has any link with consumption > 0
      final hasPositiveConsumption = allLinks
          .where((l) => l.accessoryId == a.id)
          .any((l) => l.defaultQuantity > 0);
      
      if (!hasPositiveConsumption) {
        if (a.stock <= 0) lowAccs.add(a);
      } else {
        if (a.stock < 5) lowAccs.add(a);
      }
    }
    return lowAccs;
  }

  Future<List<String>> getLowStockItemsSummary() async {
    final lowMeds = await getLowStockMedications();
    final lowAccs = await getLowStockAccessories();
    
    return [
      ...lowMeds.map((m) => m.name),
      ...lowAccs.map((a) => a.name),
    ];
  }
}
