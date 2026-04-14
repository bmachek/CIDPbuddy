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
                  child: _buildEmptyState(),
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
      floatingActionButton: Column(
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
            label: const Text('Vitals & Symptome'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
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
    );
  }

  Widget _buildDiaryEntryCard(BuildContext context, DiaryEntry entry) {
    final dateStr = DateFormat('dd. MMMM yyyy').format(entry.date);
    final timeStr = DateFormat('HH:mm').format(entry.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.withOpacity(0.1))),
          child: Icon(Icons.analytics_rounded, color: Theme.of(context).colorScheme.secondary),
        ),
        title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(timeStr, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (entry.systolicBP != null) _buildSmallChip(context, '${entry.systolicBP?.toInt()}/${entry.diastolicBP?.toInt()}', Icons.favorite),
                if (entry.heartRate != null) _buildSmallChip(context, '${entry.heartRate} bpm', Icons.monitor_heart),
                if (entry.weight != null) _buildSmallChip(context, '${entry.weight} kg', Icons.monitor_weight),
              ],
            ),
            const SizedBox(height: 8),
            _buildSymptomMiniBar(context, entry),
          ],
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddDiaryEntryPage(initialEntry: entry))),
      ),
    );
  }

  Widget _buildSmallChip(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSymptomMiniBar(BuildContext context, DiaryEntry entry) {
    // Average score or just simple indicators
    final scores = [
      entry.strengthScore, entry.sensoryScore, entry.fatigueScore, entry.painScore, entry.balanceScore
    ].whereType<int>().toList();
    if (scores.isEmpty) return const SizedBox();
    
    return Row(
      children: [
        Text('Symptome:', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(width: 6),
        ...List.generate(5, (i) {
          final score = (i < scores.length) ? scores[i] : 0;
          return Container(
            width: 12,
            height: 4,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: _getColorForScore(score).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ],
    );
  }

  Color _getColorForScore(int score) {
    if (score >= 8) return Colors.red;
    if (score >= 5) return Colors.orange;
    return Colors.green;
  }

  Widget _buildEmptyState() {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          dateStr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 4),
                  Text(timeStr, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                ],
              ),
              if (log.batchNumber != null && log.batchNumber!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text('Charge: ${log.batchNumber}', style: const TextStyle(fontSize: 13)),
                ),
              if (log.notes != null && log.notes!.isNotEmpty)
                Text(log.notes!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              if (log.bodyWeight != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.monitor_weight_rounded, size: 14, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text('${log.bodyWeight} kg', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _showEditLogDialog(context, Provider.of<AppDatabase>(context, listen: false), log),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                      onPressed: () => _confirmDeleteLog(context, Provider.of<AppDatabase>(context, listen: false), log),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(
                  '${log.dosage.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (time != null) {
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
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.orange.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.local_shipping_outlined, color: Colors.orange),
                ),
                title: const Text('Bestellung erhalten', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(dateStr),
              ),
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
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
                          return Text('• ${item.quantity.toStringAsFixed(0)} $unit $name', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant));
                        },
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicationEventCard(BuildContext context, MedicationEvent event) {
    final dateStr = DateFormat('dd. MMMM yyyy').format(event.date);
    final isDiscontinued = event.type == MedicationEventType.discontinued;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: (isDiscontinued ? Colors.grey : Colors.green).withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDiscontinued ? Colors.grey : Colors.green).withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            isDiscontinued ? Icons.heart_broken_outlined : Icons.add_moderator_outlined,
            color: isDiscontinued ? Colors.grey : Colors.green,
          ),
        ),
        title: Text(
          isDiscontinued ? 'Abgesetzt: ${event.medication.name}' : 'Neu verordnet: ${event.medication.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(dateStr),
      ),
    );
  }
}
