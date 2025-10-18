import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_reference_defaults.dart';

/// Result of validating a vital measurement input.
class ValidatedVitalMeasurement extends Equatable {
  /// The vital type being validated.
  final VitalType type;

  /// The numeric value submitted for validation.
  final double value;

  /// Normalised unit associated with this measurement.
  final String unit;

  /// The calculated status for the measurement.
  final VitalStatus status;

  /// Reference range used for the validation (if available).
  final ReferenceRange? referenceRange;

  const ValidatedVitalMeasurement({
    required this.type,
    required this.value,
    required this.unit,
    required this.status,
    this.referenceRange,
  });

  @override
  List<Object?> get props => [type, value, unit, status, referenceRange];
}

/// Validates raw vital measurement input and determines the resulting status.
class ValidateVitalMeasurement {
  /// Validates the supplied [value] for the given vital [type].
  ///
  /// Returns [ValidationFailure] when provided value is not a finite number.
  /// Otherwise, returns a [ValidatedVitalMeasurement] containing the resolved
  /// unit, reference range, and calculated status.
  Either<Failure, ValidatedVitalMeasurement> call({
    required VitalType type,
    required double value,
    String? unit,
    ReferenceRange? referenceRange,
  }) {
    if (value.isNaN || value.isInfinite) {
      return Left(
        const ValidationFailure(message: 'Invalid vital measurement value'),
      );
    }

    final resolvedUnit = unit ?? VitalReferenceDefaults.getUnit(type);
    final resolvedRange = referenceRange ?? VitalReferenceDefaults.getDefault(type);
    final status = _calculateStatus(value, resolvedRange);

    return Right(
      ValidatedVitalMeasurement(
        type: type,
        value: value,
        unit: resolvedUnit,
        status: status,
        referenceRange: resolvedRange,
      ),
    );
  }

  VitalStatus _calculateStatus(
    double value,
    ReferenceRange? referenceRange,
  ) {
    if (referenceRange == null) {
      return VitalStatus.normal;
    }

    final min = referenceRange.min;
    final max = referenceRange.max;

    if (value < min || value > max) {
      final deviation =
          value < min ? (min - value) / min : (value - max) / max;
      return deviation > 0.2 ? VitalStatus.critical : VitalStatus.warning;
    }

    return VitalStatus.normal;
  }
}
