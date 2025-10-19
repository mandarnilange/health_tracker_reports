import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_statistics.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/biomarker_selector.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/time_range_selector.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/trend_chart.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:health_tracker_reports/presentation/providers/trend_provider.dart';
import 'package:health_tracker_reports/presentation/providers/vital_trend_provider.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:health_tracker_reports/presentation/widgets/trend_indicator.dart';
import 'package:intl/intl.dart';

/// Trends page that displays biomarker and vital trends over time.
///
/// This page allows users to:
/// - Switch between Biomarkers and Vitals tabs
/// - Select a biomarker to view trends for
/// - Select a vital type to view trends for
/// - Choose a time range (3M, 6M, 1Y, All) for biomarkers
/// - View charts showing values over time
/// - View statistics for vitals
class TrendsPage extends ConsumerStatefulWidget {
  const TrendsPage({super.key});

  @override
  ConsumerState<TrendsPage> createState() => _TrendsPageState();
}

class _TrendsPageState extends ConsumerState<TrendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'Compare Reports',
            onPressed: () {
              context.push(RouteNames.comparison);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Biomarkers'),
            Tab(text: 'Vitals'),
          ],
        ),
      ),
      body: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return _buildEmptyState(context);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBiomarkersTab(context),
              _buildVitalsTab(context),
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

  /// Builds the biomarkers tab content
  Widget _buildBiomarkersTab(BuildContext context) {
    final trendState = ref.watch(trendProvider);
    final availableBiomarkers = ref.watch(availableBiomarkersProvider);
    final trendDataAsync = trendState.trendData;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        BiomarkerSelector(
          biomarkerNames: availableBiomarkers,
          selectedBiomarker: trendState.selectedBiomarkerName,
          onBiomarkerSelected: (biomarkerName) {
            ref.read(trendProvider.notifier).selectBiomarker(biomarkerName);
          },
        ),
        const SizedBox(height: 16),
        TimeRangeSelector(
          selectedTimeRange: trendState.selectedTimeRange,
          onTimeRangeSelected: (timeRange) {
            ref.read(trendProvider.notifier).selectTimeRange(timeRange);
          },
        ),
        const SizedBox(height: 16),
        _buildBiomarkerChartContainer(
          context: context,
          trendState: trendState,
          trendDataAsync: trendDataAsync,
        ),
      ],
    );
  }

  /// Builds the vitals tab content
  Widget _buildVitalsTab(BuildContext context) {
    final selectedVitalType = ref.watch(selectedVitalTypeProvider);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildVitalTypeSelector(context, selectedVitalType),
        const SizedBox(height: 16),
        if (selectedVitalType != null) ...[
          _buildVitalTrendContainer(context, selectedVitalType),
          const SizedBox(height: 16),
          _buildVitalStatisticsCard(context, selectedVitalType),
        ] else
          _buildVitalEmptyState(context),
      ],
    );
  }

  /// Builds the vital type dropdown selector
  Widget _buildVitalTypeSelector(BuildContext context, VitalType? selectedType) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Vital',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButton<VitalType>(
              value: selectedType,
              isExpanded: true,
              hint: const Text('Choose a vital type'),
              items: VitalType.values.map((type) {
                return DropdownMenuItem<VitalType>(
                  value: type,
                  child: Row(
                    children: [
                      Text(type.icon),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (VitalType? newValue) {
                ref.read(selectedVitalTypeProvider.notifier).state = newValue;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the vital trend chart container
  Widget _buildVitalTrendContainer(BuildContext context, VitalType vitalType) {
    final trendDataAsync = ref.watch(vitalTrendProvider(vitalType));

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
      data: (measurements) {
        if (measurements.isEmpty) {
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
                    'No data found for ${vitalType.displayName}',
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

        // Convert VitalMeasurements to TrendDataPoints for the chart
        // Note: VitalMeasurements don't have dates, so we need to get them from HealthLogs
        // For now, we'll create dummy dates based on index
        final trendDataPoints = measurements.asMap().entries.map((entry) {
          final index = entry.key;
          final measurement = entry.value;
          // Create dates going backwards from today
          final date = DateTime.now().subtract(Duration(days: index * 7));

          // Convert VitalStatus to BiomarkerStatus for chart compatibility
          final biomarkerStatus = _convertVitalStatusToBiomarkerStatus(measurement.status);

          return TrendDataPoint(
            date: date,
            value: measurement.value,
            unit: measurement.unit,
            referenceRange: measurement.referenceRange,
            reportId: measurement.id,
            status: biomarkerStatus,
          );
        }).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                vitalType.displayName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${measurements.length} data point${measurements.length > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        measurements.first.unit,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 320,
                  child: TrendChart(dataPoints: trendDataPoints),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the vital statistics card
  Widget _buildVitalStatisticsCard(BuildContext context, VitalType vitalType) {
    final statsAsync = ref.watch(vitalStatisticsProvider(vitalType));

    return statsAsync.when(
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  'Calculating statistics...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
      data: (stats) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Average',
                        stats.average.toStringAsFixed(1),
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Min',
                        stats.min.toStringAsFixed(1),
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Max',
                        stats.max.toStringAsFixed(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Trend',
                        _getTrendDirectionSymbol(stats.trendDirection),
                        color: _getTrendDirectionColor(
                          context,
                          stats.trendDirection,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Count',
                        '${stats.count} measurement${stats.count > 1 ? 's' : ''}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a single statistics item
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
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
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  /// Gets the symbol for a trend direction
  String _getTrendDirectionSymbol(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return '↑ Increasing';
      case TrendDirection.decreasing:
        return '↓ Decreasing';
      case TrendDirection.stable:
        return '→ Stable';
    }
  }

  /// Gets the color for a trend direction
  Color _getTrendDirectionColor(BuildContext context, TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return Colors.red;
      case TrendDirection.decreasing:
        return Colors.blue;
      case TrendDirection.stable:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  /// Builds the empty state for vitals tab when no vital is selected
  Widget _buildVitalEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a vital',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a vital from the dropdown above to view its trend',
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

  /// Converts VitalStatus to BiomarkerStatus for chart compatibility
  BiomarkerStatus _convertVitalStatusToBiomarkerStatus(VitalStatus status) {
    switch (status) {
      case VitalStatus.normal:
        return BiomarkerStatus.normal;
      case VitalStatus.warning:
        return BiomarkerStatus.high;
      case VitalStatus.critical:
        return BiomarkerStatus.high;
    }
  }

  /// Builds the biomarker chart container with trend data visualization
  Widget _buildBiomarkerChartContainer({
    required BuildContext context,
    required TrendState trendState,
    required AsyncValue<List<TrendDataPoint>> trendDataAsync,
  }) {
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
