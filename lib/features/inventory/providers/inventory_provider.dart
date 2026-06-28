import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import '../../reminders/services/notification_service.dart';
import 'package:drift/drift.dart';

class InventoryProvider extends ChangeNotifier {
  final AppDatabase _db;

  InventoryProvider(this._db);

  Stream<List<Medication>> get medicationsStream => _db.watchActiveMedications();
  Stream<List<Medication>> get discontinuedMedicationsStream => _db.watchDiscontinuedMedications();
  Stream<List<Accessory>> get accessoriesStream => _db.watchAllAccessories();

  /// Cancels any OS-scheduled reminders for a medication's planned infusions.
  /// Must run before the rows are deleted, since the database layer has no
  /// access to the NotificationService.
  Future<void> _cancelRemindersForMedication(int medId) async {
    final planned = await _db.getPlannedInfusionsForMedication(medId);
    for (final p in planned) {
      await NotificationService().cancelTreatmentReminders(p.id);
    }
  }

  Future<void> discontinueMedication(int id) async {
    await _cancelRemindersForMedication(id);
    await _db.discontinueMedication(id);
    notifyListeners();
  }

  Future<void> deleteMedication(Medication med) async {
    await _cancelRemindersForMedication(med.id);
    await _db.deleteMedication(med);
    notifyListeners();
  }

  Future<void> reenrollMedication(int id) async {
    await _db.reenrollMedication(id);
    notifyListeners();
  }

  Future<int> addMedication({
    required String name,
    required String dosage,
    required String pzn,
    required double stock,
    required String unit,
    required MedicationType type,
    double packageSize = 1.0,
    double minStock = 5.0,
    bool trackBatchNumber = true,
    bool trackWeight = true,
    bool useTimer = false,
  }) async {
    final id = await _db.insertMedication(MedicationsCompanion.insert(
      name: name,
      dosage: Value(dosage),
      pzn: Value(pzn),
      stock: Value(stock),
      unit: unit,
      type: Value(type),
      packageSize: Value(packageSize),
      minStock: Value(minStock),
      trackBatchNumber: Value(type == MedicationType.pill ? false : trackBatchNumber),
      trackWeight: Value(type == MedicationType.pill ? false : trackWeight),
      useTimer: Value(type == MedicationType.pill ? false : useTimer),
    ));
    notifyListeners();
    return id;
  }

  Future<void> updateMedication(Medication med) async {
    await _db.updateMedication(med);
    notifyListeners();
  }

  Future<void> addAccessory({
    required String name,
    required double stock,
    required String unit,
    double packageSize = 1.0,
    double minStock = 0.0,
  }) async {
    await _db.insertAccessory(AccessoriesCompanion.insert(
      name: name,
      stock: Value(stock),
      unit: unit,
      packageSize: Value(packageSize),
      minStock: Value(minStock),
    ));
    notifyListeners();
  }

  Future<void> updateMedicationStock(Medication med, double delta) async {
    final newStock = med.stock + delta;
    await updateMedication(med.copyWith(stock: newStock));
  }

  Future<void> updateAccessoryStock(Accessory acc, double delta) async {
    final newStock = acc.stock + delta;
    await _db.updateAccessory(acc.copyWith(stock: newStock));
    notifyListeners();
  }
}
