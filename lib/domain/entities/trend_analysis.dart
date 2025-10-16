import 'package:equatable/equatable.dart';

/// Represents the analysis of a biomarker trend over time.
///
/// This entity captures the direction and magnitude of change for a biomarker
/// across multiple measurements, providing insights into how the biomarker
/// is changing over time.
class TrendAnalysis extends Equatable {
  /// Direction of the trend (increasing, decreasing, or stable)
  final TrendDirection direction;

  /// Percentage change from first to last value
  ///
  /// Calculated as: ((last - first) / first) * 100
  final double percentageChange;

  /// First value in the trend data series
  final double firstValue;

  /// Last value in the trend data series
  final double lastValue;

  /// Number of data points used to calculate this trend
  final int dataPointsCount;

  /// Creates a [TrendAnalysis] with the given properties.
  const TrendAnalysis({
    required this.direction,
    required this.percentageChange,
    required this.firstValue,
    required this.lastValue,
    required this.dataPointsCount,
  });

  /// Gets the absolute change between the last and first values.
  ///
  /// Returns a positive value for increasing trends and negative for decreasing.
  double get absoluteChange => lastValue - firstValue;

  /// Checks if the percentage change is significant (> 5% or < -5%).
  ///
  /// A change is considered significant if it exceeds +/- 5% threshold.
  bool get isSignificantChange =>
      percentageChange > 5.0 || percentageChange < -5.0;

  /// Creates a copy of this trend analysis with the given fields replaced with new values.
  TrendAnalysis copyWith({
    TrendDirection? direction,
    double? percentageChange,
    double? firstValue,
    double? lastValue,
    int? dataPointsCount,
  }) {
    return TrendAnalysis(
      direction: direction ?? this.direction,
      percentageChange: percentageChange ?? this.percentageChange,
      firstValue: firstValue ?? this.firstValue,
      lastValue: lastValue ?? this.lastValue,
      dataPointsCount: dataPointsCount ?? this.dataPointsCount,
    );
  }

  @override
  List<Object?> get props => [
        direction,
        percentageChange,
        firstValue,
        lastValue,
        dataPointsCount,
      ];
}

/// Represents the direction of a biomarker trend.
enum TrendDirection {
  /// Value is increasing over time (percentage change > 5%)
  increasing,

  /// Value is decreasing over time (percentage change < -5%)
  decreasing,

  /// Value is relatively stable over time (percentage change between -5% and 5%)
  stable,
}
