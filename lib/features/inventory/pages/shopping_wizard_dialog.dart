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
                const Text('Ergebnis:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
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
                        Expanded(child: Text('Kein Zubehör zusätzlich nötig.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _results!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _results![index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.isMandatory 
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                            : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: item.isMandatory 
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.3) 
                              : Colors.grey.withOpacity(0.1),
                            width: item.isMandatory ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: item.isMandatory ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white, 
                                    shape: BoxShape.circle, 
                                    border: Border.all(color: Colors.grey.withOpacity(0.1))
                                  ),
                                  child: Icon(
                                    item.isMandatory ? Icons.star_rounded : Icons.build_circle_rounded, 
                                    size: 20, 
                                    color: item.isMandatory ? Colors.orange : Theme.of(context).primaryColor
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
                                          fontWeight: item.isMandatory ? FontWeight.bold : FontWeight.w500,
                                          color: item.isMandatory ? Theme.of(context).primaryColor : null,
                                        )
                                      ),
                                      if (item.isMandatory)
                                        const Text('Wird mitbestellt', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
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
                                          style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            border: InputBorder.none,
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (val) {
                                            final qty = double.tryParse(val) ?? 0;
                                            setState(() {
                                              item.updateReach(_dailyReq * (item.neededCount / (_calculateNeededQtyForMed(double.tryParse(_qtyController.text) ?? 0, item)) == 0 ? 1 : (item.neededCount / (_calculateNeededQtyForMed(double.tryParse(_qtyController.text) ?? 0, item)))), qty);
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
                            if (item.reachDate != null) ...[
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
                    },
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

  String _getMedReachText() {
    if (_selectedMed == null || _medReachDate == null) return '';
    return 'Reicht bis: ${DateFormat('dd.MM.yyyy').format(_medReachDate!)}';
  }

  void _calculateBOM(AppDatabase db) async {
    if (_selectedMed == null) return;
    final orderQty = double.tryParse(_qtyController.text) ?? 0.0;
    
    // Calculate daily requirement for medication
    final activeSchedules = await (db.select(db.infusionSchedules)..where((t) => t.medicationId.equals(_selectedMed!.id) & t.isActive.equals(true))).get();
    
    double dailyReq = 0;
    for (var s in activeSchedules) {
      final intakeCount = s.intakeTimes?.split(',').where((t) => t.isNotEmpty).length ?? 1;
      final dosagePerDay = s.dosage * intakeCount;
      
      switch (s.frequencyType) {
        case 'daily':
          dailyReq += dosagePerDay;
          break;
        case 'interval':
          dailyReq += dosagePerDay / (s.intervalValue ?? 1);
          break;
        case 'weekly':
          dailyReq += dosagePerDay / (7 * (s.intervalValue ?? 1));
          break;
        case 'weekdays':
          final weekdayCount = s.selectedWeekdays?.split(',').where((t) => t.isNotEmpty).length ?? 0;
          dailyReq += (dosagePerDay * weekdayCount) / 7.0;
          break;
      }
    }
    
    _dailyReq = dailyReq;

    // Med reach date
    DateTime? medReach;
    if (dailyReq > 0) {
      final days = (_selectedMed!.stock + orderQty) / dailyReq;
      medReach = DateTime.now().add(Duration(days: days.floor()));
    }

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
      if (shortfall > 0) {
        if (acc.packageSize > 0) {
          plannedQty = (shortfall / acc.packageSize).ceil() * acc.packageSize;
        } else {
          plannedQty = shortfall;
        }
      } else if (link.isMandatory) {
        if (orderQty > 0) {
           plannedQty = acc.packageSize > 0 ? acc.packageSize : 1.0;
        }
      }
      
      final accDailyReq = dailyReq * link.defaultQuantity;
      final item = _ShoppingItem(acc.id, acc.name, plannedQty, acc.unit, acc.stock, link.isMandatory, acc.packageSize, accDailyReq);
      
      if (accDailyReq > 0) {
        final days = (acc.stock + plannedQty) / accDailyReq;
        item.reachDate = DateTime.now().add(Duration(days: days.floor()));
      }
      
      items.add(item);
    }

    if (mounted) {
      setState(() {
        _results = items;
        _medReachDate = medReach;
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
  final bool isMandatory;
  final double packageSize;
  final double dailyUsage;
  final TextEditingController controller;
  DateTime? reachDate;

  _ShoppingItem(this.id, this.name, this.neededCount, this.unit, this.currentStock, this.isMandatory, this.packageSize, this.dailyUsage) 
    : controller = TextEditingController(text: neededCount.toStringAsFixed(0));

  void updateReach(double usage, double newQty) {
    if (usage > 0) {
       final days = (currentStock + newQty) / usage;
       reachDate = DateTime.now().add(Duration(days: days.floor()));
    }
  }
}


