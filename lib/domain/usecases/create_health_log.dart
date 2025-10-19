import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/core/utils/clock.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/usecases/validate_vital_measurement.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Input model representing raw vital data before validation.
class VitalMeasurementInput {
  /// Type of vital being recorded.
  final VitalType type;

  /// Measured value entered by the user.
  final double value;

  /// Optional unit override supplied by the user.
  final String? unit;

  /// Optional custom reference range for this measurement.
  final ReferenceRange? referenceRange;

  /// Optional pre-existing identifier (used when duplicating logs).
  final String? id;

  const VitalMeasurementInput({
    required this.type,
    required this.value,
    this.unit,
    this.referenceRange,
    this.id,
  });
}

/// Parameters required to create a new [HealthLog].
class CreateHealthLogParams {
  /// Timestamp when vitals were recorded.
  final DateTime timestamp;

  /// Vitals captured in this log.
  final List<VitalMeasurementInput> vitals;

  /// Optional notes associated with the log.
  final String? notes;

  const CreateHealthLogParams({
    required this.timestamp,
    required this.vitals,
    this.notes,
  });
}

@lazySingleton
class CreateHealthLog {
  final HealthLogRepository repository;
  final ValidateVitalMeasurement validateVitalMeasurement;
  final Uuid _uuid;
  final Clock _clock;

  CreateHealthLog({
    required this.repository,
    required this.validateVitalMeasurement,
    Clock? clock,
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid(),
        _clock = clock ?? SystemClock();

  Future<Either<Failure, HealthLog>> call(CreateHealthLogParams params) async {
    if (params.vitals.isEmpty) {
      return const Left(
        ValidationFailure(message: 'At least one vital measurement is required'),
      );
    }

    final logId = _uuid.v4();
    final timestamp = params.timestamp;
    final createdAt = _clock.now();
    final notes = _normaliseNotes(params.notes);
    final validatedVitals = <VitalMeasurement>[];

    for (final vital in params.vitals) {
      final validationResult = validateVitalMeasurement(
        type: vital.type,
        value: vital.value,
        unit: vital.unit,
        referenceRange: vital.referenceRange,
      );

      ValidatedVitalMeasurement? validated;
      final failure = validationResult.fold<Failure?>(
        (err) => err,
        (result) {
          validated = result;
          return null;
        },
      );

      if (failure != null) {
        return Left(failure);
      }

      final validatedMeasurement = validated!;
      validatedVitals.add(
        VitalMeasurement(
          id: vital.id ?? _uuid.v4(),
          type: validatedMeasurement.type,
          value: validatedMeasurement.value,
          unit: validatedMeasurement.unit,
          status: validatedMeasurement.status,
          referenceRange: validatedMeasurement.referenceRange,
        ),
      );
    }

    final healthLog = HealthLog(
      id: logId,
      timestamp: timestamp,
      vitals: validatedVitals,
      notes: notes,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final saveResult = await repository.saveHealthLog(healthLog);
    return saveResult.map((_) => healthLog);
  }

  String? _normaliseNotes(String? notes) {
    if (notes == null) {
      return null;
    }
    final trimmed = notes.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
