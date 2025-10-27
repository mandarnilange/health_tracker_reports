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
import 'package:health_tracker_reports/presentation/pages/health_log/health_log_entry_sheet.dart';
import 'package:health_tracker_reports/presentation/providers/health_log_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateHealthLog extends Mock implements CreateHealthLog {}

class MockGetAllHealthLogs extends Mock implements GetAllHealthLogs {}

class MockUpdateHealthLog extends Mock implements UpdateHealthLog {}

class MockDeleteHealthLog extends Mock implements DeleteHealthLog {}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required List<Override> overrides,
  HealthLog? initialLog,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    HealthLogEntrySheet.show(context, initialLog: initialLog),
                child: const Text('open sheet'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open sheet'));
  await tester.pumpAndSettle();
}

List<Override> _buildOverrides({
  required MockCreateHealthLog mockCreate,
  required MockGetAllHealthLogs mockGetAll,
  required MockUpdateHealthLog mockUpdate,
  required MockDeleteHealthLog mockDelete,
}) {
  when(() => mockCreate(any())).thenAnswer((_) async => Right(_emptyLog()));
  when(() => mockGetAll()).thenAnswer((_) async => const Right(<HealthLog>[]));
  when(() => mockUpdate(any())).thenAnswer((_) async => Right(_emptyLog()));
  when(() => mockDelete(any())).thenAnswer((_) async => const Right(null));

  return [
    getAllHealthLogsUseCaseProvider.overrideWithValue(mockGetAll),
    createHealthLogUseCaseProvider.overrideWithValue(mockCreate),
    updateHealthLogUseCaseProvider.overrideWithValue(mockUpdate),
    deleteHealthLogUseCaseProvider.overrideWithValue(mockDelete),
    healthLogsProvider.overrideWith(
      (ref) => HealthLogsNotifier(
        getAllHealthLogs: mockGetAll,
        createHealthLog: mockCreate,
        updateHealthLog: mockUpdate,
        deleteHealthLog: mockDelete,
      ),
    ),
  ];
}

HealthLog _emptyLog() {
  final now = DateTime.now();
  return HealthLog(
    id: 'log-id',
    timestamp: now,
    vitals: const [],
    notes: null,
    createdAt: now,
    updatedAt: now,
  );
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
          VitalMeasurementInput(type: VitalType.heartRate, value: 70)
        ],
      ),
    );
  });

  group('HealthLogEntrySheet', () {
    late MockCreateHealthLog mockCreate;
    late MockGetAllHealthLogs mockGetAll;
    late MockUpdateHealthLog mockUpdate;
    late MockDeleteHealthLog mockDelete;

    setUp(() {
      mockCreate = MockCreateHealthLog();
      mockGetAll = MockGetAllHealthLogs();
      mockUpdate = MockUpdateHealthLog();
      mockDelete = MockDeleteHealthLog();
    });

    testWidgets('shows default vital inputs and notes field', (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized()
          as TestWidgetsFlutterBinding;
      binding.window.physicalSizeTestValue = const Size(1200, 2200);
      binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        binding.window.clearPhysicalSizeTestValue();
        binding.window.clearDevicePixelRatioTestValue();
      });

      await _pumpSheet(
        tester,
        overrides: _buildOverrides(
          mockCreate: mockCreate,
          mockGetAll: mockGetAll,
          mockUpdate: mockUpdate,
          mockDelete: mockDelete,
        ),
      );

      expect(find.textContaining('BP Systolic'), findsWidgets);
      expect(find.textContaining('SpO2'), findsWidgets);
      expect(find.textContaining('Heart Rate'), findsWidgets);
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsWidgets);
      final textFields =
          tester.widgetList<TextField>(find.byType(TextField)).toList();
      final notesField = textFields.firstWhere(
        (field) => field.maxLines == 3,
        orElse: () => throw StateError('Notes field not found'),
      );
      expect(notesField.decoration?.labelText, 'Notes (Optional)');
    });

    testWidgets('adds additional vital from dropdown', (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized()
          as TestWidgetsFlutterBinding;
      binding.window.physicalSizeTestValue = const Size(1200, 2200);
      binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        binding.window.clearPhysicalSizeTestValue();
        binding.window.clearDevicePixelRatioTestValue();
      });

      await _pumpSheet(
        tester,
        overrides: _buildOverrides(
          mockCreate: mockCreate,
          mockGetAll: mockGetAll,
          mockUpdate: mockUpdate,
          mockDelete: mockDelete,
        ),
      );

      await tester.tap(find.text('Add Another Vital'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Temperature'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Temperature'), findsWidgets);
    });

    testWidgets(
      'pre-fills inputs when editing an existing log',
      (tester) async {
        final binding = TestWidgetsFlutterBinding.ensureInitialized()
            as TestWidgetsFlutterBinding;
        binding.window.physicalSizeTestValue = const Size(1200, 2200);
        binding.window.devicePixelRatioTestValue = 1.0;
        addTearDown(() {
          binding.window.clearPhysicalSizeTestValue();
          binding.window.clearDevicePixelRatioTestValue();
        });

        final timestamp = DateTime(2025, 10, 20, 6, 30);
        final existingLog = HealthLog(
          id: 'log-1',
          timestamp: timestamp,
          vitals: const [
            VitalMeasurement(
              id: 'bp-sys',
              type: VitalType.bloodPressureSystolic,
              value: 115,
              unit: 'mmHg',
              status: VitalStatus.normal,
              referenceRange: ReferenceRange(min: 90, max: 120),
            ),
            VitalMeasurement(
              id: 'bp-dia',
              type: VitalType.bloodPressureDiastolic,
              value: 75,
              unit: 'mmHg',
              status: VitalStatus.normal,
              referenceRange: ReferenceRange(min: 60, max: 80),
            ),
            VitalMeasurement(
              id: 'spo2',
              type: VitalType.oxygenSaturation,
              value: 96,
              unit: '%',
              status: VitalStatus.normal,
              referenceRange: ReferenceRange(min: 95, max: 100),
            ),
            VitalMeasurement(
              id: 'hr',
              type: VitalType.heartRate,
              value: 68,
              unit: 'bpm',
              status: VitalStatus.normal,
              referenceRange: ReferenceRange(min: 60, max: 100),
            ),
          ],
          notes: 'Morning jog',
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        when(() => mockUpdate(any()))
            .thenAnswer((_) async => Right(existingLog));

        await _pumpSheet(
          tester,
          overrides: _buildOverrides(
            mockCreate: mockCreate,
            mockGetAll: mockGetAll,
            mockUpdate: mockUpdate,
            mockDelete: mockDelete,
          ),
          initialLog: existingLog,
        );
        final fields = tester
            .widgetList<TextFormField>(find.byType(TextFormField))
            .toList();
        expect(fields.length, greaterThanOrEqualTo(4));
        expect(fields[0].controller?.text, '115');
        expect(fields[1].controller?.text, '75');
        expect(fields[2].controller?.text, '96');
        expect(fields[3].controller?.text, '68');

        final notesField = tester
            .widgetList<TextField>(find.byType(TextField))
            .firstWhere(
              (field) => field.maxLines == 3,
              orElse: () => throw StateError('Notes field not found'),
            );
        expect(notesField.controller?.text, 'Morning jog');
      },
    );
  });
}
