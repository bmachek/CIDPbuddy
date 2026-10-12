import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:cidpbuddy/core/database/database.dart';
import 'package:cidpbuddy/core/services/scheduler_service.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';
import 'package:cidpbuddy/core/theme/app_colors.dart';

class AddSchedulePage extends StatefulWidget {
  final InfusionSchedule? initialSchedule;
  final int? preselectedMedicationId;
  const AddSchedulePage({
    super.key,
    this.initialSchedule,
    this.preselectedMedicationId,
  });

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  Medication? _selectedMedication;
  late final TextEditingController _dosageController;
  late final TextEditingController _intervalController;
  late DateTime _startDate;
  late String _frequencyType;
  final List<int> _selectedWeekdays = [];
  final List<TimeOfDay> _intakeTimes = [const TimeOfDay(hour: 8, minute: 0)];
  bool _isFirstLoad = true;
  bool _isSaving = false;

  /// Created once: a future built inside `build` would be re-issued on every
  /// keystroke and show a spinner each time.
  late final Future<List<Medication>> _medicationsFuture;

  /// Snapshot of the form as opened, so leaving warns only about real edits.
  late final String _initialState;

  /// A weekday schedule without a single day, or an interval below one day,
  /// would save fine but never produce an appointment or a reminder — and an
  /// interval of 0 used to make the scheduler emit the same day 5000 times.
  bool get _isFrequencyValid {
    if (_frequencyType == 'weekdays') return _selectedWeekdays.isNotEmpty;
    if (_frequencyType == 'interval') {
      return (int.tryParse(_intervalController.text.trim()) ?? 0) >= 1;
    }
    return true;
  }

  /// The stored `value` is a database enum and must stay untranslated; only
  /// the label follows the UI language, so this cannot be a field initializer.
  List<Map<String, String>> _frequencies(BuildContext context) => [
    {'value': 'daily', 'label': context.l10n.frequencyDaily},
    {'value': 'interval', 'label': context.l10n.frequencyInterval},
    {'value': 'weekly', 'label': context.l10n.frequencyWeekly},
    {'value': 'biweekly', 'label': context.l10n.frequencyBiweekly},
    {'value': 'weekdays', 'label': context.l10n.frequencyWeekdays},
  ];

