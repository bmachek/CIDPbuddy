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
      title: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          const Text('Einkaufs-Assistent'),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Berechne den Zubehörbedarf basierend auf deiner geplanten Medikamenten-Bestellung.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
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
                  decoration: InputDecoration(
                    labelText: 'Medikament',
                    prefixIcon: const Icon(Icons.medication_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qtyController,
              decoration: InputDecoration(
                labelText: 'Bestellmenge (Flaschen)',
                prefixIcon: const Icon(Icons.shopping_basket_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _results = null),
            ),
            const SizedBox(height: 24),
            if (_results != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              const Text('Ergebnis:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              if (_results!.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(child: Text('Genug Zubehör im Bestand!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _results!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _results![index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.withOpacity(0.1))),
                              child: Icon(Icons.build_circle_rounded, size: 20, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Bestand: ${item.currentStock.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text(
                              '+${item.neededCount.toStringAsFixed(0)} ${item.unit}',
                              style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _selectedMed == null ? null : () => _calculateBOM(db),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
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
