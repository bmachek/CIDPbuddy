import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:cidpbuddy/core/services/medication_service.dart';
import 'package:cidpbuddy/core/database/database.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';
import 'package:cidpbuddy/core/theme/app_colors.dart';

/// Digits and one decimal separator; the German keyboard produces a comma, so
/// both `.` and `,` are accepted and everything else is dropped as typed.
final _numberInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

/// Parses a number the way a patient types it: `1,5` and `1.5` are the same.
double? _parseNumber(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));

class ShoppingWizardDialog extends StatefulWidget {
  final Medication? initialMedication;
  final PendingOrder? orderToEdit;
  const ShoppingWizardDialog({
    super.key,
    this.initialMedication,
    this.orderToEdit,
  });

  @override
  State<ShoppingWizardDialog> createState() => _ShoppingWizardDialogState();
}

class _ShoppingWizardDialogState extends State<ShoppingWizardDialog> {
  Medication? _selectedMed;
  final _qtyController = TextEditingController(text: '1');
  List<_ShoppingItem>? _results;
  DateTime? _deliveryDate;
  bool _isFirstBuild = true;
  bool _isSaving = false;
  DateTime? _medReachDate;

  @override
  void initState() {
    super.initState();
    if (widget.orderToEdit != null) {
      _deliveryDate = widget.orderToEdit!.deliveryDate;
      _qtyController.text = widget.orderToEdit!.medicationQty.toStringAsFixed(
        0,
      );
    } else {
      _selectedMed = widget.initialMedication;
      if (_selectedMed != null) {
        _qtyController.text = _selectedMed!.packageSize.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final status = AppStatusColors.of(context);

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
            widget.orderToEdit == null
                ? Icons.auto_awesome_rounded
                : Icons.edit_note_rounded,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.orderToEdit == null
                  ? context.l10n.shoppingWizardTitle
                  : context.l10n.shoppingWizardEditTitle,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      content: SizedBox(
        // Fill a phone, but stop growing on tablets — a dialog wider than
        // 480 dp is hard to scan and its fields become absurdly long.
        width: math.min(MediaQuery.sizeOf(context).width * 0.9, 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.orderToEdit == null
                    ? context.l10n.shoppingWizardIntro
                    : context.l10n.shoppingWizardEditIntro,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FutureBuilder<List<Medication>>(
                future: db.getAllActiveMedications(),
                builder: (context, snapshot) {
                  final meds = snapshot.data ?? [];
                  final items = [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        context.l10n.shoppingWizardSuppliesOnly,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...meds.map(
                      (m) => DropdownMenuItem<int?>(
                        value: m.id,
                        child: Text(m.name, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ];

                  // Safety: Ensure _selectedMed.id is in items to prevent Flutter crash if still loading
                  if (_selectedMed != null &&
                      !items.any((it) => it.value == _selectedMed!.id)) {
                    items.add(
                      DropdownMenuItem<int?>(
                        value: _selectedMed!.id,
                        child: Text(
                          _selectedMed!.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }

                  return DropdownButtonFormField<int?>(
                    initialValue: _selectedMed?.id,
                    isExpanded: true,
                    items: items,
                    onChanged: (val) {
                      setState(() {
                        if (val == null) {
                          _selectedMed = null;
                          _qtyController.text = '0';
                        } else {
                          // Find in recently loaded meds or keep current
                          _selectedMed =
                              meds.where((m) => m.id == val).firstOrNull ??
                              _selectedMed;
                          if (_selectedMed != null) {
                            _qtyController.text = _selectedMed!.packageSize
                                .toStringAsFixed(0);
                          }
                        }
                      });
                      _calculateBOM(db);
                    },
                    decoration: InputDecoration(
                      labelText: context.l10n.medicationFallbackName,
                      prefixIcon: const Icon(Icons.medication_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                  );
                },
              ),
              if (_selectedMed != null) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _qtyController,
                  decoration: InputDecoration(
                    labelText: context.l10n.shoppingWizardOrderQuantity(
                      _selectedMed?.unit ?? context.l10n.unitBottle,
                    ),
                    prefixIcon: const Icon(Icons.shopping_basket_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    helperText: _getMedReachText(),
                    helperStyle: TextStyle(
                      color: status.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: _numberInputFormatters,
                  onChanged: (_) => _calculateBOM(db),
                ),
              ],
              const SizedBox(height: 16),
              ListTile(
                tileColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outline),
                ),
                leading: const Icon(Icons.event_rounded),
                title: Text(
                  context.l10n.shoppingWizardDeliveryDate,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  _deliveryDate == null
                      ? context.l10n.shoppingWizardImmediately
                      : AppDateFormat.date(context, _deliveryDate!),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deliveryDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 30),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  // Dismissing the picker keeps the current date; the clear
                  // button next to it is the explicit way to remove one.
                  if (date == null || !mounted) return;
                  setState(() => _deliveryDate = date);
                },
                trailing: _deliveryDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: context.l10n.tooltipClearDate,
                        onPressed: () => setState(() => _deliveryDate = null),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              if (_results != null) ...[
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  context.l10n.shoppingWizardSuggestion,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                if (_results!.any((it) => it.isSystemRecommended)) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      context.l10n.shoppingWizardRequired,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ..._results!
                      .where((it) => it.isSystemRecommended)
                      .map((item) => _buildAccessoryRow(item)),
                  const SizedBox(height: 16),
                ],

                if (_results!.any((it) => !it.isSystemRecommended)) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      context.l10n.shoppingWizardOptional,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ..._results!
                      .where((it) => !it.isSystemRecommended)
                      .map((item) => _buildAccessoryRow(item)),
                ],

                if (_results!.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      context.l10n.shoppingWizardNoSuggestions,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _addManualAccessory(db),
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: Text(context.l10n.shoppingWizardAddOther),
                    style: TextButton.styleFrom(
                      foregroundColor: status.accentText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
          // The brand blue at text-safe contrast on both dialog surfaces; the
          // dark theme's default text-button colour only reaches ~3:1.
          style: TextButton.styleFrom(foregroundColor: status.accentText),
          child: Text(context.l10n.actionCancel),
        ),
        ElevatedButton(
          // An order always belongs to a medication (PendingOrders.medicationId
          // is not nullable); saving without one used to crash on `_selectedMed!`.
          onPressed: _selectedMed == null || _isSaving
              ? null
              : () => _saveOrder(db),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            widget.orderToEdit == null
                ? context.l10n.shoppingWizardSaveOrder
                : context.l10n.actionSaveChanges,
          ),
        ),
      ],
    );
  }

  void _addManualAccessory(AppDatabase db) async {
    final allAcc = await db.getAllAccessories();
    if (!mounted) return;

    final Accessory? selected = await showDialog<Accessory>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.shoppingWizardPickSupply),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allAcc.length,
            itemBuilder: (context, index) {
              final acc = allAcc[index];
              return ListTile(
                title: Text(acc.name),
                subtitle: Text(
                  context.l10n.stockValue(
                    acc.stock.toStringAsFixed(0),
                    acc.unit,
                  ),
                ),
                onTap: () => Navigator.pop(context, acc),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: AppStatusColors.of(dialogContext).accentText,
            ),
            child: Text(dialogContext.l10n.actionCancel),
          ),
        ],
      ),
    );

    if (selected == null || !mounted) return;

    final alreadyListed = _results?.any((it) => it.id == selected.id) ?? false;
    if (alreadyListed) {
      _showMessage(context.l10n.shoppingWizardAlreadyInList);
      return;
    }

    setState(() {
      _results ??= [];
      _results!.add(
        _ShoppingItem(
          selected.id,
          selected.name,
          selected.packageSize,
          selected.unit,
          selected.stock,
          false,
          false,
          selected.packageSize,
          0,
          true,
        ),
      );
    });
  }

  void _calculateInitialData(AppDatabase db) async {
    if (widget.orderToEdit != null) {
      final med =
          await (db.select(db.medications)
                ..where((t) => t.id.equals(widget.orderToEdit!.medicationId)))
              .getSingle();
      if (!mounted) return;
      setState(() {
        _selectedMed = med;
      });
    }
    _calculateBOM(db);
  }

  Widget _buildAccessoryRow(_ShoppingItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = AppStatusColors.of(context);
    final highlighted = item.isSystemRecommended || item.isUserAddition;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outline,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.isSystemRecommended
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Icon(
                  item.isSystemRecommended
                      ? Icons.star_rounded
                      : Icons.add_circle_outline_rounded,
                  size: 20,
                  color: item.isSystemRecommended
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
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
                        fontWeight: item.isSystemRecommended
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: item.isSystemRecommended
                            ? status.accentText
                            : null,
                      ),
                    ),
                    if (item.isSystemRecommended)
                      Text(
                        context.l10n.shoppingWizardRecommendedAmount,
                        style: TextStyle(
                          fontSize: 12,
                          color: status.accentText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (item.isUserAddition)
                      Text(
                        context.l10n.shoppingWizardAdditionallySelected,
                        style: TextStyle(
                          fontSize: 12,
                          color: status.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // A full-height, bordered field: the old 80 dp borderless box was
          // below the 48 dp tap target and had no label for screen readers.
          TextField(
            controller: item.controller,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: item.isActuallySelected
                  ? status.accentText
                  : colorScheme.onSurfaceVariant,
            ),
            decoration: InputDecoration(
              labelText: context.l10n.shoppingWizardOrderQuantity(item.unit),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _numberInputFormatters,
            onChanged: (val) {
              final qty = _parseNumber(val) ?? 0;
              setState(() {
                item.updateReach(item.dailyUsage, qty);
              });
            },
          ),
          if (item.reachDate != null && item.isActuallySelected) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.date_range_rounded, size: 16, color: status.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.l10n.inventoryLastsUntil(
                      AppDateFormat.date(context, item.reachDate!),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: status.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
    return context.l10n.inventoryLastsUntil(
      AppDateFormat.date(context, _medReachDate!),
    );
  }

  void _calculateBOM(AppDatabase db) async {
    if (!mounted) return;
    // Keep manual additions if they exist
    final manualAdditions =
        _results?.where((it) => it.isManualAddition).toList() ?? [];

    if (_selectedMed == null) {
      setState(() {
        _results = manualAdditions;
      });
      return;
    }

    final selectedMed = _selectedMed!;
    final orderQty = _parseNumber(_qtyController.text) ?? 0.0;
    final medService = Provider.of<MedicationService>(context, listen: false);

    final dailyReq = await medService.getDailyRequirement(selectedMed.id);

    // Med reach date
    final reachDate = await medService.calculateReachDate(
      selectedMed,
      additionalStock: orderQty,
    );

    // If editing, load existing order items to set initial counts
    List<PendingOrderItem> existingItems = [];
    if (widget.orderToEdit != null) {
      existingItems = await db.getPendingOrderItems(widget.orderToEdit!.id);
    }

    final links = await db.getAccessoriesForMedication(selectedMed.id);
    List<_ShoppingItem> items = [];

    for (var link in links) {
      final acc = await (db.select(
        db.accessories,
      )..where((t) => t.id.equals(link.accessoryId))).getSingle();

      // Calculate how much accessory is "reserved" for current med stock
      final reservedForExisting = selectedMed.stock * link.defaultQuantity;
      final availableStock = acc.stock - reservedForExisting;

      final neededForOrder = orderQty * link.defaultQuantity;
      final shortfall = neededForOrder - availableStock;

      double plannedQty = 0;
      bool isSystemRecommended = false;

      // Check if we already have this in the existing order (if editing)
      final existingItem = existingItems
          .where((it) => it.accessoryId == acc.id)
          .firstOrNull;

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
        acc.id,
        acc.name,
        plannedQty,
        acc.unit,
        acc.stock,
        link.isMandatory,
        isSystemRecommended,
        acc.packageSize,
        accDailyReq,
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

    // The user may have switched medication (or closed the dialog) while the
    // queries above ran; only the result for the current selection counts.
    if (!mounted || !identical(_selectedMed, selectedMed)) return;
    setState(() {
      _medReachDate = reachDate;
      _results = items;
    });
  }

  void _saveOrder(AppDatabase db) async {
    if (_selectedMed == null || _isSaving) return;
    final l10n = context.l10n;

    final orderQty = _parseNumber(_qtyController.text);
    if (orderQty == null) {
      _showMessage(l10n.validationEnterNumber);
      return;
    }
    final itemQuantities = <_ShoppingItem, double>{};
    for (final item in _results ?? const <_ShoppingItem>[]) {
      final qty = _parseNumber(item.controller.text);
      if (qty == null) {
        _showMessage(l10n.validationEnterNumber);
        return;
      }
      itemQuantities[item] = qty;
    }

    // Captured before the awaits: the dialog is gone by the time the
    // confirmation shows, so it must land on the page's messenger.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isSaving = true);

    try {
      await db.transaction(() async {
        int orderId;
        if (widget.orderToEdit != null) {
          orderId = widget.orderToEdit!.id;
          await db.updatePendingOrder(
            widget.orderToEdit!.copyWith(
              medicationId: _selectedMed!.id,
              medicationQty: orderQty,
              deliveryDate: Value(_deliveryDate),
            ),
          );
          // Clear existing items to re-add them (simplest way to update)
          await (db.delete(
            db.pendingOrderItems,
          )..where((t) => t.orderId.equals(orderId))).go();
        } else {
          orderId = await db.insertPendingOrder(
            PendingOrdersCompanion.insert(
              medicationId: _selectedMed!.id,
              medicationQty: orderQty,
              deliveryDate: Value(_deliveryDate),
            ),
          );
        }

        // Add medication as order item
        await db.insertPendingOrderItem(
          PendingOrderItemsCompanion.insert(
            orderId: orderId,
            medicationId: Value(_selectedMed!.id),
            quantity: orderQty,
          ),
        );

        // Add accessories as order items
        for (final entry in itemQuantities.entries) {
          if (entry.value > 0) {
            await db.insertPendingOrderItem(
              PendingOrderItemsCompanion.insert(
                orderId: orderId,
                accessoryId: Value(entry.key.id),
                quantity: entry.value,
              ),
            );
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.saveFailed('$e')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.savedOrder),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  _ShoppingItem(
    this.id,
    this.name,
    this.neededCount,
    this.unit,
    this.currentStock,
    this.isMandatoryInDb,
    this.isSystemRecommended,
    this.packageSize,
    this.dailyUsage, [
    this.isManualAddition = false,
  ]) : controller = TextEditingController(text: neededCount.toStringAsFixed(0));

  bool get isActuallySelected {
    final val = _parseNumber(controller.text) ?? 0;
    return val > 0;
  }

  bool get isUserAddition =>
      (isActuallySelected && !isSystemRecommended) || isManualAddition;

  void updateReach(double usage, double newQty) {
    if (usage > 0) {
      final days = (currentStock + newQty) / usage;
      reachDate = DateTime.now().add(Duration(days: days.floor()));
    }
  }
}
