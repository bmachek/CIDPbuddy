import 'package:drift/drift.dart';
import 'connection/connection.dart' as c;

part 'database.g.dart';

enum MedicationType { infusion, pill }

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get dosage => text().withDefault(const Constant(''))();
  TextColumn get pzn => text().nullable()();
  RealColumn get stock => real().withDefault(const Constant(0.0))();
  RealColumn get minStock => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withLength(min: 1, max: 20)(); // e.g., "Flasche", "ml", "Stk"
  IntColumn get type => intEnum<MedicationType>().withDefault(const Constant(0))(); // default infusion
  RealColumn get packageSize => real().withDefault(const Constant(1.0))();
  BoolColumn get trackBatchNumber => boolean().withDefault(const Constant(true))();
  BoolColumn get trackWeight => boolean().withDefault(const Constant(true))();
  BoolColumn get useTimer => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get discontinuedAt => dateTime().nullable()();
}

class Accessories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get stock => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withLength(min: 1, max: 20)(); // e.g., "Stk", "Pack"
  RealColumn get packageSize => real().withDefault(const Constant(1.0))();
}

class InfusionLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  RealColumn get dosage => real()();
  TextColumn get batchNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get bodyWeight => real().nullable()();
  TextColumn get photoPath => text().nullable()();
}

class MedicationAccessories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  IntColumn get accessoryId => integer().references(Accessories, #id)();
  RealColumn get defaultQuantity => real().withDefault(const Constant(1.0))();
  BoolColumn get isMandatory => boolean().withDefault(const Constant(false))();
}

class PlannedInfusions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  RealColumn get dosage => real()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get scheduleId => integer().nullable().references(InfusionSchedules, #id)();
  RealColumn get bodyWeight => real().nullable()();
}

class InfusionSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  RealColumn get dosage => real()();
  TextColumn get frequencyType => text()(); // 'daily', 'interval', 'weekly', 'weekdays'
  IntColumn get intervalValue => integer().nullable()(); // for 'interval' and 'weekly' (e.g., every 2 weeks)
  TextColumn get selectedWeekdays => text().nullable()(); // comma separated: '1,3,5'
  DateTimeColumn get startDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get intakeTimes => text().nullable()(); // comma separated: '08:00,20:00'
}

class PendingOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  RealColumn get medicationQty => real()();
  DateTimeColumn get deliveryDate => dateTime().nullable()();
  BoolColumn get isConfirmed => boolean().withDefault(const Constant(false))();
}

class PendingOrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(PendingOrders, #id)();
  IntColumn get medicationId => integer().nullable().references(Medications, #id)();
  IntColumn get accessoryId => integer().nullable().references(Accessories, #id)();
  RealColumn get quantity => real()();
}

class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  
  // Vitals
  RealColumn get systolicBP => real().nullable()();
  RealColumn get diastolicBP => real().nullable()();
  IntColumn get heartRate => integer().nullable()();
  RealColumn get temperature => real().nullable()();
  RealColumn get weight => real().nullable()();
  
  // CIDP Symptoms
  IntColumn get strengthScore => integer().nullable()(); // Kraft
  IntColumn get sensoryScore => integer().nullable()();  // Gefühl
  IntColumn get fatigueScore => integer().nullable()();  // Erschöpfung
  IntColumn get painScore => integer().nullable()();     // Schmerzen
  IntColumn get balanceScore => integer().nullable()();  // Gleichgewicht
  
  TextColumn get notes => text().nullable()();
}

@DriftDatabase(tables: [Medications, Accessories, InfusionLog, MedicationAccessories, PlannedInfusions, InfusionSchedules, PendingOrders, PendingOrderItems, DiaryEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 12; // Incremented schema version to 12 for Medications dosage and InfusionLog photoPath

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(infusionSchedules);
        await m.addColumn(plannedInfusions, plannedInfusions.scheduleId);
      }
      if (from < 3) {
        await m.addColumn(medications, medications.type);
        await m.addColumn(infusionSchedules, infusionSchedules.intakeTimes);
      }
      if (to >= 4 && from < 4) {
        await m.addColumn(infusionLog, infusionLog.bodyWeight);
        await m.addColumn(plannedInfusions, plannedInfusions.bodyWeight);
      }
      if (to >= 5 && from < 5) {
        await m.createTable(pendingOrders);
      }
      if (to >= 6 && from < 6) {
        await m.createTable(pendingOrderItems);
      }
      if (to >= 7 && from < 7) {
        await m.addColumn(medications, medications.packageSize);
        await m.addColumn(accessories, accessories.packageSize);
      }
      if (to >= 9 && from < 9) {
        await m.addColumn(medications, medications.trackBatchNumber);
        await m.addColumn(medications, medications.trackWeight);
        await m.addColumn(medications, medications.useTimer);
      }
      if (to >= 10 && from < 10) {
        await m.addColumn(medicationAccessories, medicationAccessories.isMandatory);
      }
      if (to >= 11 && from < 11) {
        // SQLite doesn't allow adding a NOT NULL column with a non-constant default (like CURRENT_TIMESTAMP)
        // via ALTER TABLE. We'll add it with a constant timestamp (current time) instead.
        final nowTs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await customStatement('ALTER TABLE medications ADD COLUMN created_at INTEGER NOT NULL DEFAULT $nowTs');
        await m.addColumn(medications, medications.discontinuedAt);
      }
      if (to >= 12 && from < 12) {
        await m.addColumn(medications, medications.dosage);
        await m.addColumn(infusionLog, infusionLog.photoPath);
      }
    },
  );

  // Medications
  Future<List<Medication>> getAllActiveMedications() => (select(medications)..where((t) => t.discontinuedAt.isNull())).get();
  Stream<List<Medication>> watchActiveMedications() => (select(medications)..where((t) => t.discontinuedAt.isNull())).watch();
  Stream<List<Medication>> watchDiscontinuedMedications() => (select(medications)..where((t) => t.discontinuedAt.isNotNull())).watch();
  Future<List<Medication>> getAllMedications() => select(medications).get();
  Stream<List<Medication>> watchAllMedications() => select(medications).watch();
  Future<int> insertMedication(MedicationsCompanion med) =>
      into(medications).insert(med);
  Future updateMedication(Medication med) => update(medications).replace(med);
  Future deleteMedication(Medication med) => delete(medications).delete(med);

  // Accessories
  Future<List<Accessory>> getAllAccessories() => select(accessories).get();
  Stream<List<Accessory>> watchAllAccessories() => select(accessories).watch();
  Future<int> insertAccessory(AccessoriesCompanion acc) =>
      into(accessories).insert(acc);
  Future updateAccessory(Accessory acc) => update(accessories).replace(acc);
  Future deleteAccessory(Accessory acc) => delete(accessories).delete(acc);

  // Infusions
  Stream<List<InfusionLogData>> watchInfusionLogs() =>
      (select(infusionLog)..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])).watch();
  Future<int> insertInfusionLog(InfusionLogCompanion log) =>
      into(infusionLog).insert(log);
  Future deleteInfusionLog(int id) =>
      (delete(infusionLog)..where((t) => t.id.equals(id))).go();
  Future updateInfusionLog(InfusionLogData log) =>
      update(infusionLog).replace(log);

  // Medication - Accessory Link (BOM)
  Future<List<MedicationAccessory>> getAccessoriesForMedication(int medId) =>
      (select(medicationAccessories)..where((t) => t.medicationId.equals(medId))).get();
  Stream<List<MedicationAccessory>> watchAccessoriesForMedication(int medId) =>
      (select(medicationAccessories)..where((t) => t.medicationId.equals(medId))).watch();
  Future<int> insertMedicationAccessory(MedicationAccessoriesCompanion entry) =>
      into(medicationAccessories).insert(entry);
  Future<List<MedicationAccessory>> getAllMedicationAccessories() => select(medicationAccessories).get();
  Stream<List<MedicationAccessory>> watchAllMedicationAccessories() => select(medicationAccessories).watch();
  Future updateMedicationAccessory(MedicationAccessory entry) =>
      update(medicationAccessories).replace(entry);

  // Planned Infusions / Treatments
  Stream<List<PlannedInfusion>> watchPlannedInfusions() =>
      (select(plannedInfusions)..where((t) => t.isCompleted.equals(false))..orderBy([(t) => OrderingTerm(expression: t.date)])).watch();
  
  Stream<List<PlannedInfusion>> watchTodayPlannedTreatments() => watchUpcomingPlannedTreatments(24);
  
  Stream<List<PlannedInfusion>> watchPlannedTreatmentsRange({required int daysBack, required int daysForward}) {
    final now = DateTime.now();
    final startRange = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysBack));
    final endRange = DateTime(now.year, now.month, now.day).add(Duration(days: daysForward + 1));
    
    return (select(plannedInfusions)
      ..where((t) => t.date.isBetweenValues(startRange, endRange) & t.isCompleted.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.date)]))
      .watch();
  }

  Stream<List<PlannedInfusion>> watchUpcomingPlannedTreatments(int hours) {
    final now = DateTime.now();
    final endRange = now.add(Duration(hours: hours));
    
    return (select(plannedInfusions)
      ..where((t) => t.date.isBetweenValues(now.subtract(const Duration(hours: 12)), endRange) & t.isCompleted.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.date)]))
      .watch()
      .map((list) {
        // Filter: for each scheduleId, only keep the first occurrence (next one)
        // items without scheduleId (manual appointments) are always included
        final Map<int, PlannedInfusion> nextPerSchedule = {};
        final List<PlannedInfusion> results = [];
        
        for (var item in list) {
          if (item.scheduleId == null) {
            results.add(item);
          } else {
            if (!nextPerSchedule.containsKey(item.scheduleId)) {
              nextPerSchedule[item.scheduleId!] = item;
              results.add(item);
            }
          }
        }
        return results;
      });
  }

  Future<int> insertPlannedInfusion(PlannedInfusionsCompanion entry) =>
      into(plannedInfusions).insert(entry);
  Future completePlannedInfusion(int id) =>
      (update(plannedInfusions)..where((t) => t.id.equals(id))).write(const PlannedInfusionsCompanion(isCompleted: Value(true)));
  Future deletePlannedInfusionsForSchedule(int scheduleId) =>
      (delete(plannedInfusions)..where((t) => t.scheduleId.equals(scheduleId) & t.isCompleted.equals(false))).go();
  Future deletePlannedInfusion(int id) =>
      (delete(plannedInfusions)..where((t) => t.id.equals(id))).go();
  Future updatePlannedInfusion(PlannedInfusion entry) =>
      update(plannedInfusions).replace(entry);

  Future deleteIncompletePlannedInfusionsBefore(DateTime date) =>
      (delete(plannedInfusions)..where((t) => t.date.isSmallerThan(Constant(date)) & t.isCompleted.equals(false))).go();

  // Schedules
  Stream<List<InfusionSchedule>> watchSchedules() => select(infusionSchedules).watch();
  Future<List<InfusionSchedule>> getAllActiveSchedules() => (select(infusionSchedules)..where((t) => t.isActive.equals(true))).get();
  Future<int> insertSchedule(InfusionSchedulesCompanion entry) => into(infusionSchedules).insert(entry);
  Future deleteSchedule(int id) => (delete(infusionSchedules)..where((t) => t.id.equals(id))).go();
  Future updateSchedule(InfusionSchedule schedule) => update(infusionSchedules).replace(schedule);

  // Pending Orders
  Stream<List<PendingOrder>> watchPendingOrders() =>
      (select(pendingOrders)..where((t) => t.isConfirmed.equals(false))..orderBy([(t) => OrderingTerm(expression: t.deliveryDate)])).watch();
  Stream<List<PendingOrder>> watchConfirmedOrders() =>
      (select(pendingOrders)..where((t) => t.isConfirmed.equals(true))..orderBy([(t) => OrderingTerm(expression: t.deliveryDate, mode: OrderingMode.desc)])).watch();
  Future<int> insertPendingOrder(PendingOrdersCompanion entry) => into(pendingOrders).insert(entry);
  Future deletePendingOrder(int id) => (delete(pendingOrders)..where((t) => t.id.equals(id))).go();
  Future updatePendingOrder(PendingOrder entry) => update(pendingOrders).replace(entry);

  Future<int> insertPendingOrderItem(PendingOrderItemsCompanion entry) => into(pendingOrderItems).insert(entry);
  Future<List<PendingOrderItem>> getPendingOrderItems(int orderId) => (select(pendingOrderItems)..where((t) => t.orderId.equals(orderId))).get();
  Stream<List<PendingOrderItem>> watchAllPendingOrderItems() {
    return (select(pendingOrderItems).join([
      innerJoin(pendingOrders, pendingOrders.id.equalsExp(pendingOrderItems.orderId)),
    ])..where(pendingOrders.isConfirmed.equals(false)))
    .watch()
    .map((rows) => rows.map((row) => row.readTable(pendingOrderItems)).toList());
  }

  Future confirmOrder(int orderId) async {
    final items = await getPendingOrderItems(orderId);
    
    await transaction(() async {
      for (var item in items) {
        if (item.medicationId != null) {
          final med = await (select(medications)..where((t) => t.id.equals(item.medicationId!))).getSingle();
          await update(medications).replace(med.copyWith(stock: med.stock + item.quantity));
        } else if (item.accessoryId != null) {
          final acc = await (select(accessories)..where((t) => t.id.equals(item.accessoryId!))).getSingle();
          await update(accessories).replace(acc.copyWith(stock: acc.stock + item.quantity));
        }
      }
      await (update(pendingOrders)..where((t) => t.id.equals(orderId))).write(PendingOrdersCompanion(isConfirmed: Value(true)));
    });
  }

  // Diary Entries
  Stream<List<DiaryEntry>> watchDiaryEntries() => (select(diaryEntries)..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])).watch();
  Future<int> insertDiaryEntry(DiaryEntriesCompanion entry) => into(diaryEntries).insert(entry);
  Future updateDiaryEntry(DiaryEntry entry) => update(diaryEntries).replace(entry);
  Future deleteDiaryEntry(int id) => (delete(diaryEntries)..where((t) => t.id.equals(id))).go();

  Future discontinueMedication(int id) async {
    await transaction(() async {
      await (update(medications)..where((t) => t.id.equals(id)))
          .write(MedicationsCompanion(discontinuedAt: Value(DateTime.now())));
      // Also deactivate all schedules for this medication
      await (update(infusionSchedules)..where((t) => t.medicationId.equals(id)))
          .write(const InfusionSchedulesCompanion(isActive: Value(false)));
      // Delete upcoming planned infusions
      await (delete(plannedInfusions)..where((t) => t.medicationId.equals(id) & t.isCompleted.equals(false))).go();
    });
  }

  Future reenrollMedication(int id) async {
    await (update(medications)..where((t) => t.id.equals(id)))
        .write(const MedicationsCompanion(discontinuedAt: Value.absent()));
  }

  Future<List<InfusionLogData>> getConfirmedBestellungenHistory() async {
    // This is a helper for the history view
    return []; // Placeholder if needed, but I'll use raw streams in UI
  }
}

QueryExecutor _openConnection() => c.openConnection();
