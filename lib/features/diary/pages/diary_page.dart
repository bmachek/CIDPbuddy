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
      appBar: AppBar(
        title: const Text('Infusionstagebuch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatisticsPage()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<InfusionLogData>>(
        stream: diaryProvider.infusionLogsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final logs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return _buildLogCard(context, log);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddInfusionPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Infusion erfassen'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_edu, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Noch keine Infusionen erfasst', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, InfusionLogData log) {
    final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(log.date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('Infusion am $dateStr'),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                if (log.batchNumber != null && log.batchNumber!.isNotEmpty)
                    Text('Charge: ${log.batchNumber}'),
                if (log.notes != null && log.notes!.isNotEmpty)
                    Text('Notiz: ${log.notes}', maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
        ),
        trailing: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.1),
          child: const Icon(Icons.check, color: Colors.teal),
        ),
      ),
    );
  }
}
