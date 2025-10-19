import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';

// Placeholder for Phase 6
abstract class GetVitalTrend {
  Future<Either<Failure, List<TrendDataPoint>>> call(
    String vitalName, {
    DateTime? startDate,
    DateTime? endDate,
  });
}