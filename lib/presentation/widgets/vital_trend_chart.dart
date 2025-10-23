import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reference_range.dart';
import '../../domain/entities/vital_measurement.dart';

/// A chart widget that displays vital sign trends over time.
///
/// This widget uses fl_chart to visualize vital measurements with:
/// - Line chart for trend visualization
/// - Reference range bands (if applicable)
/// - Color-coded points based on status (normal/warning/critical)
/// - Dual-line chart for blood pressure (systolic + diastolic)
/// - Touch interactions with tooltips
/// - Optional statistics (average, min/max, trend indicator)
class VitalTrendChart extends StatelessWidget {
  /// The vital measurements to display
  final List<VitalMeasurement> measurements;

  /// The type of vital being displayed
  final VitalType vitalType;

  /// The dates corresponding to each measurement
  final List<DateTime> dates;

  /// Whether to show statistics (average, min/max, trend)
  final bool showStatistics;

  /// Creates a [VitalTrendChart] with the given parameters.
  const VitalTrendChart({
    super.key,
    required this.measurements,
    required this.vitalType,
    required this.dates,
    this.showStatistics = false,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return _buildEmptyState();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Vital trend chart for ${vitalType.displayName}',
      child: Column(
        children: [
          if (_isBloodPressure) _buildLegend(colorScheme),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                _buildLineChartData(colorScheme),
              ),
            ),
          ),
          if (showStatistics) _buildStatistics(colorScheme),
        ],
      ),
    );
  }

  /// Builds the empty state widget when there's no data.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the legend for blood pressure dual lines.
  Widget _buildLegend(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(
            color: Colors.red[600]!,
            label: 'Systolic',
          ),
          const SizedBox(width: 24),
          _LegendItem(
            color: Colors.blue[600]!,
            label: 'Diastolic',
          ),
        ],
      ),
    );
  }

  /// Builds the statistics display (average, min/max, trend).
  Widget _buildStatistics(ColorScheme colorScheme) {
    final values = measurements.map((m) => m.value).toList();
    final average = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    // Calculate trend (simple: compare first and last values)
    final trend = measurements.last.value - measurements.first.value;
    final isIncreasing = trend > 0;
    final trendIcon = isIncreasing ? Icons.arrow_upward : Icons.arrow_downward;
    final trendColor = isIncreasing ? Colors.red[600] : Colors.green[600];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Avg',
            value: average.toStringAsFixed(1),
            unit: measurements.first.unit,
          ),
          _StatItem(
            label: 'Min',
            value: min.toStringAsFixed(1),
            unit: measurements.first.unit,
          ),
          _StatItem(
            label: 'Max',
            value: max.toStringAsFixed(1),
            unit: measurements.first.unit,
          ),
          Row(
            children: [
              Icon(trendIcon, color: trendColor, size: 20),
              const SizedBox(width: 4),
              Text(
                'Trend',
                style: TextStyle(
                  color: trendColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the line chart data configuration.
  LineChartData _buildLineChartData(ColorScheme colorScheme) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _calculateInterval(),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: _buildTitlesData(colorScheme),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      lineBarsData: _buildLineBarsData(colorScheme),
      extraLinesData: _buildExtraLinesData(colorScheme),
      lineTouchData: _buildTouchData(colorScheme),
      minX: dates.first.millisecondsSinceEpoch.toDouble(),
      maxX: dates.last.millisecondsSinceEpoch.toDouble(),
      minY: _calculateMinY(),
      maxY: _calculateMaxY(),
    );
  }

  /// Builds the titles configuration for axes.
  FlTitlesData _buildTitlesData(ColorScheme colorScheme) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: _calculateXInterval(),
          getTitlesWidget: (value, meta) {
            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
            final formattedDate = DateFormat('MM/dd').format(date);

            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                formattedDate,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
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
          reservedSize: 45,
          interval: _calculateInterval(),
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 10,
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

  /// Builds the line bars data (one or two lines).
  List<LineChartBarData> _buildLineBarsData(ColorScheme colorScheme) {
    if (_isBloodPressure) {
      return [
        _buildSystolicLine(colorScheme),
        _buildDiastolicLine(colorScheme),
      ];
    }

    return [_buildSingleLine(colorScheme)];
  }

  /// Builds a single line for non-BP vitals.
  LineChartBarData _buildSingleLine(ColorScheme colorScheme) {
    final spots = <FlSpot>[];
    for (int i = 0; i < measurements.length; i++) {
      spots.add(FlSpot(dates[i].millisecondsSinceEpoch.toDouble(), measurements[i].value));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: colorScheme.primary,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final status = measurements[index].status;
          final color = _getStatusColor(status);

          return FlDotCirclePainter(
            radius: 6,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: colorScheme.primary.withOpacity(0.1),
      ),
    );
  }

  /// Builds the systolic line for blood pressure.
  LineChartBarData _buildSystolicLine(ColorScheme colorScheme) {
    final spots = <FlSpot>[];
    final systolicMeasurements = <VitalMeasurement>[];

    for (int i = 0; i < measurements.length; i++) {
      if (measurements[i].type == VitalType.bloodPressureSystolic) {
        spots.add(FlSpot(
          dates[i].millisecondsSinceEpoch.toDouble(),
          measurements[i].value,
        ));
        systolicMeasurements.add(measurements[i]);
      }
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Colors.red[600],
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final status = systolicMeasurements[index].status;
          final color = _getStatusColor(status);

          return FlDotCirclePainter(
            radius: 6,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
    );
  }

  /// Builds the diastolic line for blood pressure.
  LineChartBarData _buildDiastolicLine(ColorScheme colorScheme) {
    final spots = <FlSpot>[];
    final diastolicMeasurements = <VitalMeasurement>[];

    for (int i = 0; i < measurements.length; i++) {
      if (measurements[i].type == VitalType.bloodPressureDiastolic) {
        spots.add(FlSpot(
          dates[i].millisecondsSinceEpoch.toDouble(),
          measurements[i].value,
        ));
        diastolicMeasurements.add(measurements[i]);
      }
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Colors.blue[600],
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final status = diastolicMeasurements[index].status;
          final color = _getStatusColor(status);

          return FlDotCirclePainter(
            radius: 6,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
    );
  }

  /// Builds extra lines for reference range and optional average.
  ExtraLinesData? _buildExtraLinesData(ColorScheme colorScheme) {
    final referenceRange = measurements.first.referenceRange;
    if (referenceRange == null) {
      // If showing statistics, add average line
      if (showStatistics) {
        final values = measurements.map((m) => m.value).toList();
        final average = values.reduce((a, b) => a + b) / values.length;

        return ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: average,
              color: colorScheme.secondary.withOpacity(0.5),
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (line) => 'Avg',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }
      return null;
    }

    final horizontalLines = <HorizontalLine>[
      HorizontalLine(
        y: referenceRange.min,
        color: Colors.green.withOpacity(0.3),
        strokeWidth: 1,
        dashArray: [3, 3],
      ),
      HorizontalLine(
        y: referenceRange.max,
        color: Colors.green.withOpacity(0.3),
        strokeWidth: 1,
        dashArray: [3, 3],
      ),
    ];

    // Add average line if showing statistics
    if (showStatistics) {
      final values = measurements.map((m) => m.value).toList();
      final average = values.reduce((a, b) => a + b) / values.length;

      horizontalLines.add(
        HorizontalLine(
          y: average,
          color: colorScheme.secondary.withOpacity(0.5),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: (line) => 'Avg',
            style: TextStyle(
              color: colorScheme.secondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return ExtraLinesData(horizontalLines: horizontalLines);
  }

  /// Builds touch interaction configuration.
  LineTouchData _buildTouchData(ColorScheme colorScheme) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => colorScheme.inverseSurface,
        tooltipBorder: BorderSide(
          color: colorScheme.outline,
          width: 1,
        ),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((touchedSpot) {
            final timestamp = touchedSpot.x;
            final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
            final formattedDate = DateFormat('MMM dd, yyyy').format(date);
            final value = touchedSpot.y;

            final unit = _isBloodPressure ? 'mmHg' : measurements.first.unit;
            final valueStr =
                '${value.toStringAsFixed(_isBloodPressure ? 0 : 1)} $unit';

            return LineTooltipItem(
              '$valueStr\n$formattedDate',
              TextStyle(
                color: colorScheme.onInverseSurface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  /// Gets the color for a given status.
  Color _getStatusColor(VitalStatus status) {
    switch (status) {
      case VitalStatus.normal:
        return Colors.green[600]!;
      case VitalStatus.warning:
        return Colors.orange[600]!;
      case VitalStatus.critical:
        return Colors.red[600]!;
    }
  }

  /// Calculates the minimum Y value for the chart.
  double _calculateMinY() {
    final values = measurements.map((m) => m.value).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final referenceRange = measurements.first.referenceRange;

    if (referenceRange != null) {
      return (minValue < referenceRange.min ? minValue : referenceRange.min) *
          0.9;
    }

    return minValue * 0.9;
  }

  /// Calculates the maximum Y value for the chart.
  double _calculateMaxY() {
    final values = measurements.map((m) => m.value).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final referenceRange = measurements.first.referenceRange;

    if (referenceRange != null) {
      return (maxValue > referenceRange.max ? maxValue : referenceRange.max) *
          1.1;
    }

    return maxValue * 1.1;
  }

  /// Calculates the Y-axis interval.
  double _calculateInterval() {
    final range = _calculateMaxY() - _calculateMinY();
    return (range / 5).ceilToDouble();
  }

  /// Calculates the X-axis interval for date labels.
  double _calculateXInterval() {
    if (dates.length < 2) {
      return const Duration(days: 1).inMilliseconds.toDouble();
    }
    final duration = dates.last.difference(dates.first);

    if (duration.inDays <= 7) {
      return const Duration(days: 1).inMilliseconds.toDouble();
    } else if (duration.inDays <= 14) {
      return const Duration(days: 2).inMilliseconds.toDouble();
    } else if (duration.inDays <= 30) {
      return const Duration(days: 5).inMilliseconds.toDouble();
    } else {
      return const Duration(days: 7).inMilliseconds.toDouble();
    }
  }

  /// Whether this is a blood pressure vital.
  bool get _isBloodPressure =>
      vitalType == VitalType.bloodPressureSystolic ||
      vitalType == VitalType.bloodPressureDiastolic;
}

/// A legend item for the chart.
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// A statistics item display.
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value $unit',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
