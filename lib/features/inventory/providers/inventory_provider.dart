import 'dart:async';
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

  Future<void> discontinueMedication(int id) async {
    // Capture reminder ids first (the rows are about to be removed), then run
    // the user-critical DB operation. Reminder cleanup is best-effort and must
    // never block or fail the discontinue itself.
    final reminderIds = await _plannedInfusionIds(id);
    await _db.discontinueMedication(id);
    notifyListeners();
    unawaited(_cancelReminders(reminderIds));
  }

  Future<void> deleteMedication(Medication med) async {
    final reminderIds = await _plannedInfusionIds(med.id);
    await _db.deleteMedication(med);
    notifyListeners();
    unawaited(_cancelReminders(reminderIds));
  }

  /// Ids of a medication's planned infusions, used to cancel their OS reminders.
  /// Returns an empty list on any error so it never blocks discontinue/delete.
  Future<List<int>> _plannedInfusionIds(int medId) async {
    try {
      final planned = await _db.getPlannedInfusionsForMedication(medId);
      return planned.map((p) => p.id).toList();
    } catch (e) {
      debugPrint('InventoryProvider: could not load planned infusions for $medId: $e');
      return const [];
    }
  }

  /// Best-effort cancellation of OS-scheduled reminders. Each call is guarded so
  /// one failure cannot abort the rest, and the whole thing runs unawaited so it
  /// never delays the UI. Any survivors are swept by syncPlannedInfusions.
  Future<void> _cancelReminders(List<int> treatmentIds) async {
    for (final id in treatmentIds) {
      try {
        await NotificationService().cancelTreatmentReminders(id);
      } catch (e) {
        debugPrint('InventoryProvider: could not cancel reminders for $id: $e');
      }
    }
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
