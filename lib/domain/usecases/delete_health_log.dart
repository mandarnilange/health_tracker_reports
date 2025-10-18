import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeleteHealthLog {
  final HealthLogRepository repository;

  DeleteHealthLog({required this.repository});

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteHealthLog(id);
  }
}
