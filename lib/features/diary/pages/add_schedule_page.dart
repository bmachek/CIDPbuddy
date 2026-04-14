import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';
import '../../../core/services/scheduler_service.dart';

class AddSchedulePage extends StatefulWidget {
  final InfusionSchedule? initialSchedule;
  const AddSchedulePage({super.key, this.initialSchedule});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  Medication? _selectedMedication;
  late final TextEditingController _dosageController;
  late final TextEditingController _intervalController;
  late DateTime _startDate;
  late String _frequencyType;
  final List<int> _selectedWeekdays = [];
  bool _isFirstLoad = true;

  final List<Map<String, String>> _frequencies = [
    {'value': 'daily', 'label': 'Täglich'},
    {'value': 'interval', 'label': 'Alle X Tage'},
    {'value': 'weekly', 'label': 'Wöchentlich'},
    {'value': 'biweekly', 'label': 'Alle 2 Wochen'},
    {'value': 'weekdays', 'label': 'Bestimmte Wochentage'},
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.initialSchedule;
    _dosageController = TextEditingController(text: s?.dosage.toString() ?? '1.0');
    _intervalController = TextEditingController(text: s?.intervalValue?.toString() ?? '2');
    _startDate = (s?.startDate ?? DateTime.now());
    // Normalize to midnight local time
    _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
    _frequencyType = s?.frequencyType ?? 'daily';
    
    // Map back 'weekly' with interval 2 to 'biweekly' for the UI
    if (_frequencyType == 'weekly' && s?.intervalValue == 2) {
      _frequencyType = 'biweekly';
    }

    if (s?.selectedWeekdays != null && s!.selectedWeekdays!.isNotEmpty) {
      _selectedWeekdays.addAll(s.selectedWeekdays!.split(',').where((e) => e.isNotEmpty).map(int.parse));
    }
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.initialSchedule == null ? 'Infusionsplan erstellen' : 'Infusionsplan bearbeiten')),
      body: FutureBuilder<List<Medication>>(
        future: db.getAllMedications(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final medications = snapshot.data!;

          // Initialize selected medication on first load
          if (_isFirstLoad && widget.initialSchedule != null) {
            try {
              _selectedMedication = medications.firstWhere((m) => m.id == widget.initialSchedule!.medicationId);
            } catch (_) {}
            _isFirstLoad = false;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Medication>(
                  value: _selectedMedication,
                  items: medications.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                  onChanged: (val) => setState(() => _selectedMedication = val),
                  decoration: const InputDecoration(labelText: 'Medikament', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dosageController,
                  decoration: const InputDecoration(labelText: 'Dosis', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Häufigkeit', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _frequencyType,
                  items: _frequencies.map((f) => DropdownMenuItem(value: f['value'], child: Text(f['label']!))).toList(),
                  onChanged: (val) => setState(() => _frequencyType = val!),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                if (_frequencyType == 'interval') ...[
                  TextField(
                    controller: _intervalController,
                    decoration: const InputDecoration(labelText: 'Alle wie viele Tage?', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                ],
                if (_frequencyType == 'weekdays') ...[
                  const Text('Wochentage wählen:'),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final label = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][index];
                      final isSelected = _selectedWeekdays.contains(day);
                      return FilterChip(
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
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
                ListTile(
                  title: const Text('Startdatum'),
                  subtitle: Text('${_startDate.day}.${_startDate.month}.${_startDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _startDate = DateTime(picked.year, picked.month, picked.day));
                    }
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedMedication == null ? null : () => _saveSchedule(db),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(widget.initialSchedule == null ? 'Plan speichern' : 'Änderungen speichern'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveSchedule(AppDatabase db) async {
    String finalFreq = _frequencyType;
    int? interval;
    if (_frequencyType == 'interval') {
      interval = int.tryParse(_intervalController.text) ?? 2;
    } else if (_frequencyType == 'biweekly') {
      finalFreq = 'weekly';
      interval = 2;
    } else if (_frequencyType == 'weekly') {
      interval = 1;
    }

    if (widget.initialSchedule != null) {
      // Update existing schedule
      await db.updateSchedule(widget.initialSchedule!.copyWith(
        medicationId: _selectedMedication!.id,
        dosage: double.tryParse(_dosageController.text) ?? 1.0,
        frequencyType: finalFreq,
        intervalValue: drift.Value(interval),
        selectedWeekdays: drift.Value(_frequencyType == 'weekdays' ? _selectedWeekdays.join(',') : null),
        startDate: _startDate,
      ));
      
      // Clear out future entries to force regeneration
      await db.deletePlannedInfusionsForSchedule(widget.initialSchedule!.id);
    } else {
      // Insert new schedule
      await db.insertSchedule(InfusionSchedulesCompanion.insert(
        medicationId: _selectedMedication!.id,
        dosage: double.tryParse(_dosageController.text) ?? 1.0,
        frequencyType: finalFreq,
        intervalValue: drift.Value(interval),
        selectedWeekdays: drift.Value(_frequencyType == 'weekdays' ? _selectedWeekdays.join(',') : null),
        startDate: _startDate,
      ));
    }

    // Force immediate sync
    final scheduler = SchedulerService(db);
    await scheduler.syncPlannedInfusions();

    if (mounted) Navigator.pop(context);
  }
}
