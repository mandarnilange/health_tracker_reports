import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';

/// Contract for persisting and querying health logs.
abstract class HealthLogRepository {
  Future<Either<Failure, HealthLog>> saveHealthLog(HealthLog log);
  Future<Either<Failure, void>> updateHealthLog(HealthLog log);
  Future<Either<Failure, void>> deleteHealthLog(String id);
  Future<Either<Failure, List<HealthLog>>> getAllHealthLogs();
  Future<Either<Failure, HealthLog>> getHealthLogById(String id);
  Future<Either<Failure, List<HealthLog>>> getHealthLogsByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<Either<Failure, List<VitalMeasurement>>> getVitalTrend(
    VitalType type, {
    DateTime? startDate,
    DateTime? endDate,
  });
}
