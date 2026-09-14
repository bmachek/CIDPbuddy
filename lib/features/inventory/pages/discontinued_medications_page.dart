import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/database/database.dart';
import '../providers/inventory_provider.dart';
import 'medication_details_page.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';

class DiscontinuedMedicationsPage extends StatelessWidget {
  const DiscontinuedMedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.discontinuedTitle),
      ),
      body: StreamBuilder<List<Medication>>(
        stream: inventoryProvider.discontinuedMedicationsStream,
        builder: (context, snapshot) {
          final meds = snapshot.data ?? [];
          
          if (meds.isEmpty) {
            return Center(
              child: Text(context.l10n.discontinuedEmpty, style: const TextStyle(color: Colors.grey)),
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
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    child: const Icon(Icons.heart_broken_outlined, color: Colors.grey),
                  ),
                  title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    context.l10n.discontinuedOn(AppDateFormat.date(context, med.discontinuedAt ?? DateTime.now())),
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
