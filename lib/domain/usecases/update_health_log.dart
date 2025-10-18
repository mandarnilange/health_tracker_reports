import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/usecases/create_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/validate_vital_measurement.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

typedef DateTimeProvider = DateTime Function();

/// Parameters required to update an existing [HealthLog].
class UpdateHealthLogParams {
  /// Identifier of the health log being updated.
  final String id;

  /// Timestamp when the vitals were recorded.
  final DateTime timestamp;

  /// Original creation timestamp (preserved on update).
  final DateTime createdAt;

  /// Updated vital measurements.
  final List<VitalMeasurementInput> vitals;

  /// Updated notes (optional).
  final String? notes;

  const UpdateHealthLogParams({
    required this.id,
    required this.timestamp,
    required this.createdAt,
    required this.vitals,
    this.notes,
  });
}

@lazySingleton
class UpdateHealthLog {
  final HealthLogRepository repository;
  final ValidateVitalMeasurement validateVitalMeasurement;
  final Uuid _uuid;
  final DateTimeProvider _now;

  UpdateHealthLog({
    required this.repository,
    required this.validateVitalMeasurement,
    Uuid? uuid,
    DateTimeProvider? now,
  })  : _uuid = uuid ?? const Uuid(),
        _now = now ?? DateTime.now;

  Future<Either<Failure, HealthLog>> call(UpdateHealthLogParams params) async {
    if (params.id.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Health log id is required for updates'),
      );
    }

    if (params.vitals.isEmpty) {
      return const Left(
        ValidationFailure(message: 'At least one vital measurement is required'),
      );
    }

    final updatedAt = _now();
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

    final updatedLog = HealthLog(
      id: params.id,
      timestamp: params.timestamp,
      vitals: validatedVitals,
      notes: notes,
      createdAt: params.createdAt,
      updatedAt: updatedAt,
    );

    final result = await repository.updateHealthLog(updatedLog);
    return result.map((_) => updatedLog);
  }

  String? _normaliseNotes(String? notes) {
    if (notes == null) {
      return null;
    }
    final trimmed = notes.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
