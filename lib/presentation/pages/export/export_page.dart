import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';
import 'package:health_tracker_reports/presentation/providers/export_provider.dart';

/// Export hub page that exposes CSV export actions for reports, vitals, and trends.
class ExportPage extends ConsumerWidget {
  const ExportPage({
    super.key,
    required this.reports,
    required this.healthLogs,
    required this.trendSeries,
  });

  final List<Report> reports;
  final List<HealthLog> healthLogs;
  final List<TrendMetricSeries> trendSeries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ExportState>(
      exportNotifierProvider,
      (previous, next) {
        if (previous?.status == next.status) {
          return;
        }

        if (next.status == ExportStatus.success && next.results.isNotEmpty) {
          final message = next.results
              .map((result) => 'Saved to: ${result.path}')
              .join('\n');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } else if (next.status == ExportStatus.error && next.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.failure!.message)),
          );
        }
      },
    );

    final exportState = ref.watch(exportNotifierProvider);
    final notifier = ref.read(exportNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _ExportButton(
              label: 'Export Reports CSV',
              icon: Icons.description_outlined,
              onPressed: () =>
                  notifier.exportReports(List<Report>.from(reports)),
            ),
            const SizedBox(height: 12),
            _ExportButton(
              label: 'Export Vitals CSV',
              icon: Icons.favorite_outline,
              onPressed: () =>
                  notifier.exportVitals(List<HealthLog>.from(healthLogs)),
            ),
            const SizedBox(height: 12),
            _ExportButton(
              label: 'Export Trends CSV',
              icon: Icons.show_chart,
              onPressed: () =>
                  notifier.exportTrends(List<TrendMetricSeries>.from(trendSeries)),
            ),
            const SizedBox(height: 24),
            _ExportButton.filled(
              label: 'Export All CSVs',
              icon: Icons.cloud_download_outlined,
              onPressed: () => notifier.exportAll(
                reports: List<Report>.from(reports),
                healthLogs: List<HealthLog>.from(healthLogs),
                trends: List<TrendMetricSeries>.from(trendSeries),
              ),
            ),
            const SizedBox(height: 24),
            if (exportState.status == ExportStatus.inProgress)
              _ProgressIndicator(state: exportState),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    bool isFilled = false,
  }) : _isFilled = isFilled;

  const _ExportButton.filled({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) : this(
          label: label,
          icon: icon,
          onPressed: onPressed,
          isFilled: true,
        );

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool _isFilled;

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Text(label),
      ],
    );

    return _isFilled
        ? SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              child: buttonChild,
            ),
          )
        : SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onPressed,
              child: buttonChild,
            ),
          );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.state});

  final ExportState state;

  @override
  Widget build(BuildContext context) {
    final percent = (state.progress * 100).clamp(0, 100).round();
    final progressText = state.total > 0
        ? 'Exporting ${state.completed} of ${state.total} files ($percent%)…'
        : 'Preparing exports…';

    return Column(
      children: [
        CircularProgressIndicator(
          value: state.total > 0 ? state.progress.clamp(0, 1) : null,
        ),
        const SizedBox(height: 12),
        Text(progressText, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
