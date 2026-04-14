import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get pzn => text().nullable()();
  RealColumn get stock => real().withDefault(const Constant(0.0))();
  RealColumn get minStock => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withLength(min: 1, max: 20)(); // e.g., "Vials", "ml"
}

class Accessories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get stock => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withLength(min: 1, max: 20)(); // e.g., "Stk", "Pack"
}

class InfusionLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  RealColumn get dosage => real()();
  TextColumn get batchNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
}

class MedicationAccessories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  IntColumn get accessoryId => integer().references(Accessories, #id)();
  RealColumn get defaultQuantity => real().withDefault(const Constant(1.0))();
}

class PlannedInfusions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  RealColumn get dosage => real()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Medications, Accessories, InfusionLog, MedicationAccessories, PlannedInfusions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Medications
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

  // Medication - Accessory Link (BOM)
  Future<List<MedicationAccessory>> getAccessoriesForMedication(int medId) =>
      (select(medicationAccessories)..where((t) => t.medicationId.equals(medId))).get();
  Future<int> insertMedicationAccessory(MedicationAccessoriesCompanion entry) =>
      into(medicationAccessories).insert(entry);

  // Planned Infusions
  Stream<List<PlannedInfusion>> watchPlannedInfusions() =>
      (select(plannedInfusions)..where((t) => t.isCompleted.equals(false))..orderBy([(t) => OrderingTerm(expression: t.date)])).watch();
  Future<int> insertPlannedInfusion(PlannedInfusionsCompanion entry) =>
      into(plannedInfusions).insert(entry);
  Future completePlannedInfusion(int id) =>
      (update(plannedInfusions)..where((t) => t.id.equals(id))).write(const PlannedInfusionsCompanion(isCompleted: Value(true)));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'igkeeper.sqlite'));
    return NativeDatabase(file);
  });
}
