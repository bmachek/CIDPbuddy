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
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar.large(
              title: const Text('Termine & Pläne'),
              pinned: true,
              floating: true,
              bottom: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.upcoming_rounded, size: 18),
                        const SizedBox(width: 8),
                        const Text('Anstehend'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.repeat_rounded, size: 18),
                        const SizedBox(width: 8),
                        const Text('Zeitpläne'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _buildUpcomingTab(db),
              _buildSchedulesTab(db),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'planning_fab',
          onPressed: () => _showAddOptions(context, db),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Hinzufügen'),
        ),
      ),
    );
  }

  Widget _buildUpcomingTab(AppDatabase db) {
    return StreamBuilder<List<PlannedInfusion>>(
      stream: db.watchPlannedInfusions(),
      builder: (context, snapshot) {
        final appointments = snapshot.data ?? [];
        
        if (appointments.isEmpty) {
          return _buildEmptyState('Keine zukünftigen Termine', Icons.calendar_today_rounded);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
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
        final schedules = snapshot.data ?? [];

        if (schedules.isEmpty) {
          return _buildEmptyState('Keine aktiven Zeitpläne', Icons.repeat_on_rounded);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return _buildScheduleCard(context, db, schedule);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.grey.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, AppDatabase db, PlannedInfusion appt) {
    final dateStr = DateFormat('dd. MMMM yyyy').format(appt.date);
    
    return FutureBuilder<Medication>(
      future: (db.select(db.medications)..where((t) => t.id.equals(appt.medicationId))).getSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final med = snapshot.data!;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (appt.scheduleId != null ? Colors.blue : Theme.of(context).primaryColor).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    appt.scheduleId != null ? Icons.repeat_rounded : Icons.event_rounded,
                    color: appt.scheduleId != null ? Colors.blue : Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Geplant für den $dateStr'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _showEditAppointmentDialog(context, db, appt, med),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      onPressed: () => _confirmDeleteAppointment(context, db, appt),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dosis: ${appt.dosage} ${med.unit}',
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddInfusionPage(
                              initialMedicationId: appt.medicationId,
                              initialDosage: appt.dosage,
                            ),
                          ),
                        ).then((result) async {
                          if (result == true) {
                            await db.completePlannedInfusion(appt.id);
                          }
                        });
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: const Text('Erledigt'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 0,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteAppointment(BuildContext context, AppDatabase db, PlannedInfusion appt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termin löschen?'),
        content: const Text('Möchtest du diesen spezifischen Termin aus deiner Planung entfernen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await db.deletePlannedInfusion(appt.id);
    }
  }

  void _showEditAppointmentDialog(BuildContext context, AppDatabase db, PlannedInfusion appt, Medication med) {
    DateTime selectedDate = appt.date;
    final dosageController = TextEditingController(text: appt.dosage.toString());
    final notesController = TextEditingController(text: appt.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Termin bearbeiten'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Datum'),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageController,
                decoration: InputDecoration(labelText: 'Dosis (${med.unit})', border: const OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notizen', border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () async {
                await db.updatePlannedInfusion(appt.copyWith(
                  date: selectedDate,
                  dosage: double.tryParse(dosageController.text) ?? appt.dosage,
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
          case 'weekdays': freqLabel = 'Wochentage'; break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.repeat_rounded, color: Colors.blue),
            ),
            title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(freqLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Dosis: ${schedule.dosage} ${med.unit}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddSchedulePage(initialSchedule: schedule)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: () => _confirmDeleteSchedule(context, db, schedule),
                ),
              ],
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
        title: const Text('Zeitplan löschen?'),
        content: const Text('Alle zukünftigen (nicht erledigten) Termine dieses Plans werden ebenfalls gelöscht.'),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.event_rounded, color: Theme.of(context).primaryColor),
                ),
                title: const Text('Einmaliger Termin', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Einen einzelnen Termin hinzufügen'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddAppointmentDialog(context, db);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.repeat_rounded, color: Colors.blue),
                ),
                title: const Text('Wiederkehrender Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Einen automatischen Infusions-Rhythmus erstellen'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSchedulePage()));
                },
              ),
            ],
          ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Medication>(
                items: meds.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                onChanged: (val) => selectedMed = val,
                decoration: const InputDecoration(labelText: 'Medikament', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              InputDatePickerFormField(
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDate: selectedDate,
                onDateSaved: (date) => selectedDate = date,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(labelText: 'Geplante Dosis', border: OutlineInputBorder()),
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
