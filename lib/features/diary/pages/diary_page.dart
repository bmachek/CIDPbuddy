import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/diary_provider.dart';
import '../../../core/database/database.dart';
import 'add_infusion_page.dart';
import 'statistics_page.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryProvider = Provider.of<DiaryProvider>(context);

    return Scaffold(
      body: StreamBuilder<List<InfusionLogData>>(
        stream: diaryProvider.infusionLogsStream,
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];
          
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('Infusionstagebuch'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bar_chart_rounded),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatisticsPage()),
                    ),
                  ),
                ],
              ),
              if (logs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final log = logs[index];
                        return _buildLogCard(context, log);
                      },
                      childCount: logs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'diary_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddInfusionPage()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Infusion erfassen'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_diary.png',
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              'Dein Tagebuch ist noch leer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Erfasse deine erste Infusion, um den Überblick über deine Behandlung zu behalten.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, InfusionLogData log) {
    final dateStr = DateFormat('dd. MMMM yyyy').format(log.date);
    final timeStr = DateFormat('HH:mm').format(log.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          dateStr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 4),
                  Text(timeStr, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                ],
              ),
              if (log.batchNumber != null && log.batchNumber!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Charge: ${log.batchNumber}', style: const TextStyle(fontSize: 13)),
              ],
              if (log.notes != null && log.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(log.notes!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, color: Theme.of(context).primaryColor, size: 20),
        ),
      ),
    );
  }
}
