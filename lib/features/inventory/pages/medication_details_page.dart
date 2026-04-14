import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:igkeeper/features/reminders/services/notification_service.dart';
import '../providers/inventory_provider.dart';
import '../../../core/database/database.dart';
import 'package:drift/drift.dart' as drift;
import '../../diary/pages/add_schedule_page.dart';
import 'package:intl/intl.dart';

class MedicationDetailsPage extends StatelessWidget {
  final int medicationId;

  const MedicationDetailsPage({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final invProvider = Provider.of<InventoryProvider>(context);

    return StreamBuilder<Medication>(
      stream: (db.select(db.medications)..where((t) => t.id.equals(medicationId))).watchSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final medication = snapshot.data!;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(medication.name),
                pinned: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditMedicationDialog(context, db, medication),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    onPressed: () => _confirmDeleteMedication(context, db, medication),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('Lagerstand & Warnungen'),
                const SizedBox(height: 12),
                _buildStockAlertConfig(context, db, invProvider, medication),
                const SizedBox(height: 32),
                _buildSectionHeader('Verknüpftes Zubehör'),
                const Text(
                  'Dieses Zubehör wird bei jeder Infusion automatisch vom Bestand abgezogen.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<MedicationAccessory>>(
                  future: db.getAccessoriesForMedication(medication.id),
                  builder: (context, snapshot) {
                    final links = snapshot.data ?? [];
                    if (links.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Text('Noch kein Zubehör verknüpft', style: TextStyle(color: Colors.grey)),
                        ),
                      );
                    }

                    return Column(
                      children: links.map((link) => _buildAccessoryRow(context, db, link)).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showLinkAccessoryDialog(context, db, medication),
                        icon: const Icon(Icons.link_rounded),
                        label: const Text('Verknüpfen'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showCreateAccessoryDialog(context, db, medication),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Neu & Verknüpfen'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                const SizedBox(height: 48),
                _buildSectionHeader('Zeitpläne'),
                const Text(
                  'Lege hier fest, in welchem Rhythmus du dieses Medikament einnimmst.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<InfusionSchedule>>(
                  stream: (db.select(db.infusionSchedules)..where((t) => t.medicationId.equals(medication.id))).watch(),
                  builder: (context, snapshot) {
                    final schedules = snapshot.data ?? [];
                    if (schedules.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Text('Keine Zeitpläne aktiv', style: TextStyle(color: Colors.grey)),
                        ),
                      );
                    }
                    return Column(
                      children: schedules.map((s) => _buildScheduleCard(context, db, s, medication)).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddSchedulePage(preselectedMedicationId: medication.id)),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('Zeitplan erstellen'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showAddAppointmentDialog(context, db, medication),
                  icon: const Icon(Icons.event_rounded),
                  label: const Text('Einmaligen Termin planen'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 48),
                _buildSectionHeader('System-Aktionen'),
                const SizedBox(height: 12),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  },
);
}

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.grey),
    );
  }

