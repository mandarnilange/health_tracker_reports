import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/biomarker_selector.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/time_range_selector.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/trend_chart.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:health_tracker_reports/presentation/providers/trend_provider.dart';
import 'package:health_tracker_reports/presentation/widgets/trend_indicator.dart';
import 'package:intl/intl.dart';

/// Trends page that displays biomarker trends over time.
///
/// This page allows users to:
/// - Select a biomarker to view trends for
/// - Choose a time range (3M, 6M, 1Y, All)
/// - View a chart showing the biomarker's values over time
class TrendsPage extends ConsumerWidget {
  const TrendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);
    final trendState = ref.watch(trendProvider);
    final availableBiomarkers = ref.watch(availableBiomarkersProvider);
    final trendDataAsync = trendState.trendData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trends'),
      ),
      body: reportsAsync.when(
        data: (reports) {
          // Check if there are any reports
          if (reports.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Biomarker Selector
              BiomarkerSelector(
                biomarkerNames: availableBiomarkers,
                selectedBiomarker: trendState.selectedBiomarkerName,
                onBiomarkerSelected: (biomarkerName) {
                  ref
                      .read(trendProvider.notifier)
                      .selectBiomarker(biomarkerName);
                },
              ),
              const SizedBox(height: 16),

              // Time Range Selector
              TimeRangeSelector(
                selectedTimeRange: trendState.selectedTimeRange,
                onTimeRangeSelected: (timeRange) {
                  ref.read(trendProvider.notifier).selectTimeRange(timeRange);
                },
              ),
              const SizedBox(height: 16),

              // Chart Container
              _buildChartContainer(
                context: context,
                trendState: trendState,
                trendDataAsync: trendDataAsync,
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

  /// Builds the chart container with trend data visualization
  Widget _buildChartContainer({
    required BuildContext context,
    required TrendState trendState,
    required AsyncValue<List<TrendDataPoint>> trendDataAsync,
  }) {
    // If no biomarker is selected
    if (trendState.selectedBiomarkerName == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Select a biomarker',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a biomarker from the dropdown above to view its trend',
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

    return trendDataAsync.when(
      loading: () => Card(
        child: SizedBox(
          height: 320,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading trend data...',
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load trend data',
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
      data: (trendData) {
        if (trendData.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.data_usage,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No data found for ${trendState.selectedBiomarkerName} in the selected time range',
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

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart header
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
                                trendState.selectedBiomarkerName!,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (trendState.trendAnalysis != null) ...[
                                const SizedBox(width: 12),
                                TrendIndicator(
                                  trendAnalysis: trendState.trendAnalysis!,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${trendData.length} data point${trendData.length > 1 ? 's' : ''}',
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
                    Chip(
                      label: Text(
                        trendData.first.unit,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 320,
                  child: TrendChart(dataPoints: trendData),
                ),
                const SizedBox(height: 16),

                // Data points summary
                _buildDataPointsSummary(context, trendData),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a summary of data points
  Widget _buildDataPointsSummary(
    BuildContext context,
    List<TrendDataPoint> trendData,
  ) {
    if (trendData.isEmpty) return const SizedBox.shrink();

    final dateFormat = DateFormat('MMM dd, yyyy');
    final latestPoint = trendData.last;
    final earliestPoint = trendData.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Latest',
                '${latestPoint.value} ${latestPoint.unit}',
                dateFormat.format(latestPoint.date),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Earliest',
                '${earliestPoint.value} ${earliestPoint.unit}',
                dateFormat.format(earliestPoint.date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a summary card for a data point
  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    String date,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty state when no reports are available
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
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
              'Upload some reports to start tracking biomarker trends',
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

  /// Builds the error state
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
}
