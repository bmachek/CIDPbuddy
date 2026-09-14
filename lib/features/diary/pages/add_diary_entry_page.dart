import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';

class AddDiaryEntryPage extends StatefulWidget {
  final DiaryEntry? initialEntry;
  const AddDiaryEntryPage({super.key, this.initialEntry});

  @override
  State<AddDiaryEntryPage> createState() => _AddDiaryEntryPageState();
}

class _AddDiaryEntryPageState extends State<AddDiaryEntryPage> {
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

  @override
  void initState() {
    super.initState();
    if (widget.initialEntry != null) {
      final e = widget.initialEntry!;
      _selectedDate = e.date;
      _systolicController.text = e.systolicBP?.toString() ?? '';
      _diastolicController.text = e.diastolicBP?.toString() ?? '';
      _heartRateController.text = e.heartRate?.toString() ?? '';
      _tempController.text = e.temperature?.toString() ?? '';
      _weightController.text = e.weight?.toString() ?? '';
      _notesController.text = e.notes ?? '';
      _strength = e.strengthScore?.toDouble() ?? 5.0;
      _sensory = e.sensoryScore?.toDouble() ?? 5.0;
      _fatigue = e.fatigueScore?.toDouble() ?? 5.0;
      _pain = e.painScore?.toDouble() ?? 5.0;
      _balance = e.balanceScore?.toDouble() ?? 5.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialEntry == null
              ? context.l10n.diaryEntryTitleNew
              : context.l10n.diaryEntryTitleEdit,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context.l10n.sectionDateTime),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date == null || !context.mounted) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_selectedDate),
                );
                if (time == null || !context.mounted) return;
                setState(() {
                  _selectedDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              },
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppDateFormat.dateTime(context, _selectedDate),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Icon(Icons.calendar_today_rounded, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context.l10n.sectionVitals),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _systolicController,
                    context.l10n.fieldSystolic,
                    Icons.favorite_border_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    _diastolicController,
                    context.l10n.fieldDiastolic,
                    Icons.favorite_border_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _heartRateController,
                    context.l10n.fieldHeartRate,
                    Icons.monitor_heart_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    _tempController,
                    context.l10n.fieldTemperature,
                    Icons.thermostat_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
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
              const Color(0xFFFFB300),
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
            TextField(
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
              onPressed: () => _saveEntry(db),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
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
        isDense: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildSymptomSlider(
    String label,
    double value,
    Function(double) onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                value.toStringAsFixed(0),
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _saveEntry(AppDatabase db) async {
    final entry = DiaryEntriesCompanion.insert(
      date: _selectedDate,
      systolicBP: drift.Value(double.tryParse(_systolicController.text)),
      diastolicBP: drift.Value(double.tryParse(_diastolicController.text)),
      heartRate: drift.Value(int.tryParse(_heartRateController.text)),
      temperature: drift.Value(double.tryParse(_tempController.text)),
      weight: drift.Value(double.tryParse(_weightController.text)),
      notes: drift.Value(_notesController.text),
      strengthScore: drift.Value(_strength.round()),
      sensoryScore: drift.Value(_sensory.round()),
      fatigueScore: drift.Value(_fatigue.round()),
      painScore: drift.Value(_pain.round()),
      balanceScore: drift.Value(_balance.round()),
    );

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

    if (mounted) Navigator.pop(context);
  }
}
