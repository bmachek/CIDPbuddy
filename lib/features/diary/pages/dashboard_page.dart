import 'dart:async';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
import 'package:cidpbuddy/core/theme/app_colors.dart';
import 'package:cidpbuddy/main_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _showPast = false;
  bool _showFuture = false;
  bool _treatmentActionInFlight = false;

  /// Created once; a future built inside `build` would be re-issued on every
  /// stream event and flash the notification centre.
  late final Future<SharedPreferences> _prefsFuture;

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
  }

  /// Dose as the patient wrote it: `4`, `2.5` — never `4.0`.
  static String _dose(BuildContext context, double dosage) =>
      NumberFormat.decimalPattern(context.localeTag).format(dosage);

  SnackBar _confirmationSnackBar(BuildContext context, String text) {
    final status = AppStatusColors.of(context);
    return SnackBar(
      content: Text(text, style: TextStyle(color: status.onSuccess)),
      backgroundColor: status.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    );
  }

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
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    context.l10n.dashboardTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
                          _buildNotificationCenter(db, medications),
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
                                medicationMap,
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
                                      medicationMap[t.medicationId],
                                    ),
                                  )
                                  .toList(),
                            ),

                          const SizedBox(height: 32),
                          _buildPendingOrdersSection(db, medicationMap),
                        ],

                        // Clearance for the FAB and the translucent
                        // navigation bar (extendBody).
                        const SizedBox(height: 160),
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
        padding: const EdgeInsets.only(bottom: 16),
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

  Widget _buildNotificationCenter(
    AppDatabase db,
    List<Medication> medications,
  ) {
    return StreamBuilder<List<PendingOrderItem>>(
      stream: db.watchAllPendingOrderItems(),
      builder: (context, pendingSnapshot) {
        final pendingItems = pendingSnapshot.data ?? [];
        return StreamBuilder<List<Accessory>>(
          stream: db.watchAllAccessories(),
          builder: (context, accSnapshot) {
            return StreamBuilder<List<MedicationAccessory>>(
              stream: db.watchAllMedicationAccessories(),
              builder: (context, linksSnapshot) {
                return _NotificationCenter(
                  medications: medications,
                  accessories: accSnapshot.data ?? [],
                  links: linksSnapshot.data ?? [],
                  pendingItems: pendingItems,
                  prefsFuture: _prefsFuture,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPendingOrdersSection(
    AppDatabase db,
    Map<int, Medication> medicationMap,
  ) {
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
            ...orders.map(
              (order) => _buildOrderCard(
                context,
                db,
                order,
                medicationMap[order.medicationId],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    AppDatabase db,
    PendingOrder order,
    Medication? med,
  ) {
    final now = DateTime.now();
    final isOverdue =
        order.deliveryDate != null &&
        order.deliveryDate!.isBefore(DateTime(now.year, now.month, now.day));
    final colorScheme = Theme.of(context).colorScheme;
    // The medication may have been deleted since the order was placed. The
    // row stays visible with its delete button so the stray order can be
    // cleared instead of lingering invisibly.
    final title = med?.name ?? context.l10n.dashboardUnknownMedication;

    Future<void> onDelete() async {
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
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(context.l10n.actionDelete),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final l10n = context.l10n;
      try {
        await db.deletePendingOrder(order.id);
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed('$e'))));
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.deletedGeneric)));
    }

    Future<void> onReceived() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.dashboardConfirmDeliveryTitle),
          content: Text(context.l10n.dashboardConfirmDeliveryBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.actionNo),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.dashboardConfirmDeliveryYes),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final l10n = context.l10n;
      try {
        await db.confirmOrder(order.id);
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed('$e'))));
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.dashboardStockUpdated)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MergeSemantics(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (med != null)
                        Text(
                          context.l10n.quantityValue(
                            _dose(context, order.medicationQty),
                            med.unit,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
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
                                ? colorScheme.error
                                : colorScheme.onSurfaceVariant,
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
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.tooltipEditOrder,
              icon: Icon(Icons.edit_note_rounded, color: colorScheme.primary),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      ShoppingWizardDialog(orderToEdit: order),
                );
              },
            ),
            IconButton(
              tooltip: context.l10n.tooltipDeleteOrder,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colorScheme.error,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: Row(
            children: [
              Flexible(
                child: TextButton.icon(
                  onPressed: onReceived,
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                  ),
                  label: Text(
                    context.l10n.dashboardReceived,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  /// The shared layout of every treatment row: icon, name and status on one
  /// line (announced as a single item), the action as a full-width button
  /// underneath — never squeezed into `ListTile.trailing`, where a long
  /// label or a large font left no room for the name.
  Widget _buildTreatmentRow({
    required BuildContext context,
    required Color accentColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required String buttonLabel,
    required String buttonSemanticLabel,
    required VoidCallback? onPressed,
    double iconSize = 24,
    double leadingSize = 48,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: MergeSemantics(
            child: Row(
              children: [
                Container(
                  width: leadingSize,
                  height: leadingSize,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: iconSize),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: subtitleColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            side: BorderSide(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            buttonLabel,
            // Per-item label so a screen reader hears which medication the
            // button belongs to, not five identical "Done" buttons.
            semanticsLabel: buttonSemanticLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
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
    // Text needs more contrast than a fill: the brand blue is not readable
    // at 13 px, the error red is.
    final Color statusColor = isMissed
        ? Theme.of(context).colorScheme.error
        : AppStatusColors.of(context).accentText;

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
          : context.l10n.dashboardPlannedToday(
              _dose(context, treatment.dosage),
              med.unit,
            );
    }

    Future<void> onAction() async {
      if (!med.trackBatchNumber && !med.trackWeight && !med.useTimer) {
        // Guard against double-taps: logging and completing run asynchronously,
        // so a second tap would log the infusion and deduct the stock twice.
        if (_treatmentActionInFlight) return;
        _treatmentActionInFlight = true;
        final messenger = ScaffoldMessenger.of(context);
        final l10n = context.l10n;
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
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.saveFailed('$e'))),
          );
          return;
        } finally {
          _treatmentActionInFlight = false;
        }

        if (context.mounted) {
          messenger.showSnackBar(
            _confirmationSnackBar(context, l10n.dashboardMarkedDone(med.name)),
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

    return _buildTreatmentRow(
      context: context,
      accentColor: accentColor,
      icon: isPill ? Icons.medication_rounded : Icons.vaccines_rounded,
      iconSize: 28,
      leadingSize: 52,
      title: med.name,
      subtitle: statusText,
      subtitleColor: statusColor,
      buttonLabel: isPill
          ? context.l10n.actionDone
          : context.l10n.dashboardLogInfusionNow,
      buttonSemanticLabel: isPill
          ? context.l10n.dashboardMarkDoneFor(med.name)
          : context.l10n.dashboardLogInfusionFor(med.name),
      onPressed: onAction,
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.dashboardAllDoneBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    Medication? med,
  ) {
    // Medication missing (orphaned planned infusion, e.g. after a restore
    // whose backup referenced a deleted/absent medication). It can neither
    // be confirmed (no medication to log) nor reached otherwise — offer a
    // delete action so it can be cleared.
    if (med == null) {
      return _buildOrphanedTreatmentCard(context, db, treatment);
    }
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
        if (_treatmentActionInFlight) return;
        _treatmentActionInFlight = true;
        final messenger = ScaffoldMessenger.of(context);
        final l10n = context.l10n;
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
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.saveFailed('$e'))),
          );
          return;
        } finally {
          _treatmentActionInFlight = false;
        }

        if (context.mounted) {
          messenger.showSnackBar(
            _confirmationSnackBar(context, l10n.dashboardMarkedDone(med.name)),
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

    return _buildTreatmentRow(
      context: context,
      accentColor: Theme.of(context).colorScheme.primary,
      icon: isPill ? Icons.medication_rounded : Icons.vaccines_rounded,
      title: med.name,
      subtitle: context.l10n.dashboardTreatmentSubtitle(
        dateStr,
        timeStr,
        _dose(context, treatment.dosage),
        med.unit,
      ),
      subtitleColor: Theme.of(context).colorScheme.onSurfaceVariant,
      buttonLabel: isPill
          ? context.l10n.actionDone
          : context.l10n.dashboardLogInfusionNow,
      buttonSemanticLabel: isPill
          ? context.l10n.dashboardMarkDoneFor(med.name)
          : context.l10n.dashboardLogInfusionFor(med.name),
      onPressed: onAction,
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
    final title = context.l10n.dashboardUnknownMedication;

    Future<void> onDelete() async {
      final messenger = ScaffoldMessenger.of(context);
      final l10n = context.l10n;
      try {
        await db.deletePlannedInfusion(treatment.id);
        await NotificationService().cancelTreatmentReminders(treatment.id);
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed('$e'))));
        return;
      }
      if (context.mounted) {
        messenger.showSnackBar(
          _confirmationSnackBar(context, l10n.dashboardOrphanRemoved),
        );
      }
    }

    return _buildTreatmentRow(
      context: context,
      accentColor: Theme.of(context).colorScheme.error,
      icon: Icons.help_outline_rounded,
      title: title,
      subtitle: context.l10n.dashboardOrphanSubtitle(dateStr),
      subtitleColor: Theme.of(context).colorScheme.onSurfaceVariant,
      buttonLabel: context.l10n.actionRemove,
      buttonSemanticLabel: context.l10n.dashboardRemoveFor(title),
      onPressed: onDelete,
    );
  }

  void _showAddAppointmentDialog(BuildContext context, AppDatabase db) async {
    final meds = await db.getAllMedications();
    if (!context.mounted) return;
    if (meds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.planningNeedMedicationsFirst)),
      );
      return;
    }

    // Kept outside the builder: it can run again while the dialog is open
    // (e.g. on a theme change) and would otherwise reset the user's input.
    final formKey = GlobalKey<FormState>();
    Medication? selectedMed;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final dosageController = TextEditingController(text: '1');
    var saving = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(context.l10n.planningScheduleAppointmentTitle),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Medication>(
                      isExpanded: true,
                      items: meds
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(
                                m.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => selectedMed = val),
                      validator: (val) =>
                          val == null ? context.l10n.validationPickOne : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: context.l10n.medicationFallbackName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.sectionDateTime),
                      subtitle: Text(
                        AppDateFormat.dateTime(context, selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today_rounded),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date == null || !context.mounted) return;
                        // Without a time the appointment lands at midnight,
                        // which falls inside the default quiet hours
                        // (22:00–06:00) and silences every reminder for it.
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time == null || !context.mounted) return;
                        setState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: dosageController,
                      decoration: InputDecoration(
                        labelText: context.l10n.fieldPlannedDose,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return context.l10n.validationRequired;
                        }
                        final value = double.tryParse(
                          text.trim().replaceAll(',', '.'),
                        );
                        if (value == null) {
                          return context.l10n.validationEnterNumber;
                        }
                        if (value <= 0) {
                          return context.l10n.validationPositiveNumber;
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.actionCancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (saving) return;
                  // A missing medication or an unreadable dose is shown on
                  // the field instead of silently doing nothing.
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  final med = selectedMed;
                  final dosage = double.tryParse(
                    dosageController.text.trim().replaceAll(',', '.'),
                  );
                  if (med == null || dosage == null || dosage <= 0) return;
                  saving = true;
                  final messenger = ScaffoldMessenger.of(context);
                  final l10n = context.l10n;
                  try {
                    await db.insertPlannedInfusion(
                      PlannedInfusionsCompanion.insert(
                        date: selectedDate,
                        medicationId: med.id,
                        dosage: dosage,
                        isCompleted: const Value(false),
                      ),
                    );
                  } catch (e) {
                    saving = false;
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.saveFailed('$e'))),
                    );
                    return;
                  }
                  if (context.mounted) Navigator.pop(context);
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.savedSchedule)),
                  );
                  // Register the reminders now instead of waiting for the
                  // next app start or the 24 h background sync.
                  unawaited(
                    SchedulerService(db).syncPlannedInfusions().catchError(
                      (e) =>
                          debugPrint('Dashboard: appointment sync failed: $e'),
                    ),
                  );
                },
                child: Text(context.l10n.actionSave),
              ),
            ],
          ),
        );
      },
    );
    dosageController.dispose();
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
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
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
    Map<int, Medication> medicationMap,
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
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
        lastDate = date;
      }

      list.add(
        _buildTreatmentCard(context, db, t, medicationMap[t.medicationId]),
      );
    }
    return list;
  }

  Widget _buildDatedTreatmentCard(
    BuildContext context,
    AppDatabase db,
    PlannedInfusion treatment,
    Medication? med,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 4),
          child: Text(
            AppDateFormat.dayMonthTime(context, treatment.date),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _buildTreatmentCard(context, db, treatment, med),
      ],
    );
  }
}

