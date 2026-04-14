import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/diary_provider.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../../../core/database/database.dart';

class AddInfusionPage extends StatefulWidget {
  const AddInfusionPage({super.key});

  @override
  State<AddInfusionPage> createState() => _AddInfusionPageState();
}

class _AddInfusionPageState extends State<AddInfusionPage> {
  final _formKey = GlobalKey<FormState>();
  Medication? _selectedMed;
  final _batchController = TextEditingController();
  final _dosageController = TextEditingController(text: '1.0');
  final _notesController = TextEditingController();

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
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              onPressed: () => _save(diaryProvider),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded),
                  SizedBox(width: 12),
                  Text(
                    'Infusion speichern & Bestand abbuchen',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  void _save(DiaryProvider provider) async {
    if (_formKey.currentState!.validate() && _selectedMed != null) {
      await provider.logInfusion(
        medicationId: _selectedMed!.id,
        dosage: double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 1.0,
        batchNumber: _batchController.text,
        notes: _notesController.text,
      );
      if (mounted) Navigator.pop(context);
    }
  }
}
