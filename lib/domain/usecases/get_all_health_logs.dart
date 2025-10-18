import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAllHealthLogs {
  final HealthLogRepository repository;

  GetAllHealthLogs({required this.repository});

  Future<Either<Failure, List<HealthLog>>> call() async {
    final result = await repository.getAllHealthLogs();
    return result.map((logs) {
      final sorted = List<HealthLog>.from(logs)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sorted;
    });
  }
}
