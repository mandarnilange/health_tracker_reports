import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/local/health_log_local_datasource.dart';
import 'package:health_tracker_reports/data/datasources/local/report_local_datasource.dart';
import 'package:health_tracker_reports/data/models/health_log_model.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/data/models/vital_measurement_model.dart';
import 'package:health_tracker_reports/data/repositories/timeline_repository_impl.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:mocktail/mocktail.dart';

class MockReportLocalDataSource extends Mock implements ReportLocalDataSource {}

class MockHealthLogLocalDataSource extends Mock
    implements HealthLogLocalDataSource {}

void main() {
  late TimelineRepositoryImpl repository;
  late MockReportLocalDataSource mockReportDataSource;
  late MockHealthLogLocalDataSource mockHealthLogDataSource;

  final now = DateTime(2025, 10, 20, 10);

  final reportModel = ReportModel(
    id: 'report-1',
    date: now.subtract(const Duration(days: 1)),
    labName: 'Quest Diagnostics',
    biomarkers: const [],
    originalFilePath: '/tmp/report.pdf',
    createdAt: now.subtract(const Duration(days: 1)),
    updatedAt: now.subtract(const Duration(days: 1)),
  );

  final healthLogModel = HealthLogModel(
    id: 'log-1',
    timestamp: now,
    vitals: [
      VitalMeasurementModel(
        id: 'vital-1',
        vitalTypeIndex: 0,
        value: 118,
        unit: 'mmHg',
        statusIndex: 0,
      ),
    ],
    notes: 'Morning',
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockReportDataSource = MockReportLocalDataSource();
    mockHealthLogDataSource = MockHealthLogLocalDataSource();
    repository = TimelineRepositoryImpl(
      reportLocalDataSource: mockReportDataSource,
      healthLogLocalDataSource: mockHealthLogDataSource,
    );
  });

  group('getUnifiedTimeline', () {
    test('should combine reports and health logs sorted by timestamp', () async {
      when(() => mockReportDataSource.getAllReports())
          .thenAnswer((_) async => [reportModel]);
      when(() => mockHealthLogDataSource.getAllHealthLogs())
          .thenAnswer((_) async => [healthLogModel]);

      final result = await repository.getUnifiedTimeline();

      result.fold(
        (failure) => fail('Expected success'),
        (entries) {
          expect(entries.length, 2);
          expect(entries.first.entryType, HealthEntryType.healthLog);
          expect(entries.last.entryType, HealthEntryType.labReport);
        },
      );
    });

    test('should filter by entry type when provided', () async {
      when(() => mockReportDataSource.getAllReports())
          .thenAnswer((_) async => [reportModel]);
      when(() => mockHealthLogDataSource.getAllHealthLogs())
          .thenAnswer((_) async => [healthLogModel]);

      final result = await repository.getUnifiedTimeline(
        filterType: HealthEntryType.labReport,
      );

      result.fold(
        (failure) => fail('Expected success'),
        (entries) {
          expect(entries, hasLength(1));
          expect(entries.single.entryType, HealthEntryType.labReport);
        },
      );
    });

    test('should filter by date range inclusively', () async {
      when(() => mockReportDataSource.getAllReports())
          .thenAnswer((_) async => [reportModel]);
      when(() => mockHealthLogDataSource.getAllHealthLogs())
          .thenAnswer((_) async => [healthLogModel]);

      final result = await repository.getUnifiedTimeline(
        startDate: now.subtract(const Duration(hours: 1)),
        endDate: now.add(const Duration(hours: 1)),
      );

      result.fold(
        (failure) => fail('Expected success'),
        (entries) {
          expect(entries, hasLength(1));
          expect(entries.single.entryType, HealthEntryType.healthLog);
        },
      );
    });

    test('should return CacheFailure when any data source throws', () async {
      when(() => mockReportDataSource.getAllReports())
          .thenThrow(CacheException());
      when(() => mockHealthLogDataSource.getAllHealthLogs())
          .thenAnswer((_) async => [healthLogModel]);

      final result = await repository.getUnifiedTimeline();

      expect(result, const Left(CacheFailure()));
    });
  });
}
