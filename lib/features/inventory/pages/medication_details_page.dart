import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:igkeeper/features/reminders/services/notification_service.dart';
import '../providers/inventory_provider.dart';
import 'package:igkeeper/core/database/database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:igkeeper/features/diary/pages/add_schedule_page.dart';
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
                  if (medication.discontinuedAt == null)
                    IconButton(
                      icon: const Icon(Icons.heart_broken_outlined, color: Colors.orange),
                      onPressed: () => _confirmDiscontinueMedication(context, invProvider, medication),
                      tooltip: 'Absetzen',
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.add_moderator_outlined, color: Colors.green),
                      onPressed: () => invProvider.reenrollMedication(medication.id),
                      tooltip: 'Wieder verordnen',
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    onPressed: () => _confirmDeleteMedication(context, db, medication),
                    tooltip: 'Vollständig löschen',
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              if (medication.discontinuedAt != null)
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.orange.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Dieses Medikament ist abgesetzt seit ${DateFormat('dd.MM.yyyy').format(medication.discontinuedAt!)}',
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(context, 'Lagerstand & Warnungen'),
                const SizedBox(height: 12),
                _StockManagementCard(medication: medication),
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'Verknüpftes Zubehör'),
                Text(
                  'Dieses Zubehör wird bei jeder Infusion automatisch vom Bestand abgezogen.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
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
                        child: Center(
                          child: Text('Noch kein Zubehör verknüpft', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                _buildSectionHeader(context, 'Einnahme-Workflow'),
                Text(
                  'Konfiguriere hier, welche Felder beim Erfassen einer Einnahme angezeigt werden.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 12),
                _buildWorkflowConfig(context, db, invProvider, medication),
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'Zeitpläne'),
                Text(
                  'Lege hier fest, in welchem Rhythmus du dieses Medikament einnimmst.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
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
                        child: Center(
                          child: Text('Keine Zeitpläne aktiv', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                _buildSectionHeader(context, 'System-Aktionen'),
                const SizedBox(height: 12),
                if (medication.discontinuedAt == null)
                  ElevatedButton.icon(
                    onPressed: () => _confirmDiscontinueMedication(context, invProvider, medication),
                    icon: const Icon(Icons.heart_broken_outlined),
                    label: const Text('Medikament absetzen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      foregroundColor: Colors.orange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => invProvider.reenrollMedication(medication.id),
                    icon: const Icon(Icons.add_moderator_outlined),
                    label: const Text('Wieder verordnen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      foregroundColor: Colors.green,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _confirmDeleteMedication(context, db, medication),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Vollständig aus Datenbank löschen'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: colorScheme.primary),
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
                if (link.isMandatory)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Tooltip(
                      message: 'Muss mitbestellt werden',
                      child: Icon(Icons.star_rounded, color: Colors.orange, size: 20),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.grey),
                  onPressed: () => _showEditLinkDialog(context, db, link, acc),
                ),
                IconButton(
                  icon: const Icon(Icons.link_off_rounded, color: Colors.grey),
                  onPressed: () async {
                    await (db.delete(db.medicationAccessories)..where((t) => t.id.equals(link.id))).go();
                    if (context.mounted) (context as Element).markNeedsBuild();
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
    ).then((_) {
      if (context.mounted) (context as Element).markNeedsBuild();
    });
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

        bool isMandatory = false;

        return AlertDialog(
          title: const Text('Zubehör verknüpfen'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: StatefulBuilder(
            builder: (context, setDialogState) => Column(
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
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Immer mitbestellen', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Wird im Einkaufsassistent hervorgehoben', style: TextStyle(fontSize: 12)),
                  value: isMandatory,
                  onChanged: (val) => setDialogState(() => isMandatory = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
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
                    isMandatory: drift.Value(isMandatory),
                  ));
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Verknüpfen'),
            ),
          ],
        );
      },
    ).then((_) {
      if (context.mounted) (context as Element).markNeedsBuild();
    });
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

        bool isMandatory = false;

        return AlertDialog(
          title: const Text('Neues Zubehör anlegen'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: StatefulBuilder(
            builder: (context, setDialogState) => SingleChildScrollView(
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
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Immer mitbestellen', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Wird im Einkaufsassistent hervorgehoben', style: TextStyle(fontSize: 12)),
                    value: isMandatory,
                    onChanged: (val) => setDialogState(() => isMandatory = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
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
                    isMandatory: drift.Value(isMandatory),
                  ));
                  
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Anlegen'),
            ),
          ],
        );
      },
    ).then((_) {
      if (context.mounted) (context as Element).markNeedsBuild();
    });
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
        content: Text('Möchtest du "${med.name}" wirklich vollständig aus der App löschen? Dies kann nicht rückgängig gemacht werden und sollte nur bei Fehlern erfolgen. Für Ende einer Therapie bitte "Absetzen" nutzen.'),
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

  void _confirmDiscontinueMedication(BuildContext context, InventoryProvider provider, Medication med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medikament absetzen?'),
        content: Text('Möchtest du "${med.name}" absetzen? Es wird aus der aktiven Liste entfernt, bleibt aber in der Historie erhalten. Zukünftige Termine werden gelöscht.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await provider.discontinueMedication(med.id);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to inventory
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Absetzen'),
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

  Widget _buildWorkflowConfig(BuildContext context, AppDatabase db, InventoryProvider provider, Medication medication) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Chargennummer erfassen'),
            subtitle: const Text('Barcode scannen oder manuell eingeben'),
            value: medication.trackBatchNumber,
            onChanged: (val) => provider.updateMedication(medication.copyWith(trackBatchNumber: val)),
            secondary: const Icon(Icons.qr_code_rounded, color: Colors.blueGrey),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Körpergewicht erfassen'),
            subtitle: const Text('Gewicht bei der Infusion protokollieren'),
            value: medication.trackWeight,
            onChanged: (val) => provider.updateMedication(medication.copyWith(trackWeight: val)),
            secondary: const Icon(Icons.monitor_weight_rounded, color: Colors.blueGrey),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Einnahmetimer nutzen'),
            subtitle: const Text('Premedikation-Timer vor der Infusion'),
            value: medication.useTimer,
            onChanged: (val) => provider.updateMedication(medication.copyWith(useTimer: val)),
            secondary: const Icon(Icons.av_timer_rounded, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }


  void _showEditLinkDialog(BuildContext context, AppDatabase db, MedicationAccessory link, Accessory acc) {
    final qtyController = TextEditingController(text: link.defaultQuantity.toStringAsFixed(1));
    bool isMandatory = link.isMandatory;
    final pkgSizeController = TextEditingController(text: acc.packageSize.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${acc.name} konfigurieren'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qtyController,
                decoration: InputDecoration(labelText: 'Bedarf pro Infusion (${acc.unit})', border: const OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pkgSizeController,
                decoration: const InputDecoration(labelText: 'Packungsgröße (für Bestellung)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Immer mitbestellen', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Wird im Einkaufsassistent hervorgehoben', style: TextStyle(fontSize: 12)),
                value: isMandatory,
                onChanged: (val) => setState(() => isMandatory = val),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Zubehör global bearbeiten (Name, Einheit)'),
                onPressed: () {
                   Navigator.pop(context);
                   _showEditAccessoryDialog(context, db, acc);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () async {
                await db.updateMedicationAccessory(link.copyWith(
                  defaultQuantity: double.tryParse(qtyController.text) ?? 1.0,
                  isMandatory: isMandatory,
                ));
                // Also update accessory package size if changed
                final newPkgSize = double.tryParse(pkgSizeController.text) ?? 1.0;
                if (newPkgSize != acc.packageSize) {
                  await db.updateAccessory(acc.copyWith(packageSize: newPkgSize));
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (context.mounted) (context as Element).markNeedsBuild();
    });
  }
}

class _StockManagementCard extends StatefulWidget {
  final Medication medication;

  const _StockManagementCard({required this.medication});

  @override
  State<_StockManagementCard> createState() => _StockManagementCardState();
}

class _StockManagementCardState extends State<_StockManagementCard> {
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: widget.medication.stock.toStringAsFixed(0));
    _minStockController = TextEditingController(text: widget.medication.minStock.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(_StockManagementCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.medication.stock != widget.medication.stock && !_isSaving) {
      _stockController.text = widget.medication.stock.toStringAsFixed(0);
    }
    if (oldWidget.medication.minStock != widget.medication.minStock && !_isSaving) {
      _minStockController.text = widget.medication.minStock.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final db = Provider.of<AppDatabase>(context, listen: false);
    
    final newStock = double.tryParse(_stockController.text) ?? widget.medication.stock;
    final newMinStock = double.tryParse(_minStockController.text) ?? widget.medication.minStock;

    await db.updateMedication(widget.medication.copyWith(
      stock: newStock,
      minStock: newMinStock,
    ));

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lagerstand aktualisiert'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
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
                child: const Icon(Icons.inventory_2_rounded, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Bestandsverwaltung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stockController,
                  decoration: InputDecoration(
                    labelText: 'Aktueller Bestand',
                    suffixText: widget.medication.unit,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minStockController,
                  decoration: InputDecoration(
                    labelText: 'Warnung bei weniger als (Tage)',
                    suffixText: 'Tage',
                    helperText: 'Niedriger Bestand Warnung',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveChanges,
              icon: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Speichert...' : 'Bestand Speichern'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
