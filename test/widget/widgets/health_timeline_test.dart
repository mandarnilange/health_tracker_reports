import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
import 'package:health_tracker_reports/presentation/widgets/health_timeline.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUnifiedTimeline extends Mock implements GetUnifiedTimeline {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetUnifiedTimeline mockGetUnifiedTimeline;
  late List<HealthEntry> entries;

  setUpAll(() {
    registerFallbackValue(HealthEntryType.labReport);
  });

  setUp(() {
    mockGetUnifiedTimeline = MockGetUnifiedTimeline();
    final now = DateTime(2025, 10, 20, 9);
    entries = [
      HealthLog(
        id: 'log-1',
        timestamp: now,
        vitals: const [
          VitalMeasurement(
            id: 'v1',
            type: VitalType.heartRate,
            value: 78,
            unit: 'bpm',
            status: VitalStatus.normal,
            referenceRange: ReferenceRange(min: 60, max: 100),
          ),
        ],
        notes: 'Morning',
        createdAt: now,
        updatedAt: now,
      ),
      Report(
        id: 'report-1',
        date: now.subtract(const Duration(days: 1)),
        labName: 'Quest Diagnostics',
        biomarkers: const [],
        originalFilePath: '/tmp/report.pdf',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  });

  Future<void> pumpTimeline(
    WidgetTester tester, {
    required Future<Either<Failure, List<HealthEntry>>> Function(
            Invocation invocation)
        handler,
  }) async {
    when(() => mockGetUnifiedTimeline(filterType: any(named: 'filterType')))
        .thenAnswer(handler);

    final container = ProviderContainer(
      overrides: [
        getUnifiedTimelineUseCaseProvider.overrideWithValue(
          mockGetUnifiedTimeline,
        ),
      ],
    );

    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: HealthTimeline()),
        ),
      ),
    );

    await tester.pump(); // start async work
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('HealthTimeline', () {
    testWidgets('renders entries grouped with filter chips', (tester) async {
      await pumpTimeline(
        tester,
        handler: (_) async => Right(entries),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Lab Reports'), findsOneWidget);
      expect(find.text('Health Logs'), findsOneWidget);
      expect(find.textContaining('Quest Diagnostics'), findsOneWidget);
      expect(find.textContaining('Heart Rate - 78 bpm'), findsOneWidget);
    });

    testWidgets('shows empty state when no entries', (tester) async {
      await pumpTimeline(
        tester,
        handler: (_) async => const Right(<HealthEntry>[]),
      );

      expect(find.text('No entries yet'), findsOneWidget);
    });

    testWidgets('shows error message when loading fails', (tester) async {
      await pumpTimeline(
        tester,
        handler: (_) async => const Left(CacheFailure('boom')),
      );

      expect(find.textContaining('boom'), findsOneWidget);
    });
  });
}
