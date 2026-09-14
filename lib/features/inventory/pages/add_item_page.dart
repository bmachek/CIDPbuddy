import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../../../core/database/database.dart';
import '../../diary/pages/add_schedule_page.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';

/// What the user is creating. Previously a German string literal that was both
/// the dropdown label and the branch key — splitting the two lets the label be
/// translated without the `if` conditions changing meaning.
enum _ItemKind { medication, supply }

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  _ItemKind _type = _ItemKind.medication;
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _pznController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _unitController = TextEditingController();
  final _packageSizeController = TextEditingController(text: '1');
  final _minStockController = TextEditingController(text: '5');
  MedicationType _medType = MedicationType.infusion;
  bool _didSeedUnit = false;

  @override
  Widget build(BuildContext context) {
    // The default unit is a translated word, so it cannot be seeded in the
    // field initializer above — no localizations exist before the first build.
    if (!_didSeedUnit) {
      _didSeedUnit = true;
      _unitController.text = context.l10n.unitBottle;
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addItemTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<_ItemKind>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: context.l10n.fieldCategory,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))),
              ),
              items: [
                DropdownMenuItem(
                    value: _ItemKind.medication, child: Text(context.l10n.categoryMedication)),
                DropdownMenuItem(
                    value: _ItemKind.supply, child: Text(context.l10n.categorySupply)),
              ],
              onChanged: (val) {
                setState(() {
                  _type = val!;
                  _unitController.text = _type == _ItemKind.medication
                      ? context.l10n.unitBottle
                      : context.l10n.unitPieces;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_type == _ItemKind.medication) ...[
              DropdownButtonFormField<MedicationType>(
                initialValue: _medType,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldDosageForm,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))),
                ),
                items: [
                  DropdownMenuItem(
                      value: MedicationType.infusion, child: Text(context.l10n.dosageFormInfusion)),
                  DropdownMenuItem(
                      value: MedicationType.pill, child: Text(context.l10n.dosageFormPill)),
                ],
                onChanged: (val) {
                  setState(() {
                    _medType = val!;
                    _unitController.text = _medType == MedicationType.pill
                        ? context.l10n.unitPieces
                        : context.l10n.unitBottle;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.fieldMedicationName,
                hintText: context.l10n.fieldMedicationNameHint,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))),
              ),
              validator: (val) => val == null || val.isEmpty ? context.l10n.validationRequired : null,
            ),
            if (_type == _ItemKind.medication) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldStrength,
                  hintText: context.l10n.fieldStrengthHint,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))),
                ),
              ),
            ],
            if (_type == _ItemKind.medication) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _pznController,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldPznOptional,
                  hintText: context.l10n.fieldPznHint,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))),
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
                      labelText: context.l10n.fieldInitialStock,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _packageSizeController,
              decoration: InputDecoration(
                labelText: context.l10n.fieldDefaultReorderAmount,
                hintText: context.l10n.fieldDefaultReorderAmountHint,
                prefixIcon: const Icon(Icons.inventory_2_rounded),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minStockController,
              decoration: InputDecoration(
                labelText: _type == _ItemKind.medication
                    ? context.l10n.fieldMinStockDays
                    : context.l10n.fieldMinStock,
                hintText: _type == _ItemKind.medication
                    ? context.l10n.fieldMinStockDaysHint
                    : context.l10n.fieldMinStockHint,
                prefixIcon: const Icon(Icons.notification_important_rounded),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _save,
              child: Text(context.l10n.actionSave),
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
      
      if (_type == _ItemKind.medication) {
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
          minStock: double.tryParse(_minStockController.text) ?? 5.0,
        );
        if (mounted) Navigator.pop(context);
      }
    }
  }
}
