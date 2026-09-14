import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/diary_provider.dart';
import '../../../core/database/database.dart';
import 'package:cidpbuddy/core/l10n/l10n_ext.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryProvider = Provider.of<DiaryProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(context.l10n.statisticsTitle),
          ),
          StreamBuilder<List<InfusionLogData>>(
            stream: diaryProvider.infusionLogsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text(context.l10n.statisticsEmpty)),
                );
              }

              final logs = snapshot.data!;
              final monthlyData = _processMonthlyData(context, logs);

              return SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      context.l10n.statisticsMonthlyDose,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.statisticsMonthlyDoseSubtitle,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 240,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxY(monthlyData),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => Theme.of(context).colorScheme.secondaryContainer,
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
                                  if (index >= 0 && index < monthlyData.length) {
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        monthlyData[index].month,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                                reservedSize: 32,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true, 
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
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
              );
            },
          ),
        ],
      ),
    );
  }

  List<_MonthDosage> _processMonthlyData(BuildContext context, List<InfusionLogData> logs) {
    final Map<String, double> grouped = {};
    // Sort logs by date first (ascending for chart)
    final sortedLogs = List<InfusionLogData>.from(logs)..sort((a,b) => a.date.compareTo(b.date));
    
    for (var log in sortedLogs) {
      final key = AppDateFormat.monthAxis(context, log.date);
      grouped[key] = (grouped[key] ?? 0) + log.dosage;
    }

    // Convert map to list, take last 6 months
    final result = grouped.entries.map((e) => _MonthDosage(e.key, e.value)).toList();
    return result.length > 6 ? result.sublist(result.length - 6) : result;
  }

  double _getMaxY(List<_MonthDosage> data) {
    if (data.isEmpty) return 10;
    final max = data.map((e) => e.dosage).reduce((a, b) => a > b ? a : b);
    return max * 1.2; // Add some padding
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context, List<_MonthDosage> data) {
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
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
    
    // Find last recorded weight
    double? lastWeight;
    try {
      lastWeight = logs.firstWhere((l) => l.bodyWeight != null).bodyWeight;
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.statisticsSummary, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildSummaryRow(context, context.l10n.statisticsTotalInfusions, count.toString(), Icons.history_rounded),
          _buildSummaryRow(context, context.l10n.statisticsTotalDose, context.l10n.unitsValue(total.toStringAsFixed(1)), Icons.summarize_rounded),
          _buildSummaryRow(context, context.l10n.statisticsAverageDose, context.l10n.unitsValue(avg.toStringAsFixed(1)), Icons.analytics_rounded),
          if (lastWeight != null)
            _buildSummaryRow(context, context.l10n.statisticsLastWeight, context.l10n.kilogramsValue(lastWeight.toStringAsFixed(1)), Icons.monitor_weight_rounded),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}

class _MonthDosage {
  final String month;
  final double dosage;
  _MonthDosage(this.month, this.dosage);
}
