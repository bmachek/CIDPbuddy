import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import '../providers/diary_provider.dart';
import '../../inventory/providers/inventory_provider.dart';
import 'package:cidpbuddy/core/database/database.dart';
import '../widgets/premedication_timer_modal.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';
import 'package:cidpbuddy/core/theme/app_colors.dart';

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
  String? _capturedPhotoPath;
  bool _isProcessingOcr = false;
  bool _isSaving = false;

  /// Snapshot of the form as opened, so leaving warns only about real edits.
  late final String _initialState;

  /// The preselected medication is bound once the stream delivers (see
  /// build), so it is tracked separately from the text snapshot.
  int? _initialMedicationId;
  bool _medicationBound = false;

  List<TextEditingController> get _controllers => [
    _batchController,
    _dosageController,
    _notesController,
    _weightController,
  ];

  /// Text-field representation of a stored number: `4` rather than `4.0`.
  static String _numberText(num? value) {
    if (value == null) return '';
    if (value is int || value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  /// Accepts both decimal separators; the keyboard depends on the locale.
  static double? _parseNumber(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  String _snapshot() => [
    ..._controllers.map((c) => c.text),
    _selectedDate.toIso8601String(),
    _capturedPhotoPath ?? '',
  ].join('|');

  bool get _isDirty =>
      _snapshot() != _initialState || _selectedMed?.id != _initialMedicationId;

  @override
  void initState() {
    super.initState();
    _dosageController = TextEditingController(
      text: widget.initialDosage == null
          ? '1'
          : _numberText(widget.initialDosage),
    );
    _selectedDate = widget.initialDate ?? DateTime.now();
    _initialState = _snapshot();
    // PopScope.canPop is read in build, so typing must trigger a rebuild.
    for (final c in _controllers) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.discardChangesTitle),
        content: Text(context.l10n.discardChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.actionDiscard),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  InputDecoration _fieldDecoration({
    required String labelText,
    required IconData icon,
    String? hintText,
    String? suffixText,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixText: suffixText,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary.withValues(alpha: 0.1)),
      ),
      filled: true,
      fillColor: primary.withValues(alpha: 0.04),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invProvider = Provider.of<InventoryProvider>(context);
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await _confirmDiscard();
        if (discard && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.addInfusionTitle),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  context.l10n.addInfusionDetailsHeading,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppStatusColors.of(context).accentText,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Medication>>(
                  stream: invProvider.medicationsStream,
                  builder: (context, snapshot) {
                    final allMeds = snapshot.data ?? [];
                    // Filter to only show infusions
                    final meds = allMeds
                        .where((m) => m.type == MedicationType.infusion)
                        .toList();

                    // Bind the preselected medication once the list is in.
                    if (!_medicationBound &&
                        widget.initialMedicationId != null &&
                        allMeds.isNotEmpty) {
                      for (final m in allMeds) {
                        if (m.id == widget.initialMedicationId) {
                          _selectedMed = m;
                          break;
                        }
                      }
                      if (_selectedMed == null) {
                        debugPrint(
                          'AddInfusionPage: medication '
                          '${widget.initialMedicationId} not found',
                        );
                      }
                      // Whatever got bound is the pristine choice.
                      _initialMedicationId = _selectedMed?.id;
                      _medicationBound = true;
                    }

                    final items = meds
                        .map(
                          (m) => DropdownMenuItem<Medication>(
                            value: m,
                            child: Text(
                              m.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList();

                    // Safety check: Ensure current selection is in the items
                    // list to prevent Flutter's assertion error
                    if (_selectedMed != null &&
                        !meds.any((m) => m.id == _selectedMed!.id)) {
                      items.add(
                        DropdownMenuItem<Medication>(
                          value: _selectedMed!,
                          child: Text(
                            _selectedMed!.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildInlineMessage(
                        context,
                        context.l10n.errorLoadingData,
                        Icons.error_outline_rounded,
                      );
                    }
                    if (items.isEmpty && snapshot.hasData) {
                      // Nothing to pick: say so instead of showing an empty
                      // dropdown the patient cannot get past.
                      return _buildInlineMessage(
                        context,
                        context.l10n.inventoryNoMedications,
                        Icons.medication_outlined,
                      );
                    }

                    return DropdownButtonFormField<Medication>(
                      initialValue: _selectedMed,
                      isExpanded: true,
                      decoration: _fieldDecoration(
                        labelText: context.l10n.addInfusionPickMedication,
                        icon: Icons.medication_rounded,
                      ),
                      items: items,
                      onChanged: (val) => setState(() => _selectedMed = val),
                      validator: (val) =>
                          val == null ? context.l10n.validationPickOne : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.addInfusionWhen,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                AppDateFormat.dateTime(context, _selectedDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.edit_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
                if (_selectedMed?.trackBatchNumber ?? true) ...[
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _batchController,
                          decoration: _fieldDecoration(
                            labelText: context.l10n.fieldBatchNumber,
                            hintText: context.l10n.fieldBatchNumberHint,
                            icon: Icons.qr_code_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        onTap: _openScanner,
                        icon: Icons.qr_code_scanner_rounded,
                        tooltip: context.l10n.actionScanBarcode,
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        onTap: _takePhoto,
                        icon: Icons.camera_alt_rounded,
                        tooltip: context.l10n.actionPhotoOfLabel,
                        isLoading: _isProcessingOcr,
                      ),
                    ],
                  ),
                  if (_capturedPhotoPath != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Image.file(
                            File(_capturedPhotoPath!),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            semanticLabel: context.l10n.actionPhotoOfLabel,
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: IconButton.filled(
                              tooltip: context.l10n.tooltipRemovePhoto,
                              onPressed: () =>
                                  setState(() => _capturedPhotoPath = null),
                              icon: const Icon(Icons.close_rounded, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withValues(
                                  alpha: 0.5,
                                ),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildBatchDocumentationHint(context),
                ],
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dosageController,
                  decoration: _fieldDecoration(
                    labelText: context.l10n.fieldDosageUnits,
                    icon: Icons.scale_rounded,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: (text) {
                    if (text == null || text.trim().isEmpty) {
                      return context.l10n.validationRequired;
                    }
                    final value = _parseNumber(text);
                    if (value == null) {
                      return context.l10n.validationEnterNumber;
                    }
                    if (value <= 0) {
                      return context.l10n.validationPositiveNumber;
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                if (_selectedMed?.trackWeight ?? true) ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _weightController,
                    decoration: _fieldDecoration(
                      labelText: context.l10n.fieldBodyWeight,
                      icon: Icons.monitor_weight_rounded,
                      suffixText: context.l10n.kilogramsShort,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) return null;
                      final value = _parseNumber(text);
                      if (value == null) {
                        return context.l10n.validationEnterNumber;
                      }
                      if (value <= 0) {
                        return context.l10n.validationPositiveNumber;
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ],
                const SizedBox(height: 20),
                TextFormField(
                  controller: _notesController,
                  decoration: _fieldDecoration(
                    labelText: context.l10n.fieldInfusionNotes,
                    icon: Icons.note_alt_rounded,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                // The timer is started from the save button for medications
                // that use one (e.g. Hyqvia); there is no separate control.
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : () => _save(diaryProvider),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _shouldShowTimer
                              ? context.l10n.addInfusionSaveAndStartTimer
                              : context.l10n.addInfusionSaveAndDeductStock,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineMessage(BuildContext context, String text, IconData icon) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  /// Legal note: recording a batch here does not replace the legally required
  /// batch documentation.
  Widget _buildBatchDocumentationHint(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.legalBatchDocumentationShort,
              style: TextStyle(fontSize: 12, height: 1.35, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String tooltip,
    bool isLoading = false,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    // The tooltip is what a screen reader announces (like IconButton does
    // it); the Semantics wrapper marks the node as a button.
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: !isLoading,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withValues(alpha: 0.2)),
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon, color: primary),
          ),
        ),
      ),
    );
  }

  void _openScanner() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.actionScanBarcode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.actionClose,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
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
      ),
    );

    if (result != null && mounted) {
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
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null || !mounted) return;
    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _save(DiaryProvider provider) async {
    // Guard against double-taps: the log is written asynchronously before the
    // page closes, so a second tap would log the infusion and deduct the
    // stock twice.
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final medication = _selectedMed;
    final dosage = _parseNumber(_dosageController.text);
    // The validators refuse anything unparseable, so a wrong dose is never
    // guessed and written into the treatment record.
    if (medication == null || dosage == null || dosage <= 0) return;
    setState(() => _isSaving = true);

    // Captured before the page closes: the confirmation must land on the
    // screen the patient returns to.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await provider.logInfusion(
        medicationId: medication.id,
        dosage: dosage,
        batchNumber: _batchController.text,
        notes: _notesController.text,
        bodyWeight: _parseNumber(_weightController.text),
        date: _selectedDate,
        photoPath: _capturedPhotoPath,
      );
    } catch (e) {
      // Re-enable the button so the user can retry instead of being stuck —
      // and say what went wrong, this is a treatment record.
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed('$e'))));
      return;
    }

    if (!mounted) return;
    final showTimer = _shouldShowTimer;
    // Pop first so the patient is back on the list; the timer sheet then
    // opens on top of it.
    Navigator.pop(context, true);
    messenger.showSnackBar(SnackBar(content: Text(l10n.savedInfusion)));
    if (showTimer) _showTimer(context);
  }

  void _showTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremedicationTimerModal(),
    );
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (!mounted || image == null) return;

    // Save permanently to app directory
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(
      directory.path,
      'charge_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await File(image.path).copy(path);
    if (!mounted) return;

    setState(() {
      _capturedPhotoPath = path;
      _isProcessingOcr = true;
    });

    // Perform OCR
    try {
      final inputImage = InputImage.fromFilePath(path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      // Simple logic for batch number: first sequence of uppercase letters/numbers
      String? foundBatch;
      final patterns = [
        RegExp(r'LOT\s*[:\-\s]\s*([A-Z0-9]+)', caseSensitive: false),
        RegExp(r'CH.-B\s*[:\-\s]\s*([A-Z0-9]+)', caseSensitive: false),
        RegExp(r'Batch\s*[:\-\s]\s*([A-Z0-9]+)', caseSensitive: false),
        RegExp(
          r'([A-Z0-9]{6,12})',
        ), // Alphanumeric candidates (common for Takeda/CSL)
      ];

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          for (final pattern in patterns) {
            final match = pattern.firstMatch(line.text);
            if (match != null) {
              foundBatch = match.groupCount >= 1
                  ? match.group(1)
                  : match.group(0);
              break;
            }
          }
          if (foundBatch != null) break;
        }
        if (foundBatch != null) break;
      }

      if (foundBatch != null && mounted) {
        setState(() => _batchController.text = foundBatch!);
      }
      textRecognizer.close();
    } catch (e) {
      debugPrint('OCR Error: $e');
      // The photo is kept; only the automatic batch read-out failed, so the
      // patient knows to type the batch number by hand.
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saveFailed('$e'))));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingOcr = false);
      }
    }
  }
}
