import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/diary_provider.dart';
import '../../../core/database/database.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';
import 'package:cidpbuddy/core/theme/app_colors.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryProvider = Provider.of<DiaryProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(context.l10n.statisticsTitle)),
          StreamBuilder<List<InfusionLogData>>(
            stream: diaryProvider.infusionLogsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildMessage(
                    context,
                    context.l10n.errorLoadingData,
                    Icons.error_outline_rounded,
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildMessage(
                    context,
                    context.l10n.statisticsEmpty,
                    Icons.bar_chart_rounded,
                  ),
                );
              }

              final logs = snapshot.data!;
              final monthlyData = _processMonthlyData(context, logs);
              final axisFormat = NumberFormat.decimalPattern(context.localeTag);

              return SliverSafeArea(
                top: false,
                sliver: SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        context.l10n.statisticsMonthlyDose,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppStatusColors.of(context).accentText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.statisticsMonthlyDoseSubtitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 260,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _getMaxY(monthlyData),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                tooltipRoundedRadius: 8,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 &&
                                        index < monthlyData.length) {
                                      return SideTitleWidget(
                                        meta: meta,
                                        child: Text(
                                          monthlyData[index].month,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 48,
                                  getTitlesWidget: (value, meta) => Text(
                                    axisFormat.format(value.toInt()),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.1),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: _buildBarGroups(context, monthlyData),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildSummary(context, logs),
                    ]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, String text, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_MonthDosage> _processMonthlyData(
    BuildContext context,
    List<InfusionLogData> logs,
  ) {
    final Map<String, double> grouped = {};
    // Sort logs by date first (ascending for chart)
    final sortedLogs = List<InfusionLogData>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (var log in sortedLogs) {
      final key = AppDateFormat.monthAxis(context, log.date);
      grouped[key] = (grouped[key] ?? 0) + log.dosage;
    }

    // Convert map to list, take last 6 months
    final result = grouped.entries
        .map((e) => _MonthDosage(e.key, e.value))
        .toList();
    return result.length > 6 ? result.sublist(result.length - 6) : result;
  }

  double _getMaxY(List<_MonthDosage> data) {
    if (data.isEmpty) return 10;
    final max = data.map((e) => e.dosage).reduce((a, b) => a > b ? a : b);
    return max * 1.2; // Add some padding
  }

  List<BarChartGroupData> _buildBarGroups(
    BuildContext context,
    List<_MonthDosage> data,
  ) {
    return List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[i].dosage,
            color: Theme.of(context).colorScheme.primary,
            width: 24,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(data),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.05),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSummary(BuildContext context, List<InfusionLogData> logs) {
    final total = logs.fold<double>(0, (sum, item) => sum + item.dosage);
    final count = logs.length;
    final avg = count > 0 ? total / count : 0.0;
    final intFormat = NumberFormat.decimalPattern(context.localeTag);
    final oneDecimal = NumberFormat.decimalPatternDigits(
      locale: context.localeTag,
      decimalDigits: 1,
    );

    // Find last recorded weight
    double? lastWeight;
    for (final log in logs) {
      if (log.bodyWeight != null) {
        lastWeight = log.bodyWeight;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.statisticsSummary,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            context,
            context.l10n.statisticsTotalInfusions,
            intFormat.format(count),
            Icons.history_rounded,
          ),
          _buildSummaryRow(
            context,
            context.l10n.statisticsTotalDose,
            context.l10n.unitsValue(oneDecimal.format(total)),
            Icons.summarize_rounded,
          ),
          _buildSummaryRow(
            context,
            context.l10n.statisticsAverageDose,
            context.l10n.unitsValue(oneDecimal.format(avg)),
            Icons.analytics_rounded,
          ),
          if (lastWeight != null)
            _buildSummaryRow(
              context,
              context.l10n.statisticsLastWeight,
              context.l10n.kilogramsValue(oneDecimal.format(lastWeight)),
              Icons.monitor_weight_rounded,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppStatusColors.of(context).accentText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthDosage {
  final String month;
  final double dosage;
  _MonthDosage(this.month, this.dosage);
}
