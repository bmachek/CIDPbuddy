import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cidpbuddy/core/services/scheduler_service.dart';
import 'package:cidpbuddy/core/theme/app_colors.dart';
import 'package:cidpbuddy/features/reminders/services/notification_service.dart';
import '../providers/inventory_provider.dart';
import 'package:cidpbuddy/core/database/database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:cidpbuddy/features/diary/pages/add_schedule_page.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';

/// Digits and one decimal separator; the German keyboard produces a comma, so
/// both `.` and `,` are accepted and everything else is dropped as typed.
final _numberInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

/// Parses a number the way a patient types it: `1,5` and `1.5` are the same.
double? _parseNumber(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));

/// Form validator for a numeric field; [positive] additionally requires > 0.
String? _validateNumber(
  BuildContext context,
  String? value, {
  bool positive = false,
}) {
  final number = _parseNumber(value ?? '');
  if (number == null) return context.l10n.validationEnterNumber;
  if (positive && number <= 0) return context.l10n.validationPositiveNumber;
  return null;
}

/// A dialog's numeric field with the outlined border used throughout the
/// page's dialogs and inline validation instead of a silent fallback value.
Widget _numberField(
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
    validator: (value) => _validateNumber(context, value, positive: positive),
  );
}

/// Text buttons in dialogs: the brand blue at a tone that passes AA as
/// small text on both dialog surfaces (the dark theme's default only
/// reaches ~3:1).
ButtonStyle _accentTextButtonStyle(BuildContext context) =>
    TextButton.styleFrom(
      foregroundColor: AppStatusColors.of(context).accentText,
    );

void _showSnack(ScaffoldMessengerState messenger, String text) {
  messenger.showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );
}

/// Intake times are stored as a comma-joined `HH:mm` list; show each in the
/// device's clock format, separated by a readable ", ".
String _formatIntakeTimes(BuildContext context, String raw) {
  return raw
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .map((t) {
        final parts = t.split(':');
        final hour = parts.length == 2 ? int.tryParse(parts[0]) : null;
        final minute = parts.length == 2 ? int.tryParse(parts[1]) : null;
        if (hour == null || minute == null) return t;
        return AppDateFormat.time(context, DateTime(2000, 1, 1, hour, minute));
      })
      .join(', ');
}

class MedicationDetailsPage extends StatelessWidget {
  final int medicationId;

