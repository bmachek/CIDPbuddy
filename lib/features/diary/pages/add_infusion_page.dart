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
      appBar: AppBar(title: const Text('Infusion erfassen')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            StreamBuilder<List<Medication>>(
              stream: invProvider.medicationsStream,
              builder: (context, snapshot) {
                final meds = snapshot.data ?? [];
                return DropdownButtonFormField<Medication>(
                  value: _selectedMed,
                  decoration: const InputDecoration(labelText: 'Medikament'),
                  items: meds.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                  onChanged: (val) => setState(() => _selectedMed = val),
                  validator: (val) => val == null ? 'Bitte wählen' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _batchController,
                    decoration: const InputDecoration(
                      labelText: 'Chargennummer / Barcode',
                      hintText: 'Scannen oder tippen',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.teal),
                  onPressed: _openScanner,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'Dosis / Einheiten'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notizen (Befinden, etc.)'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _save(diaryProvider),
              child: const Text('Infusion bestätigen & Bestand abbuchen'),
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
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              Navigator.pop(context, barcodes.first.rawValue);
            }
          },
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
        dosage: double.tryParse(_dosageController.text) ?? 1.0,
        batchNumber: _batchController.text,
        notes: _notesController.text,
      );
      if (mounted) Navigator.pop(context);
    }
  }
}
