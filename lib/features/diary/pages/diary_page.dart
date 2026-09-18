import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../../../core/database/database.dart';
import 'add_infusion_page.dart';
import 'add_diary_entry_page.dart';
import 'statistics_page.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';
import 'package:cidpbuddy/core/theme/app_colors.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryProvider = Provider.of<DiaryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<dynamic>>(
        stream: diaryProvider.combinedEntriesStream,
        builder: (context, snapshot) {
          final entries = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(context.l10n.diaryTitle),
                actions: [
                  IconButton(
                    tooltip: context.l10n.tooltipOpenStatistics,
                    icon: const Icon(Icons.bar_chart_rounded),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatisticsPage()),
                    ),
                  ),
                ],
              ),
              if (snapshot.hasError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(context),
                )
              else if (entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context),
                )
              else
                SliverPadding(
                  // The bottom clearance keeps the last entry above the
                  // translucent navigation bar (extendBody) and the FABs.
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = entries[index];
                      if (entry is InfusionLogData) {
                        return _buildLogCard(context, entry);
                      } else if (entry is DiaryEntry) {
                        return _buildDiaryEntryCard(context, entry);
                      } else if (entry is PendingOrder) {
                        return _buildOrderHistoryCard(context, entry);
                      } else if (entry is MedicationEvent) {
                        return _buildMedicationEventCard(context, entry);
                      }
                      return const SizedBox();
                    }, childCount: entries.length),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'diary_fab_entry',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDiaryEntryPage()),
              ),
              icon: const Icon(Icons.analytics_outlined),
              label: Text(context.l10n.diaryEntryTitleNew),
              backgroundColor: Theme.of(
                context,
              ).cardColor.withValues(alpha: 0.9),
              foregroundColor: AppStatusColors.of(context).accentText,
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: 'diary_fab_infusion',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddInfusionPage()),
              ),
              icon: const Icon(Icons.medication_rounded),
              label: Text(context.l10n.addInfusionTitle),
            ),
          ],
        ),
      ),
    );
  }

  /// Blood pressure as `120/80`; a half-recorded reading shows what exists.
  String _bloodPressure(BuildContext context, DiaryEntry entry) {
    final format = NumberFormat.decimalPattern(context.localeTag);
    final systolic = entry.systolicBP;
    final diastolic = entry.diastolicBP;
    if (systolic != null && diastolic != null) {
      return '${format.format(systolic.round())}/${format.format(diastolic.round())}';
    }
    return format.format((systolic ?? diastolic ?? 0).round());
  }

  Widget _buildDiaryEntryCard(BuildContext context, DiaryEntry entry) {
    final dateStr = AppDateFormat.longDate(context, entry.date);
    final timeStr = AppDateFormat.time(context, entry.date);
    final intFormat = NumberFormat.decimalPattern(context.localeTag);
    final oneDecimal = NumberFormat.decimalPatternDigits(
      locale: context.localeTag,
      decimalDigits: 1,
    );

    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddDiaryEntryPage(initialEntry: entry),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (entry.systolicBP != null ||
                              entry.diastolicBP != null)
                            _buildSmallChip(
                              context,
                              _bloodPressure(context, entry),
                              Icons.favorite,
                            ),
                          if (entry.heartRate != null)
                            _buildSmallChip(
                              context,
                              context.l10n.bpmValue(
                                intFormat.format(entry.heartRate),
                              ),
                              Icons.monitor_heart,
                            ),
                          if (entry.weight != null)
                            _buildSmallChip(
                              context,
                              context.l10n.kilogramsValue(
                                oneDecimal.format(entry.weight),
                              ),
                              Icons.monitor_weight,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSymptomMiniBar(context, entry),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildSmallChip(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomMiniBar(BuildContext context, DiaryEntry entry) {
    final l10n = context.l10n;
    final symptoms = <({IconData icon, String name, int? score})>[
      (
        icon: Icons.fitness_center_rounded,
        name: l10n.symptomStrength,
        score: entry.strengthScore,
      ),
      (
        icon: Icons.touch_app_rounded,
        name: l10n.symptomSensory,
        score: entry.sensoryScore,
      ),
      (
        icon: Icons.battery_alert_rounded,
        name: l10n.symptomFatigue,
        score: entry.fatigueScore,
      ),
      (
        icon: Icons.bolt_rounded,
        name: l10n.symptomPain,
        score: entry.painScore,
      ),
      (
        icon: Icons.balance_rounded,
        name: l10n.symptomBalance,
        score: entry.balanceScore,
      ),
    ];

    final activeSymptoms = symptoms.where((s) => s.score != null).toList();
    if (activeSymptoms.isEmpty) return const SizedBox();
    final numberFormat = NumberFormat.decimalPattern(context.localeTag);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.diaryVitalsAndSymptomsLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AppStatusColors.of(context).accentText,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: activeSymptoms.map((s) {
            final score = s.score ?? 0;
            final color = _getColorForScore(context, score);
            // Colour alone is not enough: the score is printed under each
            // bar, and a screen reader hears "Pain: 7 of 10".
            return Expanded(
              child: Semantics(
                label: l10n.symptomScoreLabel(s.name, score),
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Column(
                    children: [
                      Icon(s.icon, size: 16, color: color),
                      const SizedBox(height: 4),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        numberFormat.format(score),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getColorForScore(BuildContext context, int score) {
    if (score >= 8) return Theme.of(context).colorScheme.error;
    if (score >= 5) return AppStatusColors.of(context).warning;
    return AppStatusColors.of(context).success;
  }

  Widget _buildEmptyState(BuildContext context) {
    // Scrollable so that a large system font never overflows the space the
    // sliver leaves for it.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 160),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_diary.png',
            height: 200,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.diaryEmptyTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.diaryEmptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.errorLoadingData,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, InfusionLogData log) {
    final dateStr = AppDateFormat.longDate(context, log.date);
    final timeStr = AppDateFormat.time(context, log.date);
    final accentText = AppStatusColors.of(context).accentText;
    final oneDecimal = NumberFormat.decimalPatternDigits(
      locale: context.localeTag,
      decimalDigits: 1,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.vaccines_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: accentText,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            timeStr,
                            style: TextStyle(
                              color: accentText,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (log.batchNumber != null && log.batchNumber!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          context.l10n.batchValue(log.batchNumber!),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (log.notes != null && log.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          log.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    if (log.bodyWeight != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.monitor_weight_rounded,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                context.l10n.kilogramsValue(
                                  oneDecimal.format(log.bodyWeight),
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (log.photoPath != null && log.photoPath!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(log.photoPath!),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            semanticLabel: context.l10n.actionPhotoOfLabel,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: context.l10n.tooltipEditInfusionLog,
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _showEditLogDialog(
                          context,
                          Provider.of<AppDatabase>(context, listen: false),
                          log,
                        ),
                      ),
                      IconButton(
                        tooltip: context.l10n.tooltipDeleteInfusionLog,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        onPressed: () => _confirmDeleteLog(
                          context,
                          Provider.of<AppDatabase>(context, listen: false),
                          log,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      oneDecimal.format(log.dosage),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: accentText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  void _showEditLogDialog(
    BuildContext context,
    AppDatabase db,
    InfusionLogData log,
  ) {
    final formKey = GlobalKey<FormState>();
    final batchController = TextEditingController(text: log.batchNumber ?? '');
    final weight = log.bodyWeight;
    final weightController = TextEditingController(
      text: weight == null
          ? ''
          : (weight == weight.roundToDouble()
                ? weight.toInt().toString()
                : weight.toString()),
    );
    final notesController = TextEditingController(text: log.notes ?? '');
    DateTime selectedDate = log.date;
    var saving = false;

    showDialog(
      context: context,
      // Three fields to fill in: an accidental tap outside must not throw
      // the edits away.
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.diaryEntryTitleEdit),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.sectionDateTime),
                    subtitle: Text(
                      AppDateFormat.dateTime(context, selectedDate),
                    ),
                    trailing: const Icon(Icons.edit_calendar_rounded),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now(),
                      );
                      if (date == null || !context.mounted) return;
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time == null || !context.mounted) return;
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: batchController,
                    decoration: InputDecoration(
                      labelText: context.l10n.fieldBatchNumberShort,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: weightController,
                    decoration: InputDecoration(
                      labelText: context.l10n.fieldBodyWeight,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) return null;
                      final value = double.tryParse(
                        text.trim().replaceAll(',', '.'),
                      );
                      if (value == null) {
                        return context.l10n.validationEnterNumber;
                      }
                      if (value <= 0) {
                        return context.l10n.validationPositiveNumber;
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: context.l10n.fieldNotes,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.actionCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (saving) return;
                if (!(formKey.currentState?.validate() ?? false)) return;
                saving = true;
                final messenger = ScaffoldMessenger.of(context);
                final l10n = context.l10n;
                try {
                  await db.updateInfusionLog(
                    log.copyWith(
                      date: selectedDate,
                      batchNumber: drift.Value(batchController.text),
                      bodyWeight: drift.Value(
                        double.tryParse(
                          weightController.text.trim().replaceAll(',', '.'),
                        ),
                      ),
                      notes: drift.Value(notesController.text),
                    ),
                  );
                } catch (e) {
                  saving = false;
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.saveFailed('$e'))),
                  );
                  return;
                }
                if (context.mounted) Navigator.pop(context);
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.savedInfusion)),
                );
              },
              child: Text(context.l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteLog(
    BuildContext context,
    AppDatabase db,
    InfusionLogData log,
  ) {
    var deleting = false;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.diaryDeleteEntryTitle),
        content: Text(context.l10n.diaryDeleteEntryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.actionCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              // Guard against double-taps: the dialog only closes after the
              // transaction, so a second tap would credit the stock twice.
              if (deleting) return;
              deleting = true;
              final messenger = ScaffoldMessenger.of(context);
              final l10n = context.l10n;
              try {
                await db.transaction(() async {
                  // 1. Revert medication stock. The medication may have been
                  // deleted since; its history stays, so just skip the stock.
                  final med =
                      await (db.select(db.medications)
                            ..where((t) => t.id.equals(log.medicationId)))
                          .getSingleOrNull();
                  if (med != null) {
                    await db.updateMedication(
                      med.copyWith(stock: med.stock + log.dosage),
                    );
                  }

                  // 2. Revert accessory stock (based on CURRENT links as best effort)
                  final links = await db.getAccessoriesForMedication(
                    log.medicationId,
                  );
                  for (final link in links) {
                    final acc =
                        await (db.select(db.accessories)
                              ..where((t) => t.id.equals(link.accessoryId)))
                            .getSingleOrNull();
                    if (acc == null) continue;
                    await db.updateAccessory(
                      acc.copyWith(stock: acc.stock + link.defaultQuantity),
                    );
                  }

                  // 3. Delete log
                  await db.deleteInfusionLog(log.id);
                });
              } catch (e) {
                deleting = false;
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.saveFailed('$e'))),
                );
                return;
              }

              if (context.mounted) Navigator.pop(context);
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.deletedGeneric)),
              );
            },
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryCard(BuildContext context, PendingOrder order) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final dateStr = AppDateFormat.longDate(
      context,
      order.deliveryDate ?? DateTime.now(),
    );
    final quantityFormat = NumberFormat.decimalPattern(context.localeTag);

    return FutureBuilder<List<PendingOrderItem>>(
      future: db.getPendingOrderItems(order.id),
      builder: (context, itemsSnapshot) {
        final items = itemsSnapshot.data ?? [];

        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              title: Text(
                context.l10n.diaryOrderReceived,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                dateStr,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(58, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((item) {
                    return FutureBuilder<dynamic>(
                      future: item.medicationId != null
                          ? (db.select(db.medications)..where(
                                  (t) => t.id.equals(item.medicationId!),
                                ))
                                .getSingle()
                          : (db.select(
                                  db.accessories,
                                )..where((t) => t.id.equals(item.accessoryId!)))
                                .getSingle(),
                      builder: (context, nameSnapshot) {
                        final String text;
                        if (nameSnapshot.hasError) {
                          // The item was deleted since: say so instead of
                          // leaving a permanent "…" placeholder.
                          text = context.l10n.errorLoadingData;
                        } else if (nameSnapshot.hasData) {
                          text = context.l10n.deliveredItem(
                            quantityFormat.format(item.quantity),
                            nameSnapshot.data?.unit ?? '',
                            nameSnapshot.data?.name ?? '',
                          );
                        } else {
                          text = '…';
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AppStatusColors.of(context).success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildMedicationEventCard(
    BuildContext context,
    MedicationEvent event,
  ) {
    final dateStr = AppDateFormat.longDate(context, event.date);
    final isDiscontinued = event.type == MedicationEventType.discontinued;
    final status = AppStatusColors.of(context);
    final accent = isDiscontinued ? status.inactive : status.success;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: CircleAvatar(
            backgroundColor: accent.withValues(alpha: 0.1),
            child: Icon(
              isDiscontinued
                  ? Icons.heart_broken_outlined
                  : Icons.add_moderator_outlined,
              color: accent,
            ),
          ),
          title: Text(
            isDiscontinued
                ? context.l10n.diaryEventDiscontinued(event.medication.name)
                : context.l10n.diaryEventPrescribed(event.medication.name),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(dateStr),
        ),
        const Divider(),
      ],
    );
  }
}
