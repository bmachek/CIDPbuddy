import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/diary_provider.dart';
import '../../inventory/providers/inventory_provider.dart';
import 'package:igkeeper/core/database/database.dart';
import '../widgets/premedication_timer_modal.dart';

class AddInfusionPage extends StatefulWidget {
  final int? initialMedicationId;
  final double? initialDosage;
  final DateTime? initialDate;

  const AddInfusionPage({
    super.key,
    this.initialMedicationId,
    this.initialDosage,
    this.initialDate,
  });

  @override
  State<AddInfusionPage> createState() => _AddInfusionPageState();
}

class _AddInfusionPageState extends State<AddInfusionPage> {
  final _formKey = GlobalKey<FormState>();
  Medication? _selectedMed;
  final _batchController = TextEditingController();
  late final TextEditingController _dosageController;
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  late DateTime _selectedDate;
  bool _timerEnabled = true;

  @override
  void initState() {
    super.initState();
    _dosageController = TextEditingController(
      text: widget.initialDosage?.toString() ?? '1.0',
    );
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadTimerSetting();
  }

  Future<void> _loadTimerSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _timerEnabled = prefs.getBool('hyqvia_timer_enabled') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final invProvider = Provider.of<InventoryProvider>(context);
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Infusion erfassen'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Details der Infusion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Medication>>(
              stream: invProvider.medicationsStream,
              builder: (context, snapshot) {
                final meds = snapshot.data ?? [];
                
                // Set initial medication if provided and not yet set
                if (_selectedMed == null && widget.initialMedicationId != null && meds.isNotEmpty) {
                  try {
                    _selectedMed = meds.firstWhere((m) => m.id == widget.initialMedicationId);
                  } catch (_) {
                    // Not found, ignore
                  }
                }

                return DropdownButtonFormField<Medication>(
                  value: _selectedMed,
                  decoration: InputDecoration(
                    labelText: 'Medikament wählen',
                    prefixIcon: const Icon(Icons.medication_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  items: meds.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                  onChanged: (val) => setState(() => _selectedMed = val),
                  validator: (val) => val == null ? 'Bitte wählen' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 20, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Zeitpunkt der Infusion', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            DateFormat('dd.MM.yyyy, HH:mm').format(_selectedDate),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_rounded, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
            if (_selectedMed?.trackBatchNumber ?? true) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _batchController,
                      decoration: InputDecoration(
                        labelText: 'Chargennummer / Barcode',
                        hintText: 'Scannen oder tippen',
                        prefixIcon: const Icon(Icons.qr_code_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _openScanner,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                      ),
                      child: Icon(Icons.qr_code_scanner_rounded, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _dosageController,
              decoration: InputDecoration(
                labelText: 'Dosierung / Einheiten',
                prefixIcon: const Icon(Icons.scale_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            if (_selectedMed?.trackWeight ?? true) ...[
              const SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Körpergewicht (kg)',
                  prefixIcon: const Icon(Icons.monitor_weight_rounded),
                  suffixText: 'kg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notizen (Befinden, Verlauf)',
                prefixIcon: const Icon(Icons.note_alt_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            // We'll remove the manual timer button and integrate it into the Save button for Hyqvia
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              onPressed: () => _save(diaryProvider),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded),
                  const SizedBox(width: 12),
                  Text(
                    _shouldShowTimer ? 'Speichern & Timer starten' : 'Infusion speichern & Bestand abbuchen',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openScanner() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Barcode scannen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      Navigator.pop(context, barcodes.first.rawValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _batchController.text = result;
      });
    }
  }

  bool get _shouldShowTimer => _selectedMed?.useTimer == true;

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  void _save(DiaryProvider provider) async {
    if (_formKey.currentState!.validate() && _selectedMed != null) {
      await provider.logInfusion(
        medicationId: _selectedMed!.id,
        dosage: double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 1.0,
        batchNumber: _batchController.text,
        notes: _notesController.text,
        bodyWeight: double.tryParse(_weightController.text.replaceAll(',', '.')),
        date: _selectedDate,
      );
      
      if (mounted) {
        if (_shouldShowTimer) {
          // Show the timer modal if enabled for this medication
          // but we actually want to pop the add page first so they are back on the list
          Navigator.pop(context, true);
          _showTimer(context);
        } else {
          Navigator.pop(context, true);
        }
      }
    }
  }

  void _showTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremedicationTimerModal(),
    );
  }
}
