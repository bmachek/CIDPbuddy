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
      appBar: AppBar(
        title: const Text('Bestand'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_checkout),
            tooltip: 'Einkaufs-Assistent',
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const ShoppingWizardDialog(),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Medikamente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          StreamBuilder<List<Medication>>(
            stream: provider.medicationsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Keine Medikamente angelegt'),
                  )),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildMedicationItem(context, snapshot.data![index], provider),
                  childCount: snapshot.data!.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Zubehör',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          StreamBuilder<List<Accessory>>(
            stream: provider.accessoriesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Kein Zubehör angelegt'),
                  )),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildAccessoryItem(context, snapshot.data![index], provider),
                  childCount: snapshot.data!.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Hinzufügen'),
      ),
    );
  }

  Widget _buildMedicationItem(BuildContext context, Medication med, InventoryProvider provider) {
    final isLowStock = med.stock <= med.minStock && med.minStock > 0;

    return Card(
      color: isLowStock ? Colors.orange.withOpacity(0.1) : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MedicationDetailsPage(medication: med)),
        ),
        leading: CircleAvatar(
          backgroundColor: isLowStock ? Colors.orange : null,
          child: Icon(
            isLowStock ? Icons.warning_amber_rounded : Icons.medication,
            color: isLowStock ? Colors.white : null,
          ),
        ),
        title: Text(
          med.name,
          style: TextStyle(fontWeight: isLowStock ? FontWeight.bold : null),
        ),
        subtitle: Text(isLowStock ? 'Niedriger Bestand!' : 'PZN: ${med.pzn ?? "-"}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => provider.updateMedicationStock(med, -1),
            ),
            Text(
              '${med.stock.toStringAsFixed(0)} ${med.unit}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => provider.updateMedicationStock(med, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessoryItem(BuildContext context, Accessory acc, InventoryProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.2),
          child: Icon(Icons.build_circle_outlined, color: Colors.teal),
        ),
        title: Text(acc.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => provider.updateAccessoryStock(acc, -1),
            ),
            Text(
              '${acc.stock.toStringAsFixed(0)} ${acc.unit}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => provider.updateAccessoryStock(acc, 1),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper extension for colors if needed, but using standard here
extension ColorExt on Color {
  static const Color tealOpacity = Color(0x33008080);
}
