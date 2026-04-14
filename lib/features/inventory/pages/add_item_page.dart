import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Medikament';
  final _nameController = TextEditingController();
  final _pznController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _unitController = TextEditingController(text: 'Flasche');

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
              value: _type,
              decoration: const InputDecoration(labelText: 'Typ'),
              items: ['Medikament', 'Zubehör']
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Bezeichnung', hintText: 'z.B. Hizentra 20%'),
              validator: (val) => val == null || val.isEmpty ? 'Pflichtfeld' : null,
            ),
            if (_type == 'Medikament') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _pznController,
                decoration: const InputDecoration(labelText: 'PZN (Optional)', hintText: 'Scan folgt später'),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(labelText: 'Anfangsbestand'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Einheit'),
                  ),
                ),
              ],
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
      
      if (_type == 'Medikament') {
        await provider.addMedication(
          name: _nameController.text,
          pzn: _pznController.text,
          stock: stock,
          unit: _unitController.text,
        );
      } else {
        await provider.addAccessory(
          name: _nameController.text,
          stock: stock,
          unit: _unitController.text,
        );
      }
      
      if (mounted) Navigator.pop(context);
    }
  }
}
