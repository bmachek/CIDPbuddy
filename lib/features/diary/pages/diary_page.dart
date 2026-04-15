import 'dart:io';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../../../core/database/database.dart';
import 'add_infusion_page.dart';
import 'add_diary_entry_page.dart';
import 'statistics_page.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryProvider = Provider.of<DiaryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<dynamic>>(
        stream: diaryProvider.combinedEntriesStream,
        builder: (context, snapshot) {
          final entries = snapshot.data ?? [];
          
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('Mein Tagebuch'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bar_chart_rounded),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatisticsPage()),
                    ),
                  ),
                ],
              ),
              if (entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = entries[index];
                        if (entry is InfusionLogData) {
                          return _buildLogCard(context, entry);
                        } else if (entry is DiaryEntry) {
                          return _buildDiaryEntryCard(context, entry);
                        } else if (entry is PendingOrder) {
                          return _buildOrderHistoryCard(context, entry);
                        } else if (entry is MedicationEvent) {
                          return _buildMedicationEventCard(context, entry);
                        }
                        return const SizedBox();
                      },
                      childCount: entries.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120), // Moved higher for better accessibility
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'diary_fab_entry',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDiaryEntryPage()),
              ),
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Vitalwerte & Symptome'),
              backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.9),
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: 'diary_fab_infusion',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddInfusionPage()),
              ),
              icon: const Icon(Icons.medication_rounded),
              label: const Text('Infusion erfassen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryEntryCard(BuildContext context, DiaryEntry entry) {
    final dateStr = DateFormat('dd. MMMM yyyy').format(entry.date);
    final timeStr = DateFormat('HH:mm').format(entry.date);

    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddDiaryEntryPage(initialEntry: entry))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.analytics_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 2),
                      Text(timeStr, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (entry.systolicBP != null) _buildSmallChip(context, '${entry.systolicBP?.toInt()}/${entry.diastolicBP?.toInt()}', Icons.favorite),
                          if (entry.heartRate != null) _buildSmallChip(context, '${entry.heartRate} bpm', Icons.monitor_heart),
                          if (entry.weight != null) _buildSmallChip(context, '${entry.weight} kg', Icons.monitor_weight),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSymptomMiniBar(context, entry),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildSmallChip(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildSymptomMiniBar(BuildContext context, DiaryEntry entry) {
    final Map<IconData, int?> symptomScores = {
      Icons.fitness_center_rounded: entry.strengthScore,
      Icons.touch_app_rounded: entry.sensoryScore,
      Icons.battery_alert_rounded: entry.fatigueScore,
      Icons.bolt_rounded: entry.painScore,
      Icons.balance_rounded: entry.balanceScore,
    };

    final activeSymptoms = symptomScores.entries.where((e) => e.value != null).toList();
    if (activeSymptoms.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('VITALWERTE & SYMPTOME:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: activeSymptoms.map((e) {
            final score = e.value ?? 0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Column(
                  children: [
                    Icon(e.key, size: 14, color: _getColorForScore(context, score)),
                    const SizedBox(height: 4),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getColorForScore(context, score),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(color: _getColorForScore(context, score).withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getColorForScore(BuildContext context, int score) {
    if (score >= 8) return Theme.of(context).colorScheme.error;
    if (score >= 5) return const Color(0xFFFFB300); // Warning Gold
    return Theme.of(context).colorScheme.tertiary; // Emerald
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_diary.png',
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              'Dein Tagebuch ist noch leer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Erfasse deine erste Infusion, um den Überblick über deine Behandlung zu behalten.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, InfusionLogData log) {
    final dateStr = DateFormat('dd. MMMM yyyy').format(log.date);
    final timeStr = DateFormat('HH:mm').format(log.date);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.vaccines_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(timeStr, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                    if (log.batchNumber != null && log.batchNumber!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Charge: ${log.batchNumber}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                    if (log.notes != null && log.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(log.notes!, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ),
                    if (log.bodyWeight != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            Icon(Icons.monitor_weight_rounded, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                            const SizedBox(width: 4),
                            Text('${log.bodyWeight} kg', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    if (log.photoPath != null && log.photoPath!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(log.photoPath!),
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showEditLogDialog(context, Provider.of<AppDatabase>(context, listen: false), log),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error, size: 18),
                        onPressed: () => _confirmDeleteLog(context, Provider.of<AppDatabase>(context, listen: false), log),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      log.dosage.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  void _showEditLogDialog(BuildContext context, AppDatabase db, InfusionLogData log) {
    final batchController = TextEditingController(text: log.batchNumber ?? '');
    final weightController = TextEditingController(text: log.bodyWeight?.toString() ?? '');
    final notesController = TextEditingController(text: log.notes ?? '');
    DateTime selectedDate = log.date;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Eintrag bearbeiten'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Datum & Uhrzeit'),
                subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(selectedDate)),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (time != null && context.mounted) {
                      setState(() {
                        selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: batchController,
                decoration: const InputDecoration(labelText: 'Chargennummer', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Körpergewicht (kg)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notizen', border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () async {
                await db.updateInfusionLog(log.copyWith(
                  date: selectedDate,
                  batchNumber: drift.Value(batchController.text),
                  bodyWeight: drift.Value(double.tryParse(weightController.text.replaceAll(',', '.'))),
                  notes: drift.Value(notesController.text),
                ));
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteLog(BuildContext context, AppDatabase db, InfusionLogData log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content: const Text('Möchtest du diesen Eintrag wirklich löschen? Der Bestand wird automatisch zurückgebucht.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () async {
              await db.transaction(() async {
                // 1. Revert medication stock
                final med = await (db.select(db.medications)..where((t) => t.id.equals(log.medicationId))).getSingle();
                await db.updateMedication(med.copyWith(stock: med.stock + log.dosage));

                // 2. Revert accessory stock (based on CURRENT links as best effort)
                final links = await db.getAccessoriesForMedication(log.medicationId);
                for (final link in links) {
                  final acc = await (db.select(db.accessories)..where((t) => t.id.equals(link.accessoryId))).getSingle();
                  await db.updateAccessory(acc.copyWith(stock: acc.stock + link.defaultQuantity));
                }

                // 3. Delete log
                await db.deleteInfusionLog(log.id);
              });

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryCard(BuildContext context, PendingOrder order) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final dateStr = DateFormat('dd. MMMM yyyy').format(order.deliveryDate ?? DateTime.now());

    return FutureBuilder<List<PendingOrderItem>>(
      future: db.getPendingOrderItems(order.id),
      builder: (context, itemsSnapshot) {
        final items = itemsSnapshot.data ?? [];
        
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_shipping_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
          ),
          title: const Text('Bestellung erhalten', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(dateStr, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(58, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return FutureBuilder<dynamic>(
                  future: item.medicationId != null 
                    ? (db.select(db.medications)..where((t) => t.id.equals(item.medicationId!))).getSingle()
                    : (db.select(db.accessories)..where((t) => t.id.equals(item.accessoryId!))).getSingle(),
                  builder: (context, nameSnapshot) {
                    final name = nameSnapshot.data?.name ?? '...';
                    final unit = nameSnapshot.data?.unit ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 12, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                          const SizedBox(width: 8),
                          Expanded(child: Text('${item.quantity.toStringAsFixed(0)} $unit $name', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        const Divider(),
      ],
    );
      },
    );
  }

  Widget _buildMedicationEventCard(BuildContext context, MedicationEvent event) {
    final dateStr = DateFormat('dd. MMMM yyyy').format(event.date);
    final isDiscontinued = event.type == MedicationEventType.discontinued;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: CircleAvatar(
            backgroundColor: (isDiscontinued ? Colors.grey : Theme.of(context).colorScheme.tertiary).withValues(alpha: 0.1),
            child: Icon(
              isDiscontinued ? Icons.heart_broken_outlined : Icons.add_moderator_outlined,
              color: isDiscontinued ? Colors.grey : Theme.of(context).colorScheme.tertiary,
            ),
          ),
          title: Text(
            isDiscontinued ? 'Abgesetzt: ${event.medication.name}' : 'Neu verordnet: ${event.medication.name}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(dateStr),
        ),
        const Divider(),
      ],
    );
  }
}
