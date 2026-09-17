import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cidpbuddy/core/database/database.dart';
import '../providers/diary_provider.dart';
import 'add_infusion_page.dart';
import '../../reminders/services/notification_service.dart';
import '../../inventory/pages/shopping_wizard_dialog.dart';
import '../widgets/active_timer_banner.dart';
import 'package:drift/drift.dart' show Value;
import 'package:cidpbuddy/core/services/medication_service.dart';
import 'package:cidpbuddy/core/services/scheduler_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _showPast = false;
  bool _showFuture = false;
  bool _treatmentActionInFlight = false;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      height: 32,
                      width: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.dashboardTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                onPressed: () {}, // Future settings link
              ),
            ],
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [SizedBox(height: 8), ActiveTimerBanner()],
              ),
            ),
          ),
          StreamBuilder<List<Medication>>(
            stream: db.watchAllMedications(),
            builder: (context, medsSnapshot) {
              final medications = medsSnapshot.data ?? [];
              final medicationMap = {for (var m in medications) m.id: m};

              return StreamBuilder<List<PlannedInfusion>>(
                stream: db.watchPlannedTreatmentsRange(
                  daysBack: 7,
                  daysForward: 30,
                ),
                builder: (context, snapshot) {
                  final allTreatments = snapshot.data ?? [];
                  final now = DateTime.now();
                  final todayStart = DateTime(now.year, now.month, now.day);
                  final todayEnd = todayStart.add(const Duration(days: 1));
                  // Focus Section: Missed (Past Incomplete), Today's Infusions, Today's Overdue Pills
                  final focusTreatments = allTreatments.where((t) {
                    final med = medicationMap[t.medicationId];
                    if (med == null) return false;
                    final isInfusion = med.type != MedicationType.pill;

                    // Past incomplete treatments (Verpasst)
                    if (t.date.isBefore(now)) return true;
                    // Infusions planned for today (regardless of time)
                    if (isInfusion &&
                        t.date.isAfter(todayStart) &&
                        t.date.isBefore(todayEnd)) {
                      return true;
                    }

                    return false;
                  }).toList();

                  // Future Section: Future Pills (after now) + Future Infusions (after today)
                  final futureTreatments = allTreatments.where((t) {
                    if (focusTreatments.contains(t)) return false;
                    return t.date.isAfter(now);
                  }).toList();

                  // Past Section: Historical (usually done or hidden from focus)
                  // For now, let's keep it for everything that is completed in the past
                  // or past items if we ever decide to move them out of focus once 'done'
                  // but here they are still incomplete from the stream.
                  final pastTreatments = allTreatments.where((t) {
                    if (focusTreatments.contains(t) ||
                        futureTreatments.contains(t)) {
                      return false;
                    }
                    return t.date.isBefore(todayStart);
                  }).toList();

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 16),

                        if (focusTreatments.isEmpty &&
                            futureTreatments.isEmpty &&
                            pastTreatments.isEmpty)
                          _buildEmptyState(context)
                        else ...[
                          ...focusTreatments.map(
                            (t) => _buildFocusTreatmentCard(
                              context,
                              db,
                              t,
                              medicationMap[t.medicationId],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Notification Center - Now below upcoming focus items
                          _buildNotificationCenter(db),
                          const SizedBox(height: 24),

                          if (futureTreatments.isNotEmpty)
                            _buildExpansionSection(
                              context: context,
                              title: context.l10n.dashboardSectionLater(
                                futureTreatments.length,
                              ),
                              icon: Icons.event_repeat_rounded,
                              isExpanded: _showFuture,
                              onToggle: (val) =>
                                  setState(() => _showFuture = val),
                              children: _groupAndBuildFutureList(
                                context,
                                db,
                                futureTreatments,
                              ),
                            ),

                          if (pastTreatments.isNotEmpty)
                            _buildExpansionSection(
                              context: context,
                              title: context.l10n.dashboardSectionPast(
                                pastTreatments.length,
                              ),
                              icon: Icons.history_rounded,
                              isExpanded: _showPast,
                              onToggle: (val) =>
                                  setState(() => _showPast = val),
                              children: pastTreatments
                                  .map(
                                    (t) => _buildDatedTreatmentCard(
                                      context,
                                      db,
                                      t,
                                    ),
                                  )
                                  .toList(),
                            ),

                          const SizedBox(height: 32),
                          _buildPendingOrdersSection(db),
                        ],

                        const SizedBox(height: 120),
                      ]),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddAppointmentDialog(context, db),
          icon: const Icon(Icons.add_rounded),
          label: Text(context.l10n.planningScheduleAppointmentTitle),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildNotificationCenter(AppDatabase db) {
    return StreamBuilder<List<PendingOrderItem>>(
      stream: db.watchAllPendingOrderItems(),
      builder: (context, pendingSnapshot) {
        final pendingItems = pendingSnapshot.data ?? [];
        final pendingMedIds = pendingItems
            .map((o) => o.medicationId)
            .whereType<int>()
            .toSet();
        final pendingAccIds = pendingItems
            .map((o) => o.accessoryId)
            .whereType<int>()
            .toSet();

        return StreamBuilder<List<Medication>>(
          stream: db.watchAllMedications(),
          builder: (context, medsSnapshot) {
            return StreamBuilder<List<Accessory>>(
              stream: db.watchAllAccessories(),
              builder: (context, accSnapshot) {
                return StreamBuilder<List<MedicationAccessory>>(
                  stream: db.watchAllMedicationAccessories(),
                  builder: (context, linksSnapshot) {
                    final medService = Provider.of<MedicationService>(
                      context,
                      listen: false,
                    );

                    return FutureBuilder<List<dynamic>>(
                      future: Future.wait([
                        medService.getLowStockMedications(),
                        SharedPreferences.getInstance(),
                      ]),
                      builder: (context, combinedSnapshot) {
                        final lowMeds =
                            (combinedSnapshot.data?[0] as List<Medication>?) ??
                            [];
                        final prefs =
                            combinedSnapshot.data?[1] as SharedPreferences?;
                        final autoBackupEnabled =
                            prefs?.getBool('auto_backup_enabled') ?? false;

                        final allAccs = accSnapshot.data ?? [];
                        final allLinks = linksSnapshot.data ?? [];

                        // Filter out items that already have a pending order
                        final filteredLowMeds = lowMeds
                            .where((m) => !pendingMedIds.contains(m.id))
                            .toList();

                        final lowAccs = allAccs.where((a) {
                          if (pendingAccIds.contains(a.id)) return false;

                          // Check if this accessory has any link with consumption > 0
                          final hasPositiveConsumption = allLinks
                              .where((l) => l.accessoryId == a.id)
                              .any((l) => l.defaultQuantity > 0);

                          if (!hasPositiveConsumption) {
                            // For items with 0 consumption (or not linked), only warn at stock 0
                            return a.stock <= 0;
                          } else {
                            // For items with consumption, warn at stock < 5 (standard threshold)
                            return a.stock < 5;
                          }
                        }).toList();

                        final isStockProblem =
                            filteredLowMeds.isNotEmpty || lowAccs.isNotEmpty;

                        return Column(
                          children: [
                            if (!autoBackupEnabled) ...[
                              InkWell(
                                onTap: () {
                                  // Open settings or show a dialog
                                  // For now, let's assume there's a way to open settings
                                  // Navigator.push(... SettingsPage)
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.orange.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.cloud_off_rounded,
                                        color: Colors.orange,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              context
                                                  .l10n
                                                  .dashboardNoBackupTitle,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              context
                                                  .l10n
                                                  .dashboardNoBackupBody,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.orange,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (isStockProblem) ...[
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ShoppingWizardDialog(
                                      initialMedication:
                                          filteredLowMeds.isNotEmpty
                                          ? filteredLowMeds.first
                                          : null,
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                context
                                                    .l10n
                                                    .dashboardOrderRecommended,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                context.l10n
                                                    .dashboardLowStockNames(
                                                      [
                                                        ...filteredLowMeds.map(
                                                          (m) => m.name,
                                                        ),
                                                        ...lowAccs.map(
                                                          (a) => a.name,
                                                        ),
                                                      ].join(', '),
                                                    ),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              ),
                            ] else if (pendingItems.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_shipping_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.tertiary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        context.l10n.dashboardOrdersOnTheWay,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPendingOrdersSection(AppDatabase db) {
    return StreamBuilder<List<PendingOrder>>(
      stream: db.watchPendingOrders(),
      builder: (context, snapshot) {
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                context.l10n.dashboardPendingDeliveries,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ...orders.map((order) => _buildOrderCard(context, db, order)),
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    AppDatabase db,
    PendingOrder order,
  ) {
    final now = DateTime.now();
    final isOverdue =
        order.deliveryDate != null &&
        order.deliveryDate!.isBefore(DateTime(now.year, now.month, now.day));

    return FutureBuilder<Medication>(
      future: (db.select(
        db.medications,
      )..where((t) => t.id.equals(order.medicationId))).getSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final med = snapshot.data!;

        return Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                med.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.quantityValue(
                      order.medicationQty.toStringAsFixed(0),
                      med.unit,
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (order.deliveryDate != null)
                    Text(
                      context.l10n.dashboardDeliveryDate(
                        AppDateFormat.date(context, order.deliveryDate!),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: isOverdue
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: isOverdue
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    )
                  else
                    Text(
                      context.l10n.dashboardNoDeliveryDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_note_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            ShoppingWizardDialog(orderToEdit: order),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(context.l10n.dashboardDeleteOrderTitle),
                          content: Text(context.l10n.dashboardDeleteOrderBody),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(context.l10n.actionCancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                              child: Text(context.l10n.actionDelete),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await db.deletePendingOrder(order.id);
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            context.l10n.dashboardConfirmDeliveryTitle,
                          ),
                          content: Text(
                            context.l10n.dashboardConfirmDeliveryBody,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(context.l10n.actionNo),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                context.l10n.dashboardConfirmDeliveryYes,
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await db.confirmOrder(order.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.dashboardStockUpdated),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                    ),
                    label: Text(
                      context.l10n.dashboardReceived,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildFocusTreatmentCard(
    BuildContext context,
    AppDatabase db,
    PlannedInfusion treatment,
    Medication? med,
  ) {
    if (med == null) return const SizedBox();

    final medDate = treatment.date;
    final now = DateTime.now();
    final isPill = med.type == MedicationType.pill;
    final isMissed = medDate.isBefore(now);

    // Primary color for this card
    final Color accentColor = isMissed
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    // Status text
    String statusText;
    if (isPill) {
      final time = AppDateFormat.time(context, medDate);
      statusText = isMissed
          ? context.l10n.dashboardMissedAt(time)
          : context.l10n.dashboardTodayAt(time);
    } else {
      // Infusion Forecast
      statusText = isMissed
          ? context.l10n.dashboardMissedInfusion
          : context.l10n.dashboardPlannedToday('${treatment.dosage}', med.unit);
    }

    Future<void> onAction() async {
      if (!med.trackBatchNumber && !med.trackWeight && !med.useTimer) {
        // Guard against double-taps: logging and completing run asynchronously,
        // so a second tap would log the infusion and deduct the stock twice.
        if (_treatmentActionInFlight) return;
        _treatmentActionInFlight = true;
        try {
          final diaryProvider = Provider.of<DiaryProvider>(
            context,
            listen: false,
          );
          await diaryProvider.logInfusion(
            medicationId: treatment.medicationId,
            dosage: treatment.dosage,
            date: treatment.date,
          );
          await SchedulerService(db).completeTreatment(treatment.id);
        } finally {
          _treatmentActionInFlight = false;
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.dashboardMarkedDone(med.name)),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            ),
          );
        }
        return;
      }

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
          await SchedulerService(db).completeTreatment(treatment.id);
        }
      });
    }

    return Column(
      children: [
        ListTile(
          onTap: onAction,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPill ? Icons.medication_rounded : Icons.vaccines_rounded,
              color: accentColor,
              size: 28,
            ),
          ),
          title: Text(
            med.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              statusText,
              style: TextStyle(
                color: accentColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          trailing: ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              side: BorderSide(color: accentColor.withValues(alpha: 0.1)),
            ),
            child: Text(
              isPill
                  ? context.l10n.actionDone
                  : context.l10n.dashboardLogInfusionNow,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.tertiary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.dashboardAllDoneTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.dashboardAllDoneBody,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentCard(
    BuildContext context,
    AppDatabase db,
    PlannedInfusion treatment,
  ) {
    return FutureBuilder<Medication>(
      future: (db.select(
        db.medications,
      )..where((t) => t.id.equals(treatment.medicationId))).getSingle(),
      builder: (context, snapshot) {
        // Still loading: keep it empty to avoid a flash of the fallback card.
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox();
        }
        // Medication missing (orphaned planned infusion, e.g. after a restore
        // whose backup referenced a deleted/absent medication). It can neither
        // be confirmed (no medication to log) nor reached otherwise — offer a
        // delete action so it can be cleared.
        if (!snapshot.hasData) {
          return _buildOrphanedTreatmentCard(context, db, treatment);
        }
        final med = snapshot.data!;
        final medDate = treatment.date;
        final now = DateTime.now();
        final isToday =
            medDate.year == now.year &&
            medDate.month == now.month &&
            medDate.day == now.day;
        final dateStr = isToday
            ? context.l10n.today
            : AppDateFormat.dayMonth(context, medDate);
        final timeStr = AppDateFormat.time(context, medDate);
        final isPill = med.type == MedicationType.pill;

        Future<void> onAction() async {
          if (!med.trackBatchNumber && !med.trackWeight && !med.useTimer) {
            final diaryProvider = Provider.of<DiaryProvider>(
              context,
              listen: false,
            );
            await diaryProvider.logInfusion(
              medicationId: treatment.medicationId,
              dosage: treatment.dosage,
              date: treatment.date,
            );
            await SchedulerService(db).completeTreatment(treatment.id);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(context.l10n.dashboardMarkedDone(med.name)),
                      ),
                    ],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                ),
              );
            }
            return;
          }

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
              await SchedulerService(db).completeTreatment(treatment.id);
            }
          });
        }

        return Column(
          children: [
            ListTile(
              onTap: onAction,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPill ? Icons.medication_rounded : Icons.vaccines_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              title: Text(
                med.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                context.l10n.dashboardTreatmentSubtitle(
                  dateStr,
                  timeStr,
                  '${treatment.dosage}',
                  med.unit,
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  isPill
                      ? context.l10n.actionDone
                      : context.l10n.dashboardLogInfusionNow,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  /// Fallback card for a planned infusion whose medication no longer exists.
  /// Since there is nothing to log, the only sensible action is to remove the
  /// stray entry.
  Widget _buildOrphanedTreatmentCard(
    BuildContext context,
    AppDatabase db,
    PlannedInfusion treatment,
  ) {
    final dateStr = AppDateFormat.dayMonthTime(context, treatment.date);

    Future<void> onDelete() async {
      await db.deletePlannedInfusion(treatment.id);
      await NotificationService().cancelTreatmentReminders(treatment.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.dashboardOrphanRemoved),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          ),
        );
      }
    }

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
          ),
          title: Text(
            context.l10n.dashboardUnknownMedication,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            context.l10n.dashboardOrphanSubtitle(dateStr),
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: ElevatedButton(
            onPressed: onDelete,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              context.l10n.actionRemove,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  void _showAddAppointmentDialog(BuildContext context, AppDatabase db) async {
    final meds = await db.getAllMedications();
    if (meds.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.planningNeedMedicationsFirst)),
        );
      }
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        Medication? selectedMed;
        DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
        final dosageController = TextEditingController(text: '1.0');

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(context.l10n.planningScheduleAppointmentTitle),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Medication>(
                  items: meds
                      .map(
                        (m) => DropdownMenuItem(value: m, child: Text(m.name)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedMed = val),
                  decoration: InputDecoration(
                    labelText: context.l10n.medicationFallbackName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(context.l10n.fieldDate),
                  subtitle: Text(AppDateFormat.date(context, selectedDate)),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => selectedDate = date);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dosageController,
                  decoration: InputDecoration(
                    labelText: context.l10n.fieldPlannedDose,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.actionCancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedMed != null) {
                    await db.insertPlannedInfusion(
                      PlannedInfusionsCompanion.insert(
                        date: selectedDate,
                        medicationId: selectedMed!.id,
                        dosage: double.tryParse(dosageController.text) ?? 1.0,
                        isCompleted: const Value(false),
                      ),
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: Text(context.l10n.actionSave),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpansionSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isExpanded,
    required ValueChanged<bool> onToggle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: onToggle,
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: children,
      ),
    );
  }

  List<Widget> _groupAndBuildFutureList(
    BuildContext context,
    AppDatabase db,
    List<PlannedInfusion> treatments,
  ) {
    final List<Widget> list = [];
    DateTime? lastDate;

    for (var i = 0; i < treatments.length; i++) {
      final t = treatments[i];
      final date = DateTime(t.date.year, t.date.month, t.date.day);

      if (lastDate == null || !DateUtils.isSameDay(lastDate, date)) {
        list.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppDateFormat.weekdayLongDate(context, date).toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
        lastDate = date;
      }

      list.add(_buildTreatmentCard(context, db, t));
    }
    return list;
  }

  Widget _buildDatedTreatmentCard(
    BuildContext context,
    AppDatabase db,
    PlannedInfusion treatment,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 4),
          child: Text(
            AppDateFormat.dayMonthTime(context, treatment.date),
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _buildTreatmentCard(context, db, treatment),
      ],
    );
  }
}
