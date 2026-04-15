import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import 'package:drift/drift.dart';

class InventoryProvider extends ChangeNotifier {
  final AppDatabase _db;

  InventoryProvider(this._db);

  Stream<List<Medication>> get medicationsStream => _db.watchActiveMedications();
  Stream<List<Medication>> get discontinuedMedicationsStream => _db.watchDiscontinuedMedications();
  Stream<List<Accessory>> get accessoriesStream => _db.watchAllAccessories();

  Future<void> discontinueMedication(int id) async {
    await _db.discontinueMedication(id);
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
  }) async {
    await _db.insertAccessory(AccessoriesCompanion.insert(
      name: name,
      stock: Value(stock),
      unit: unit,
      packageSize: Value(packageSize),
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
