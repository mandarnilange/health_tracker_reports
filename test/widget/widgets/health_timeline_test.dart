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
            id: 'bp-sys',
            type: VitalType.bloodPressureSystolic,
            value: 120,
            unit: 'mmHg',
            status: VitalStatus.normal,
            referenceRange: ReferenceRange(min: 90, max: 120),
          ),
          VitalMeasurement(
            id: 'bp-dia',
            type: VitalType.bloodPressureDiastolic,
            value: 80,
            unit: 'mmHg',
            status: VitalStatus.normal,
            referenceRange: ReferenceRange(min: 60, max: 80),
          ),
          VitalMeasurement(
            id: 'spo2',
            type: VitalType.oxygenSaturation,
            value: 92,
            unit: '%',
            status: VitalStatus.warning,
            referenceRange: ReferenceRange(min: 95, max: 100),
          ),
          VitalMeasurement(
            id: 'hr',
            type: VitalType.heartRate,
            value: 78,
            unit: 'bpm',
            status: VitalStatus.normal,
            referenceRange: ReferenceRange(min: 60, max: 100),
          ),
          VitalMeasurement(
            id: 'weight',
            type: VitalType.weight,
            value: 70,
            unit: 'kg',
            status: VitalStatus.normal,
          ),
        ],
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
      expect(find.text('BP - 120/80'), findsOneWidget);
      expect(find.text('SpO2 - 92%'), findsOneWidget);
      expect(find.text('HR - 78 bpm'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('shows empty state when no entries', (tester) async {
      await pumpTimeline(
        tester,
        handler: (_) async => const Right(<HealthEntry>[]),
      );

      expect(find.text('No entries yet'), findsOneWidget);
    });

    testWidgets('keeps date header pinned while scrolling', (tester) async {
      await pumpTimeline(
        tester,
        handler: (_) async => Right(entries),
      );

      final headerFinder = find.textContaining('Today •');
      expect(headerFinder, findsOneWidget);
      final initialTop = tester.getTopLeft(headerFinder).dy;

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pump();

      final afterTop = tester.getTopLeft(headerFinder).dy;
      expect(afterTop, closeTo(initialTop, 1.0));
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
