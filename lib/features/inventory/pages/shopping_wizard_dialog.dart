import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:igkeeper/core/services/medication_service.dart';
import 'package:igkeeper/core/database/database.dart';

class ShoppingWizardDialog extends StatefulWidget {
  final Medication? initialMedication;
  final PendingOrder? orderToEdit;
  const ShoppingWizardDialog({super.key, this.initialMedication, this.orderToEdit});

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
    if (widget.orderToEdit != null) {
      _deliveryDate = widget.orderToEdit!.deliveryDate;
      _qtyController.text = widget.orderToEdit!.medicationQty.toStringAsFixed(0);
    } else {
      _selectedMed = widget.initialMedication;
      if (_selectedMed != null) {
        _qtyController.text = _selectedMed!.packageSize.toStringAsFixed(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    if (_isFirstBuild) {
      _isFirstBuild = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateInitialData(db);
      });
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.orderToEdit == null ? Icons.auto_awesome_rounded : Icons.edit_note_rounded, 
            color: Theme.of(context).colorScheme.primary
          ),
          const SizedBox(width: 12),
          Text(widget.orderToEdit == null ? 'Einkaufs-Assistent' : 'Bestellung bearbeiten'),
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
              Text(
                widget.orderToEdit == null 
                  ? 'Berechne den Bedarf an Verbrauchsmaterial basierend auf deiner geplanten Medikamenten-Bestellung.'
                  : 'Passe deine Bestellung und den Bedarf an Verbrauchsmaterial an.',
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              FutureBuilder<List<Medication>>(
                future: db.getAllActiveMedications(),
                builder: (context, snapshot) {
                  final meds = snapshot.data ?? [];
                  final items = [
                    const DropdownMenuItem<int?>(
                      value: null, 
                      child: Text('Nur Verbrauchsmaterial bestellen (Kein Medikament)')
                    ),
                    ...meds.map((m) => DropdownMenuItem<int?>(value: m.id, child: Text(m.name))),
                  ];

                  // Safety: Ensure _selectedMed.id is in items to prevent Flutter crash if still loading
                  if (_selectedMed != null && !items.any((it) => it.value == _selectedMed!.id)) {
                    items.add(DropdownMenuItem<int?>(
                      value: _selectedMed!.id, 
                      child: Text(_selectedMed!.name)
                    ));
                  }

                  return DropdownButtonFormField<int?>(
                    initialValue: _selectedMed?.id,
                    items: items,
                    onChanged: (val) {
                      setState(() {
                        if (val == null) {
                          _selectedMed = null;
                          _qtyController.text = '0';
                        } else {
                          // Find in recently loaded meds or keep current
                          _selectedMed = meds.where((m) => m.id == val).firstOrNull ?? _selectedMed;
                          if (_selectedMed != null) {
                            _qtyController.text = _selectedMed!.packageSize.toStringAsFixed(0);
                          }
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
              if (_selectedMed != null) ...[
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
              ],
              const SizedBox(height: 16),
              ListTile(
                tileColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
                leading: const Icon(Icons.event_rounded),
                title: const Text('Lieferdatum (Optional)', style: TextStyle(fontSize: 14)),
                subtitle: Text(_deliveryDate == null ? 'Gleich nach Bestätigung' : DateFormat('dd.MM.yyyy').format(_deliveryDate!)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deliveryDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
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
                const Text('Verbrauchsmaterial-Vorschlag:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                
                if (_results!.any((it) => it.isSystemRecommended)) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Notwendig für diese Bestellung:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  ..._results!.where((it) => it.isSystemRecommended).map((item) => _buildAccessoryRow(item)),
                  const SizedBox(height: 16),
                ],

                if (_results!.any((it) => !it.isSystemRecommended)) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Weiteres Verbrauchsmaterial (Optional):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                  ..._results!.where((it) => !it.isSystemRecommended).map((item) => _buildAccessoryRow(item)),
                ],

                if (_results!.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Kein Verbrauchsmaterial automatisch vorgeschlagen.', 
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                const SizedBox(height: 20),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _addManualAccessory(db),
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text('Anderes Verbrauchsmaterial hinzufügen'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
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
          onPressed: (_selectedMed == null && (_results == null || !_results!.any((it) => it.isActuallySelected))) ? null : () => _saveOrder(db),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(widget.orderToEdit == null ? 'Bestellung speichern' : 'Änderungen speichern'),
        ),
      ],
    );
  }

  void _addManualAccessory(AppDatabase db) async {
    final allAcc = await db.getAllAccessories();
    if (!mounted) return;

    final Accessory? selected = await showDialog<Accessory>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verbrauchsmaterial auswählen'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allAcc.length,
            itemBuilder: (context, index) {
              final acc = allAcc[index];
              return ListTile(
                title: Text(acc.name),
                subtitle: Text('Bestand: ${acc.stock} ${acc.unit}'),
                onTap: () => Navigator.pop(context, acc),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _results ??= [];
        // Check if already in list
        if (_results!.any((it) => it.id == selected.id)) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bereits in der Liste!')));
           return;
        }

        _results!.add(_ShoppingItem(
          selected.id, 
          selected.name, 
          selected.packageSize, 
          selected.unit, 
          selected.stock, 
          false, 
          false, 
          selected.packageSize, 
          0,
          true
        ));
      });
    }
  }

  void _calculateInitialData(AppDatabase db) async {
    if (widget.orderToEdit != null) {
      final med = await (db.select(db.medications)..where((t) => t.id.equals(widget.orderToEdit!.medicationId))).getSingle();
      setState(() {
        _selectedMed = med;
      });
    }
    _calculateBOM(db);
  }

  Widget _buildAccessoryRow(_ShoppingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isSystemRecommended || item.isUserAddition
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
          : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isSystemRecommended || item.isUserAddition
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) 
            : Colors.grey.withValues(alpha: 0.1),
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
                  color: item.isSystemRecommended ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface, 
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1))
                ),
                child: Icon(
                  item.isSystemRecommended ? Icons.star_rounded : Icons.add_circle_outline_rounded, 
                  size: 20, 
                  color: item.isSystemRecommended ? Colors.orange : Theme.of(context).colorScheme.onSurfaceVariant
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
                        color: item.isSystemRecommended ? Theme.of(context).colorScheme.primary : null,
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
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                          color: item.isActuallySelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant
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
                    Text(item.unit, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
    // Keep manual additions if they exist
    final manualAdditions = _results?.where((it) => it.isManualAddition).toList() ?? [];
    
    if (_selectedMed == null) {
      setState(() {
        _results = manualAdditions;
      });
      return;
    }
    
    final orderQty = double.tryParse(_qtyController.text) ?? 0.0;
    final medService = Provider.of<MedicationService>(context, listen: false);
    
    final dailyReq = await medService.getDailyRequirement(_selectedMed!.id);

    // Med reach date
    _medReachDate = await medService.calculateReachDate(_selectedMed!, additionalStock: orderQty);

    // If editing, load existing order items to set initial counts
    List<PendingOrderItem> existingItems = [];
    if (widget.orderToEdit != null) {
      existingItems = await db.getPendingOrderItems(widget.orderToEdit!.id);
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
      bool isSystemRecommended = false;
      
      // Check if we already have this in the existing order (if editing)
      final existingItem = existingItems.where((it) => it.accessoryId == acc.id).firstOrNull;
      
      if (existingItem != null) {
        plannedQty = existingItem.quantity;
        // Logic for recommendation still applies for visual styling
        if (shortfall > 0 || link.isMandatory) {
          isSystemRecommended = true;
        }
      } else {
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
    
    // Add manual additions that were not part of the medication links
    for (var manual in manualAdditions) {
      if (!items.any((it) => it.id == manual.id)) {
        items.add(manual);
      }
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
      int orderId;
      if (widget.orderToEdit != null) {
        orderId = widget.orderToEdit!.id;
        await db.updatePendingOrder(widget.orderToEdit!.copyWith(
          medicationId: _selectedMed!.id,
          medicationQty: orderQty,
          deliveryDate: Value(_deliveryDate),
        ));
        // Clear existing items to re-add them (simplest way to update)
        await (db.delete(db.pendingOrderItems)..where((t) => t.orderId.equals(orderId))).go();
      } else {
        orderId = await db.insertPendingOrder(PendingOrdersCompanion.insert(
          medicationId: _selectedMed!.id,
          medicationQty: orderQty,
          deliveryDate: Value(_deliveryDate),
        ));
      }

        // Add medication as order item (if selected)
        if (_selectedMed != null) {
          await db.insertPendingOrderItem(PendingOrderItemsCompanion.insert(
            orderId: orderId,
            medicationId: Value(_selectedMed!.id),
            quantity: orderQty,
          ));
        }

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
  final bool isManualAddition;
  final TextEditingController controller;
  DateTime? reachDate;

  _ShoppingItem(this.id, this.name, this.neededCount, this.unit, this.currentStock, this.isMandatoryInDb, this.isSystemRecommended, this.packageSize, this.dailyUsage, [this.isManualAddition = false]) 
    : controller = TextEditingController(text: neededCount.toStringAsFixed(0));

  bool get isActuallySelected {
    final val = double.tryParse(controller.text) ?? 0;
    return val > 0;
  }

  bool get isUserAddition => (isActuallySelected && !isSystemRecommended) || isManualAddition;

  void updateReach(double usage, double newQty) {
    if (usage > 0) {
       final days = (currentStock + newQty) / usage;
       reachDate = DateTime.now().add(Duration(days: days.floor()));
    }
  }
}


