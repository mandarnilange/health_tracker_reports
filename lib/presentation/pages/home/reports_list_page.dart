import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/presentation/pages/health_log/health_log_entry_sheet.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:health_tracker_reports/presentation/widgets/health_timeline.dart';

class ReportsListPage extends StatelessWidget {
  const ReportsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push(RouteNames.settings),
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: 'View Trends',
            onPressed: () => context.push(RouteNames.trends),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export Data',
            onPressed: () => context.pushNamed('export'),
          ),
        ],
      ),
      body: const HealthTimeline(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'upload_report',
            onPressed: () => context.push(RouteNames.upload),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Report'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'log_vitals',
            onPressed: () => HealthLogEntrySheet.show(context),
            icon: const Icon(Icons.add_chart),
            label: const Text('Log Vitals'),
          ),
        ],
      ),
    );
  }
}
