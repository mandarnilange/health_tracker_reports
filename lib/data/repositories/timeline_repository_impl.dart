import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/local/health_log_local_datasource.dart';
import 'package:health_tracker_reports/data/datasources/local/report_local_datasource.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/repositories/timeline_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TimelineRepository)
class TimelineRepositoryImpl implements TimelineRepository {
  final ReportLocalDataSource reportLocalDataSource;
  final HealthLogLocalDataSource healthLogLocalDataSource;

  TimelineRepositoryImpl({
    required this.reportLocalDataSource,
    required this.healthLogLocalDataSource,
  });

  @override
  Future<Either<Failure, List<HealthEntry>>> getUnifiedTimeline({
    DateTime? startDate,
    DateTime? endDate,
    HealthEntryType? filterType,
  }) async {
    try {
      final reports = await reportLocalDataSource.getAllReports();
      final healthLogs = await healthLogLocalDataSource.getAllHealthLogs();

      final entries = <HealthEntry>[
        ...reports.map((report) => report.toEntity()),
        ...healthLogs.map((log) => log.toEntity()),
      ];

      var filteredEntries = entries;

      if (filterType != null) {
        filteredEntries =
            filteredEntries.where((entry) => entry.entryType == filterType).toList();
      }

      if (startDate != null) {
        filteredEntries = filteredEntries
            .where((entry) => !entry.timestamp.isBefore(startDate))
            .toList();
      }
      if (endDate != null) {
        filteredEntries = filteredEntries
            .where((entry) => !entry.timestamp.isAfter(endDate))
            .toList();
      }

      filteredEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return Right(filteredEntries);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}
