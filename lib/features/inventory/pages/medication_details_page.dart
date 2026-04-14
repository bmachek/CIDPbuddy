import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:igkeeper/features/reminders/services/notification_service.dart';
import '../providers/inventory_provider.dart';
import '../../../core/database/database.dart';
import 'package:drift/drift.dart' as drift;

class MedicationDetailsPage extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsPage({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final invProvider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(medication.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStockAlertConfig(context, db, invProvider),
          const SizedBox(height: 24),
          const Text('Verknüpftes Zubehör', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Dieses Zubehör wird bei jeder Infusion automatisch vom Bestand abgezogen.', 
                     style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          FutureBuilder<List<MedicationAccessory>>(
            future: db.getAccessoriesForMedication(medication.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Noch kein Zubehör verknüpft'));
              }

              return Column(
                children: snapshot.data!.map((link) => _buildAccessoryRow(context, db, link)).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddAccessoryDialog(context, db),
            icon: const Icon(Icons.add_link),
            label: const Text('Zubehör verknüpfen'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await NotificationService().scheduleNotification(
                id: medication.id,
                title: 'Erinnerung: ${medication.name}',
                body: 'Es ist Zeit für deine Infusion / Einnahme.',
                scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erinnerung für in 1 Minute geplant!'))
                );
              }
            },
            icon: const Icon(Icons.notification_add),
            label: const Text('Test-Erinnerung (+1 Min)'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessoryRow(BuildContext context, AppDatabase db, MedicationAccessory link) {
    return FutureBuilder<Accessory>(
      future: (db.select(db.accessories)..where((t) => t.id.equals(link.accessoryId))).getSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final acc = snapshot.data!;
        return ListTile(
          leading: const Icon(Icons.build_circle_outlined),
          title: Text(acc.name),
          subtitle: Text('Bedarf pro Gabe: ${link.defaultQuantity.toStringAsFixed(0)} ${acc.unit}'),
          trailing: IconButton(
            icon: const Icon(Icons.link_off, color: Colors.grey),
            onPressed: () async {
              // Delete link
              await (db.delete(db.medicationAccessories)..where((t) => t.id.equals(link.id))).go();
              (context as Element).markNeedsBuild(); // Refresh simple way
            },
          ),
        );
      },
    );
  }

  void _showAddAccessoryDialog(BuildContext context, AppDatabase db) async {
    final allAcc = await db.getAllAccessories();
    if (allAcc.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zuerst Zubehör im Inventar anlegen!')));
      }
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        Accessory? selected;
        final qtyController = TextEditingController(text: '1');
        
        return AlertDialog(
          title: const Text('Zubehör hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Accessory>(
                items: allAcc.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
                onChanged: (val) => selected = val,
                decoration: const InputDecoration(labelText: 'Zubehör wählen'),
              ),
              TextField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Menge pro Infusion'),
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
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    ).then((_) => (context as Element).markNeedsBuild());
  }

  Widget _buildStockAlertConfig(BuildContext context, AppDatabase db, InventoryProvider provider) {
    final controller = TextEditingController(text: medication.minStock.toStringAsFixed(0));
    return Card(
      color: Colors.teal.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.teal),
                SizedBox(width: 8),
                Text('Bestands-Warnung', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Gib an, ab welcher Menge du eine Warnung erhalten möchtest.', style: TextStyle(fontSize: 12)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Mindestbestand'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final newMin = double.tryParse(controller.text) ?? 0.0;
                    await db.updateMedication(medication.copyWith(minStock: newMin));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mindestbestand aktualisiert')));
                    }
                  },
                  child: const Text('Speichern'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
