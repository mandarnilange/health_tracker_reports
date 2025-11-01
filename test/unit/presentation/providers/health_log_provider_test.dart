import 'package:dartz/dartz.dart';
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
import 'package:health_tracker_reports/presentation/providers/health_log_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllHealthLogs extends Mock implements GetAllHealthLogs {}

class MockCreateHealthLog extends Mock implements CreateHealthLog {}

class MockUpdateHealthLog extends Mock implements UpdateHealthLog {}

class MockDeleteHealthLog extends Mock implements DeleteHealthLog {}

void main() {
  late MockGetAllHealthLogs mockGetAllHealthLogs;
  late MockCreateHealthLog mockCreateHealthLog;
  late MockUpdateHealthLog mockUpdateHealthLog;
  late MockDeleteHealthLog mockDeleteHealthLog;
  late HealthLogsNotifier notifier;

  final tTimestamp = DateTime(2025, 10, 20, 7, 30);
  final tCreatedAt = DateTime(2025, 10, 20, 7, 35);
  final tUpdatedAt = DateTime(2025, 10, 20, 7, 40);

  final tHealthLog = HealthLog(
    id: 'log-1',
    timestamp: tTimestamp,
    vitals: const [
      VitalMeasurement(
        id: 'vital-1',
        type: VitalType.heartRate,
        value: 75,
        unit: 'bpm',
        status: VitalStatus.normal,
        referenceRange: ReferenceRange(min: 60, max: 100),
      ),
    ],
    notes: 'Morning reading',
    createdAt: tCreatedAt,
    updatedAt: tUpdatedAt,
  );

  final tCreateParams = CreateHealthLogParams(
    timestamp: tTimestamp,
    vitals: const [
      VitalMeasurementInput(type: VitalType.heartRate, value: 75),
    ],
    notes: 'Morning reading',
  );

  final tUpdateParams = UpdateHealthLogParams(
    id: 'log-1',
    timestamp: tTimestamp,
    createdAt: tCreatedAt,
    vitals: const [
      VitalMeasurementInput(type: VitalType.heartRate, value: 80),
    ],
    notes: 'Updated notes',
  );

  setUpAll(() {
    registerFallbackValue(tCreateParams);
    registerFallbackValue(tUpdateParams);
  });

  setUp(() {
    mockGetAllHealthLogs = MockGetAllHealthLogs();
    mockCreateHealthLog = MockCreateHealthLog();
    mockUpdateHealthLog = MockUpdateHealthLog();
    mockDeleteHealthLog = MockDeleteHealthLog();

    when(() => mockGetAllHealthLogs())
        .thenAnswer((_) async => const Right(<HealthLog>[]));
    when(() => mockCreateHealthLog(any()))
        .thenAnswer((_) async => Right(tHealthLog));
    when(() => mockUpdateHealthLog(any()))
        .thenAnswer((_) async => Right(tHealthLog));
    when(() => mockDeleteHealthLog(any()))
        .thenAnswer((_) async => const Right(null));

    notifier = HealthLogsNotifier(
      getAllHealthLogs: mockGetAllHealthLogs,
      createHealthLog: mockCreateHealthLog,
      updateHealthLog: mockUpdateHealthLog,
      deleteHealthLog: mockDeleteHealthLog,
    );
  });

  Future<void> pumpEventQueue() async {
    await Future<void>.delayed(Duration.zero);
  }

  group('loadHealthLogs', () {
    test('emits data when use case succeeds', () async {
      when(() => mockGetAllHealthLogs())
          .thenAnswer((_) async => Right([tHealthLog]));

      await notifier.loadHealthLogs();

      expect(
        notifier.state,
        isA<AsyncData<List<HealthLog>>>().having(
          (value) => value.value,
          'value',
          [tHealthLog],
        ),
      );
    });

    test('emits error when use case fails', () async {
      when(() => mockGetAllHealthLogs())
          .thenAnswer((_) async => const Left(CacheFailure()));

      await notifier.loadHealthLogs();

      expect(notifier.state.hasError, isTrue);
      expect(notifier.state.error, isA<CacheFailure>());
    });
  });

  group('addHealthLog', () {
    test('reloads logs on success', () async {
      when(() => mockGetAllHealthLogs())
          .thenAnswer((_) async => Right([tHealthLog]));
      when(() => mockCreateHealthLog(any()))
          .thenAnswer((_) async => Right(tHealthLog));

      await notifier.addHealthLog(tCreateParams);
      await pumpEventQueue();

      verify(() => mockCreateHealthLog(tCreateParams)).called(1);
      verify(() => mockGetAllHealthLogs()).called(greaterThanOrEqualTo(1));
      expect(notifier.state.value, [tHealthLog]);
    });

    test('sets error state when creation fails', () async {
      when(() => mockCreateHealthLog(any()))
          .thenAnswer((_) async => const Left(ValidationFailure(message: 'oops')));

      await notifier.addHealthLog(tCreateParams);
      await pumpEventQueue();

      expect(notifier.state.hasError, isTrue);
      expect(notifier.state.error, isA<ValidationFailure>());
    });

    test('triggers timeline refresh callback on success', () async {
      var timelineRefreshCalled = false;

      when(() => mockGetAllHealthLogs())
          .thenAnswer((_) async => Right([tHealthLog]));
      when(() => mockCreateHealthLog(any()))
          .thenAnswer((_) async => Right(tHealthLog));

      final notifierWithCallback = HealthLogsNotifier(
        getAllHealthLogs: mockGetAllHealthLogs,
        createHealthLog: mockCreateHealthLog,
        updateHealthLog: mockUpdateHealthLog,
        deleteHealthLog: mockDeleteHealthLog,
        onDataChanged: () async {
          timelineRefreshCalled = true;
        },
      );

      await notifierWithCallback.addHealthLog(tCreateParams);
      await pumpEventQueue();

      expect(timelineRefreshCalled, isTrue);
    });
  });

  group('updateHealthLog', () {
    test('reloads logs on success', () async {
      when(() => mockGetAllHealthLogs())
          .thenAnswer((_) async => Right([tHealthLog]));
      when(() => mockUpdateHealthLog(any()))
          .thenAnswer((_) async => Right(tHealthLog));

      await notifier.updateHealthLog(tUpdateParams);
      await pumpEventQueue();

      verify(() => mockUpdateHealthLog(tUpdateParams)).called(1);
      expect(notifier.state.value, [tHealthLog]);
    });

    test('sets error state when update fails', () async {
      when(() => mockUpdateHealthLog(any()))
          .thenAnswer((_) async => const Left(CacheFailure()));

      await notifier.updateHealthLog(tUpdateParams);
      await pumpEventQueue();

      expect(notifier.state.hasError, isTrue);
      expect(notifier.state.error, isA<CacheFailure>());
    });

    test('triggers timeline refresh callback on success', () async {
      var timelineRefreshCalled = false;

      when(() => mockGetAllHealthLogs())
          .thenAnswer((_) async => Right([tHealthLog]));
      when(() => mockUpdateHealthLog(any()))
          .thenAnswer((_) async => Right(tHealthLog));

      final notifierWithCallback = HealthLogsNotifier(
        getAllHealthLogs: mockGetAllHealthLogs,
        createHealthLog: mockCreateHealthLog,
        updateHealthLog: mockUpdateHealthLog,
        deleteHealthLog: mockDeleteHealthLog,
        onDataChanged: () async {
          timelineRefreshCalled = true;
        },
      );

      await notifierWithCallback.updateHealthLog(tUpdateParams);
      await pumpEventQueue();

      expect(timelineRefreshCalled, isTrue);
    });
  });

  group('deleteHealthLog', () {
    test('reloads logs on success', () async {
      when(() => mockGetAllHealthLogs())
          .thenAnswer((_) async => const Right(<HealthLog>[]));
      when(() => mockDeleteHealthLog(any()))
          .thenAnswer((_) async => const Right(null));

      await notifier.deleteHealthLog('log-1');
      await pumpEventQueue();

      verify(() => mockDeleteHealthLog('log-1')).called(1);
      expect(notifier.state.value, isEmpty);
    });

    test('sets error state when delete fails', () async {
      when(() => mockDeleteHealthLog(any()))
          .thenAnswer((_) async => const Left(CacheFailure()));

      await notifier.deleteHealthLog('log-1');
      await pumpEventQueue();

      expect(notifier.state.hasError, isTrue);
      expect(notifier.state.error, isA<CacheFailure>());
    });
  });
}
