import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/local/health_log_local_datasource.dart';
import 'package:health_tracker_reports/data/models/health_log_model.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HealthLogRepository)
class HealthLogRepositoryImpl implements HealthLogRepository {
  final HealthLogLocalDataSource localDataSource;

  HealthLogRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, HealthLog>> saveHealthLog(HealthLog log) async {
    try {
      await localDataSource.saveHealthLog(HealthLogModel.fromEntity(log));
      return Right(log);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<HealthLog>>> getAllHealthLogs() async {
    try {
      final models = await localDataSource.getAllHealthLogs();
      final logs =
          models.map((model) => model.toEntity()).toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Right(logs);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, HealthLog>> getHealthLogById(String id) async {
    try {
      final model = await localDataSource.getHealthLogById(id);
      return Right(model.toEntity());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteHealthLog(String id) async {
    try {
      await localDataSource.deleteHealthLog(id);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateHealthLog(HealthLog log) async {
    try {
      await localDataSource.updateHealthLog(HealthLogModel.fromEntity(log));
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<HealthLog>>> getHealthLogsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final models = await localDataSource.getAllHealthLogs();
      final filtered = models
          .map((model) => model.toEntity())
          .where((log) =>
              !log.timestamp.isBefore(start) && !log.timestamp.isAfter(end))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Right(filtered);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<VitalMeasurement>>> getVitalTrend(
    VitalType type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final models = await localDataSource.getAllHealthLogs();
      final entries = models.map((model) => model.toEntity()).toList();

      final measurements = <_TimestampedMeasurement>[];

      for (final log in entries) {
        if (startDate != null && log.timestamp.isBefore(startDate)) continue;
        if (endDate != null && log.timestamp.isAfter(endDate)) continue;

        for (final vital in log.vitals) {
          if (vital.type == type) {
            measurements.add(
              _TimestampedMeasurement(timestamp: log.timestamp, vital: vital),
            );
          }
        }
      }

      measurements.sort(
        (a, b) => a.timestamp.compareTo(b.timestamp),
      );

      return Right(
        measurements.map((entry) => entry.vital).toList(),
      );
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}

class _TimestampedMeasurement {
  final DateTime timestamp;
  final VitalMeasurement vital;

  _TimestampedMeasurement({required this.timestamp, required this.vital});
}
