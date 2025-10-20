import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetVitalTrend {
  final HealthLogRepository repository;

  GetVitalTrend({required this.repository});

  Future<Either<Failure, List<VitalMeasurement>>> call(
    VitalType type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final result = await repository.getVitalTrend(
      type,
      startDate: startDate,
      endDate: endDate,
    );

    return result.map((measurements) {
      final sorted = List<VitalMeasurement>.from(measurements)
        ..sort((a, b) => a.id.compareTo(b.id));
      return sorted;
    });
  }
}
