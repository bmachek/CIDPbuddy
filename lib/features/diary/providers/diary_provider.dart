import 'package:flutter/material.dart';
import 'package:igkeeper/core/database/database.dart';
import 'package:drift/drift.dart';

class DiaryProvider extends ChangeNotifier {
  final AppDatabase _db;

  DiaryProvider(this._db);

  Stream<List<InfusionLogData>> get infusionLogsStream => _db.watchInfusionLogs();

  Future<void> logInfusion({
    required int medicationId,
    required double dosage,
    String? batchNumber,
    String? notes,
    DateTime? date,
  }) async {
    // 1. Transaction to ensure database integrity
    await _db.transaction(() async {
      // 2. Reduce medication stock
      final med = await (_db.select(_db.medications)..where((t) => t.id.equals(medicationId))).getSingle();
      await _db.updateMedication(med.copyWith(stock: med.stock - dosage));

      // 3. Find and reduce accessory stock (BOM logic)
      final accessories = await _db.getAccessoriesForMedication(medicationId);
      for (final link in accessories) {
        final acc = await (_db.select(_db.accessories)..where((t) => t.id.equals(link.accessoryId))).getSingle();
        await _db.updateAccessory(acc.copyWith(stock: acc.stock - link.defaultQuantity));
      }

      // 4. Create log entry
      await _db.insertInfusionLog(InfusionLogCompanion.insert(
        date: date ?? DateTime.now(),
        medicationId: medicationId,
        dosage: dosage,
        batchNumber: Value(batchNumber),
        notes: Value(notes),
      ));
    });

    notifyListeners();
  }
}
