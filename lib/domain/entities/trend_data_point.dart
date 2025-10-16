import 'package:equatable/equatable.dart';
import 'biomarker.dart';
import 'reference_range.dart';

/// Represents a single data point in a biomarker trend over time.
///
/// A trend data point captures the value of a specific biomarker at a particular
/// date, along with metadata about its status and which report it came from.
/// This is used to visualize biomarker trends across multiple lab reports.
class TrendDataPoint extends Equatable {
  /// Date when this measurement was taken
  final DateTime date;

  /// Measured value of the biomarker
  final double value;

  /// Unit of measurement (e.g., "g/dL", "mg/dL", "mmol/L")
  final String unit;

  /// Reference range (normal range) for this biomarker
  final ReferenceRange? referenceRange;

  /// ID of the report this data point came from
  final String reportId;

  /// Status of this biomarker value relative to its reference range
  final BiomarkerStatus status;

  /// Creates a [TrendDataPoint] with the given properties.
  const TrendDataPoint({
    required this.date,
    required this.value,
    required this.unit,
    this.referenceRange,
    required this.reportId,
    required this.status,
  });

  /// Creates a [TrendDataPoint] from a [Biomarker] and report metadata.
  ///
  /// This factory constructor simplifies creating trend data points
  /// from biomarkers found in reports.
  factory TrendDataPoint.fromBiomarker({
    required Biomarker biomarker,
    required DateTime date,
    required String reportId,
  }) {
    return TrendDataPoint(
      date: date,
      value: biomarker.value,
      unit: biomarker.unit,
      referenceRange: biomarker.referenceRange,
      reportId: reportId,
      status: biomarker.status,
    );
  }

  /// Creates a copy of this trend data point with the given fields replaced with new values.
  TrendDataPoint copyWith({
    DateTime? date,
    double? value,
    String? unit,
    ReferenceRange? referenceRange,
    String? reportId,
    BiomarkerStatus? status,
  }) {
    return TrendDataPoint(
      date: date ?? this.date,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      referenceRange: referenceRange ?? this.referenceRange,
      reportId: reportId ?? this.reportId,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        date,
        value,
        unit,
        referenceRange,
        reportId,
        status,
      ];
}
