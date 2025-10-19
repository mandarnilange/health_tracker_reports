import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
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
    final reportsState = ref.watch(reportsProvider);
    final healthLogsState = ref.watch(healthLogsProvider);

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
            onPressed: () =>
                _handleExportPressed(context, reportsState, healthLogsState),
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

  void _handleExportPressed(
    BuildContext context,
    AsyncValue<List<Report>> reportsState,
    AsyncValue<List<HealthLog>> healthLogsState,
  ) {
    final isLoading = reportsState.isLoading || healthLogsState.isLoading;

    if (isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reports and health logs are still loading. Please try again shortly.'),
        ),
      );
      return;
    }

    final hasError = reportsState.hasError || healthLogsState.hasError;
    if (hasError) {
      final errorMessage = reportsState.error?.toString() ??
          healthLogsState.error?.toString() ??
          'Unable to load data for export.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
      return;
    }

    final reports = reportsState.value ?? const <Report>[];
    final healthLogs = healthLogsState.value ?? const <HealthLog>[];

    final args = ExportPageArgs(
      reports: reports,
      healthLogs: healthLogs,
      trendSeries: _buildTrendSeries(reports, healthLogs),
    );

    context.push(RouteNames.export, extra: args);
  }

  List<TrendMetricSeries> _buildTrendSeries(
    List<Report> reports,
    List<HealthLog> healthLogs,
  ) {
    final biomarkerSeries = <String, List<TrendMetricPoint>>{};

    for (final report in reports) {
      for (final biomarker in report.biomarkers) {
        final points = biomarkerSeries.putIfAbsent(biomarker.name, () => []);
        points.add(
          TrendMetricPoint(
            timestamp: biomarker.measuredAt,
            value: biomarker.value,
            unit: biomarker.unit,
            isOutOfRange: biomarker.isOutOfRange,
          ),
        );
      }
    }

    final vitalSeries = <VitalType, List<TrendMetricPoint>>{};
    for (final log in healthLogs) {
      for (final vital in log.vitals) {
        final points = vitalSeries.putIfAbsent(vital.type, () => []);
        points.add(
          TrendMetricPoint(
            timestamp: log.timestamp,
            value: vital.value,
            unit: vital.unit,
            isOutOfRange: vital.isOutOfRange,
          ),
        );
      }
    }

    List<TrendMetricSeries> buildSeriesFromMap<K>(
      Map<K, List<TrendMetricPoint>> map,
      TrendMetricType type,
      String Function(K key) nameBuilder,
    ) {
      return map.entries.map((entry) {
        entry.value.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return TrendMetricSeries(
          type: type,
          name: nameBuilder(entry.key),
          points: List.unmodifiable(entry.value),
        );
      }).toList(growable: false);
    }

    return [
      ...buildSeriesFromMap(
        biomarkerSeries,
        TrendMetricType.biomarker,
        (key) => key,
      ),
      ...buildSeriesFromMap(
        vitalSeries,
        TrendMetricType.vital,
        (type) => type.displayName,
      ),
    ];
  }
}
