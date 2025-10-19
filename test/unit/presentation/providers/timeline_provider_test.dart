import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/usecases/get_unified_timeline.dart';
import 'package:health_tracker_reports/presentation/providers/timeline_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUnifiedTimeline extends Mock implements GetUnifiedTimeline {}

void main() {
  late MockGetUnifiedTimeline mockGetUnifiedTimeline;
  late TimelineNotifier notifier;

  final now = DateTime(2025, 10, 20, 8);

  final tHealthLog = HealthLog(
    id: 'log-1',
    timestamp: now,
    vitals: const [
      VitalMeasurement(
        id: 'vital-1',
        type: VitalType.heartRate,
        value: 80,
        unit: 'bpm',
        status: VitalStatus.normal,
        referenceRange: ReferenceRange(min: 60, max: 100),
      ),
    ],
    notes: 'Morning',
    createdAt: now,
    updatedAt: now,
  );

  final tReport = Report(
    id: 'report-1',
    date: now.subtract(const Duration(days: 1)),
    labName: 'Quest Diagnostics',
    biomarkers: const [],
    originalFilePath: '/tmp/report.pdf',
    createdAt: now.subtract(const Duration(days: 1)),
    updatedAt: now.subtract(const Duration(days: 1)),
  );

  Future<void> pump() async {
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() {
    mockGetUnifiedTimeline = MockGetUnifiedTimeline();
    when(() => mockGetUnifiedTimeline(filterType: any(named: 'filterType')))
        .thenAnswer((_) async => const Right(<HealthEntry>[]));
    notifier = TimelineNotifier(getUnifiedTimeline: mockGetUnifiedTimeline);
  });

  group('loadTimeline', () {
    test('emits loaded entries on success', () async {
      when(() => mockGetUnifiedTimeline(filterType: any(named: 'filterType')))
          .thenAnswer((_) async => Right([tHealthLog, tReport]));

      await notifier.loadTimeline();
      await pump();

      expect(
        notifier.state,
        isA<AsyncData<List<HealthEntry>>>().having(
          (value) => value.value,
          'entries',
          containsAll([tHealthLog, tReport]),
        ),
      );
    });

    test('emits error on failure', () async {
      when(() => mockGetUnifiedTimeline(filterType: any(named: 'filterType')))
          .thenAnswer((_) async => const Left(CacheFailure()));

      await notifier.loadTimeline();
      await pump();

      expect(notifier.state.hasError, isTrue);
      expect(notifier.state.error, isA<CacheFailure>());
    });

    test('passes filter to use case', () async {
      when(() => mockGetUnifiedTimeline(filterType: any(named: 'filterType')))
          .thenAnswer((_) async => Right([tHealthLog]));

      await notifier.loadTimeline(filter: HealthEntryType.healthLog);
      await pump();

      verify(() => mockGetUnifiedTimeline(filterType: HealthEntryType.healthLog))
          .called(1);
    });
  });

  group('refresh', () {
    test('delegates to loadTimeline', () async {
      when(() => mockGetUnifiedTimeline(filterType: any(named: 'filterType')))
          .thenAnswer((_) async => Right([tHealthLog]));

      await notifier.refresh();
      await pump();

      verify(() => mockGetUnifiedTimeline(filterType: any(named: 'filterType')))
          .called(greaterThanOrEqualTo(2));
    });
  });

  group('filteredTimelineProvider', () {
    test('returns filtered entries when filter set', () async {
      final List<HealthEntry> entries = [tHealthLog, tReport];
      final container = ProviderContainer(
        overrides: [
          getUnifiedTimelineUseCaseProvider.overrideWithValue(mockGetUnifiedTimeline),
        ],
      );

      when(() => mockGetUnifiedTimeline(filterType: any(named: 'filterType')))
          .thenAnswer((_) async => Right(entries));

      await container.read(timelineProvider.notifier).loadTimeline();
      container.read(timelineFilterProvider.notifier).state =
          HealthEntryType.healthLog;

      final filtered = container.read(filteredTimelineProvider);

      expect(filtered.asData?.value, [tHealthLog]);
    });

    test('returns same entries when filter is null', () async {
      final List<HealthEntry> entries = [tHealthLog, tReport];
      final container = ProviderContainer(
        overrides: [
          getUnifiedTimelineUseCaseProvider.overrideWithValue(mockGetUnifiedTimeline),
        ],
      );

      when(() => mockGetUnifiedTimeline(filterType: any(named: 'filterType')))
          .thenAnswer((_) async => Right(entries));

      await container.read(timelineProvider.notifier).loadTimeline();

      final filtered = container.read(filteredTimelineProvider);

      expect(filtered.asData?.value, entries);
    });
  });
}
