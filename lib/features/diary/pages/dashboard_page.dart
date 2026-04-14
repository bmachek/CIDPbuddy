import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database.dart';
import '../providers/diary_provider.dart';
import 'add_infusion_page.dart';
import '../../reminders/services/notification_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final now = DateTime.now();
    final greeting = _getGreeting();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(greeting, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                const Text('Deine Übersicht', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {}, // Future settings link
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummarySection(db),
                  const SizedBox(height: 32),
                  const Text(
                    'HEUTE GEPLANT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          StreamBuilder<List<PlannedInfusion>>(
            stream: db.watchTodayPlannedTreatments(),
            builder: (context, snapshot) {
              final todayTreatments = snapshot.data ?? [];
              
              if (todayTreatments.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.teal),
                        SizedBox(height: 16),
                        Text('Alles erledigt für heute!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTreatmentCard(context, db, todayTreatments[index]),
                    childCount: todayTreatments.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Guten Morgen';
    if (hour < 18) return 'Guten Tag';
    return 'Guten Abend';
  }

  Widget _buildSummarySection(AppDatabase db) {
    return StreamBuilder<List<PlannedInfusion>>(
      stream: db.watchTodayPlannedTreatments(),
      builder: (context, snapshot) {
        final remainingCount = snapshot.data?.length ?? 0;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade400, Colors.teal.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.medication_rounded, color: Colors.white, size: 32),
              const SizedBox(height: 16),
              Text(
                remainingCount > 0 
                  ? 'Noch $remainingCount Einnahmen heute' 
                  : 'Keine anstehenden Termine',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                remainingCount > 0 
                  ? 'Vergiss nicht deine Medikamente!' 
                  : 'Du bist voll im Plan.',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTreatmentCard(BuildContext context, AppDatabase db, PlannedInfusion treatment) {
    return FutureBuilder<Medication>(
      future: (db.select(db.medications)..where((t) => t.id.equals(treatment.medicationId))).getSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final med = snapshot.data!;
        final timeStr = DateFormat('HH:mm').format(treatment.date);
        final isPill = med.type == MedicationType.pill;

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
                color: (isPill ? Colors.orange : Colors.blue).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPill ? Icons.pill_rounded : Icons.vaccines_rounded,
                color: isPill ? Colors.orange : Colors.blue,
              ),
            ),
            title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Geplant um $timeStr Uhr • ${treatment.dosage} ${med.unit}'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddInfusionPage(
                      initialMedicationId: treatment.medicationId,
                      initialDosage: treatment.dosage,
                      initialDate: treatment.date,
                    ),
                  ),
                ).then((result) async {
                  if (result == true) {
                    await db.completePlannedInfusion(treatment.id);
                    await NotificationService().cancelTreatmentReminders(treatment.id);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                foregroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Erledigt'),
            ),
          ),
        );
      },
    );
  }
}
