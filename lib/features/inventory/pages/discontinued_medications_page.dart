import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database.dart';
import '../providers/inventory_provider.dart';
import 'medication_details_page.dart';

class DiscontinuedMedicationsPage extends StatelessWidget {
  const DiscontinuedMedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abgesetzte Medikamente'),
      ),
      body: StreamBuilder<List<Medication>>(
        stream: inventoryProvider.discontinuedMedicationsStream,
        builder: (context, snapshot) {
          final meds = snapshot.data ?? [];
          
          if (meds.isEmpty) {
            return const Center(
              child: Text('Keine abgesetzten Medikamente vorhanden.', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final med = meds[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    child: const Icon(Icons.heart_broken_outlined, color: Colors.grey),
                  ),
                  title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Abgesetzt am: ${DateFormat('dd.MM.yyyy').format(med.discontinuedAt ?? DateTime.now())}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => MedicationDetailsPage(medicationId: med.id))
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
