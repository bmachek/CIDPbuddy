import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';
import '../providers/diary_provider.dart';
import 'add_infusion_page.dart';

class PlanningPage extends StatelessWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Termine')),
      body: StreamBuilder<List<PlannedInfusion>>(
        stream: db.watchPlannedInfusions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final appointments = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return _buildAppointmentCard(context, db, appt);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAppointmentDialog(context, db),
        icon: const Icon(Icons.event_available),
        label: const Text('Termin planen'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Keine zukünftigen Termine geplant', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, AppDatabase db, PlannedInfusion appt) {
    final dateStr = DateFormat('dd.MM.yyyy').format(appt.date);
    
    return FutureBuilder<Medication>(
      future: (db.select(db.medications)..where((t) => t.id.equals(appt.medicationId))).getSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final med = snapshot.data!;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.event)),
            title: Text('$dateStr - ${med.name}'),
            subtitle: Text('Dosis: ${appt.dosage} ${med.unit}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Navigate to logging page and mark as done afterwards
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddInfusionPage()), // In a real app we'd pre-fill this
                ).then((_) async {
                  await db.completePlannedInfusion(appt.id);
                });
              },
              child: const Text('Abhaken'),
            ),
          ),
        );
      },
    );
  }

  void _showAddAppointmentDialog(BuildContext context, AppDatabase db) async {
    final meds = await db.getAllMedications();
    if (meds.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zuerst Medikamente im Inventar anlegen!')));
      }
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        Medication? selectedMed;
        DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
        final dosageController = TextEditingController(text: '1.0');

        return AlertDialog(
          title: const Text('Termin planen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Medication>(
                items: meds.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                onChanged: (val) => selectedMed = val,
                decoration: const InputDecoration(labelText: 'Medikament'),
              ),
              const SizedBox(height: 16),
              InputDatePickerFormField(
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDate: selectedDate,
                onDateSaved: (date) => selectedDate = date,
              ),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(labelText: 'Geplante Dosis'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () async {
                if (selectedMed != null) {
                  await db.insertPlannedInfusion(PlannedInfusionsCompanion.insert(
                    date: selectedDate,
                    medicationId: selectedMed!.id,
                    dosage: double.tryParse(dosageController.text) ?? 1.0,
                    isCompleted: const drift.Value(false),
                  ));
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }
}
