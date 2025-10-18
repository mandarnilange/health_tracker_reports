import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';

/// Repository contract for fetching unified health timeline entries.
abstract class TimelineRepository {
  /// Retrieves timeline entries, optionally filtered by date window or type.
  Future<Either<Failure, List<HealthEntry>>> getUnifiedTimeline({
    DateTime? startDate,
    DateTime? endDate,
    HealthEntryType? filterType,
  });
}
