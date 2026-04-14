import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../../../core/database/database.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryProvider = Provider.of<DiaryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Infusions-Statistiken')),
      body: StreamBuilder<List<InfusionLogData>>(
        stream: diaryProvider.infusionLogsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Noch keine Daten für Statistiken vorhanden.'));
          }

          final logs = snapshot.data!;
          final monthlyData = _processMonthlyData(logs);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Monatliche Dosis (Gramm/Einheiten)', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(monthlyData),
                      barTouchData: BarTouchData(enabled: true),
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
                                  child: Text(monthlyData[index].month, style: const TextStyle(fontSize: 10)),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(monthlyData),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildSummary(logs),
              ],
            ),
          );
        },
      ),
    );
  }

  List<_MonthDosage> _processMonthlyData(List<InfusionLogData> logs) {
    final Map<String, double> grouped = {};
    // Sort logs by date first (ascending for chart)
    final sortedLogs = List<InfusionLogData>.from(logs)..sort((a,b) => a.date.compareTo(b.date));
    
    for (var log in sortedLogs) {
      final key = DateFormat('MM/yy').format(log.date);
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

  List<BarChartGroupData> _buildBarGroups(List<_MonthDosage> data) {
    return List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[i].dosage,
            color: Colors.teal,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget _buildSummary(List<InfusionLogData> logs) {
    final total = logs.fold<double>(0, (sum, item) => sum + item.dosage);
    final count = logs.length;
    final avg = count > 0 ? total / count : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow('Gesamt-Infusionen', count.toString()),
            _buildSummaryRow('Gesamt-Dosis', '${total.toStringAsFixed(1)} Einheiten'),
            _buildSummaryRow('Ø Dosis / Gabe', '${avg.toStringAsFixed(1)} Einheiten'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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
