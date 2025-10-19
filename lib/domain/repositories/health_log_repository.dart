import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';

abstract class HealthLogRepository {
  Future<Either<Failure, List<HealthLog>>> getHealthLogsByDateRange(
    DateTime start,
    DateTime end,
  );
}