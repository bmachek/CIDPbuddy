import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import 'package:drift/drift.dart';

class InventoryProvider extends ChangeNotifier {
  final AppDatabase _db;

  InventoryProvider(this._db);

  Stream<List<Medication>> get medicationsStream => _db.watchAllMedications();
  Stream<List<Accessory>> get accessoriesStream => _db.watchAllAccessories();

  Future<void> addMedication({
    required String name,
    required String pzn,
    required double stock,
    required String unit,
    required MedicationType type,
  }) async {
    await _db.insertMedication(MedicationsCompanion.insert(
      name: name,
      pzn: Value(pzn),
      stock: Value(stock),
      unit: unit,
      type: Value(type),
    ));
    notifyListeners();
  }

  Future<void> addAccessory({
    required String name,
    required double stock,
    required String unit,
  }) async {
    await _db.insertAccessory(AccessoriesCompanion.insert(
      name: name,
      stock: Value(stock),
      unit: unit,
    ));
    notifyListeners();
  }

  Future<void> updateMedicationStock(Medication med, double delta) async {
    final newStock = med.stock + delta;
    await _db.updateMedication(med.copyWith(stock: newStock));
    notifyListeners();
  }

  Future<void> updateAccessoryStock(Accessory acc, double delta) async {
    final newStock = acc.stock + delta;
    await _db.updateAccessory(acc.copyWith(stock: newStock));
    notifyListeners();
  }
}
