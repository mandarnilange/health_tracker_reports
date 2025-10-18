import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/repositories/timeline_repository.dart';
import 'package:health_tracker_reports/domain/usecases/get_unified_timeline.dart';
import 'package:mocktail/mocktail.dart';

class MockTimelineRepository extends Mock implements TimelineRepository {}

void main() {
  late GetUnifiedTimeline usecase;
  late MockTimelineRepository mockRepository;

  final now = DateTime(2025, 10, 20, 9);
  final reportEntry = Report(
    id: 'report-1',
    date: now.subtract(const Duration(days: 1)),
    labName: 'Quest Diagnostics',
    biomarkers: const [],
    originalFilePath: '/path/report.pdf',
    notes: null,
    createdAt: now.subtract(const Duration(days: 1)),
    updatedAt: now.subtract(const Duration(days: 1)),
  );
  final logEntry = HealthLog(
    id: 'log-1',
    timestamp: now,
    vitals: const [],
    notes: 'Morning log',
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockRepository = MockTimelineRepository();
    usecase = GetUnifiedTimeline(repository: mockRepository);
  });

  test('should return combined entries sorted by timestamp', () async {
    // Arrange
    when(
      () => mockRepository.getUnifiedTimeline(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        filterType: any(named: 'filterType'),
      ),
    ).thenAnswer(
      (_) async => Right([reportEntry, logEntry]),
    );

    final start = now.subtract(const Duration(days: 7));
    final end = now;

    // Act
    final result = await usecase(
      startDate: start,
      endDate: end,
      filterType: null,
    );

    // Assert
    result.fold(
      (failure) => fail('Expected success but got ${failure.message}'),
      (entries) {
        expect(entries.length, 2);
        expect(entries.first, logEntry); // Newest first
        expect(entries.last, reportEntry);
      },
    );

    verify(
      () => mockRepository.getUnifiedTimeline(
        startDate: start,
        endDate: end,
        filterType: null,
      ),
    ).called(1);
  });

  test('should return failure when repository call fails', () async {
    // Arrange
    when(
      () => mockRepository.getUnifiedTimeline(
        startDate: null,
        endDate: null,
        filterType: HealthEntryType.healthLog,
      ),
    ).thenAnswer(
      (_) async => const Left(CacheFailure()),
    );

    // Act
    final result = await usecase(filterType: HealthEntryType.healthLog);

    // Assert
    expect(result, const Left(CacheFailure()));
  });
}
