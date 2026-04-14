import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../providers/inventory_provider.dart';
import '../../../core/database/database.dart';
import 'add_item_page.dart';
import 'medication_details_page.dart';
import 'shopping_wizard_dialog.dart';
import '../../diary/pages/add_infusion_page.dart';
import '../../diary/pages/add_schedule_page.dart';
import '../../reminders/services/notification_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            title: const Text('Medikation'),
            pinned: true,
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                tooltip: 'Einkaufs-Assistent',
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => const ShoppingWizardDialog(),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Bestand'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_note_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Planung'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInventoryTab(context, inventoryProvider),
            _buildPlanningTab(context, db),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'medication_fab',
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddItemPage()),
            );
          } else {
            _showPlanningOptions(context, db);
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Hinzufügen'),
      ),
    );
  }

  Widget _buildInventoryTab(BuildContext context, InventoryProvider provider) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Icon(Icons.medication_rounded, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Medikamente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        StreamBuilder<List<Medication>>(
          stream: provider.medicationsStream,
          builder: (context, snapshot) {
            final meds = snapshot.data ?? [];
            if (meds.isEmpty) return const _EmptySection(message: 'Keine Medikamente angelegt');
            return Column(
              children: meds.map((med) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildMedicationItem(context, med, provider),
              )).toList(),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            children: [
              Icon(Icons.category_rounded, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Zubehör',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        StreamBuilder<List<Accessory>>(
          stream: provider.accessoriesStream,
          builder: (context, snapshot) {
            final accs = snapshot.data ?? [];
            if (accs.isEmpty) return const _EmptySection(message: 'Kein Zubehör angelegt');
            return Column(
              children: accs.map((acc) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildAccessoryItem(context, acc, provider),
              )).toList(),
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildPlanningTab(BuildContext context, AppDatabase db) {
    return StreamBuilder<List<PlannedInfusion>>(
      stream: db.watchPlannedInfusions(),
      builder: (context, snapshot) {
        final appointments = snapshot.data ?? [];
        return StreamBuilder<List<InfusionSchedule>>(
          stream: db.watchSchedules(),
          builder: (context, scheduleSnapshot) {
            final schedules = scheduleSnapshot.data ?? [];

            if (appointments.isEmpty && schedules.isEmpty) {
              return _buildEmptyState('Keine Planung vorhanden', Icons.event_busy_rounded);
            }

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final overdue = appointments.where((a) => a.date.isBefore(today)).toList();
            final upcoming = appointments.where((a) => !a.date.isBefore(today)).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (overdue.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Überfällig', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                      TextButton(
                        onPressed: () => _bulkDeleteOverdue(context, db),
                        child: const Text('Alle löschen', style: TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                    ],
                  ),
                  ...overdue.map((a) => _buildAppointmentCard(context, db, a, isOverdue: true)),
                  const SizedBox(height: 24),
                ],
                if (upcoming.isNotEmpty) ...[
                  const Text('Anstehende Termine', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  ...upcoming.map((a) => _buildAppointmentCard(context, db, a, isOverdue: false)),
                  const SizedBox(height: 24),
                ],
                if (schedules.isNotEmpty) ...[
                  const Text('Aktive Zeitpläne', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  ...schedules.map((s) => _buildScheduleCard(context, db, s)),
                ],
                const SizedBox(height: 100),
              ],
            );
          },
        );
      },
    );
  }

  // --- Helper Widgets from InventoryPage ---

  Widget _buildMedicationItem(BuildContext context, Medication med, InventoryProvider provider) {
    final isLowStock = med.stock <= med.minStock && med.minStock > 0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isLowStock ? Colors.orange.withOpacity(0.05) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isLowStock ? Colors.orange.withOpacity(0.2) : Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationDetailsPage(medicationId: med.id))),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: (isLowStock ? Colors.orange : Theme.of(context).primaryColor).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(isLowStock ? Icons.warning_amber_rounded : Icons.medication_rounded, color: isLowStock ? Colors.orange : Theme.of(context).primaryColor, size: 20),
        ),
        title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isLowStock ? 'Niedriger Bestand!' : 'PZN: ${med.pzn ?? "-"}'),
        trailing: _StockCounter(
          stock: med.stock, unit: med.unit,
          onAdd: () => provider.updateMedicationStock(med, 1),
          onRemove: () => provider.updateMedicationStock(med, -1),
        ),
      ),
    );
  }

  Widget _buildAccessoryItem(BuildContext context, Accessory acc, InventoryProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.build_circle_rounded, color: Colors.teal, size: 20),
        ),
        title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: _StockCounter(
          stock: acc.stock, unit: acc.unit,
          onAdd: () => provider.updateAccessoryStock(acc, 1),
          onRemove: () => provider.updateAccessoryStock(acc, -1),
        ),
      ),
    );
  }

  // --- Helper Widgets from PlanningPage ---

  Widget _buildAppointmentCard(BuildContext context, AppDatabase db, PlannedInfusion appt, {bool isOverdue = false}) {
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
                title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('dd. MMMM yyyy').format(appt.date), style: isOverdue ? const TextStyle(color: Colors.red, fontWeight: FontWeight.bold) : null),
                leading: Icon(isOverdue ? Icons.priority_high_rounded : Icons.event_rounded, color: isOverdue ? Colors.red : Theme.of(context).primaryColor),
                trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20), onPressed: () => db.deletePlannedInfusion(appt.id)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${appt.dosage} ${med.unit}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddInfusionPage(initialMedicationId: appt.medicationId, initialDosage: appt.dosage, initialDate: appt.date))),
                      style: ElevatedButton.styleFrom(elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12)),
                      child: const Text('Erledigt'),
                    )
                  ],
                ),
              )
            ],
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
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
          ),
          child: ListTile(
            leading: const Icon(Icons.repeat_rounded, color: Colors.blue),
            title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Rhythmus: ${schedule.frequencyType}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddSchedulePage(initialSchedule: schedule))),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showPlanningOptions(BuildContext context, AppDatabase db) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event_rounded),
              title: const Text('Einmaliger Termin'),
              onTap: () { Navigator.pop(context); /* logic for direct appointment add if needed */ },
            ),
            ListTile(
              leading: const Icon(Icons.repeat_rounded),
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

  void _bulkDeleteOverdue(BuildContext context, AppDatabase db) async {
    final today = DateTime.now();
    await db.deleteIncompletePlannedInfusionsBefore(DateTime(today.year, today.month, today.day));
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(message, style: const TextStyle(color: Colors.grey))));
}

class _StockCounter extends StatelessWidget {
  final double stock;
  final String unit;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _StockCounter({required this.stock, required this.unit, required this.onAdd, required this.onRemove});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline_rounded, size: 18), onPressed: onRemove),
        Text('${stock.toStringAsFixed(0)} $unit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        IconButton(icon: const Icon(Icons.add_circle_outline_rounded, size: 18), onPressed: onAdd),
      ],
    );
  }
}
