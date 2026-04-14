import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../../../core/database/database.dart';
import 'add_infusion_page.dart';
import 'statistics_page.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryProvider = Provider.of<DiaryProvider>(context);

    return Scaffold(
      body: StreamBuilder<List<InfusionLogData>>(
        stream: diaryProvider.infusionLogsStream,
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];
          
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('Infusionstagebuch'),
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
              if (logs.isEmpty)
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
                        final log = logs[index];
                        return _buildLogCard(context, log);
                      },
                      childCount: logs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'diary_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddInfusionPage()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Infusion erfassen'),
      ),
    );
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
            const Text(
              'Erfasse deine erste Infusion, um den Überblick über deine Behandlung zu behalten.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
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
              if (log.batchNumber != null && log.batchNumber!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Charge: ${log.batchNumber}', style: const TextStyle(fontSize: 13)),
              ],
                Text(log.notes!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
              if (log.bodyWeight != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.monitor_weight_rounded, size: 14, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text('${log.bodyWeight} kg', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ],
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
}
