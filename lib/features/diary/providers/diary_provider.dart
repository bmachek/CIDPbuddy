import 'package:flutter/material.dart';
import '../../../core/database/database.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

class DiaryProvider extends ChangeNotifier {
  final AppDatabase _db;

  DiaryProvider(this._db);

  Stream<List<InfusionLogData>> get infusionLogsStream => _db.watchInfusionLogs();
  Stream<List<DiaryEntry>> get diaryEntriesStream => _db.watchDiaryEntries();

  Stream<List<dynamic>> get combinedEntriesStream {
    return Rx.combineLatest4<List<InfusionLogData>, List<DiaryEntry>, List<PendingOrder>, List<Medication>, List<dynamic>>(
      _db.watchInfusionLogs(),
      _db.watchDiaryEntries(),
      _db.watchConfirmedOrders(),
      _db.watchAllMedications(),
      (logs, entries, orders, meds) {
        final List<dynamic> combined = [...logs, ...entries, ...orders];
        
        // Add mediation status events
        for (var med in meds) {
          combined.add(MedicationEvent(med, med.createdAt, MedicationEventType.created));
          if (med.discontinuedAt != null) {
            combined.add(MedicationEvent(med, med.discontinuedAt!, MedicationEventType.discontinued));
          }
        }

        combined.sort((a, b) {
          final aDate = _getDate(a);
          final bDate = _getDate(b);
          return bDate.compareTo(aDate);
        });
        return combined;
      },
    );
  }

  DateTime _getDate(dynamic entry) {
    if (entry is InfusionLogData) return entry.date;
    if (entry is DiaryEntry) return entry.date;
    if (entry is PendingOrder) return entry.deliveryDate ?? DateTime.now();
    if (entry is MedicationEvent) return entry.date;
    return DateTime.now();
  }

  Future<void> logInfusion({
    required int medicationId,
    required double dosage,
    String? batchNumber,
    String? notes,
    double? bodyWeight,
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
        bodyWeight: Value(bodyWeight),
      ));
    });

    notifyListeners();
  }
}

enum MedicationEventType { created, discontinued }

class MedicationEvent {
  final Medication medication;
  final DateTime date;
  final MedicationEventType type;

  MedicationEvent(this.medication, this.date, this.type);
}
