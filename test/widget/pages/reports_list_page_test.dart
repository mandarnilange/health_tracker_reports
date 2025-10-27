import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/usecases/get_unified_timeline.dart';
import 'package:health_tracker_reports/presentation/pages/home/reports_list_page.dart';
import 'package:health_tracker_reports/presentation/providers/timeline_provider.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUnifiedTimeline extends Mock implements GetUnifiedTimeline {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetUnifiedTimeline mockGetUnifiedTimeline;
  late List<HealthEntry> entries;
  late DateTime now;

  setUp(() {
    mockGetUnifiedTimeline = MockGetUnifiedTimeline();
    now = DateTime(2025, 10, 20, 9);
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
        notes: 'Morning log',
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

  Future<void> pumpPage(WidgetTester tester) async {
    when(() => mockGetUnifiedTimeline(filterType: any(named: 'filterType')))
        .thenAnswer((_) async => Right(entries));

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
          home: ReportsListPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('renders timeline view and actions', (tester) async {
    await pumpPage(tester);

    final expectedTimestamp =
        DateFormat('MMM d, yyyy • h:mm a').format(now);

    expect(find.text('Health Timeline'), findsOneWidget);
    expect(find.text(expectedTimestamp), findsOneWidget);
    expect(find.text('Quest Diagnostics'), findsOneWidget);
    expect(find.byIcon(Icons.upload_file), findsOneWidget);
  });
}
