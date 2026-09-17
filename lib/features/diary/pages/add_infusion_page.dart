import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _dosageController = TextEditingController(
      text: widget.initialDosage?.toString() ?? '1.0',
    );
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final invProvider = Provider.of<InventoryProvider>(context);
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.addInfusionTitle),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              context.l10n.addInfusionDetailsHeading,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
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

                // Set initial medication if provided and not yet set
                if (_selectedMed == null &&
                    widget.initialMedicationId != null &&
                    allMeds.isNotEmpty) {
                  try {
                    _selectedMed = allMeds.firstWhere(
                      (m) => m.id == widget.initialMedicationId,
                    );
                  } catch (_) {}
                }

                final items = meds
                    .map(
                      (m) => DropdownMenuItem<Medication>(
                        value: m,
                        child: Text(m.name),
                      ),
                    )
                    .toList();

                // Safety check: Ensure current selection is in the items list to prevent Flutter's assertion error
                if (_selectedMed != null &&
                    !meds.any((m) => m.id == _selectedMed!.id)) {
                  items.add(
                    DropdownMenuItem<Medication>(
                      value: _selectedMed!,
                      child: Text(_selectedMed!.name),
                    ),
                  );
                }

                return DropdownButtonFormField<Medication>(
                  initialValue: _selectedMed,
                  decoration: InputDecoration(
                    labelText: context.l10n.addInfusionPickMedication,
                    prefixIcon: const Icon(Icons.medication_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.04),
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
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            AppDateFormat.dateTime(context, _selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_rounded, size: 18),
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
                        labelText: context.l10n.fieldBatchNumber,
                        hintText: context.l10n.fieldBatchNumberHint,
                        prefixIcon: const Icon(Icons.qr_code_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.04),
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
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton.filled(
                          onPressed: () =>
                              setState(() => _capturedPhotoPath = null),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.5,
                            ),
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
              decoration: InputDecoration(
                labelText: context.l10n.fieldDosageUnits,
                prefixIcon: const Icon(Icons.scale_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.04),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            if (_selectedMed?.trackWeight ?? true) ...[
              const SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: context.l10n.fieldBodyWeight,
                  prefixIcon: const Icon(Icons.monitor_weight_rounded),
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.04),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: context.l10n.fieldInfusionNotes,
                prefixIcon: const Icon(Icons.note_alt_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.04),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            // We'll remove the manual timer button and integrate it into the Save button for Hyqvia
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: Theme.of(context).colorScheme.primary),
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
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                context.l10n.actionScanBarcode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
    if (_formKey.currentState!.validate() && _selectedMed != null) {
      setState(() => _isSaving = true);
      try {
        await provider.logInfusion(
          medicationId: _selectedMed!.id,
          dosage:
              double.tryParse(_dosageController.text.replaceAll(',', '.')) ??
              1.0,
          batchNumber: _batchController.text,
          notes: _notesController.text,
          bodyWeight: double.tryParse(
            _weightController.text.replaceAll(',', '.'),
          ),
          date: _selectedDate,
          photoPath: _capturedPhotoPath,
        );
      } catch (e) {
        // Re-enable the button so the user can retry instead of being stuck.
        if (mounted) setState(() => _isSaving = false);
        return;
      }

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
    } finally {
      if (mounted) {
        setState(() => _isProcessingOcr = false);
      }
    }
  }
}
