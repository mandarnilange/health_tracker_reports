import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/repositories/timeline_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetUnifiedTimeline {
  final TimelineRepository repository;

  GetUnifiedTimeline({required this.repository});

  Future<Either<Failure, List<HealthEntry>>> call({
    DateTime? startDate,
    DateTime? endDate,
    HealthEntryType? filterType,
  }) async {
    final result = await repository.getUnifiedTimeline(
      startDate: startDate,
      endDate: endDate,
      filterType: filterType,
    );

    return result.map((entries) {
      final sorted = List<HealthEntry>.from(entries)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sorted;
    });
  }
}
