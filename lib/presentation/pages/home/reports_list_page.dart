import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';
import 'package:health_tracker_reports/presentation/pages/export/export_page_args.dart';
import 'package:health_tracker_reports/presentation/pages/health_log/health_log_entry_sheet.dart';
import 'package:health_tracker_reports/presentation/providers/health_log_provider.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:health_tracker_reports/presentation/widgets/health_timeline.dart';

class ReportsListPage extends ConsumerWidget {
  const ReportsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () => _handleExportPressed(context, ref),
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

  void _handleExportPressed(BuildContext context, WidgetRef ref) {
    final reportsState = ref.read(reportsProvider);
    final logsState = ref.read(healthLogsProvider);

    final reportsLoaded = reportsState is AsyncData<List<Report>>;
    final healthLogsLoaded = logsState is AsyncData<List<HealthLog>>;

    if (!reportsLoaded || !healthLogsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reports and health logs are still loading. Please try again shortly.'),
        ),
      );
      return;
    }

    final reports = (reportsState as AsyncData<List<Report>>).value;
    final healthLogs = (logsState as AsyncData<List<HealthLog>>).value;

    final args = ExportPageArgs(
      reports: reports,
      healthLogs: healthLogs,
      trendSeries: const <TrendMetricSeries>[], // TODO: derive aggregated trend series
    );

    context.push(RouteNames.export, extra: args);
  }
}
