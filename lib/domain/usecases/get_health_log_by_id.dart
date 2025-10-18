import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetHealthLogById {
  final HealthLogRepository repository;

  GetHealthLogById({required this.repository});

  Future<Either<Failure, HealthLog>> call(String id) {
    return repository.getHealthLogById(id);
  }
}
