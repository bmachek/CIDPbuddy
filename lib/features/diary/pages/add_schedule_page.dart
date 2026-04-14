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
      appBar: AppBar(
        title: Text(widget.initialSchedule == null ? 'Infusionsplan erstellen' : 'Infusionsplan bearbeiten'),
        centerTitle: true,
      ),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Medikation & Dosis'),
                const SizedBox(height: 16),
                DropdownButtonFormField<Medication>(
                  value: _selectedMedication,
                  items: medications.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                  onChanged: (val) => setState(() => _selectedMedication = val),
                  decoration: InputDecoration(
                    labelText: 'Medikament wählen',
                    prefixIcon: const Icon(Icons.medication_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dosageController,
                  decoration: InputDecoration(
                    labelText: 'Einheiten pro Infusion',
                    prefixIcon: const Icon(Icons.scale_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('Häufigkeit'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _frequencyType,
                  items: _frequencies.map((f) => DropdownMenuItem(value: f['value'], child: Text(f['label']!))).toList(),
                  onChanged: (val) => setState(() => _frequencyType = val!),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.repeat_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                if (_frequencyType == 'interval') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _intervalController,
                    decoration: InputDecoration(
                      labelText: 'Anzahl der Tage',
                      hintText: 'Z.B. alle 5 Tage',
                      prefixIcon: const Icon(Icons.today_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                if (_frequencyType == 'weekdays') ...[
                  const SizedBox(height: 16),
                  const Text('Tage auswählen:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final label = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][index];
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
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Theme.of(context).primaryColor : null,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 32),
                _buildSectionHeader('Zeitraum'),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: Theme.of(context).primaryColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() => _startDate = DateTime(picked.year, picked.month, picked.day));
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 20, color: Colors.grey),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Startdatum', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  DateFormat('dd. MMMM yyyy').format(_startDate),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.edit_rounded, size: 18, color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _selectedMedication == null ? null : () => _saveSchedule(db),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded),
                      const SizedBox(width: 12),
                      Text(
                        widget.initialSchedule == null ? 'Zeitplan aktivieren' : 'Änderungen speichern',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.grey),
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
        dosage: double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 1.0,
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
        dosage: double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 1.0,
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
