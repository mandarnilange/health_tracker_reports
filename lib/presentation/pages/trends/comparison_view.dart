import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_comparison.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/biomarker_selector.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/comparison_table.dart';
import 'package:health_tracker_reports/presentation/providers/comparison_provider.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:health_tracker_reports/presentation/providers/trend_provider.dart';

/// Page for comparing a specific biomarker across multiple reports.
///
/// This page allows users to:
/// - Select multiple reports to compare
/// - Choose a biomarker to compare across the selected reports
/// - View a comparison table showing values, changes, and trends
class ComparisonView extends ConsumerWidget {
  const ComparisonView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);
    final comparisonState = ref.watch(comparisonProvider);
    final availableBiomarkers = ref.watch(availableBiomarkersProvider);
    final comparisonDataAsync = comparisonState.comparisonData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Reports'),
        actions: [
          if (comparisonState.selectedReportIds.isNotEmpty ||
              comparisonState.selectedBiomarkerName != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear selection',
              onPressed: () {
                ref.read(comparisonProvider.notifier).clearSelection();
              },
            ),
        ],
      ),
      body: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Report Selector Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Reports',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose at least 2 reports to compare',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...reports.map((report) {
                        final isSelected = comparisonState.selectedReportIds
                            .contains(report.id);
                        return CheckboxListTile(
                          dense: true,
                          value: isSelected,
                          title: Text(
                            '${report.labName} - ${_formatDate(report.date)}',
                          ),
                          subtitle: Text(
                            '${report.biomarkers.length} biomarkers',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onChanged: (value) {
                            ref
                                .read(comparisonProvider.notifier)
                                .toggleReportSelection(report.id);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Biomarker Selector
              BiomarkerSelector(
                biomarkerNames: availableBiomarkers,
                selectedBiomarker: comparisonState.selectedBiomarkerName,
                onBiomarkerSelected: (biomarkerName) {
                  ref
                      .read(comparisonProvider.notifier)
                      .selectBiomarker(biomarkerName);
                  if (biomarkerName != null) {
                    ref.read(comparisonProvider.notifier).loadComparison();
                  }
                },
              ),
              const SizedBox(height: 16),

              // Comparison Table or Info
              _buildComparisonContainer(
                context: context,
                ref: ref,
                comparisonState: comparisonState,
                comparisonDataAsync: comparisonDataAsync,
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildComparisonContainer({
    required BuildContext context,
    required WidgetRef ref,
    required ComparisonState comparisonState,
    required AsyncValue<BiomarkerComparison?> comparisonDataAsync,
  }) {
    // No biomarker selected
    if (comparisonState.selectedBiomarkerName == null) {
      return _buildInfoCard(
        context: context,
        icon: Icons.biotech,
        title: 'Select a biomarker',
        message:
            'Choose a biomarker from the dropdown above to compare across reports',
      );
    }

    // No reports selected
    if (comparisonState.selectedReportIds.isEmpty) {
      return _buildInfoCard(
        context: context,
        icon: Icons.checklist,
        title: 'Select reports',
        message: 'Choose at least 2 reports to compare',
      );
    }

    // Less than 2 reports selected
    if (comparisonState.selectedReportIds.length < 2) {
      return _buildInfoCard(
        context: context,
        icon: Icons.numbers,
        title: 'Need more reports',
        message:
            'Select at least one more report to compare (${comparisonState.selectedReportIds.length}/2)',
      );
    }

    // Show comparison data
    return comparisonDataAsync.when(
      loading: () => Card(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading comparison data...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load comparison',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error is Failure ? error.message : error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      data: (comparison) {
        if (comparison == null) {
          return _buildInfoCard(
            context: context,
            icon: Icons.compare_arrows,
            title: 'Ready to compare',
            message: 'Click "Load Comparison" to view the comparison table',
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comparison.biomarkerName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 12),
                              _buildTrendChip(context, comparison.overallTrend),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${comparison.comparisons.length} report${comparison.comparisons.length > 1 ? 's' : ''}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Comparison Table
                ComparisonTable(comparison: comparison),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendChip(BuildContext context, TrendDirection trendDirection) {
    final String label;
    final IconData icon;
    final Color color;

    switch (trendDirection) {
      case TrendDirection.increasing:
        label = 'Increasing';
        icon = Icons.trending_up;
        color = Colors.red;
      case TrendDirection.decreasing:
        label = 'Decreasing';
        icon = Icons.trending_down;
        color = Colors.green;
      case TrendDirection.stable:
        label = 'Stable';
        icon = Icons.trending_flat;
        color = Colors.blue;
      case TrendDirection.fluctuating:
        label = 'Fluctuating';
        icon = Icons.show_chart;
        color = Colors.orange;
      case TrendDirection.insufficient:
        label = 'Insufficient data';
        icon = Icons.remove;
        color = Colors.grey;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows,
              size: 96,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Upload some reports to start comparing biomarkers',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