  Widget _buildAccessoryRow(BuildContext context, AppDatabase db, MedicationAccessory link) {
    return FutureBuilder<Accessory>(
      future: (db.select(db.accessories)..where((t) => t.id.equals(link.accessoryId))).getSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final acc = snapshot.data!;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: const Icon(Icons.build_circle_rounded, color: Colors.teal),
            title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Bedarf: ${link.defaultQuantity.toStringAsFixed(0)} ${acc.unit}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                  onPressed: () => _showEditAccessoryDialog(context, db, acc),
                ),
                IconButton(
                  icon: const Icon(Icons.link_off_rounded, color: Colors.grey),
                  onPressed: () async {
                    await (db.delete(db.medicationAccessories)..where((t) => t.id.equals(link.id))).go();
                    (context as Element).markNeedsBuild();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditAccessoryDialog(BuildContext context, AppDatabase db, Accessory acc) {
    final nameController = TextEditingController(text: acc.name);
    final unitController = TextEditingController(text: acc.unit);
    final pkgSizeController = TextEditingController(text: acc.packageSize.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zubehör bearbeiten'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(labelText: 'Einheit', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pkgSizeController,
              decoration: const InputDecoration(labelText: 'Packungsgröße (für Bestellung)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await db.updateAccessory(acc.copyWith(
                name: nameController.text,
                unit: unitController.text,
                packageSize: double.tryParse(pkgSizeController.text) ?? 1.0,
              ));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    ).then((_) => (context as Element).markNeedsBuild());
  }

  void _showLinkAccessoryDialog(BuildContext context, AppDatabase db, Medication medication) async {
    final allAcc = await db.getAllAccessories();
    if (!context.mounted) return;

    if (allAcc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zuerst Zubehör anlegen!')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        Accessory? selected;
        final qtyController = TextEditingController(text: '1');

        return AlertDialog(
          title: const Text('Zubehör verknüpfen'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Accessory>(
                items: allAcc.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
                onChanged: (val) => selected = val,
                decoration: const InputDecoration(labelText: 'Zubehör wählen', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Bedarf pro Infusion', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () async {
                if (selected != null) {
                  await db.insertMedicationAccessory(MedicationAccessoriesCompanion.insert(
                    medicationId: medication.id,
                    accessoryId: selected!.id,
                    defaultQuantity: drift.Value(double.tryParse(qtyController.text) ?? 1.0),
                  ));
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Verknüpfen'),
            ),
          ],
        );
      },
    ).then((_) => (context as Element).markNeedsBuild());
  }

  void _showCreateAccessoryDialog(BuildContext context, AppDatabase db, Medication medication) async {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final unitController = TextEditingController(text: 'Stk');
        final stockController = TextEditingController(text: '0');
        final qtyController = TextEditingController(text: '1');
        final pkgSizeController = TextEditingController(text: '1.0');

        return AlertDialog(
          title: const Text('Neues Zubehör anlegen'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name des Zubehörs', border: OutlineInputBorder()),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Einheit (z.B. Stk, Set)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Aktueller Lagerstand', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  decoration: const InputDecoration(labelText: 'Bedarf pro Infusion', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pkgSizeController,
                  decoration: const InputDecoration(labelText: 'Packungsgröße (für Bestellung)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final pkgSize = double.tryParse(pkgSizeController.text) ?? 1.0;
                  final accId = await db.insertAccessory(AccessoriesCompanion.insert(
                    name: nameController.text,
                    stock: drift.Value(double.tryParse(stockController.text) ?? 0.0),
                    unit: unitController.text,
                    packageSize: drift.Value(pkgSize),
                  ));

                  await db.insertMedicationAccessory(MedicationAccessoriesCompanion.insert(
                    medicationId: medication.id,
                    accessoryId: accId,
                    defaultQuantity: drift.Value(double.tryParse(qtyController.text) ?? 1.0),
                  ));
                  
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Anlegen'),
            ),
          ],
        );
      },
    ).then((_) => (context as Element).markNeedsBuild());
  }

  void _showEditMedicationDialog(BuildContext context, AppDatabase db, Medication med) {
    final nameController = TextEditingController(text: med.name);
    final pznController = TextEditingController(text: med.pzn ?? '');
    final unitController = TextEditingController(text: med.unit);
    final pkgSizeController = TextEditingController(text: med.packageSize.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medikament bearbeiten'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pznController,
              decoration: const InputDecoration(labelText: 'PZN', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(labelText: 'Einheit (z.B. Flasche)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pkgSizeController,
              decoration: const InputDecoration(labelText: 'Packungsgröße (für Bestellung)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await db.updateMedication(med.copyWith(
                name: nameController.text,
                pzn: drift.Value(pznController.text),
                unit: unitController.text,
                packageSize: double.tryParse(pkgSizeController.text) ?? 1.0,
              ));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMedication(BuildContext context, AppDatabase db, Medication med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medikament löschen?'),
        content: Text('Möchtest du "${med.name}" wirklich löschen? Alle Verknüpfungen gehen verloren.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () async {
              await db.deleteMedication(med);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to inventory
              }
            },
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog(BuildContext context, AppDatabase db, Medication med) async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final dosageController = TextEditingController(text: '1.0');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Termin planen'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Datum'),
                  subtitle: Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => selectedDate = date);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dosageController,
                  decoration: InputDecoration(labelText: 'Geplante Dosis (${med.unit})', border: const OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
              ElevatedButton(
                onPressed: () async {
                  await db.insertPlannedInfusion(PlannedInfusionsCompanion.insert(
                    date: selectedDate,
                    medicationId: med.id,
                    dosage: double.tryParse(dosageController.text) ?? 1.0,
                    isCompleted: const drift.Value(false),
                  ));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Speichern'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleCard(BuildContext context, AppDatabase db, InfusionSchedule schedule, Medication med) {
    String freqLabel = '';
    switch (schedule.frequencyType) {
      case 'daily': freqLabel = 'Täglich'; break;
      case 'weekly': freqLabel = schedule.intervalValue == 2 ? 'Alle 2 Wochen' : 'Wöchentlich'; break;
      case 'interval': freqLabel = 'Alle ${schedule.intervalValue} Tage'; break;
      case 'weekdays': freqLabel = 'Wochentage'; break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.repeat_rounded, color: Colors.blue),
        ),
        title: Text(freqLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Dosis: ${schedule.dosage} ${med.unit}'),
            if (schedule.intakeTimes != null && schedule.intakeTimes!.isNotEmpty)
              Text('Zeiten: ${schedule.intakeTimes}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddSchedulePage(initialSchedule: schedule)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: () => _confirmDeleteSchedule(context, db, schedule),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSchedule(BuildContext context, AppDatabase db, InfusionSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zeitplan löschen?'),
        content: const Text('Alle zukünftigen (nicht erledigten) Termine dieses Plans werden ebenfalls gelöscht.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () async {
              final futureAppts = await (db.select(db.plannedInfusions)..where((t) => t.scheduleId.equals(schedule.id) & t.isCompleted.equals(false))).get();
              for (final appt in futureAppts) {
                await NotificationService().cancelTreatmentReminders(appt.id);
              }
              await db.deletePlannedInfusionsForSchedule(schedule.id);
              await db.deleteSchedule(schedule.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStockAlertConfig(BuildContext context, AppDatabase db, InventoryProvider provider, Medication medication) {
    final controller = TextEditingController(text: medication.minStock.toStringAsFixed(0));
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.notifications_active_rounded, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Niedriger Bestand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Ab welcher Menge möchtest du gewarnt werden?',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Mindestbestand',
                    suffixText: medication.unit,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  final newMin = double.tryParse(controller.text) ?? 0.0;
                  await db.updateMedication(medication.copyWith(minStock: newMin));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mindestbestand aktualisiert')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('OK'),
              )
            ],
          ),
        ],
      ),
    );
  }
}
