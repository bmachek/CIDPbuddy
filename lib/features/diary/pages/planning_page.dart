import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/database.dart';
import 'add_infusion_page.dart';
import 'add_schedule_page.dart';

class PlanningPage extends StatelessWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Termine & Pläne'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Anstehend', icon: Icon(Icons.upcoming)),
              Tab(text: 'Zeitpläne', icon: Icon(Icons.repeat)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpcomingTab(db),
            _buildSchedulesTab(db),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'planning_fab',
          onPressed: () => _showAddOptions(context, db),
          icon: const Icon(Icons.add),
          label: const Text('Hinzufügen'),
        ),
      ),
    );
  }

  Widget _buildUpcomingTab(AppDatabase db) {
    return StreamBuilder<List<PlannedInfusion>>(
      stream: db.watchPlannedInfusions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('Keine zukünftigen Termine');
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
    );
  }

  Widget _buildSchedulesTab(AppDatabase db) {
    return StreamBuilder<List<InfusionSchedule>>(
      stream: db.watchSchedules(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('Keine aktiven Zeitpläne');
        }

        final schedules = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return _buildScheduleCard(context, db, schedule);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
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
            leading: CircleAvatar(
              backgroundColor: appt.scheduleId != null ? Colors.blue.shade100 : null,
              child: Icon(appt.scheduleId != null ? Icons.repeat : Icons.event),
            ),
            title: Text('$dateStr - ${med.name}'),
            subtitle: Text('Dosis: ${appt.dosage} ${med.unit}'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddInfusionPage()),
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

  Widget _buildScheduleCard(BuildContext context, AppDatabase db, InfusionSchedule schedule) {
    return FutureBuilder<Medication>(
      future: (db.select(db.medications)..where((t) => t.id.equals(schedule.medicationId))).getSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final med = snapshot.data!;

        String freqLabel = '';
        switch (schedule.frequencyType) {
          case 'daily': freqLabel = 'Täglich'; break;
          case 'weekly': freqLabel = schedule.intervalValue == 2 ? 'Alle 2 Wochen' : 'Wöchentlich'; break;
          case 'interval': freqLabel = 'Alle ${schedule.intervalValue} Tage'; break;
          case 'weekdays': freqLabel = 'Bestimmte Wochentage'; break;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.repeat)),
            title: Text('${med.name} ($freqLabel)'),
            subtitle: Text('Dosis: ${schedule.dosage} ${med.unit}\nStart: ${DateFormat('dd.MM.yyyy').format(schedule.startDate)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteSchedule(context, db, schedule),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteSchedule(BuildContext context, AppDatabase db, InfusionSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan löschen?'),
        content: const Text('Alle zukünftigen (nicht abgehakten) Termine dieses Plans werden ebenfalls gelöscht.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () async {
              await db.deletePlannedInfusionsForSchedule(schedule.id);
              await db.deleteSchedule(schedule.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context, AppDatabase db) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Einmaliger Termin'),
              onTap: () {
                Navigator.pop(context);
                _showAddAppointmentDialog(context, db);
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Wiederkehrender Plan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSchedulePage()));
              },
            ),
          ],
        ),
      ),
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
