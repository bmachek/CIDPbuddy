import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';
import 'package:cidpbuddy/core/theme/app_colors.dart';

class AddDiaryEntryPage extends StatefulWidget {
  final DiaryEntry? initialEntry;
  const AddDiaryEntryPage({super.key, this.initialEntry});

  @override
  State<AddDiaryEntryPage> createState() => _AddDiaryEntryPageState();
}

class _AddDiaryEntryPageState extends State<AddDiaryEntryPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _tempController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  double _strength = 5;
  double _sensory = 5;
  double _fatigue = 5;
  double _pain = 5;
  double _balance = 5;
  bool _isSaving = false;

  /// Snapshot of the form as it was opened, so leaving the page can warn
  /// about unsaved edits — and only about real ones.
  late final DateTime _initialDate;
  late final List<String> _initialTexts;
  late final List<double> _initialScores;

  List<TextEditingController> get _controllers => [
    _systolicController,
    _diastolicController,
    _heartRateController,
    _tempController,
    _weightController,
    _notesController,
  ];

  List<double> get _scores => [_strength, _sensory, _fatigue, _pain, _balance];

  bool get _isDirty {
    if (_selectedDate != _initialDate) return true;
    for (var i = 0; i < _controllers.length; i++) {
      if (_controllers[i].text != _initialTexts[i]) return true;
    }
    for (var i = 0; i < _scores.length; i++) {
      if (_scores[i] != _initialScores[i]) return true;
    }
    return false;
  }

  /// Text-field representation of a stored number: `72` rather than `72.0`.
  static String _numberText(num? value) {
    if (value == null) return '';
    if (value is int || value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  /// Accepts both decimal separators; the keyboard depends on the locale.
  static double? _parseNumber(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  @override
  void initState() {
    super.initState();
    if (widget.initialEntry != null) {
      final e = widget.initialEntry!;
      _selectedDate = e.date;
      _systolicController.text = _numberText(e.systolicBP);
      _diastolicController.text = _numberText(e.diastolicBP);
      _heartRateController.text = _numberText(e.heartRate);
      _tempController.text = _numberText(e.temperature);
      _weightController.text = _numberText(e.weight);
      _notesController.text = e.notes ?? '';
      _strength = e.strengthScore?.toDouble() ?? 5.0;
      _sensory = e.sensoryScore?.toDouble() ?? 5.0;
      _fatigue = e.fatigueScore?.toDouble() ?? 5.0;
      _pain = e.painScore?.toDouble() ?? 5.0;
      _balance = e.balanceScore?.toDouble() ?? 5.0;
    }
    _initialDate = _selectedDate;
    _initialTexts = _controllers.map((c) => c.text).toList();
    _initialScores = List.of(_scores);
    // PopScope.canPop is read in build, so typing must trigger a rebuild.
    for (final c in _controllers) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
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
            widget.initialEntry == null
                ? context.l10n.diaryEntryTitleNew
                : context.l10n.diaryEntryTitleEdit,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context.l10n.sectionDateTime),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppDateFormat.dateTime(context, _selectedDate),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.calendar_today_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context.l10n.sectionVitals),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          _systolicController,
                          context.l10n.fieldSystolic,
                          Icons.favorite_border_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNumberField(
                          _diastolicController,
                          context.l10n.fieldDiastolic,
                          Icons.favorite_border_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          _heartRateController,
                          context.l10n.fieldHeartRate,
                          Icons.monitor_heart_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNumberField(
                          _tempController,
                          context.l10n.fieldTemperature,
                          Icons.thermostat_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNumberField(
                    _weightController,
                    context.l10n.fieldWeight,
                    Icons.monitor_weight_rounded,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context.l10n.sectionSymptoms),
                  const SizedBox(height: 8),
                  _buildSymptomSlider(
                    context.l10n.symptomStrength,
                    _strength,
                    (val) => setState(() => _strength = val),
                    Theme.of(context).colorScheme.primary,
                  ),
                  _buildSymptomSlider(
                    context.l10n.symptomSensory,
                    _sensory,
                    (val) => setState(() => _sensory = val),
                    Theme.of(context).colorScheme.tertiary,
                  ),
                  _buildSymptomSlider(
                    context.l10n.symptomFatigue,
                    _fatigue,
                    (val) => setState(() => _fatigue = val),
                    AppStatusColors.of(context).warning,
                  ),
                  _buildSymptomSlider(
                    context.l10n.symptomPain,
                    _pain,
                    (val) => setState(() => _pain = val),
                    Theme.of(context).colorScheme.error,
                  ),
                  _buildSymptomSlider(
                    context.l10n.symptomBalance,
                    _balance,
                    (val) => setState(() => _balance = val),
                    Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context.l10n.sectionNotes),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: context.l10n.diaryNotesHint,
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveEntry(db),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      context.l10n.diaryEntrySave,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null || !mounted) return;
    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppStatusColors.of(context).accentText,
      ),
    );
  }

  /// An optional vital sign. Empty is fine; anything else must be a number
  /// above zero, otherwise the value would be dropped silently on save.
  String? _validateOptionalNumber(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final value = _parseNumber(text);
    if (value == null) return context.l10n.validationEnterNumber;
    if (value <= 0) return context.l10n.validationPositiveNumber;
    return null;
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
          ),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      validator: _validateOptionalNumber,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildSymptomSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
    Color color,
  ) {
    const min = 1.0;
    const max = 10.0;
    final score = value.round();
    final numberFormat = NumberFormat.decimalPattern(context.localeTag);
    final l10n = context.l10n;
    final canDecrease = value > min;
    final canIncrease = value < max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: MergeSemantics(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  numberFormat.format(score),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Stepper buttons beside the slider: a tremor makes hitting one of
        // ten slider stops hard, a 48 dp button is not.
        Row(
          children: [
            IconButton(
              tooltip: l10n.symptomScoreLabel(
                label,
                (score - 1).clamp(min.toInt(), max.toInt()),
              ),
              icon: const Icon(Icons.remove_circle_outline_rounded),
              onPressed: canDecrease ? () => onChanged(value - 1) : null,
            ),
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: 9,
                activeColor: color,
                label: numberFormat.format(score),
                semanticFormatterCallback: (v) =>
                    l10n.symptomScoreLabel(label, v.round()),
                onChanged: onChanged,
              ),
            ),
            IconButton(
              tooltip: l10n.symptomScoreLabel(
                label,
                (score + 1).clamp(min.toInt(), max.toInt()),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: canIncrease ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveEntry(AppDatabase db) async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final heartRate = _parseNumber(_heartRateController.text);
    final entry = DiaryEntriesCompanion.insert(
      date: _selectedDate,
      systolicBP: drift.Value(_parseNumber(_systolicController.text)),
      diastolicBP: drift.Value(_parseNumber(_diastolicController.text)),
      heartRate: drift.Value(heartRate?.round()),
      temperature: drift.Value(_parseNumber(_tempController.text)),
      weight: drift.Value(_parseNumber(_weightController.text)),
      notes: drift.Value(_notesController.text),
      strengthScore: drift.Value(_strength.round()),
      sensoryScore: drift.Value(_sensory.round()),
      fatigueScore: drift.Value(_fatigue.round()),
      painScore: drift.Value(_pain.round()),
      balanceScore: drift.Value(_balance.round()),
    );

    // Captured before the page closes: the confirmation must land on the
    // screen the patient returns to.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      if (widget.initialEntry != null) {
        await db.updateDiaryEntry(
          widget.initialEntry!.copyWith(
            date: _selectedDate,
            systolicBP: entry.systolicBP,
            diastolicBP: entry.diastolicBP,
            heartRate: entry.heartRate,
            temperature: entry.temperature,
            weight: entry.weight,
            notes: entry.notes,
            strengthScore: entry.strengthScore,
            sensoryScore: entry.sensoryScore,
            fatigueScore: entry.fatigueScore,
            painScore: entry.painScore,
            balanceScore: entry.balanceScore,
          ),
        );
      } else {
        await db.insertDiaryEntry(entry);
      }
    } catch (e) {
      // Re-enable the button so the patient can retry instead of losing
      // the entry.
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed('$e'))));
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(l10n.savedDiaryEntry)));
  }
}
