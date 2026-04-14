import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/database/database.dart';

class ShoppingWizardDialog extends StatefulWidget {
  const ShoppingWizardDialog({super.key});

  @override
  State<ShoppingWizardDialog> createState() => _ShoppingWizardDialogState();
}

class _ShoppingWizardDialogState extends State<ShoppingWizardDialog> {
  Medication? _selectedMed;
  final _qtyController = TextEditingController(text: '1');
  List<_ShoppingItem>? _results;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return AlertDialog(
      title: const Text('Einkaufs-Assistent'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Wähle ein Medikament und die Bestellmenge, um den Zubehörbedarf zu berechnen.',
                       style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            FutureBuilder<List<Medication>>(
              future: db.getAllMedications(),
              builder: (context, snapshot) {
                final meds = snapshot.data ?? [];
                return DropdownButtonFormField<Medication>(
                  value: _selectedMed,
                  items: meds.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                  onChanged: (val) => setState(() {
                    _selectedMed = val;
                    _results = null;
                  }),
                  decoration: const InputDecoration(labelText: 'Medikament'),
                );
              },
            ),
            TextField(
              controller: _qtyController,
              decoration: const InputDecoration(labelText: 'Bestellmenge (Flaschen/Vials)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _results = null),
            ),
            const SizedBox(height: 16),
            if (_results != null) ...[
              const Divider(),
              const Text('Benötigtes Zubehör:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_results!.isEmpty)
                const Text('Ausreichend Zubehör im Bestand!')
              else
                ..._results!.map((item) => ListTile(
                  dense: true,
                  title: Text(item.name),
                  trailing: Text('${item.neededCount.toStringAsFixed(0)} ${item.unit}'),
                  subtitle: Text('Aktueller Bestand: ${item.currentStock.toStringAsFixed(0)}'),
                )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        ElevatedButton(
          onPressed: _selectedMed == null ? null : () => _calculateBOM(db),
          child: const Text('Berechnen'),
        ),
      ],
    );
  }

  void _calculateBOM(AppDatabase db) async {
    final orderQty = double.tryParse(_qtyController.text) ?? 1.0;
    final links = await db.getAccessoriesForMedication(_selectedMed!.id);
    
    List<_ShoppingItem> items = [];
    
    for (var link in links) {
      final acc = await (db.select(db.accessories)..where((t) => t.id.equals(link.accessoryId))).getSingle();
      final totalNeeded = orderQty * link.defaultQuantity;
      final shortfall = totalNeeded - acc.stock;
      
      if (shortfall > 0) {
        items.add(_ShoppingItem(acc.name, shortfall, acc.unit, acc.stock));
      }
    }

    setState(() {
      _results = items;
    });
  }
}

class _ShoppingItem {
  final String name;
  final double neededCount;
  final String unit;
  final double currentStock;

  _ShoppingItem(this.name, this.neededCount, this.unit, this.currentStock);
}
