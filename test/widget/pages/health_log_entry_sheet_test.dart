import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_reference_defaults.dart';
import 'package:health_tracker_reports/domain/usecases/create_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/delete_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_health_logs.dart';
import 'package:health_tracker_reports/domain/usecases/update_health_log.dart';
import 'package:health_tracker_reports/presentation/pages/health_log/health_log_entry_sheet.dart';
import 'package:health_tracker_reports/presentation/providers/health_log_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateHealthLog extends Mock implements CreateHealthLog {}

class MockGetAllHealthLogs extends Mock implements GetAllHealthLogs {}

class TestHealthLogsNotifier extends HealthLogsNotifier {
  TestHealthLogsNotifier({
    required super.getAllHealthLogs,
    required super.createHealthLog,
    required super.updateHealthLog,
    required super.deleteHealthLog,
  });

  CreateHealthLogParams? lastParams;

  @override
  Future<void> addHealthLog(CreateHealthLogParams params) {
    lastParams = params;
    return super.addHealthLog(params);
  }
}

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

  group('HealthLogEntrySheet', () {
    late MockCreateHealthLog mockCreateHealthLog;
    late MockGetAllHealthLogs mockGetAllHealthLogs;

    ProviderScope buildSheet() {
      mockCreateHealthLog = MockCreateHealthLog();
      mockGetAllHealthLogs = MockGetAllHealthLogs();
      final mockUpdateHealthLog = MockUpdateHealthLog();
      final mockDeleteHealthLog = MockDeleteHealthLog();

      when(() => mockCreateHealthLog(any())).thenAnswer((_) async => Right(
            HealthLog(
              id: 'log-id',
              timestamp: DateTime.now(),
              vitals: const [],
              notes: null,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ));
      when(() => mockGetAllHealthLogs()).thenAnswer(
        (_) async => const Right(<HealthLog>[]),
      );
      when(() => mockUpdateHealthLog(any())).thenAnswer((_) async => Right(
            HealthLog(
              id: 'log-id',
              timestamp: DateTime.now(),
              vitals: const [],
              notes: null,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ));
      when(() => mockDeleteHealthLog(any()))
          .thenAnswer((_) async => const Right(null));

      return ProviderScope(
        overrides: [
          getAllHealthLogsUseCaseProvider
              .overrideWithValue(mockGetAllHealthLogs),
          createHealthLogUseCaseProvider.overrideWithValue(mockCreateHealthLog),
          updateHealthLogUseCaseProvider.overrideWithValue(mockUpdateHealthLog),
          deleteHealthLogUseCaseProvider.overrideWithValue(mockDeleteHealthLog),
          healthLogsProvider.overrideWith((ref) => TestHealthLogsNotifier(
                getAllHealthLogs: mockGetAllHealthLogs,
                createHealthLog: mockCreateHealthLog,
                updateHealthLog: mockUpdateHealthLog,
                deleteHealthLog: mockDeleteHealthLog,
              )),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: HealthLogEntrySheet(),
          ),
        ),
      );
    }

    testWidgets('shows default vital inputs and notes field', (tester) async {
      await tester.pumpWidget(buildSheet());

      expect(find.textContaining('BP Systolic'), findsWidgets);
      expect(find.textContaining('SpO2'), findsWidgets);
      expect(find.textContaining('Heart Rate'), findsWidgets);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('adds additional vital from dropdown', (tester) async {
      await tester.pumpWidget(buildSheet());

      await tester.tap(find.text('Add Another Vital'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Temperature'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Temperature'), findsWidgets);
    });

    testWidgets('saves health log and closes sheet', (tester) async {
      await tester.pumpWidget(buildSheet());

      await tester.enterText(find.byType(TextFormField).at(0), '120');
      await tester.enterText(find.byType(TextFormField).at(1), '80');
      await tester.enterText(find.byType(TextFormField).at(2), '98');
      await tester.enterText(find.byType(TextFormField).at(3), '72');

      await tester.ensureVisible(find.text('Save Health Log'));
      await tester.tap(find.text('Save Health Log'));
      await tester.pumpAndSettle();

      verify(() => mockCreateHealthLog(any())).called(1);
    });
  });
}

class MockUpdateHealthLog extends Mock implements UpdateHealthLog {}

class MockDeleteHealthLog extends Mock implements DeleteHealthLog {}
