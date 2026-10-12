import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'package:cidpbuddy/core/database/database.dart';
import 'package:cidpbuddy/core/services/medication_service.dart';
import 'package:cidpbuddy/core/theme/app_colors.dart';
import 'add_item_page.dart';
import 'medication_details_page.dart';
import 'shopping_wizard_dialog.dart';
import 'discontinued_medications_page.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';

/// Digits and one decimal separator; the German keyboard produces a comma, so
/// both `.` and `,` are accepted and everything else is dropped as typed.
final _numberInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

/// Parses a number the way a patient types it: `1,5` and `1.5` are the same.
double? _parseNumber(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));

/// Text buttons: the brand blue at a tone that passes AA as small text on
/// both surfaces (the dark theme's default only reaches ~3:1).
ButtonStyle _accentTextButtonStyle(BuildContext context) =>
    TextButton.styleFrom(
      foregroundColor: AppStatusColors.of(context).accentText,
    );

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return StreamBuilder<List<PendingOrder>>(
      stream: db.watchPendingOrders(),
      builder: (context, pendingSnapshot) {
        final pendingMedIds = (pendingSnapshot.data ?? [])
            .map((o) => o.medicationId)
            .toSet();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: Text(context.l10n.navMedication),
                pinned: true,
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_cart_checkout_rounded),
                    ),
                    tooltip: context.l10n.shoppingWizardTitle,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const ShoppingWizardDialog(),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: _buildInventoryContent(
                  context,
                  inventoryProvider,
                  pendingMedIds,
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 120),
            child: FloatingActionButton.extended(
              heroTag: 'medication_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddItemPage()),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.actionAdd),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required EdgeInsets padding,
  }) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryContent(
    BuildContext context,
    InventoryProvider provider,
    Set<int> pendingMedIds,
  ) {
    final db = Provider.of<AppDatabase>(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.medication_rounded,
          color: colorScheme.primary,
          label: context.l10n.inventorySectionMedications,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        ),
        StreamBuilder<List<Medication>>(
          stream: provider.medicationsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _EmptySection(message: context.l10n.errorLoadingData);
            }
            // A Drift watch stream never reaches `ConnectionState.done`, so
            // the empty state has to key off the first emitted list.
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final meds = snapshot.data!;
            return Column(
              children: [
                if (meds.isEmpty)
                  _EmptySection(
                    message: context.l10n.inventoryNoMedications,
                    hint: context.l10n.inventoryAddFirstMedicationHint,
                  ),
                ...meds.map(
                  (med) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildMedicationItem(
                      context,
                      med,
                      provider,
                      db,
                      pendingMedIds.contains(med.id),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: _accentTextButtonStyle(context),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DiscontinuedMedicationsPage(),
                        ),
                      ),
                      icon: const Icon(Icons.history_rounded, size: 16),
                      label: Text(
                        context.l10n.discontinuedTitle,
                        style: const TextStyle(fontSize: 13),
                      ),
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
            if (snapshot.hasError) {
              return _EmptySection(message: context.l10n.errorLoadingData);
            }
            final allAcc = snapshot.data ?? [];
            if (allAcc.isEmpty) return const SizedBox.shrink();

            return StreamBuilder<List<MedicationAccessory>>(
              stream: db.watchAllMedicationAccessories(),
              builder: (context, linksSnapshot) {
                if (linksSnapshot.hasError) {
                  return _EmptySection(message: context.l10n.errorLoadingData);
                }
                final links = linksSnapshot.data ?? [];
                final linkedIds = links.map((l) => l.accessoryId).toSet();
                final standaloneAcc = allAcc
                    .where((a) => !linkedIds.contains(a.id))
                    .toList();

                if (standaloneAcc.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      icon: Icons.inventory_2_rounded,
                      color: colorScheme.tertiary,
                      label: context.l10n.inventorySectionStandaloneSupplies,
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                    ),
                    ...standaloneAcc.map(
                      (acc) => Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.tertiary.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                Icons.build_circle_rounded,
                                color: colorScheme.tertiary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              acc.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              context.l10n.stockValue(
                                acc.stock.toStringAsFixed(0),
                                acc.unit,
                              ),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  tooltip: context.l10n.tooltipEditSupply,
                                  onPressed: () => _showEditAccessoryDialog(
                                    context,
                                    db,
                                    acc,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                    color: colorScheme.error,
                                  ),
                                  tooltip: context.l10n.tooltipDeleteSupply,
                                  onPressed: () =>
                                      _confirmDeleteAccessory(context, db, acc),
                                ),
                              ],
                            ),
                          ),
                          const Divider(indent: 72),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildMedicationItem(
    BuildContext context,
    Medication med,
    InventoryProvider provider,
    AppDatabase db,
    bool hasPendingOrder,
  ) {
    final medService = Provider.of<MedicationService>(context, listen: false);

    return FutureBuilder<double?>(
      future: medService.calculateDaysRemaining(med),
      builder: (context, daysSnapshot) {
        final daysRemaining = daysSnapshot.data;
        final isLowStock =
            daysRemaining != null &&
            daysRemaining <= med.minStock &&
            med.minStock > 0 &&
            !hasPendingOrder;

        return FutureBuilder<PlannedInfusion?>(
          future:
              (db.select(db.plannedInfusions)
                    ..where(
                      (t) =>
                          t.medicationId.equals(med.id) &
                          t.isCompleted.equals(false),
                    )
                    ..orderBy([(t) => OrderingTerm(expression: t.date)])
                    ..limit(1))
                  .getSingleOrNull(),
          builder: (context, nextInfSnapshot) {
            final nextInf = nextInfSnapshot.data;

            final reachText = daysRemaining != null
                ? context.l10n.inventoryLastsUntil(
                    AppDateFormat.date(
                      context,
                      DateTime.now().add(Duration(days: daysRemaining.floor())),
                    ),
                  )
                : (isLowStock
                      ? context.l10n.inventoryLowStock
                      : (hasPendingOrder
                            ? context.l10n.inventoryOrderOnTheWay
                            : context.l10n.inventoryPzn(med.pzn ?? '-')));

            return StreamBuilder<List<MedicationAccessory>>(
              stream: db.watchAccessoriesForMedication(med.id),
              builder: (context, snapshot) {
                final links = snapshot.data ?? [];
                final hasAccessories = links.isNotEmpty;
                final title = _buildMedicationTitle(context, med);
                final subtitle = _buildMedicationSubtitle(
                  context,
                  reachText: reachText,
                  isLowStock: isLowStock,
                  daysRemaining: daysRemaining,
                  nextInfusion: nextInf,
                );

                return Column(
                  children: [
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: hasAccessories
                          ? ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: _buildMedicationLeading(
                                context,
                                isLowStock,
                              ),
                              title: title,
                              subtitle: subtitle,
                              trailing: _buildMedicationTrailing(context, med),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                72,
                                0,
                                16,
                                16,
                              ),
                              children: [
                                ...links.map(
                                  (link) => _buildEmbeddedAccessoryItem(
                                    context,
                                    db,
                                    link,
                                  ),
                                ),
                              ],
                            )
                          : ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: _buildMedicationLeading(
                                context,
                                isLowStock,
                              ),
                              title: title,
                              subtitle: subtitle,
                              trailing: _buildMedicationTrailing(context, med),
                              onTap: () => _openDetails(context, med),
                            ),
                    ),
                    const Divider(indent: 72),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _openDetails(BuildContext context, Medication med) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicationDetailsPage(medicationId: med.id),
      ),
    );
  }

  Widget _buildMedicationTitle(BuildContext context, Medication med) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            med.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        if (med.dosage.isNotEmpty) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              med.dosage,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppStatusColors.of(context).accentText,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMedicationSubtitle(
    BuildContext context, {
    required String reachText,
    required bool isLowStock,
    required double? daysRemaining,
    required PlannedInfusion? nextInfusion,
  }) {
    final status = AppStatusColors.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final emphasised = isLowStock || daysRemaining != null;
    // Low stock needs attention (warning); a known reach date is reassuring
    // (success); anything else is neutral. All three pass AA as small text.
    final color = isLowStock
        ? status.warning
        : (daysRemaining != null
              ? status.success
              : colorScheme.onSurfaceVariant);

    return Text.rich(
      TextSpan(
        style: TextStyle(color: color, fontSize: 12, height: 1.4),
        children: [
          TextSpan(
            text: reachText,
            style: TextStyle(
              fontWeight: emphasised ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (nextInfusion != null)
            TextSpan(
              text:
                  '\n${context.l10n.inventoryNextTreatment(AppDateFormat.dayMonthTime(context, nextInfusion.date))}',
              style: TextStyle(
                color: status.accentText,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicationLeading(BuildContext context, bool isLowStock) {
    final color = isLowStock
        ? AppStatusColors.of(context).warning
        : Theme.of(context).colorScheme.primary;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isLowStock ? Icons.info_outline_rounded : Icons.medication_rounded,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildMedicationTrailing(BuildContext context, Medication med) {
    return IconButton(
      icon: const Icon(Icons.chevron_right_rounded),
      tooltip: context.l10n.tooltipShowDetails,
      onPressed: () => _openDetails(context, med),
    );
  }

  Widget _buildEmbeddedAccessoryItem(
    BuildContext context,
    AppDatabase db,
    MedicationAccessory link,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder<Accessory>(
      stream: (db.select(
        db.accessories,
      )..where((t) => t.id.equals(link.accessoryId))).watchSingle(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              context.l10n.errorLoadingData,
              style: TextStyle(fontSize: 13, color: colorScheme.error),
            ),
          );
        }
        if (!snapshot.hasData) return const SizedBox.shrink();
        final acc = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(
                Icons.build_circle_rounded,
                color: colorScheme.tertiary,
                size: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      acc.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      context.l10n.stockValue(
                        acc.stock.toStringAsFixed(0),
                        acc.unit,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip: context.l10n.tooltipEditSupply,
                onPressed: () => _showEditAccessoryDialog(context, db, acc),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditAccessoryDialog(
    BuildContext context,
    AppDatabase db,
    Accessory acc,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: acc.name);
    final unitController = TextEditingController(text: acc.unit);
    final stockController = TextEditingController(
      text: acc.stock.toStringAsFixed(1),
    );
    final pkgSizeController = TextEditingController(
      text: acc.packageSize.toStringAsFixed(1),
    );
    final minStockController = TextEditingController(
      text: acc.minStock.toStringAsFixed(1),
    );
    final messenger = ScaffoldMessenger.of(context);

    String? validateNumber(
      BuildContext context,
      String? value, {
      bool positive = false,
    }) {
      final number = _parseNumber(value ?? '');
      if (number == null) return context.l10n.validationEnterNumber;
      if (positive && number <= 0) {
        return context.l10n.validationPositiveNumber;
      }
      return null;
    }

    Widget numberField(
      BuildContext context, {
      required TextEditingController controller,
      required String labelText,
      bool positive = false,
    }) {
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: _numberInputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) =>
            validateNumber(context, value, positive: positive),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.accessoryEditTitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        // Scrollable so the keyboard never hides the lower fields or the
        // Save button on a small phone.
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: dialogContext.l10n.fieldName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? dialogContext.l10n.validationRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: unitController,
                  decoration: InputDecoration(
                    labelText: dialogContext.l10n.fieldUnit,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                numberField(
                  dialogContext,
                  controller: stockController,
                  labelText: dialogContext.l10n.fieldCurrentStock,
                ),
                const SizedBox(height: 12),
                numberField(
                  dialogContext,
                  controller: pkgSizeController,
                  labelText: dialogContext.l10n.fieldPackageSize,
                  positive: true,
                ),
                const SizedBox(height: 12),
                numberField(
                  dialogContext,
                  controller: minStockController,
                  labelText: dialogContext.l10n.fieldMinStock,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: _accentTextButtonStyle(dialogContext),
            child: Text(dialogContext.l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final navigator = Navigator.of(dialogContext);
              final l10n = dialogContext.l10n;
              try {
                await db.updateAccessory(
                  acc.copyWith(
                    name: nameController.text.trim(),
                    unit: unitController.text.trim(),
                    // The validators above guarantee these parse.
                    stock: _parseNumber(stockController.text)!,
                    packageSize: _parseNumber(pkgSizeController.text)!,
                    minStock: _parseNumber(minStockController.text)!,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.saveFailed('$e')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.savedSupply),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(dialogContext.l10n.actionSave),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccessory(
    BuildContext context,
    AppDatabase db,
    Accessory acc,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.accessoryDeleteTitle),
        content: Text(dialogContext.l10n.confirmDeleteNamed(acc.name)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: _accentTextButtonStyle(dialogContext),
            child: Text(dialogContext.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final l10n = dialogContext.l10n;
              try {
                await db.deleteAccessory(acc);
              } catch (e) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.saveFailed('$e')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.deletedGeneric),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(dialogContext.l10n.actionDelete),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  final String? hint;
  const _EmptySection({required this.message, this.hint});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 8),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
