import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/database/database.dart';
import '../providers/inventory_provider.dart';
import 'medication_details_page.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';
import 'package:cidpbuddy/core/theme/app_colors.dart';

class DiscontinuedMedicationsPage extends StatelessWidget {
  const DiscontinuedMedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final status = AppStatusColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.discontinuedTitle)),
      body: StreamBuilder<List<Medication>>(
        stream: inventoryProvider.discontinuedMedicationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _CenteredMessage(context.l10n.errorLoadingData);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final meds = snapshot.data!;
          if (meds.isEmpty) {
            return _CenteredMessage(context.l10n.discontinuedEmpty);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final med = meds[index];
              // tileColor + shape instead of a coloured Container around the
              // tile, so the ink splash stays visible on tap.
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  tileColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.05),
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: status.inactive.withValues(alpha: 0.12),
                    child: Icon(
                      Icons.heart_broken_outlined,
                      color: status.inactive,
                    ),
                  ),
                  title: Text(
                    med.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    context.l10n.discontinuedOn(
                      AppDateFormat.date(
                        context,
                        med.discontinuedAt ?? DateTime.now(),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MedicationDetailsPage(medicationId: med.id),
                    ),
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

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  );
}
