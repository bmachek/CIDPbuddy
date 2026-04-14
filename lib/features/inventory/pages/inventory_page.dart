import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import 'package:igkeeper/core/database/database.dart';
import 'package:igkeeper/core/services/medication_service.dart';
import 'add_item_page.dart';
import 'medication_details_page.dart';
import 'shopping_wizard_dialog.dart';
import 'discontinued_medications_page.dart';
import 'package:drift/drift.dart' hide Column;

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return StreamBuilder<List<PendingOrder>>(
      stream: db.watchPendingOrders(),
      builder: (context, pendingSnapshot) {
        final pendingMedIds = (pendingSnapshot.data ?? []).map((o) => o.medicationId).toSet();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('Medikation'),
                pinned: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_checkout_rounded),
                    tooltip: 'Einkaufs-Assistent',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const ShoppingWizardDialog(),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: _buildInventoryContent(context, inventoryProvider, pendingMedIds),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'medication_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddItemPage()),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Hinzufügen'),
          ),
        );
      }
    );
  }

  Widget _buildInventoryContent(BuildContext context, InventoryProvider provider, Set<int> pendingMedIds) {
    final db = Provider.of<AppDatabase>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Icon(Icons.medication_rounded, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Medikamente & Verbrauchsmaterial',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        StreamBuilder<List<Medication>>(
          stream: provider.medicationsStream,
          builder: (context, snapshot) {
            final meds = snapshot.data ?? [];
            if (meds.isEmpty && snapshot.connectionState == ConnectionState.done) {
               return const _EmptySection(message: 'Keine Medikamente angelegt');
            }
            return Column(
              children: [
                ...meds.map((med) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildMedicationItem(context, med, provider, db, pendingMedIds.contains(med.id)),
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DiscontinuedMedicationsPage()),
                      ),
                      icon: const Icon(Icons.history_rounded, size: 16),
                      label: const Text('Abgesetzte Medikamente', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        StreamBuilder<List<Accessory>>(
          stream: db.watchAllAccessories(),
          builder: (context, snapshot) {
            final allAcc = snapshot.data ?? [];
            if (allAcc.isEmpty) return const SizedBox();
            
            return StreamBuilder<List<MedicationAccessory>>(
              stream: db.watchAllMedicationAccessories(),
              builder: (context, linksSnapshot) {
                final links = linksSnapshot.data ?? [];
                final linkedIds = links.map((l) => l.accessoryId).toSet();
                final standaloneAcc = allAcc.where((a) => !linkedIds.contains(a.id)).toList();
                
                if (standaloneAcc.isEmpty) return const SizedBox();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2_rounded, color: Theme.of(context).primaryColor, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Allgemeines Verbrauchsmaterial',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    ...standaloneAcc.map((acc) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.withOpacity(0.1),
                            child: const Icon(Icons.build_circle_rounded, color: Colors.teal, size: 20),
                          ),
                          title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Bestand: ${acc.stock.toStringAsFixed(0)} ${acc.unit}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_outlined, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                onPressed: () => _showEditAccessoryDialog(context, db, acc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                onPressed: () => _confirmDeleteAccessory(context, db, acc),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMedicationItem(BuildContext context, Medication med, InventoryProvider provider, AppDatabase db, bool hasPendingOrder) {
    final medService = Provider.of<MedicationService>(context, listen: false);
    
    return FutureBuilder<double?>(
      future: medService.calculateDaysRemaining(med),
      builder: (context, daysSnapshot) {
        final daysRemaining = daysSnapshot.data;
        final isLowStock = daysRemaining != null && daysRemaining <= med.minStock && med.minStock > 0 && !hasPendingOrder;
        
        return FutureBuilder<PlannedInfusion?>(
          future: (db.select(db.plannedInfusions)
            ..where((t) => t.medicationId.equals(med.id) & t.isCompleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.date)])
            ..limit(1)
          ).getSingleOrNull(),
          builder: (context, nextInfSnapshot) {
            final nextInf = nextInfSnapshot.data;
            final nextInfText = nextInf != null 
                ? '\nNächste: ${DateFormat('dd.MM. HH:mm').format(nextInf.date)} Uhr' 
                : '';

            final reachText = daysRemaining != null 
              ? 'Reicht bis: ${DateFormat('dd.MM.yyyy').format(DateTime.now().add(Duration(days: daysRemaining.floor())))}' 
              : (isLowStock ? 'Niedriger Bestand!' : (hasPendingOrder ? 'Bestellung unterwegs' : 'PZN: ${med.pzn ?? "-"}'));

            return StreamBuilder<List<MedicationAccessory>>(
              stream: db.watchAccessoriesForMedication(med.id),
              builder: (context, snapshot) {
                final links = snapshot.data ?? [];
                final hasAccessories = links.isNotEmpty;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isLowStock 
                        ? Colors.orange.withOpacity(0.15) 
                        : Theme.of(context).cardColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isLowStock ? Colors.orange.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: hasAccessories 
                      ? ExpansionTile(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                          collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                          leading: _buildMedicationLeading(isLowStock, Theme.of(context).primaryColor),
                          title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: isLowStock ? Colors.orange : (daysRemaining != null ? Colors.teal : Theme.of(context).colorScheme.onSurfaceVariant),
                                fontSize: 12,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: reachText,
                                  style: TextStyle(fontWeight: (isLowStock || daysRemaining != null) ? FontWeight.bold : FontWeight.normal),
                                ),
                                if (nextInf != null)
                                  TextSpan(
                                    text: nextInfText,
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.8), fontWeight: FontWeight.w500),
                                  ),
                              ],
                            ),
                          ),
                          trailing: _buildMedicationTrailing(context, med, provider),
                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            ...links.map((link) => _buildEmbeddedAccessoryItem(context, db, link, provider)),
                          ],
                        )
                      : ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: _buildMedicationLeading(isLowStock, Theme.of(context).primaryColor),
                          title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: isLowStock ? Colors.orange : (daysRemaining != null ? Colors.teal : Theme.of(context).colorScheme.onSurfaceVariant),
                                fontSize: 12,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: reachText,
                                  style: TextStyle(fontWeight: (isLowStock || daysRemaining != null) ? FontWeight.bold : FontWeight.normal),
                                ),
                                if (nextInf != null)
                                  TextSpan(
                                    text: nextInfText,
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.8), fontWeight: FontWeight.w500),
                                  ),
                              ],
                            ),
                          ),
                          trailing: _buildMedicationTrailing(context, med, provider),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationDetailsPage(medicationId: med.id))),
                        ),
                  ),
                );
              },
            );
          },
        );
      }
    );
  }

  Widget _buildMedicationLeading(bool isLowStock, Color primaryColor) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: (isLowStock ? Colors.orange : primaryColor).withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(isLowStock ? Icons.warning_amber_rounded : Icons.medication_rounded, color: isLowStock ? Colors.orange : primaryColor, size: 20),
    );
  }

  Widget _buildMedicationTrailing(BuildContext context, Medication med, InventoryProvider provider) {
    return IconButton(
      icon: const Icon(Icons.chevron_right_rounded),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationDetailsPage(medicationId: med.id))),
    );
  }

  Widget _buildEmbeddedAccessoryItem(BuildContext context, AppDatabase db, MedicationAccessory link, InventoryProvider provider) {
    return StreamBuilder<Accessory>(
      stream: (db.select(db.accessories)..where((t) => t.id.equals(link.accessoryId))).watchSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final acc = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              const Icon(Icons.build_circle_rounded, color: Colors.teal, size: 16),
              const SizedBox(width: 12),
              Expanded(child: Text(acc.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
              Text('${acc.stock.toStringAsFixed(0)} ${acc.unit}', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                onPressed: () => _showEditAccessoryDialog(context, db, acc),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditAccessoryDialog(BuildContext context, AppDatabase db, Accessory acc) {
    final nameController = TextEditingController(text: acc.name);
    final unitController = TextEditingController(text: acc.unit);
    final stockController = TextEditingController(text: acc.stock.toStringAsFixed(1));
    final pkgSizeController = TextEditingController(text: acc.packageSize.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verbrauchsmaterial bearbeiten'),
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
              controller: stockController,
              decoration: const InputDecoration(labelText: 'Momentaner Lagerstand', border: OutlineInputBorder()),
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              await db.updateAccessory(acc.copyWith(
                name: nameController.text,
                unit: unitController.text,
                stock: double.tryParse(stockController.text) ?? acc.stock,
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

  void _confirmDeleteAccessory(BuildContext context, AppDatabase db, Accessory acc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verbrauchsmaterial löschen?'),
        content: Text('Möchtest du "${acc.name}" wirklich löschen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () async {
              await (db.delete(db.accessories)..where((t) => t.id.equals(acc.id))).go();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))));
}

class _StockCounter extends StatelessWidget {
  final double stock;
  final String unit;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _StockCounter({required this.stock, required this.unit, required this.onAdd, required this.onRemove});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline_rounded, size: 18), onPressed: onRemove),
        Text('${stock.toStringAsFixed(0)} $unit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        IconButton(icon: const Icon(Icons.add_circle_outline_rounded, size: 18), onPressed: onAdd),
      ],
    );
  }
}
