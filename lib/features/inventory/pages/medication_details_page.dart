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
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(medication.name),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('Lagerstand & Warnungen'),
                const SizedBox(height: 12),
                _buildStockAlertConfig(context, db, invProvider),
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
                        onPressed: () => _showLinkAccessoryDialog(context, db),
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
                        onPressed: () => _showCreateAccessoryDialog(context, db),
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
                _buildSectionHeader('Benachrichtigungen'),
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
                        const SnackBar(content: Text('Test-Erinnerung für in 1 Minute geplant!'))
                      );
                    }
                  },
                  icon: const Icon(Icons.notification_add_rounded),
                  label: const Text('Test-Erinnerung (+1 Min)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
            trailing: IconButton(
              icon: const Icon(Icons.link_off_rounded, color: Colors.grey),
              onPressed: () async {
                await (db.delete(db.medicationAccessories)..where((t) => t.id.equals(link.id))).go();
                (context as Element).markNeedsBuild();
              },
            ),
          ),
        );
      },
    );
  }

  void _showLinkAccessoryDialog(BuildContext context, AppDatabase db) async {
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

  void _showCreateAccessoryDialog(BuildContext context, AppDatabase db) async {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final unitController = TextEditingController(text: 'Stk');
        final stockController = TextEditingController(text: '0');
        final qtyController = TextEditingController(text: '1');

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
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final accId = await db.insertAccessory(AccessoriesCompanion.insert(
                    name: nameController.text,
                    stock: drift.Value(double.tryParse(stockController.text) ?? 0.0),
                    unit: unitController.text,
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

  Widget _buildStockAlertConfig(BuildContext context, AppDatabase db, InventoryProvider provider) {
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