  const MedicationDetailsPage({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final invProvider = Provider.of<InventoryProvider>(context);

    return StreamBuilder<Medication>(
      stream: (db.select(
        db.medications,
      )..where((t) => t.id.equals(medicationId))).watchSingle(),
      builder: (context, snapshot) {
        // `watchSingle` errors once the row is gone (deleted from another
        // screen, or a restored backup without it); a spinner forever would
        // leave the patient stuck.
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.medDetailsNotFound,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(context.l10n.actionBack),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final medication = snapshot.data!;
        final colorScheme = Theme.of(context).colorScheme;
        final status = AppStatusColors.of(context);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        medication.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (medication.dosage.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          medication.dosage,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: status.accentText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                pinned: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: context.l10n.tooltipEditMedication,
                    onPressed: () =>
                        _showEditMedicationDialog(context, db, medication),
                  ),
                  if (medication.discontinuedAt == null)
                    IconButton(
                      icon: Icon(
                        Icons.heart_broken_outlined,
                        color: colorScheme.primary,
                      ),
                      onPressed: () => _confirmDiscontinueMedication(
                        context,
                        invProvider,
                        medication,
                      ),
                      tooltip: context.l10n.medDetailsDiscontinue,
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.add_moderator_outlined,
                        color: colorScheme.tertiary,
                      ),
                      onPressed: () => _confirmReenrollMedication(
                        context,
                        invProvider,
                        medication,
                      ),
                      tooltip: context.l10n.medDetailsReenroll,
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: colorScheme.error,
                    ),
                    onPressed: () => _confirmDeleteMedication(
                      context,
                      invProvider,
                      medication,
                    ),
                    tooltip: context.l10n.medDetailsDeleteCompletely,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              if (medication.discontinuedAt != null)
                SliverToBoxAdapter(
                  child: Container(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: status.accentText,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.l10n.medDetailsDiscontinuedSince(
                              AppDateFormat.date(
                                context,
                                medication.discontinuedAt!,
                              ),
                            ),
                            style: TextStyle(
                              color: status.accentText,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader(
                      context,
                      context.l10n.medDetailsSectionStock,
                    ),
                    const SizedBox(height: 12),
                    _StockManagementCard(medication: medication),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      context,
                      context.l10n.medDetailsSectionSupplies,
                    ),
                    Text(
                      context.l10n.medDetailsSuppliesHint,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<MedicationAccessory>>(
                      stream: db.watchAccessoriesForMedication(medication.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _buildCenteredNote(
                            context,
                            context.l10n.errorLoadingData,
                          );
                        }
                        final links = snapshot.data ?? [];
                        if (links.isEmpty) {
                          return _buildCenteredNote(
                            context,
                            context.l10n.medDetailsNoSuppliesLinked,
                          );
                        }

                        return Column(
                          children: links
                              .map(
                                (link) => _buildAccessoryRow(context, db, link),
                              )
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Stacked full-width buttons: a side-by-side pair cannot
                    // hold the German labels at 320 dp or with large text,
                    // and full-width targets are easier to hit.
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showLinkAccessoryDialog(context, db, medication),
                      icon: const Icon(Icons.link_rounded),
                      label: Text(
                        context.l10n.medDetailsLink,
                        textAlign: TextAlign.center,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: status.accentText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showCreateAccessoryDialog(context, db, medication),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                        context.l10n.medDetailsCreateAndLink,
                        textAlign: TextAlign.center,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (medication.type != MedicationType.pill) ...[
                      _buildSectionHeader(
                        context,
                        context.l10n.medDetailsSectionWorkflow,
                      ),
                      Text(
                        context.l10n.medDetailsWorkflowHint,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildWorkflowConfig(
                        context,
                        db,
                        invProvider,
                        medication,
                      ),
                      const SizedBox(height: 32),
                    ],
                    _buildSectionHeader(
                      context,
                      context.l10n.planningTabSchedules,
                    ),
                    Text(
                      context.l10n.medDetailsSchedulesHint,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<InfusionSchedule>>(
                      stream:
                          (db.select(db.infusionSchedules)..where(
                                (t) => t.medicationId.equals(medication.id),
                              ))
                              .watch(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _buildCenteredNote(
                            context,
                            context.l10n.errorLoadingData,
                          );
                        }
                        final schedules = snapshot.data ?? [];
                        if (schedules.isEmpty) {
                          return _buildCenteredNote(
                            context,
                            context.l10n.planningNoSchedules,
                          );
                        }
                        return Column(
                          children: schedules
                              .map(
                                (s) => _buildScheduleCard(
                                  context,
                                  db,
                                  s,
                                  medication,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddSchedulePage(
                            preselectedMedicationId: medication.id,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(
                        context.l10n.medDetailsCreateSchedule,
                        textAlign: TextAlign.center,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _showAddAppointmentDialog(context, db, medication),
                      icon: const Icon(Icons.event_rounded),
                      label: Text(
                        context.l10n.medDetailsPlanOneOff,
                        textAlign: TextAlign.center,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: status.accentText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildSectionHeader(
                      context,
                      context.l10n.medDetailsSectionSystemActions,
                    ),
                    const SizedBox(height: 12),
                    if (medication.discontinuedAt == null)
                      ElevatedButton.icon(
                        onPressed: () => _confirmDiscontinueMedication(
                          context,
                          invProvider,
                          medication,
                        ),
                        icon: const Icon(Icons.heart_broken_outlined),
                        label: Text(
                          context.l10n.medDetailsDiscontinueMedication,
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: status.accentText,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _confirmReenrollMedication(
                          context,
                          invProvider,
                          medication,
                        ),
                        icon: const Icon(Icons.add_moderator_outlined),
                        label: Text(
                          context.l10n.medDetailsReenroll,
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: status.success,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: colorScheme.tertiary.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _confirmDeleteMedication(
                        context,
                        invProvider,
                        medication,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(
                        context.l10n.medDetailsDeleteFromDatabase,
                        textAlign: TextAlign.center,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: colorScheme.error.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppStatusColors.of(context).accentText,
      ),
    );
  }

  Widget _buildCenteredNote(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildAccessoryRow(
    BuildContext context,
    AppDatabase db,
    MedicationAccessory link,
  ) {
    return StreamBuilder<Accessory>(
      stream: (db.select(
        db.accessories,
      )..where((t) => t.id.equals(link.accessoryId))).watchSingle(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildCenteredNote(context, context.l10n.errorLoadingData);
        }
        if (!snapshot.hasData) return const SizedBox.shrink();
        final acc = snapshot.data!;
        final colorScheme = Theme.of(context).colorScheme;
        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              leading: Icon(
                Icons.build_circle_rounded,
                color: colorScheme.tertiary,
              ),
              title: Text(
                acc.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                context.l10n.medDetailsRequirement(
                  link.defaultQuantity.toStringAsFixed(0),
                  acc.unit,
                ),
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (link.isMandatory)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Tooltip(
                        message: context.l10n.medDetailsMustBeOrdered,
                        child: Icon(
                          Icons.star_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: context.l10n.tooltipLinkSettings,
                    onPressed: () =>
                        _showEditLinkDialog(context, db, link, acc),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.link_off_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: context.l10n.tooltipUnlinkSupply,
                    onPressed: () =>
                        _confirmUnlinkAccessory(context, db, link, acc),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  void _confirmUnlinkAccessory(
    BuildContext context,
    AppDatabase db,
    MedicationAccessory link,
    Accessory acc,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.confirmUnlinkSupplyTitle),
        content: Text(dialogContext.l10n.confirmUnlinkSupplyBody(acc.name)),
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
                await (db.delete(
                  db.medicationAccessories,
                )..where((t) => t.id.equals(link.id))).go();
              } catch (e) {
                navigator.pop();
                _showSnack(messenger, l10n.saveFailed('$e'));
                return;
              }
              navigator.pop();
              _showSnack(messenger, l10n.deletedGeneric);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(dialogContext.l10n.actionRemove),
          ),
        ],
      ),
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
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.accessoryEditTitle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                _numberField(
                  dialogContext,
                  controller: stockController,
                  labelText: dialogContext.l10n.fieldCurrentStock,
                ),
                const SizedBox(height: 12),
                _numberField(
                  dialogContext,
                  controller: pkgSizeController,
                  labelText: dialogContext.l10n.fieldPackageSize,
                  positive: true,
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
                  ),
                );
              } catch (e) {
                _showSnack(messenger, l10n.saveFailed('$e'));
                return;
              }
              navigator.pop();
              _showSnack(messenger, l10n.savedSupply);
            },
            child: Text(dialogContext.l10n.actionSave),
          ),
        ],
      ),
    ).then((_) {
      if (context.mounted) (context as Element).markNeedsBuild();
    });
  }

  void _showLinkAccessoryDialog(
    BuildContext context,
    AppDatabase db,
    Medication medication,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final allAcc = await db.getAllAccessories();
    if (!context.mounted) return;

    if (allAcc.isEmpty) {
      _showSnack(messenger, context.l10n.medDetailsNeedSuppliesFirst);
      return;
    }

    final formKey = GlobalKey<FormState>();
    Accessory? selected;
    final qtyController = TextEditingController(text: '1');
    bool isMandatory = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(dialogContext.l10n.medDetailsLinkSupplyTitle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Accessory>(
                    isExpanded: true,
                    items: allAcc
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text(
                              a.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setDialogState(() => selected = val),
                    validator: (val) => val == null
                        ? dialogContext.l10n.validationPickOne
                        : null,
                    decoration: InputDecoration(
                      labelText: dialogContext.l10n.medDetailsPickSupply,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _numberField(
                    dialogContext,
                    controller: qtyController,
                    labelText: dialogContext.l10n.fieldPerInfusionRequirement,
                    positive: true,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(
                      dialogContext.l10n.medDetailsAlwaysOrder,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      dialogContext.l10n.medDetailsAlwaysOrderHint,
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: isMandatory,
                    onChanged: (val) => setDialogState(() => isMandatory = val),
                    contentPadding: EdgeInsets.zero,
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
                  await db.insertMedicationAccessory(
                    MedicationAccessoriesCompanion.insert(
                      medicationId: medication.id,
                      accessoryId: selected!.id,
                      defaultQuantity: drift.Value(
                        _parseNumber(qtyController.text)!,
                      ),
                      isMandatory: drift.Value(isMandatory),
                    ),
                  );
                } catch (e) {
                  _showSnack(messenger, l10n.saveFailed('$e'));
                  return;
                }
                navigator.pop();
              },
              child: Text(dialogContext.l10n.medDetailsLink),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (context.mounted) (context as Element).markNeedsBuild();
    });
  }

  void _showCreateAccessoryDialog(
    BuildContext context,
    AppDatabase db,
    Medication medication,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final unitController = TextEditingController(text: context.l10n.unitPieces);
    final stockController = TextEditingController(text: '0');
    final qtyController = TextEditingController(text: '1');
    final pkgSizeController = TextEditingController(text: '1.0');
    bool isMandatory = false;
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(dialogContext.l10n.medDetailsCreateSupplyTitle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: dialogContext.l10n.fieldSupplyName,
                      border: const OutlineInputBorder(),
                    ),
                    autofocus: true,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? dialogContext.l10n.validationRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: unitController,
                    decoration: InputDecoration(
                      labelText: dialogContext.l10n.fieldUnitWithExample,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    dialogContext,
                    controller: stockController,
                    labelText: dialogContext.l10n.fieldCurrentStock,
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    dialogContext,
                    controller: qtyController,
                    labelText: dialogContext.l10n.fieldPerInfusionRequirement,
                    positive: true,
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    dialogContext,
                    controller: pkgSizeController,
                    labelText: dialogContext.l10n.fieldPackageSize,
                    positive: true,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(
                      dialogContext.l10n.medDetailsAlwaysOrder,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      dialogContext.l10n.medDetailsAlwaysOrderHint,
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: isMandatory,
                    onChanged: (val) => setDialogState(() => isMandatory = val),
                    contentPadding: EdgeInsets.zero,
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
                  final accId = await db.insertAccessory(
                    AccessoriesCompanion.insert(
                      name: nameController.text.trim(),
                      stock: drift.Value(_parseNumber(stockController.text)!),
                      unit: unitController.text.trim(),
                      packageSize: drift.Value(
                        _parseNumber(pkgSizeController.text)!,
                      ),
                    ),
                  );
                  await db.insertMedicationAccessory(
                    MedicationAccessoriesCompanion.insert(
                      medicationId: medication.id,
                      accessoryId: accId,
                      defaultQuantity: drift.Value(
                        _parseNumber(qtyController.text)!,
                      ),
                      isMandatory: drift.Value(isMandatory),
                    ),
                  );
                } catch (e) {
                  _showSnack(messenger, l10n.saveFailed('$e'));
                  return;
                }
                navigator.pop();
                _showSnack(messenger, l10n.savedSupply);
              },
              child: Text(dialogContext.l10n.actionCreate),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (context.mounted) (context as Element).markNeedsBuild();
    });
  }

  void _showEditMedicationDialog(
    BuildContext context,
    AppDatabase db,
    Medication med,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: med.name);
    final dosageController = TextEditingController(text: med.dosage);
    final pznController = TextEditingController(text: med.pzn ?? '');
    final unitController = TextEditingController(text: med.unit);
    final pkgSizeController = TextEditingController(
      text: med.packageSize.toStringAsFixed(1),
    );
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.medDetailsEditMedication),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                  controller: dosageController,
                  decoration: InputDecoration(
                    labelText: dialogContext.l10n.fieldStrengthWithExample,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pznController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: dialogContext.l10n.fieldPzn,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: unitController,
                  decoration: InputDecoration(
                    labelText: dialogContext.l10n.fieldUnitWithBottleExample,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                _numberField(
                  dialogContext,
                  controller: pkgSizeController,
                  labelText: dialogContext.l10n.fieldPackageSize,
                  positive: true,
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
                await db.updateMedication(
                  med.copyWith(
                    name: nameController.text.trim(),
                    dosage: dosageController.text.trim(),
                    pzn: drift.Value(pznController.text.trim()),
                    unit: unitController.text.trim(),
                    packageSize: _parseNumber(pkgSizeController.text)!,
                  ),
                );
              } catch (e) {
                _showSnack(messenger, l10n.saveFailed('$e'));
                return;
              }
              navigator.pop();
              _showSnack(messenger, l10n.savedMedication);
            },
            child: Text(dialogContext.l10n.actionSave),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMedication(
    BuildContext context,
    InventoryProvider provider,
    Medication med,
  ) {
    // The page's navigator and messenger, captured before the dialog opens:
    // after the await the dialog's own context is deactivated.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.medDetailsDeleteTitle),
        content: Text(dialogContext.l10n.medDetailsDeleteBody(med.name)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: _accentTextButtonStyle(dialogContext),
            child: Text(dialogContext.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () async {
              final l10n = dialogContext.l10n;
              try {
                await provider.deleteMedication(med);
              } catch (e) {
                navigator.pop();
                _showSnack(messenger, l10n.saveFailed('$e'));
                return;
              }
              navigator.pop(); // Close dialog
              navigator.pop(); // Go back to inventory
              _showSnack(messenger, l10n.deletedGeneric);
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

  void _confirmDiscontinueMedication(
    BuildContext context,
    InventoryProvider provider,
    Medication med,
  ) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.medDetailsDiscontinueTitle),
        content: Text(dialogContext.l10n.medDetailsDiscontinueBody(med.name)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: _accentTextButtonStyle(dialogContext),
            child: Text(dialogContext.l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final l10n = dialogContext.l10n;
              try {
                await provider.discontinueMedication(med.id);
              } catch (e) {
                navigator.pop();
                _showSnack(messenger, l10n.saveFailed('$e'));
                return;
              }
              navigator.pop(); // Close dialog
              navigator.pop(); // Go back to inventory
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.primary,
              foregroundColor: Theme.of(dialogContext).colorScheme.onPrimary,
            ),
            child: Text(dialogContext.l10n.medDetailsDiscontinue),
          ),
        ],
      ),
    );
  }

  void _confirmReenrollMedication(
    BuildContext context,
    InventoryProvider provider,
    Medication med,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.confirmReenrollTitle),
        content: Text(dialogContext.l10n.confirmReenrollBody(med.name)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: _accentTextButtonStyle(dialogContext),
            child: Text(dialogContext.l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final l10n = dialogContext.l10n;
              try {
                await provider.reenrollMedication(med.id);
              } catch (e) {
                navigator.pop();
                _showSnack(messenger, l10n.saveFailed('$e'));
                return;
              }
              navigator.pop();
              _showSnack(messenger, l10n.reenrolledMedication(med.name));
            },
            child: Text(dialogContext.l10n.medDetailsReenroll),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog(
    BuildContext context,
    AppDatabase db,
    Medication med,
  ) async {
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final dosageController = TextEditingController(text: '1.0');
    final messenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) => AlertDialog(
            title: Text(dialogContext.l10n.planningScheduleAppointmentTitle),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      med.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(dialogContext.l10n.sectionDateTime),
                      subtitle: Text(
                        AppDateFormat.dateTime(dialogContext, selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today_rounded),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date == null || !dialogContext.mounted) return;
                        // Without a time the appointment lands at midnight,
                        // which falls inside the default quiet hours
                        // (22:00–06:00) and silences every reminder for it.
                        final time = await showTimePicker(
                          context: dialogContext,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time == null || !dialogContext.mounted) return;
                        setState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _numberField(
                      dialogContext,
                      controller: dosageController,
                      labelText: dialogContext.l10n.fieldPlannedDoseWithUnit(
                        med.unit,
                      ),
                      positive: true,
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
                  final confirmation = l10n.planningScheduledFor(
                    AppDateFormat.dateTime(dialogContext, selectedDate),
                  );
                  try {
                    await db.insertPlannedInfusion(
                      PlannedInfusionsCompanion.insert(
                        date: selectedDate,
                        medicationId: med.id,
                        dosage: _parseNumber(dosageController.text)!,
                        isCompleted: const drift.Value(false),
                      ),
                    );
                  } catch (e) {
                    _showSnack(messenger, l10n.saveFailed('$e'));
                    return;
                  }
                  navigator.pop();
                  _showSnack(messenger, confirmation);
                  // Register the reminders now instead of waiting for the next
                  // app start or the 24 h background sync.
                  unawaited(
                    SchedulerService(db).syncPlannedInfusions().catchError(
                      (e) => debugPrint(
                        'MedicationDetails: appointment sync failed: $e',
                      ),
                    ),
                  );
                },
                child: Text(dialogContext.l10n.actionSave),
              ),
            ],
          ),
        );
      },
    );
    dosageController.dispose();
  }

  Widget _buildScheduleCard(
    BuildContext context,
    AppDatabase db,
    InfusionSchedule schedule,
    Medication med,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    String freqLabel = '';
    switch (schedule.frequencyType) {
      case 'daily':
        freqLabel = context.l10n.frequencyDaily;
        break;
      case 'weekly':
        freqLabel = schedule.intervalValue == 2
            ? context.l10n.frequencyBiweekly
            : context.l10n.frequencyWeekly;
        break;
      case 'interval':
        freqLabel = context.l10n.frequencyEveryNDays(
          schedule.intervalValue ?? 0,
        );
        break;
      case 'weekdays':
        freqLabel = context.l10n.frequencyWeekdaysShort;
        break;
    }

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.repeat_rounded, color: colorScheme.primary),
          ),
          title: Text(
            freqLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                context.l10n.doseValue('${schedule.dosage}', med.unit),
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              if (schedule.intakeTimes != null &&
                  schedule.intakeTimes!.isNotEmpty)
                Text(
                  context.l10n.medDetailsTimes(
                    _formatIntakeTimes(context, schedule.intakeTimes!),
                  ),
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: context.l10n.tooltipEditSchedule,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddSchedulePage(initialSchedule: schedule),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.error,
                ),
                tooltip: context.l10n.tooltipDeleteSchedule,
                onPressed: () => _confirmDeleteSchedule(context, db, schedule),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  void _confirmDeleteSchedule(
    BuildContext context,
    AppDatabase db,
    InfusionSchedule schedule,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.planningDeleteScheduleTitle),
        content: Text(dialogContext.l10n.planningDeleteScheduleBody),
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
                final futureAppts =
                    await (db.select(db.plannedInfusions)..where(
                          (t) =>
                              t.scheduleId.equals(schedule.id) &
                              t.isCompleted.equals(false),
                        ))
                        .get();
                for (final appt in futureAppts) {
                  await NotificationService().cancelTreatmentReminders(appt.id);
                }
                await db.deletePlannedInfusionsForSchedule(schedule.id);
                await db.deleteSchedule(schedule.id);
              } catch (e) {
                navigator.pop();
                _showSnack(messenger, l10n.saveFailed('$e'));
                return;
              }
              navigator.pop();
              _showSnack(messenger, l10n.deletedGeneric);
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

  Widget _buildWorkflowConfig(
    BuildContext context,
    AppDatabase db,
    InventoryProvider provider,
    Medication medication,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    // A Material rather than a coloured Container: the switch tiles draw
    // their ink on the nearest Material, which must therefore carry the
    // card colour and shape.
    return Material(
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(context.l10n.medDetailsTrackBatch),
            subtitle: Text(context.l10n.medDetailsTrackBatchHint),
            value: medication.trackBatchNumber,
            onChanged: (val) => provider.updateMedication(
              medication.copyWith(trackBatchNumber: val),
            ),
            secondary: Icon(
              Icons.qr_code_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (medication.trackBatchNumber)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                context.l10n.legalBatchDocumentationShort,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(context.l10n.medDetailsTrackWeight),
            subtitle: Text(context.l10n.medDetailsTrackWeightHint),
            value: medication.trackWeight,
            onChanged: (val) => provider.updateMedication(
              medication.copyWith(trackWeight: val),
            ),
            secondary: Icon(
              Icons.monitor_weight_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(context.l10n.medDetailsUseTimer),
            subtitle: Text(context.l10n.medDetailsUseTimerHint),
            value: medication.useTimer,
            onChanged: (val) =>
                provider.updateMedication(medication.copyWith(useTimer: val)),
            secondary: Icon(
              Icons.av_timer_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditLinkDialog(
    BuildContext context,
    AppDatabase db,
    MedicationAccessory link,
    Accessory acc,
  ) {
    final formKey = GlobalKey<FormState>();
    final qtyController = TextEditingController(
      text: link.defaultQuantity.toStringAsFixed(1),
    );
    bool isMandatory = link.isMandatory;
    final pkgSizeController = TextEditingController(
      text: acc.packageSize.toStringAsFixed(1),
    );
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(dialogContext.l10n.medDetailsConfigureNamed(acc.name)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _numberField(
                    dialogContext,
                    controller: qtyController,
                    labelText: dialogContext.l10n
                        .fieldPerInfusionRequirementWithUnit(acc.unit),
                    positive: true,
                  ),
                  const SizedBox(height: 16),
                  _numberField(
                    dialogContext,
                    controller: pkgSizeController,
                    labelText: dialogContext.l10n.fieldPackageSize,
                    positive: true,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(
                      dialogContext.l10n.medDetailsAlwaysOrder,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      dialogContext.l10n.medDetailsAlwaysOrderHint,
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: isMandatory,
                    onChanged: (val) => setState(() => isMandatory = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  TextButton.icon(
                    style: _accentTextButtonStyle(dialogContext),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      dialogContext.l10n.medDetailsEditSupplyGlobally,
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      // The page's context, not the dialog's — that one is
                      // deactivated by the pop above.
                      _showEditAccessoryDialog(context, db, acc);
                    },
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
                  await db.updateMedicationAccessory(
                    link.copyWith(
                      defaultQuantity: _parseNumber(qtyController.text)!,
                      isMandatory: isMandatory,
                    ),
                  );
                  // Also update accessory package size if changed
                  final newPkgSize = _parseNumber(pkgSizeController.text)!;
                  if (newPkgSize != acc.packageSize) {
                    await db.updateAccessory(
                      acc.copyWith(packageSize: newPkgSize),
                    );
                  }
                } catch (e) {
                  _showSnack(messenger, l10n.saveFailed('$e'));
                  return;
                }
                navigator.pop();
                _showSnack(messenger, l10n.savedSupply);
              },
              child: Text(dialogContext.l10n.actionSave),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (context.mounted) (context as Element).markNeedsBuild();
    });
  }
}

class _StockManagementCard extends StatefulWidget {
  final Medication medication;

  const _StockManagementCard({required this.medication});

  @override
  State<_StockManagementCard> createState() => _StockManagementCardState();
}

class _StockManagementCardState extends State<_StockManagementCard> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(
      text: widget.medication.stock.toStringAsFixed(0),
    );
    _minStockController = TextEditingController(
      text: widget.medication.minStock.toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(_StockManagementCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.medication.stock != widget.medication.stock && !_isSaving) {
      _stockController.text = widget.medication.stock.toStringAsFixed(0);
    }
    if (oldWidget.medication.minStock != widget.medication.minStock &&
        !_isSaving) {
      _minStockController.text = widget.medication.minStock.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    final db = Provider.of<AppDatabase>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    // The validators guarantee these parse.
    final newStock = _parseNumber(_stockController.text)!;
    final newMinStock = _parseNumber(_minStockController.text)!;

    setState(() => _isSaving = true);
    try {
      await db.updateMedication(
        widget.medication.copyWith(stock: newStock, minStock: newMinStock),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack(messenger, l10n.saveFailed('$e'));
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    _showSnack(messenger, l10n.medDetailsStockUpdated);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _stockController,
            decoration: InputDecoration(
              labelText: context.l10n.fieldCurrentStockShort,
              suffixText: widget.medication.unit,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: colorScheme.primary.withValues(alpha: 0.05),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _numberInputFormatters,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => _validateNumber(context, value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _minStockController,
            decoration: InputDecoration(
              labelText: context.l10n.fieldMinStockDays,
              hintText: context.l10n.fieldMinStockDaysHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: colorScheme.primary.withValues(alpha: 0.05),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _numberInputFormatters,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => _validateNumber(context, value),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveChanges,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(
              context.l10n.medDetailsSaveStock,
              textAlign: TextAlign.center,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
