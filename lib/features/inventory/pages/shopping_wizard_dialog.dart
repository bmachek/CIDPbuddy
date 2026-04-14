import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Table;
import '../../../core/services/medication_service.dart';
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
  DateTime? _medReachDate;

  @override
  void initState() {
    super.initState();
    _selectedMed = widget.initialMedication;
    if (_selectedMed != null) {
      _qtyController.text = _selectedMed!.packageSize.toStringAsFixed(0);
    }
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
        child: SingleChildScrollView(
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
                    onChanged: (val) {
                      setState(() {
                        _selectedMed = val;
                        if (_selectedMed != null) {
                          _qtyController.text = _selectedMed!.packageSize.toStringAsFixed(0);
                        }
                      });
                      _calculateBOM(db);
                    },
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
                  labelText: 'Bestellmenge (${_selectedMed?.unit ?? 'Flaschen'})',
                  prefixIcon: const Icon(Icons.shopping_basket_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  helperText: _getMedReachText(),
                  helperStyle: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateBOM(db),
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
              const SizedBox(height: 12),
              if (_results != null) ...[
                const Divider(),
                const SizedBox(height: 12),
                const Text('Zubehör-Vorschlag:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                
                // Group 1: Notwendig (System recommended)
                if (_results!.any((it) => it.isSystemRecommended)) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Notwendig für diese Bestellung:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  ..._results!.where((it) => it.isSystemRecommended).map((item) => _buildAccessoryRow(item)),
                  const SizedBox(height: 16),
                ],

                // Group 2: Zusätzlich (Linked but not strictly recommended by system)
                if (_results!.any((it) => !it.isSystemRecommended)) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Weiteres Zubehör (Optional):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  ..._results!.where((it) => !it.isSystemRecommended).map((item) => _buildAccessoryRow(item)),
                ],

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
                        Expanded(child: Text('Kein Zubehör verknüpft.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _selectedMed == null ? null : () => _saveOrder(db),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Bestellung speichern'),
        ),
      ],
    );
  }

  Widget _buildAccessoryRow(_ShoppingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isSystemRecommended || item.isUserAddition
          ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
          : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isSystemRecommended || item.isUserAddition
            ? Theme.of(context).colorScheme.primary.withOpacity(0.3) 
            : Colors.grey.withOpacity(0.1),
          width: item.isSystemRecommended || item.isUserAddition ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.isSystemRecommended ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white, 
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.grey.withOpacity(0.1))
                ),
                child: Icon(
                  item.isSystemRecommended ? Icons.star_rounded : Icons.add_circle_outline_rounded, 
                  size: 20, 
                  color: item.isSystemRecommended ? Colors.orange : Colors.grey
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name, 
                      style: TextStyle(
                        fontWeight: item.isSystemRecommended ? FontWeight.bold : FontWeight.w500,
                        color: item.isSystemRecommended ? Theme.of(context).primaryColor : null,
                      )
                    ),
                    if (item.isSystemRecommended)
                      const Text('Empfohlene Menge', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                    if (item.isUserAddition)
                      const Text('Zusätzlich ausgewählt', style: TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: item.controller,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w900, 
                          color: item.isActuallySelected ? Theme.of(context).primaryColor : Colors.grey
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final qty = double.tryParse(val) ?? 0;
                          setState(() {
                            item.updateReach(item.dailyUsage, qty);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(item.unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          if (item.reachDate != null && item.isActuallySelected) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.date_range_rounded, size: 14, color: Colors.teal),
                const SizedBox(width: 6),
                Text(
                  'Reicht bis: ${DateFormat('dd.MM.yyyy').format(item.reachDate!)}',
                  style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getMedReachText() {
    if (_selectedMed == null || _medReachDate == null) return '';
    return 'Reicht bis: ${DateFormat('dd.MM.yyyy').format(_medReachDate!)}';
  }

  void _calculateBOM(AppDatabase db) async {
    if (_selectedMed == null) return;
    final orderQty = double.tryParse(_qtyController.text) ?? 0.0;
    final medService = Provider.of<MedicationService>(context, listen: false);
    
    final dailyReq = await medService.getDailyRequirement(_selectedMed!.id);

    // Med reach date
    _medReachDate = await medService.calculateReachDate(_selectedMed!, additionalStock: orderQty);

    final links = await db.getAccessoriesForMedication(_selectedMed!.id);
    List<_ShoppingItem> items = [];
    
    for (var link in links) {
      final acc = await (db.select(db.accessories)..where((t) => t.id.equals(link.accessoryId))).getSingle();
      
      // Calculate how much accessory is "reserved" for current med stock
      final reservedForExisting = _selectedMed!.stock * link.defaultQuantity;
      final availableStock = acc.stock - reservedForExisting;
      
      final neededForOrder = orderQty * link.defaultQuantity;
      final shortfall = neededForOrder - availableStock;
      
      double plannedQty = 0;
      bool isSystemRecommended = false;
      
      if (shortfall > 0) {
        isSystemRecommended = true;
        if (acc.packageSize > 0) {
          plannedQty = (shortfall / acc.packageSize).ceil() * acc.packageSize;
        } else {
          plannedQty = shortfall;
        }
      } else if (link.isMandatory) {
        if (orderQty > 0) {
           isSystemRecommended = true;
           plannedQty = acc.packageSize > 0 ? acc.packageSize : 1.0;
        }
      }
      
      final accDailyReq = dailyReq * link.defaultQuantity;
      final item = _ShoppingItem(
        acc.id, acc.name, plannedQty, acc.unit, acc.stock, 
        link.isMandatory, isSystemRecommended, acc.packageSize, accDailyReq
      );
      
      if (accDailyReq > 0) {
        final days = (acc.stock + plannedQty) / accDailyReq;
        item.reachDate = DateTime.now().add(Duration(days: days.floor()));
      }
      
      items.add(item);
    }

    if (mounted) {
      setState(() {
        _results = items;
      });
    }
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
          final qty = double.tryParse(item.controller.text) ?? item.neededCount;
          if (qty > 0) {
            await db.insertPendingOrderItem(PendingOrderItemsCompanion.insert(
              orderId: orderId,
              accessoryId: Value(item.id),
              quantity: qty,
            ));
          }
        }
      }
    });

    if (mounted) Navigator.pop(context);
  }
}

class _ShoppingItem {
  final int id;
  final String name;
  final double neededCount;
  final String unit;
  final double currentStock;
  final bool isMandatoryInDb;
  final bool isSystemRecommended;
  final double packageSize;
  final double dailyUsage;
  final TextEditingController controller;
  DateTime? reachDate;

  _ShoppingItem(this.id, this.name, this.neededCount, this.unit, this.currentStock, this.isMandatoryInDb, this.isSystemRecommended, this.packageSize, this.dailyUsage) 
    : controller = TextEditingController(text: neededCount.toStringAsFixed(0));

  bool get isActuallySelected {
    final val = double.tryParse(controller.text) ?? 0;
    return val > 0;
  }

  bool get isUserAddition => isActuallySelected && !isSystemRecommended;

  void updateReach(double usage, double newQty) {
    if (usage > 0) {
       final days = (currentStock + newQty) / usage;
       reachDate = DateTime.now().add(Duration(days: days.floor()));
    }
  }
}


