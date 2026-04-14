import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../../../core/database/database.dart';
import 'add_item_page.dart';
import 'medication_details_page.dart';
import 'shopping_wizard_dialog.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Bestand'),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.medication_rounded, color: Theme.of(context).primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Medikamente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<List<Medication>>(
            stream: provider.medicationsStream,
            builder: (context, snapshot) {
              final meds = snapshot.data ?? [];
              if (meds.isEmpty) {
                return const SliverToBoxAdapter(
                  child: _EmptySection(message: 'Keine Medikamente angelegt'),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildMedicationItem(context, meds[index], provider),
                    childCount: meds.length,
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.category_rounded, color: Theme.of(context).primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Zubehör',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<List<Accessory>>(
            stream: provider.accessoriesStream,
            builder: (context, snapshot) {
              final accs = snapshot.data ?? [];
              if (accs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: _EmptySection(message: 'Kein Zubehör angelegt'),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAccessoryItem(context, accs[index], provider),
                    childCount: accs.length,
                  ),
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'inventory_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemPage()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Hinzufügen'),
      ),
    );
  }

  Widget _buildMedicationItem(BuildContext context, Medication med, InventoryProvider provider) {
    final isLowStock = med.stock <= med.minStock && med.minStock > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isLowStock ? Colors.orange.withOpacity(0.05) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLowStock ? Colors.orange.withOpacity(0.2) : Theme.of(context).dividerColor.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MedicationDetailsPage(medication: med)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isLowStock ? Colors.orange.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLowStock ? Icons.warning_amber_rounded : Icons.medication_rounded,
            color: isLowStock ? Colors.orange : Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          med.name,
          style: TextStyle(fontWeight: FontWeight.bold, color: isLowStock ? Colors.orange.shade900 : null),
        ),
        subtitle: Text(isLowStock ? 'Niedriger Bestand!' : 'PZN: ${med.pzn ?? "-"}'),
        trailing: _StockCounter(
          stock: med.stock,
          unit: med.unit,
          onAdd: () => provider.updateMedicationStock(med, 1),
          onRemove: () => provider.updateMedicationStock(med, -1),
        ),
      ),
    );
  }

  Widget _buildAccessoryItem(BuildContext context, Accessory acc, InventoryProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.build_circle_rounded, color: Colors.teal),
        ),
        title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: _ StockCounter(
          stock: acc.stock,
          unit: acc.unit,
          onAdd: () => provider.updateAccessoryStock(acc, 1),
          onRemove: () => provider.updateAccessoryStock(acc, -1),
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            Image.asset(
              'assets/images/empty_inventory.png',
              height: 120,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _StockCounter extends StatelessWidget {
  final double stock;
  final String unit;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _StockCounter({
    required this.stock,
    required this.unit,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
          onPressed: onRemove,
          visualDensity: VisualDensity.compact,
        ),
        Text(
          '${stock.toStringAsFixed(0)} $unit',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
          onPressed: onAdd,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
