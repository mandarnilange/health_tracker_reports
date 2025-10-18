import 'package:equatable/equatable.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';

/// Summary statistics for a set of vital sign measurements.
class VitalStatistics extends Equatable {
  /// Average value across all measurements.
  final double average;

  /// Minimum value in the series.
  final double min;

  /// Maximum value in the series.
  final double max;

  /// Value of the first measurement (oldest).
  final double firstValue;

  /// Value of the most recent measurement.
  final double lastValue;

  /// Total number of measurements analysed.
  final int count;

  /// Percentage change between first and last values.
  final double percentageChange;

  /// Direction of change between first and last values.
  final TrendDirection trendDirection;

  const VitalStatistics({
    required this.average,
    required this.min,
    required this.max,
    required this.firstValue,
    required this.lastValue,
    required this.count,
    required this.percentageChange,
    required this.trendDirection,
  });

  /// Convenience getter for absolute change between last and first values.
  double get absoluteChange => lastValue - firstValue;

  @override
  List<Object?> get props => [
        average,
        min,
        max,
        firstValue,
        lastValue,
        count,
        percentageChange,
        trendDirection,
      ];
}
