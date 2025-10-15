import 'package:equatable/equatable.dart';
import 'reference_range.dart';

/// Represents a biomarker (lab test parameter) with its value and reference range.
///
/// A biomarker is a measurable indicator of some biological state or condition.
/// Examples include Hemoglobin, Glucose, Cholesterol, etc.
class Biomarker extends Equatable {
  /// Unique identifier for this biomarker measurement
  final String id;

  /// Name of the biomarker (e.g., "Hemoglobin", "Glucose")
  final String name;

  /// Measured value of the biomarker
  final double value;

  /// Unit of measurement (e.g., "g/dL", "mg/dL", "mmol/L")
  final String unit;

  /// Reference range (normal range) for this biomarker
  final ReferenceRange referenceRange;

  /// Date and time when this biomarker was measured
  final DateTime measuredAt;

  /// Creates a [Biomarker] with the given properties.
  const Biomarker({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.referenceRange,
    required this.measuredAt,
  });

  /// Checks if this biomarker's value is outside the reference range.
  ///
  /// Returns `true` if the value is below min or above max of the reference range.
  bool get isOutOfRange => referenceRange.isOutOfRange(value);

  /// Gets the status of this biomarker based on its value and reference range.
  ///
  /// Returns:
  /// - [BiomarkerStatus.low] if value is below the minimum
  /// - [BiomarkerStatus.high] if value is above the maximum
  /// - [BiomarkerStatus.normal] if value is within the range
  BiomarkerStatus get status {
    if (value < referenceRange.min) {
      return BiomarkerStatus.low;
    } else if (value > referenceRange.max) {
      return BiomarkerStatus.high;
    } else {
      return BiomarkerStatus.normal;
    }
  }

  /// Creates a copy of this biomarker with the given fields replaced with new values.
  Biomarker copyWith({
    String? id,
    String? name,
    double? value,
    String? unit,
    ReferenceRange? referenceRange,
    DateTime? measuredAt,
  }) {
    return Biomarker(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      referenceRange: referenceRange ?? this.referenceRange,
      measuredAt: measuredAt ?? this.measuredAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, value, unit, referenceRange, measuredAt];
}

/// Represents the status of a biomarker value relative to its reference range.
enum BiomarkerStatus {
  /// Value is below the minimum of the reference range
  low,

  /// Value is within the reference range
  normal,

  /// Value is above the maximum of the reference range
  high,
}
