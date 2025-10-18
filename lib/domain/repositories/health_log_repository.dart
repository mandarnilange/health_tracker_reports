import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';

/// Repository contract for managing [HealthLog] entries in persistent storage.
///
/// Returns [Either] to communicate success or [Failure] outcomes for all
/// operations. Concrete implementations should be provided in the data layer.
abstract class HealthLogRepository {
  /// Persists the provided [HealthLog] and returns the saved entity.
  Future<Either<Failure, HealthLog>> saveHealthLog(HealthLog log);

  /// Retrieves all stored [HealthLog] entries sorted by timestamp descending.
  Future<Either<Failure, List<HealthLog>>> getAllHealthLogs();

  /// Retrieves a single [HealthLog] by its unique [id].
  Future<Either<Failure, HealthLog>> getHealthLogById(String id);

  /// Deletes the [HealthLog] identified by [id].
  Future<Either<Failure, void>> deleteHealthLog(String id);

  /// Persists updates to the provided [HealthLog].
  Future<Either<Failure, void>> updateHealthLog(HealthLog log);

  /// Retrieves measurements for a specific [VitalType] across all health logs.
  ///
  /// Optional [startDate] and [endDate] bounds can be supplied to limit results.
  Future<Either<Failure, List<VitalMeasurement>>> getVitalTrend(
    VitalType type, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Retrieves all health logs within the provided date range.
  Future<Either<Failure, List<HealthLog>>> getHealthLogsByDateRange(
    DateTime start,
    DateTime end,
  );
}
