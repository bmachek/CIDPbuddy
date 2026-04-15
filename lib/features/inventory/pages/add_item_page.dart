import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../../../core/database/database.dart';
import '../../diary/pages/add_schedule_page.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Medikament';
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _pznController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _unitController = TextEditingController(text: 'Flasche');
  final _packageSizeController = TextEditingController(text: '1');
  final _minStockController = TextEditingController(text: '5');
  MedicationType _medType = MedicationType.infusion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neues Element hinzufügen')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: 'Kategorie',
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2))),
              ),
              items: ['Medikament', 'Verbrauchsmaterial']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _type = val!;
                  _unitController.text = _type == 'Medikament' ? 'Flasche' : 'Stk';
                });
              },
            ),
            const SizedBox(height: 16),
            if (_type == 'Medikament') ...[
              DropdownButtonFormField<MedicationType>(
                initialValue: _medType,
                decoration: InputDecoration(
                  labelText: 'Darreichungsform',
                  filled: true,
                  fillColor: Theme.of(context).primaryColor.withValues(alpha: 0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.1))),
                ),
                items: [
                  const DropdownMenuItem(value: MedicationType.infusion, child: Text('Infusion')),
                  const DropdownMenuItem(value: MedicationType.pill, child: Text('Tablette / Pille')),
                ],
                onChanged: (val) {
                  setState(() {
                    _medType = val!;
                    if (_medType == MedicationType.pill) {
                      _unitController.text = 'Stk';
                    } else {
                      _unitController.text = 'Flasche';
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Medikamentenname', 
                hintText: 'z.B. Hizentra',
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2))),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Pflichtfeld' : null,
            ),
            if (_type == 'Medikament') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: 'Dosis / Stärke', 
                  hintText: 'z.B. 20% oder 10ml',
                  filled: true,
                  fillColor: Theme.of(context).primaryColor.withValues(alpha: 0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.1))),
                ),
              ),
            ],
            if (_type == 'Medikament') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _pznController,
                decoration: InputDecoration(
                  labelText: 'PZN (Optional)', 
                  hintText: 'Pharmazentralnummer',
                  filled: true,
                  fillColor: Theme.of(context).primaryColor.withValues(alpha: 0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.1))),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      labelText: 'Anfangsbestand',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _packageSizeController,
              decoration: InputDecoration(
                labelText: 'Standard-Nachbestellmenge',
                hintText: 'z.B. 10 Flaschen',
                prefixIcon: const Icon(Icons.inventory_2_rounded),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2))),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minStockController,
              decoration: InputDecoration(
                labelText: 'Warnschwelle (Mindestbestand)',
                hintText: 'Warnung wenn Bestand unter diese Menge fällt',
                prefixIcon: const Icon(Icons.notification_important_rounded),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2))),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _save,
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      final stock = double.tryParse(_stockController.text) ?? 0;
      final packageSize = double.tryParse(_packageSizeController.text) ?? 1.0;
      
      if (_type == 'Medikament') {
        final id = await provider.addMedication(
          name: _nameController.text,
          dosage: _dosageController.text,
          pzn: _pznController.text,
          stock: stock,
          unit: _unitController.text,
          type: _medType,
          packageSize: packageSize,
          minStock: double.tryParse(_minStockController.text) ?? 5.0,
        );
        
        if (mounted) {
          // Instead of just closing, we now immediately ask for the schedule
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AddSchedulePage(preselectedMedicationId: id),
            ),
          );
        }
      } else {
        await provider.addAccessory(
          name: _nameController.text,
          stock: stock,
          unit: _unitController.text,
          packageSize: packageSize,
        );
        if (mounted) Navigator.pop(context);
      }
    }
  }
}
