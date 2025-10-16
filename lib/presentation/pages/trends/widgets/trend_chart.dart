import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/biomarker.dart';
import '../../../../domain/entities/trend_data_point.dart';

/// A widget that displays biomarker trend data as a line chart.
///
/// This chart visualizes biomarker values over time with:
/// - Data points plotted with color coding based on status
/// - Reference range bands showing the normal range
/// - Interactive tooltips showing date, value, and unit
/// - Formatted axes for dates and values
class TrendChart extends StatelessWidget {
  /// List of trend data points to display
  final List<TrendDataPoint> dataPoints;

  const TrendChart({
    super.key,
    required this.dataPoints,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort data points by date for proper line chart rendering
    final sortedData = List<TrendDataPoint>.from(dataPoints)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Semantics(
      label: 'Biomarker trend chart showing ${dataPoints.length} data points',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: LineChart(
            _createLineChartData(context, sortedData),
          ),
        ),
      ),
    );
  }

  /// Builds the empty state when no data is available
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No trend data available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  /// Creates the LineChartData configuration for fl_chart
  LineChartData _createLineChartData(
    BuildContext context,
    List<TrendDataPoint> sortedData,
  ) {
    return LineChartData(
      lineBarsData: [_createLineChartBarData(context, sortedData)],
      titlesData: _createTitlesData(context, sortedData),
      gridData: _createGridData(context),
      borderData: _createBorderData(context),
      lineTouchData: _createLineTouchData(context, sortedData),
      extraLinesData: _createExtraLinesData(context, sortedData),
      minY: _calculateMinY(sortedData),
      maxY: _calculateMaxY(sortedData),
      minX: 0,
      maxX: (sortedData.length - 1).toDouble(),
    );
  }

  /// Creates the main line bar data with data spots
  LineChartBarData _createLineChartBarData(
    BuildContext context,
    List<TrendDataPoint> sortedData,
  ) {
    return LineChartBarData(
      spots: sortedData
          .asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
          .toList(),
      isCurved: true,
      color: Theme.of(context).colorScheme.primary,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 6,
            color: _getColorForStatus(context, sortedData[index].status),
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  /// Creates the titles configuration for axes
  FlTitlesData _createTitlesData(
    BuildContext context,
    List<TrendDataPoint> sortedData,
  ) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= sortedData.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _formatDateForAxis(sortedData[index].date),
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  /// Creates the grid configuration
  FlGridData _createGridData(BuildContext context) {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      drawHorizontalLine: true,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          strokeWidth: 1,
        );
      },
    );
  }

  /// Creates the border configuration
  FlBorderData _createBorderData(BuildContext context) {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  /// Creates the touch/tooltip configuration
  LineTouchData _createLineTouchData(
    BuildContext context,
    List<TrendDataPoint> sortedData,
  ) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.surface,
        tooltipBorder: BorderSide(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            final index = touchedSpot.x.toInt();
            if (index < 0 || index >= sortedData.length) {
              return null;
            }

            final dataPoint = sortedData[index];
            final dateStr = DateFormat('MMM dd, yyyy').format(dataPoint.date);
            final valueStr =
                '${dataPoint.value.toStringAsFixed(1)} ${dataPoint.unit}';

            return LineTooltipItem(
              '$dateStr\n$valueStr',
              TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  /// Creates the extra lines for reference range visualization
  ExtraLinesData _createExtraLinesData(
    BuildContext context,
    List<TrendDataPoint> sortedData,
  ) {
    // Get reference range from first data point (assuming all have same range)
    final referenceRange = sortedData.first.referenceRange;
    if (referenceRange == null) {
      return ExtraLinesData(horizontalLines: []);
    }

    return ExtraLinesData(
      horizontalLines: [
        // Minimum reference line
        HorizontalLine(
          y: referenceRange.min,
          color: Colors.green.withOpacity(0.5),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 5, bottom: 5),
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            labelResolver: (line) => 'Min: ${line.y.toStringAsFixed(1)}',
          ),
        ),
        // Maximum reference line
        HorizontalLine(
          y: referenceRange.max,
          color: Colors.green.withOpacity(0.5),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.only(right: 5, top: 5),
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            labelResolver: (line) => 'Max: ${line.y.toStringAsFixed(1)}',
          ),
        ),
      ],
    );
  }

  /// Formats a date for display on the x-axis
  String _formatDateForAxis(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  /// Gets the appropriate color for a biomarker status
  Color _getColorForStatus(BuildContext context, BiomarkerStatus status) {
    switch (status) {
      case BiomarkerStatus.normal:
        return Colors.green;
      case BiomarkerStatus.high:
        return Colors.red;
      case BiomarkerStatus.low:
        return Colors.orange;
    }
  }

  /// Calculates the minimum Y value for the chart
  double _calculateMinY(List<TrendDataPoint> sortedData) {
    final minValue = sortedData.map((e) => e.value).reduce(
          (a, b) => a < b ? a : b,
        );
    final referenceMin = sortedData.first.referenceRange?.min;

    if (referenceMin != null) {
      final chartMin = minValue < referenceMin ? minValue : referenceMin;
      return chartMin - (chartMin * 0.1); // 10% padding below
    }

    return minValue - (minValue * 0.1);
  }

  /// Calculates the maximum Y value for the chart
  double _calculateMaxY(List<TrendDataPoint> sortedData) {
    final maxValue = sortedData.map((e) => e.value).reduce(
          (a, b) => a > b ? a : b,
        );
    final referenceMax = sortedData.first.referenceRange?.max;

    if (referenceMax != null) {
      final chartMax = maxValue > referenceMax ? maxValue : referenceMax;
      return chartMax + (chartMax * 0.1); // 10% padding above
    }

    return maxValue + (maxValue * 0.1);
  }
}
