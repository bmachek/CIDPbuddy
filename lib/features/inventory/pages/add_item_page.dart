import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../../../core/database/database.dart';
import '../../diary/pages/add_schedule_page.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';
import 'package:cidpbuddy/core/theme/app_colors.dart';

/// What the user is creating. Previously a German string literal that was both
/// the dropdown label and the branch key — splitting the two lets the label be
/// translated without the `if` conditions changing meaning.
enum _ItemKind { medication, supply }

/// Digits and one decimal separator; the German keyboard produces a comma, so
/// both `.` and `,` are accepted and everything else is dropped as typed.
final _numberInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

/// Parses a number the way a patient types it: `1,5` and `1.5` are the same.
double? _parseNumber(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));

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

  /// The unit text the page filled in for the current category, so only a
  /// manual edit of the unit counts as an unsaved change.
  String _seededUnit = '';
  bool _isSaving = false;

  late final List<TextEditingController> _controllers = [
    _nameController,
    _dosageController,
    _pznController,
    _stockController,
    _unitController,
    _packageSizeController,
    _minStockController,
  ];

  @override
  void initState() {
    super.initState();
    // `canPop` is read at build time, so a keystroke that makes the form dirty
    // (or clean again) has to trigger a rebuild.
    for (final controller in _controllers) {
      controller.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_onFieldChanged);
      controller.dispose();
    }
    super.dispose();
  }

  bool _wasDirty = false;

  void _onFieldChanged() {
    final dirty = _hasUnsavedChanges;
    if (dirty != _wasDirty) {
      setState(() => _wasDirty = dirty);
    }
  }

  bool get _hasUnsavedChanges =>
      _nameController.text.isNotEmpty ||
      _dosageController.text.isNotEmpty ||
      _pznController.text.isNotEmpty ||
      _stockController.text != '0' ||
      _packageSizeController.text != '1' ||
      _minStockController.text != '5' ||
      _unitController.text != _seededUnit ||
      _type != _ItemKind.medication ||
      _medType != MedicationType.infusion;

  void _seedUnit(String unit) {
    _seededUnit = unit;
    _unitController.text = unit;
  }

  String? _validateNumber(String? value, {bool positive = false}) {
    final number = _parseNumber(value ?? '');
    if (number == null) return context.l10n.validationEnterNumber;
    if (positive && number <= 0) return context.l10n.validationPositiveNumber;
    return null;
  }

  InputDecoration _decoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    bool tinted = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: tinted
          ? colorScheme.primary.withValues(alpha: 0.04)
          : colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: tinted ? 0.1 : 0.2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The default unit is a translated word, so it cannot be seeded in the
    // field initializer above — no localizations exist before the first build.
    if (!_didSeedUnit) {
      _didSeedUnit = true;
      _seedUnit(context.l10n.unitBottle);
    }
    _wasDirty = _hasUnsavedChanges;

    return PopScope(
      canPop: !_wasDirty || _isSaving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await _confirmDiscard();
        if (!discard || !context.mounted) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.addItemTitle)),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<_ItemKind>(
                initialValue: _type,
                isExpanded: true,
                decoration: _decoration(labelText: context.l10n.fieldCategory),
                items: [
                  DropdownMenuItem(
                    value: _ItemKind.medication,
                    child: Text(
                      context.l10n.categoryMedication,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: _ItemKind.supply,
                    child: Text(
                      context.l10n.categorySupply,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _type = val;
                    _seedUnit(
                      _type == _ItemKind.medication
                          ? context.l10n.unitBottle
                          : context.l10n.unitPieces,
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_type == _ItemKind.medication) ...[
                DropdownButtonFormField<MedicationType>(
                  initialValue: _medType,
                  isExpanded: true,
                  decoration: _decoration(
                    labelText: context.l10n.fieldDosageForm,
                    tinted: true,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: MedicationType.infusion,
                      child: Text(
                        context.l10n.dosageFormInfusion,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: MedicationType.pill,
                      child: Text(
                        context.l10n.dosageFormPill,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      _medType = val;
                      _seedUnit(
                        _medType == MedicationType.pill
                            ? context.l10n.unitPieces
                            : context.l10n.unitBottle,
                      );
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: _decoration(
                  labelText: context.l10n.fieldMedicationName,
                  hintText: context.l10n.fieldMedicationNameHint,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? context.l10n.validationRequired
                    : null,
              ),
              if (_type == _ItemKind.medication) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dosageController,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    labelText: context.l10n.fieldStrength,
                    hintText: context.l10n.fieldStrengthHint,
                    tinted: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pznController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: _decoration(
                    labelText: context.l10n.fieldPznOptional,
                    hintText: context.l10n.fieldPznHint,
                    tinted: true,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                textInputAction: TextInputAction.next,
                decoration: _decoration(
                  labelText: context.l10n.fieldInitialStock,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _numberInputFormatters,
                validator: _validateNumber,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _packageSizeController,
                textInputAction: TextInputAction.next,
                decoration: _decoration(
                  labelText: context.l10n.fieldDefaultReorderAmount,
                  hintText: context.l10n.fieldDefaultReorderAmountHint,
                  prefixIcon: const Icon(Icons.inventory_2_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _numberInputFormatters,
                validator: (val) => _validateNumber(val, positive: true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minStockController,
                textInputAction: TextInputAction.done,
                decoration: _decoration(
                  labelText: _type == _ItemKind.medication
                      ? context.l10n.fieldMinStockDays
                      : context.l10n.fieldMinStock,
                  hintText: _type == _ItemKind.medication
                      ? context.l10n.fieldMinStockDaysHint
                      : context.l10n.fieldMinStockHint,
                  prefixIcon: const Icon(Icons.notification_important_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _numberInputFormatters,
                validator: _validateNumber,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSaving ? null : _save,
                child: Text(context.l10n.actionSave),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.discardChangesTitle),
        content: Text(dialogContext.l10n.discardChangesBody),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              foregroundColor: AppStatusColors.of(dialogContext).accentText,
            ),
            child: Text(dialogContext.l10n.actionKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(dialogContext.l10n.actionDiscard),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    // The validators above guarantee these parse.
    final stock = _parseNumber(_stockController.text)!;
    final packageSize = _parseNumber(_packageSizeController.text)!;
    final minStock = _parseNumber(_minStockController.text)!;

    setState(() => _isSaving = true);
    try {
      if (_type == _ItemKind.medication) {
        final id = await provider.addMedication(
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          pzn: _pznController.text.trim(),
          stock: stock,
          unit: _unitController.text.trim(),
          type: _medType,
          packageSize: packageSize,
          minStock: minStock,
        );
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.savedMedication),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Instead of just closing, immediately ask for the schedule.
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => AddSchedulePage(preselectedMedicationId: id),
          ),
        );
      } else {
        await provider.addAccessory(
          name: _nameController.text.trim(),
          stock: stock,
          unit: _unitController.text.trim(),
          packageSize: packageSize,
          minStock: minStock,
        );
        if (!mounted) return;
        navigator.pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.saveFailed('$e')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
