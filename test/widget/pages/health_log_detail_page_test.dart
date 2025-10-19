import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/usecases/create_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/delete_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_health_logs.dart';
import 'package:health_tracker_reports/domain/usecases/update_health_log.dart';
import 'package:health_tracker_reports/presentation/pages/health_log/health_log_detail_page.dart';
import 'package:health_tracker_reports/presentation/pages/health_log/health_log_entry_sheet.dart';
import 'package:health_tracker_reports/presentation/providers/health_log_provider.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllHealthLogs extends Mock implements GetAllHealthLogs {}

class MockCreateHealthLog extends Mock implements CreateHealthLog {}

class MockUpdateHealthLog extends Mock implements UpdateHealthLog {}

class MockDeleteHealthLog extends Mock implements DeleteHealthLog {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      CreateHealthLogParams(timestamp: DateTime.now(), vitals: const []),
    );
    registerFallbackValue(
      UpdateHealthLogParams(
        id: 'id',
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
        vitals: const [
          VitalMeasurementInput(type: VitalType.heartRate, value: 70),
        ],
      ),
    );
  });

  group('HealthLogDetailPage', () {
    late HealthLog testLog;
    late MockGetAllHealthLogs mockGetAllHealthLogs;
    late MockCreateHealthLog mockCreateHealthLog;
    late MockUpdateHealthLog mockUpdateHealthLog;
    late MockDeleteHealthLog mockDeleteHealthLog;

    setUp(() {
      mockGetAllHealthLogs = MockGetAllHealthLogs();
      mockCreateHealthLog = MockCreateHealthLog();
      mockUpdateHealthLog = MockUpdateHealthLog();
      mockDeleteHealthLog = MockDeleteHealthLog();

      final timestamp = DateTime(2025, 10, 19, 10, 30);
      testLog = HealthLog(
        id: 'test-log-1',
        timestamp: timestamp,
        vitals: [
          VitalMeasurement(
            id: 'v1',
            type: VitalType.bloodPressureSystolic,
            value: 120,
            unit: 'mmHg',
            status: VitalStatus.normal,
            referenceRange: const ReferenceRange(min: 90, max: 120),
          ),
          VitalMeasurement(
            id: 'v2',
            type: VitalType.bloodPressureDiastolic,
            value: 80,
            unit: 'mmHg',
            status: VitalStatus.normal,
            referenceRange: const ReferenceRange(min: 60, max: 80),
          ),
          VitalMeasurement(
            id: 'v3',
            type: VitalType.heartRate,
            value: 72,
            unit: 'bpm',
            status: VitalStatus.normal,
            referenceRange: const ReferenceRange(min: 60, max: 100),
          ),
          VitalMeasurement(
            id: 'v4',
            type: VitalType.oxygenSaturation,
            value: 98,
            unit: '%',
            status: VitalStatus.normal,
            referenceRange: const ReferenceRange(min: 95, max: 100),
          ),
        ],
        notes: 'Feeling great today!',
        createdAt: timestamp,
        updatedAt: timestamp,
      );

      when(() => mockGetAllHealthLogs()).thenAnswer(
        (_) async => Right([testLog]),
      );
      when(() => mockDeleteHealthLog(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockCreateHealthLog(any())).thenAnswer(
        (_) async => Right(testLog),
      );
      when(() => mockUpdateHealthLog(any())).thenAnswer(
        (_) async => Right(testLog),
      );
    });

    Widget buildPage(HealthLog log) {
      return ProviderScope(
        overrides: [
          getAllHealthLogsUseCaseProvider
              .overrideWithValue(mockGetAllHealthLogs),
          createHealthLogUseCaseProvider.overrideWithValue(mockCreateHealthLog),
          updateHealthLogUseCaseProvider.overrideWithValue(mockUpdateHealthLog),
          deleteHealthLogUseCaseProvider.overrideWithValue(mockDeleteHealthLog),
        ],
        child: MaterialApp(
          home: HealthLogDetailPage(log: log),
        ),
      );
    }

    testWidgets('displays page title in app bar', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      expect(find.text('Health Log Details'), findsOneWidget);
    });

    testWidgets('displays timestamp correctly', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      final formatted = DateFormat('MMM d, yyyy • h:mm a').format(testLog.timestamp);
      expect(find.text(formatted), findsOneWidget);
    });

    testWidgets('displays all vitals with values and units', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      // Check for vital type names
      expect(find.textContaining('BP Systolic'), findsOneWidget);
      expect(find.textContaining('BP Diastolic'), findsOneWidget);
      expect(find.textContaining('Heart Rate'), findsOneWidget);
      expect(find.textContaining('SpO2'), findsOneWidget);

      // Check for values with units (more specific)
      expect(find.textContaining('120 mmHg'), findsWidgets);
      expect(find.textContaining('80 mmHg'), findsWidgets);
      expect(find.textContaining('72 bpm'), findsOneWidget);
      expect(find.textContaining('98 %'), findsOneWidget);
    });

    testWidgets('displays status indicators for each vital', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      // Should show green indicators for normal vitals
      // Using 🟢 emoji or similar visual indicator
      expect(find.textContaining('🟢'), findsNWidgets(4));
    });

    testWidgets('displays warning status indicator for warning vitals', (tester) async {
      final logWithWarning = testLog.copyWith(
        vitals: [
          VitalMeasurement(
            id: 'v1',
            type: VitalType.bloodPressureSystolic,
            value: 130,
            unit: 'mmHg',
            status: VitalStatus.warning,
            referenceRange: const ReferenceRange(min: 90, max: 120),
          ),
        ],
      );

      await tester.pumpWidget(buildPage(logWithWarning));

      expect(find.textContaining('🟡'), findsOneWidget);
    });

    testWidgets('displays critical status indicator for critical vitals', (tester) async {
      final logWithCritical = testLog.copyWith(
        vitals: [
          VitalMeasurement(
            id: 'v1',
            type: VitalType.bloodPressureSystolic,
            value: 160,
            unit: 'mmHg',
            status: VitalStatus.critical,
            referenceRange: const ReferenceRange(min: 90, max: 120),
          ),
        ],
      );

      await tester.pumpWidget(buildPage(logWithCritical));

      expect(find.textContaining('🔴'), findsOneWidget);
    });

    testWidgets('displays reference range for each vital', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      // Should show reference ranges like "90-120 mmHg"
      expect(find.textContaining('90-120'), findsOneWidget);
      expect(find.textContaining('60-80'), findsOneWidget);
      expect(find.textContaining('60-100'), findsOneWidget);
      expect(find.textContaining('95-100'), findsOneWidget);
    });

    testWidgets('displays notes when present', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      expect(find.text('Feeling great today!'), findsOneWidget);
    });

    testWidgets('does not display notes section when notes are null', (tester) async {
      final logWithoutNotes = testLog.copyWith(notes: null);
      await tester.pumpWidget(buildPage(logWithoutNotes));

      expect(find.text('Notes'), findsNothing);
    });

    testWidgets('does not display notes section when notes are empty', (tester) async {
      final logWithEmptyNotes = testLog.copyWith(notes: '   ');
      await tester.pumpWidget(buildPage(logWithEmptyNotes));

      expect(find.text('Notes'), findsNothing);
    });

    testWidgets('displays edit button in app bar', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('displays delete button in app bar', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('tapping edit button navigates to entry sheet', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // The HealthLogEntrySheet should be shown
      expect(find.byType(HealthLogEntrySheet), findsOneWidget);
    });

    testWidgets('tapping delete button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Delete Health Log'), findsOneWidget);
      expect(find.textContaining('Are you sure'), findsOneWidget);
    });

    testWidgets('confirming delete removes the log and pops navigation', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(() => mockDeleteHealthLog(testLog.id)).called(1);
    });

    testWidgets('canceling delete closes dialog without deleting', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockDeleteHealthLog(any()));
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('displays vital type icons', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      // Each vital should have its icon displayed
      expect(find.text('🩺'), findsNWidgets(2)); // BP Systolic and Diastolic
      expect(find.text('❤️'), findsOneWidget); // Heart Rate
      expect(find.text('🫁'), findsOneWidget); // SpO2
    });

    testWidgets('handles empty vitals list', (tester) async {
      final logWithNoVitals = testLog.copyWith(vitals: []);
      await tester.pumpWidget(buildPage(logWithNoVitals));

      // Should still render the page without errors
      expect(find.text('Health Log Details'), findsOneWidget);
    });

    testWidgets('displays all vital types correctly', (tester) async {
      final allVitalsLog = HealthLog(
        id: 'all-vitals',
        timestamp: DateTime.now(),
        vitals: [
          const VitalMeasurement(
            id: 'v1',
            type: VitalType.bodyTemperature,
            value: 98.6,
            unit: '°F',
            status: VitalStatus.normal,
          ),
          const VitalMeasurement(
            id: 'v2',
            type: VitalType.weight,
            value: 70,
            unit: 'kg',
            status: VitalStatus.normal,
          ),
          const VitalMeasurement(
            id: 'v3',
            type: VitalType.bloodGlucose,
            value: 95,
            unit: 'mg/dL',
            status: VitalStatus.normal,
          ),
          const VitalMeasurement(
            id: 'v4',
            type: VitalType.sleepHours,
            value: 8,
            unit: 'hours',
            status: VitalStatus.normal,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildPage(allVitalsLog));

      expect(find.textContaining('Temperature'), findsOneWidget);
      expect(find.textContaining('Weight'), findsOneWidget);
      expect(find.textContaining('Blood Glucose'), findsOneWidget);
      expect(find.textContaining('Sleep'), findsOneWidget);
    });

    testWidgets('scrolls to show all vitals when many are present', (tester) async {
      final manyVitalsLog = HealthLog(
        id: 'many-vitals',
        timestamp: DateTime.now(),
        vitals: VitalType.values
            .map(
              (type) => VitalMeasurement(
                id: 'v-${type.name}',
                type: type,
                value: 100,
                unit: 'unit',
                status: VitalStatus.normal,
              ),
            )
            .toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildPage(manyVitalsLog));

      // Page should be scrollable
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('shows error message when delete fails', (tester) async {
      when(() => mockDeleteHealthLog(any())).thenAnswer(
        (_) async => const Left(CacheFailure('Failed to delete')),
      );

      await tester.pumpWidget(buildPage(testLog));

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to delete'), findsOneWidget);
    });

    testWidgets('displays vital cards in a visually distinct way', (tester) async {
      await tester.pumpWidget(buildPage(testLog));

      // Should have Card widgets for each vital
      expect(find.byType(Card), findsWidgets);
    });
  });
}
