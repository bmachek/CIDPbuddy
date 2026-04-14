import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/database.dart';

class ShoppingWizardDialog extends StatefulWidget {
  final Medication? initialMedication;
  const ShoppingWizardDialog({super.key, this.initialMedication});

  @override
  State<ShoppingWizardDialog> createState() => _ShoppingWizardDialogState();
}

class _ShoppingWizardDialogState extends State<ShoppingWizardDialog> {
  Medication? _selectedMed;
  final _qtyController = TextEditingController(text: '1');
  List<_ShoppingItem>? _results;
  DateTime? _deliveryDate;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _selectedMed = widget.initialMedication;
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    if (_isFirstBuild && _selectedMed != null) {
      _isFirstBuild = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateBOM(db);
      });
    }

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
            const SizedBox(height: 16),
            ListTile(
              tileColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
              leading: const Icon(Icons.event_rounded),
              title: const Text('Lieferdatum (Optional)', style: TextStyle(fontSize: 14)),
              subtitle: Text(_deliveryDate == null ? 'Gleich nach Bestätigung' : DateFormat('dd.MM.yyyy').format(_deliveryDate!)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _deliveryDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                setState(() => _deliveryDate = date);
              },
              trailing: _deliveryDate != null ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _deliveryDate = null)) : null,
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
          onPressed: _selectedMed == null ? null : () {
            if (_results == null) {
              _calculateBOM(db);
            } else {
              _saveOrder(db);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _results == null ? Theme.of(context).primaryColor : Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(_results == null ? 'Berechnen' : 'Bestellung speichern'),
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
      
      // Calculate how much accessory is "reserved" for current med stock
      final reservedForExisting = _selectedMed!.stock * link.defaultQuantity;
      final availableStock = acc.stock - reservedForExisting;
      
      final neededForOrder = orderQty * link.defaultQuantity;
      final shortfall = neededForOrder - availableStock;
      
      if (shortfall > 0) {
        items.add(_ShoppingItem(acc.id, acc.name, shortfall, acc.unit, acc.stock));
      }
    }

    setState(() {
      _results = items;
    });
  }

  void _saveOrder(AppDatabase db) async {
    final orderQty = double.tryParse(_qtyController.text) ?? 1.0;
    
    await db.transaction(() async {
      final orderId = await db.insertPendingOrder(PendingOrdersCompanion.insert(
        medicationId: _selectedMed!.id,
        medicationQty: orderQty,
        deliveryDate: Value(_deliveryDate),
      ));

      // Add medication as order item
      await db.insertPendingOrderItem(PendingOrderItemsCompanion.insert(
        orderId: orderId,
        medicationId: Value(_selectedMed!.id),
        quantity: orderQty,
      ));

      // Add accessories as order items
      if (_results != null) {
        for (var item in _results!) {
          await db.insertPendingOrderItem(PendingOrderItemsCompanion.insert(
            orderId: orderId,
            accessoryId: Value(item.id),
            quantity: item.neededCount,
          ));
        }
      }
    });

    if (mounted) Navigator.pop(context);
    // TODO: Show success snackbar or notification
  }
}

class _ShoppingItem {
  final int id;
  final String name;
  final double neededCount;
  final String unit;
  final double currentStock;

  _ShoppingItem(this.id, this.name, this.neededCount, this.unit, this.currentStock);
}