/// The low-stock / backup / delivery hints below the focus list.
///
/// A widget of its own so the low-stock query runs once per data change —
/// built inline it was re-issued on every rebuild of the dashboard.
class _NotificationCenter extends StatefulWidget {
  const _NotificationCenter({
    required this.medications,
    required this.accessories,
    required this.links,
    required this.pendingItems,
    required this.prefsFuture,
  });

  final List<Medication> medications;
  final List<Accessory> accessories;
  final List<MedicationAccessory> links;
  final List<PendingOrderItem> pendingItems;
  final Future<SharedPreferences> prefsFuture;

  @override
  State<_NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<_NotificationCenter> {
  late Future<List<Medication>> _lowStockFuture;

  @override
  void initState() {
    super.initState();
    _lowStockFuture = _loadLowStock();
  }

  Future<List<Medication>> _loadLowStock() => Provider.of<MedicationService>(
    context,
    listen: false,
  ).getLowStockMedications();

  @override
  void didUpdateWidget(covariant _NotificationCenter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Drift rows compare by value, so this only re-queries on real changes.
    if (!listEquals(oldWidget.medications, widget.medications) ||
        !listEquals(oldWidget.pendingItems, widget.pendingItems)) {
      _lowStockFuture = _loadLowStock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingMedIds = widget.pendingItems
        .map((o) => o.medicationId)
        .whereType<int>()
        .toSet();
    final pendingAccIds = widget.pendingItems
        .map((o) => o.accessoryId)
        .whereType<int>()
        .toSet();

    return FutureBuilder<SharedPreferences>(
      future: widget.prefsFuture,
      builder: (context, prefsSnapshot) {
        final autoBackupEnabled =
            prefsSnapshot.data?.getBool('auto_backup_enabled') ?? false;

        return FutureBuilder<List<Medication>>(
          future: _lowStockFuture,
          builder: (context, lowStockSnapshot) {
            final lowMeds = lowStockSnapshot.data ?? const <Medication>[];

            // Filter out items that already have a pending order
            final filteredLowMeds = lowMeds
                .where((m) => !pendingMedIds.contains(m.id))
                .toList();

            final lowAccs = widget.accessories.where((a) {
              if (pendingAccIds.contains(a.id)) return false;

              // Check if this accessory has any link with consumption > 0
              final hasPositiveConsumption = widget.links
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
                // Only once the preference has actually been read: before
                // that the card would flash on every cold start.
                if (prefsSnapshot.hasData && !autoBackupEnabled)
                  _buildBackupHint(context),
                if (isStockProblem)
                  _buildLowStockHint(context, filteredLowMeds, lowAccs)
                else if (widget.pendingItems.isNotEmpty)
                  _buildOrdersOnTheWay(context),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBackupHint(BuildContext context) {
    final warning = AppStatusColors.of(context).warning;
    return Semantics(
      button: true,
      child: InkWell(
        // Deep link into the Settings tab, where the backup is set up.
        onTap: () => MainTabs.maybeOf(context)?.select(MainTabs.settings),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: warning.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: warning, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.dashboardNoBackupTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: warning,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      context.l10n.dashboardNoBackupBody,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, color: warning, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLowStockHint(
    BuildContext context,
    List<Medication> lowMeds,
    List<Accessory> lowAccs,
  ) {
    final accentText = AppStatusColors.of(context).accentText;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ShoppingWizardDialog(
              initialMedication: lowMeds.isNotEmpty ? lowMeds.first : null,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: accentText, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.dashboardOrderRecommended,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentText,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          context.l10n.dashboardLowStockNames(
                            [
                              ...lowMeds.map((m) => m.name),
                              ...lowAccs.map((a) => a.name),
                            ].join(', '),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: accentText,
                    size: 18,
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersOnTheWay(BuildContext context) {
    final success = AppStatusColors.of(context).success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.local_shipping_rounded, color: success, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.dashboardOrdersOnTheWay,
              style: TextStyle(
                fontSize: 13,
                color: success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
