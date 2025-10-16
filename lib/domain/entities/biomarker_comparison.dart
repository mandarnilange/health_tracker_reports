import 'package:equatable/equatable.dart';
import 'biomarker.dart';

/// Represents the overall trend direction for a biomarker across multiple reports.
enum TrendDirection {
  /// Biomarker values are consistently increasing over time
  increasing,

  /// Biomarker values are consistently decreasing over time
  decreasing,

  /// Biomarker values remain relatively stable (within expected variance)
  stable,

  /// Biomarker values show no clear pattern (up and down)
  fluctuating,

  /// Not enough data points to determine a trend (less than 2 points)
  insufficient,
}

/// Represents a single data point in a biomarker comparison across multiple reports.
///
/// Contains the biomarker value from a specific report, along with calculated
/// deltas and percentage changes from the previous report in the chronological sequence.
class ComparisonDataPoint extends Equatable {
  /// ID of the report this data point came from
  final String reportId;

  /// Date of the report
  final DateTime reportDate;

  /// Measured value of the biomarker
  final double value;

  /// Unit of measurement (e.g., "g/dL", "mg/dL", "mmol/L")
  final String unit;

  /// Status of this biomarker value relative to its reference range
  final BiomarkerStatus status;

  /// Difference from the previous report's value (null for first report)
  final double? deltaFromPrevious;

  /// Percentage change from the previous report's value (null for first report)
  final double? percentageChangeFromPrevious;

  /// Creates a [ComparisonDataPoint] with the given properties.
  const ComparisonDataPoint({
    required this.reportId,
    required this.reportDate,
    required this.value,
    required this.unit,
    required this.status,
    required this.deltaFromPrevious,
    required this.percentageChangeFromPrevious,
  });

  /// Creates a copy of this data point with the given fields replaced with new values.
  ComparisonDataPoint copyWith({
    String? reportId,
    DateTime? reportDate,
    double? value,
    String? unit,
    BiomarkerStatus? status,
    double? deltaFromPrevious,
    double? percentageChangeFromPrevious,
  }) {
    return ComparisonDataPoint(
      reportId: reportId ?? this.reportId,
      reportDate: reportDate ?? this.reportDate,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      deltaFromPrevious: deltaFromPrevious ?? this.deltaFromPrevious,
      percentageChangeFromPrevious:
          percentageChangeFromPrevious ?? this.percentageChangeFromPrevious,
    );
  }

  @override
  List<Object?> get props => [
        reportId,
        reportDate,
        value,
        unit,
        status,
        deltaFromPrevious,
        percentageChangeFromPrevious,
      ];
}

/// Represents a comparison of a specific biomarker across multiple reports.
///
/// Contains all comparison data points sorted chronologically, along with
/// calculated deltas, percentage changes, and an overall trend direction.
class BiomarkerComparison extends Equatable {
  /// Name of the biomarker being compared (normalized name)
  final String biomarkerName;

  /// List of comparison data points, sorted chronologically by report date
  final List<ComparisonDataPoint> comparisons;

  /// Overall trend direction across all data points
  final TrendDirection overallTrend;

  /// Creates a [BiomarkerComparison] with the given properties.
  const BiomarkerComparison({
    required this.biomarkerName,
    required this.comparisons,
    required this.overallTrend,
  });

  /// Creates a copy of this comparison with the given fields replaced with new values.
  BiomarkerComparison copyWith({
    String? biomarkerName,
    List<ComparisonDataPoint>? comparisons,
    TrendDirection? overallTrend,
  }) {
    return BiomarkerComparison(
      biomarkerName: biomarkerName ?? this.biomarkerName,
      comparisons: comparisons ?? this.comparisons,
      overallTrend: overallTrend ?? this.overallTrend,
    );
  }

  @override
  List<Object?> get props => [biomarkerName, comparisons, overallTrend];
}