  /// Text-field representation of a stored number: `4` rather than `4.0`.
  static String _numberText(num? value) {
    if (value == null) return '';
    if (value is int || value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  static double? _parseNumber(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  /// The medication is bound once the list has loaded (see build), so it is
  /// tracked separately from the text snapshot.
  int? _initialMedicationId;

  String _snapshot() => [
    _dosageController.text,
    _intervalController.text,
    _frequencyType,
    (List.of(_selectedWeekdays)..sort()).join(','),
    _startDate.toIso8601String(),
    _intakeTimes.map((t) => '${t.hour}:${t.minute}').join(','),
  ].join('|');

  bool get _isDirty =>
      _snapshot() != _initialState ||
      _selectedMedication?.id != _initialMedicationId;

  @override
  void initState() {
    super.initState();
    final s = widget.initialSchedule;
    _dosageController = TextEditingController(
      text: s == null ? '1' : _numberText(s.dosage),
    );
    _intervalController = TextEditingController(
      text: s?.intervalValue?.toString() ?? '2',
    );
    _startDate = (s?.startDate ?? DateTime.now());
    // Normalize to midnight local time
    _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
    _frequencyType = s?.frequencyType ?? 'daily';

    // Map back 'weekly' with interval 2 to 'biweekly' for the UI
    if (_frequencyType == 'weekly' && s?.intervalValue == 2) {
      _frequencyType = 'biweekly';
    }

    // Stored as comma-separated text; a corrupt token is skipped rather than
    // crashing the page before anything is shown.
    if (s?.selectedWeekdays != null && s!.selectedWeekdays!.isNotEmpty) {
      for (final token in s.selectedWeekdays!.split(',')) {
        final day = int.tryParse(token.trim());
        if (day != null && day >= 1 && day <= 7) _selectedWeekdays.add(day);
      }
    }

    if (s?.intakeTimes != null && s!.intakeTimes!.isNotEmpty) {
      final parsed = <TimeOfDay>[];
      for (final tStr in s.intakeTimes!.split(',')) {
        final parts = tStr.split(':');
        if (parts.length != 2) continue;
        final hour = int.tryParse(parts[0].trim());
        final minute = int.tryParse(parts[1].trim());
        if (hour == null || minute == null) continue;
        if (hour < 0 || hour > 23 || minute < 0 || minute > 59) continue;
        parsed.add(TimeOfDay(hour: hour, minute: minute));
      }
      if (parsed.isNotEmpty) {
        _intakeTimes
          ..clear()
          ..addAll(parsed);
      }
    }

    _medicationsFuture = Provider.of<AppDatabase>(
      context,
      listen: false,
    ).getAllMedications();

    _initialState = _snapshot();
    _dosageController.addListener(_onFieldChanged);
    _intervalController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.discardChangesTitle),
        content: Text(context.l10n.discardChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.actionDiscard),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await _confirmDiscard();
        if (discard && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.initialSchedule == null
                ? context.l10n.scheduleTitleNew
                : context.l10n.scheduleTitleEdit,
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<List<Medication>>(
          future: _medicationsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildMessage(
                context,
                context.l10n.errorLoadingData,
                Icons.error_outline_rounded,
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final medications = snapshot.data!;
            if (medications.isEmpty) {
              return _buildMessage(
                context,
                context.l10n.inventoryNoMedications,
                Icons.medication_outlined,
              );
            }

            // Initialize selected medication on first load
            if (_isFirstLoad) {
              final wantedId =
                  widget.initialSchedule?.medicationId ??
                  widget.preselectedMedicationId;
              if (wantedId != null) {
                for (final m in medications) {
                  if (m.id == wantedId) {
                    _selectedMedication = m;
                    break;
                  }
                }
                if (_selectedMedication == null) {
                  debugPrint('AddSchedulePage: medication $wantedId not found');
                }
              }
              // Whatever got bound is the pristine choice.
              _initialMedicationId = _selectedMedication?.id;
              _isFirstLoad = false;
            }

            return SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        context.l10n.sectionMedicationAndDose,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Medication>(
                        initialValue: _selectedMedication,
                        isExpanded: true,
                        items: medications
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedMedication = val),
                        validator: (val) =>
                            val == null ? context.l10n.validationPickOne : null,
                        decoration: InputDecoration(
                          labelText: context.l10n.addInfusionPickMedication,
                          prefixIcon: const Icon(Icons.medication_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dosageController,
                        decoration: InputDecoration(
                          labelText: context.l10n.fieldUnitsPerInfusion,
                          prefixIcon: const Icon(Icons.scale_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) {
                            return context.l10n.validationRequired;
                          }
                          final value = _parseNumber(text);
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
                      const SizedBox(height: 32),
                      _buildSectionHeader(context.l10n.sectionFrequency),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _frequencyType,
                        isExpanded: true,
                        items: _frequencies(context)
                            .map(
                              (f) => DropdownMenuItem(
                                value: f['value'],
                                child: Text(
                                  f['label']!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() => _frequencyType = val);
                        },
                        decoration: InputDecoration(
                          labelText: context.l10n.sectionFrequency,
                          prefixIcon: const Icon(Icons.repeat_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      if (_frequencyType == 'interval') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _intervalController,
                          decoration: InputDecoration(
                            labelText: context.l10n.fieldNumberOfDays,
                            hintText: context.l10n.fieldNumberOfDaysHint,
                            prefixIcon: const Icon(Icons.today_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return context.l10n.validationRequired;
                            }
                            final value = int.tryParse(text.trim());
                            if (value == null) {
                              return context.l10n.validationEnterNumber;
                            }
                            if (value < 1) {
                              return context.l10n.validationPositiveNumber;
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ],
                      if (_frequencyType == 'weekdays') ...[
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.scheduleSelectDays,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(7, (index) {
                            final day = index + 1;
                            // 2024-01-01 was a Monday, so adding `index` days
                            // walks Mon–Sun and intl supplies the
                            // abbreviation per locale.
                            final label = DateFormat.E(context.localeTag)
                                .format(
                                  DateTime(
                                    2024,
                                    1,
                                    1,
                                  ).add(Duration(days: index)),
                                );
                            final isSelected = _selectedWeekdays.contains(day);
                            return ChoiceChip(
                              label: Text(label),
                              selected: isSelected,
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedWeekdays.add(day);
                                  } else {
                                    _selectedWeekdays.remove(day);
                                  }
                                });
                              },
                              selectedColor: colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              checkmarkColor: colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? colorScheme.onSurface
                                    : null,
                                fontWeight: isSelected ? FontWeight.bold : null,
                              ),
                            );
                          }),
                        ),
                      ],
                      const SizedBox(height: 32),
                      _buildSectionHeader(context.l10n.sectionPeriod),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickStartDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.outline),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.fieldStartDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      AppDateFormat.longDate(
                                        context,
                                        _startDate,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionHeader(context.l10n.sectionIntakeTimes),
                      const SizedBox(height: 16),
                      ...List.generate(
                        _intakeTimes.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickIntakeTime(index),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 48,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: colorScheme.outline,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _intakeTimes[index].format(context),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_intakeTimes.length > 1)
                                IconButton(
                                  tooltip: context.l10n.tooltipRemoveIntakeTime,
                                  icon: Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: colorScheme.error,
                                  ),
                                  onPressed: () => setState(
                                    () => _intakeTimes.removeAt(index),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => setState(
                          () => _intakeTimes.add(
                            const TimeOfDay(hour: 8, minute: 0),
                          ),
                        ),
                        // The brand blue fails AA for 14 px text in dark
                        // mode; accentText is the readable tone per theme.
                        style: TextButton.styleFrom(
                          foregroundColor: AppStatusColors.of(
                            context,
                          ).accentText,
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: Text(context.l10n.scheduleAddTime),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed:
                            (_selectedMedication == null ||
                                _isSaving ||
                                !_isFrequencyValid)
                            ? null
                            : () => _saveSchedule(db),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isSaving)
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            else
                              const Icon(Icons.save_rounded),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                widget.initialSchedule == null
                                    ? context.l10n.scheduleActivate
                                    : context.l10n.actionSaveChanges,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, String text, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              text,
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

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(
      () => _startDate = DateTime(picked.year, picked.month, picked.day),
    );
  }

  Future<void> _pickIntakeTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _intakeTimes[index],
    );
    if (picked == null || !mounted) return;
    setState(() => _intakeTimes[index] = picked);
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _saveSchedule(AppDatabase db) async {
    // Guard against double-taps: saving runs an async sync (which schedules
    // notifications) before the page closes. Without this, rapid taps would
    // each insert a new schedule, leaving multiple active duplicates.
    if (_isSaving || !_isFrequencyValid) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final medication = _selectedMedication;
    final dosage = _parseNumber(_dosageController.text);
    if (medication == null || dosage == null || dosage <= 0) return;
    setState(() => _isSaving = true);

    String finalFreq = _frequencyType;
    int? interval;
    if (_frequencyType == 'interval') {
      interval = int.tryParse(_intervalController.text.trim()) ?? 2;
      if (interval < 1) interval = 1;
    } else if (_frequencyType == 'biweekly') {
      finalFreq = 'weekly';
      interval = 2;
    } else if (_frequencyType == 'weekly') {
      interval = 1;
    }

    final intakeTimesStr = _intakeTimes
        .map(
          (t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        )
        .join(',');

    // Captured before the page closes: the confirmation must land on the
    // screen the patient returns to.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      if (widget.initialSchedule != null) {
        // Update existing schedule
        await db.updateSchedule(
          widget.initialSchedule!.copyWith(
            medicationId: medication.id,
            dosage: dosage,
            frequencyType: finalFreq,
            intervalValue: drift.Value(interval),
            selectedWeekdays: drift.Value(
              _frequencyType == 'weekdays' ? _selectedWeekdays.join(',') : null,
            ),
            startDate: _startDate,
            intakeTimes: drift.Value(intakeTimesStr),
          ),
        );

        // Clear out future entries to force regeneration
        await db.deletePlannedInfusionsForSchedule(widget.initialSchedule!.id);
      } else {
        // Insert new schedule
        await db.insertSchedule(
          InfusionSchedulesCompanion.insert(
            medicationId: medication.id,
            dosage: dosage,
            frequencyType: finalFreq,
            intervalValue: drift.Value(interval),
            selectedWeekdays: drift.Value(
              _frequencyType == 'weekdays' ? _selectedWeekdays.join(',') : null,
            ),
            startDate: _startDate,
            intakeTimes: drift.Value(intakeTimesStr),
          ),
        );
      }
    } catch (e) {
      // Re-enable the button so the user can retry instead of being stuck.
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed('$e'))));
      return;
    }

    // The schedule row is now persisted. Close the page immediately and run
    // the (potentially heavy) notification sync in the background — for a
    // medication with many schedules it issues thousands of platform calls
    // and must never block the dialog from closing.
    if (mounted) Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(l10n.savedSchedule)));
    unawaited(
      SchedulerService(db).syncPlannedInfusions().catchError(
        (e) => debugPrint('AddSchedulePage: background sync failed: $e'),
      ),
    );
  }
}
