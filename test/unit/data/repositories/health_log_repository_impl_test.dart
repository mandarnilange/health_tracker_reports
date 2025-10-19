import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/local/health_log_local_datasource.dart';
import 'package:health_tracker_reports/data/models/health_log_model.dart';
import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/data/models/vital_measurement_model.dart';
import 'package:health_tracker_reports/data/repositories/health_log_repository_impl.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthLogLocalDataSource extends Mock
    implements HealthLogLocalDataSource {}

class FakeHealthLogModel extends Fake implements HealthLogModel {}

void main() {
  late HealthLogRepositoryImpl repository;
  late MockHealthLogLocalDataSource mockLocalDataSource;

  final tTimestamp = DateTime(2025, 10, 20, 7, 30);
  final tCreatedAt = DateTime(2025, 10, 20, 7, 35);
  final tUpdatedAt = DateTime(2025, 10, 20, 7, 36);

  final tVitalMeasurementModel = VitalMeasurementModel(
    id: 'vital-1',
    vitalTypeIndex: VitalType.heartRate.index,
    value: 82,
    unit: 'bpm',
    statusIndex: VitalStatus.normal.index,
    referenceRange: const ReferenceRangeModel(min: 60, max: 100),
  );

  final tHealthLogModel = HealthLogModel(
    id: 'log-1',
    timestamp: tTimestamp,
    vitals: [tVitalMeasurementModel],
    notes: 'Morning',
    createdAt: tCreatedAt,
    updatedAt: tUpdatedAt,
  );

  final tHealthLogEntity = HealthLog(
    id: 'log-1',
    timestamp: tTimestamp,
    vitals: [
      VitalMeasurement(
        id: 'vital-1',
        type: VitalType.heartRate,
        value: 82,
        unit: 'bpm',
        status: VitalStatus.normal,
        referenceRange: const ReferenceRange(min: 60, max: 100),
      ),
    ],
    notes: 'Morning',
    createdAt: tCreatedAt,
    updatedAt: tUpdatedAt,
  );

  setUpAll(() {
    registerFallbackValue(FakeHealthLogModel());
  });

  setUp(() {
    mockLocalDataSource = MockHealthLogLocalDataSource();
    repository = HealthLogRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  group('saveHealthLog', () {
    test('should save log and return entity on success', () async {
      when(() => mockLocalDataSource.saveHealthLog(any()))
          .thenAnswer((_) async {});

      final result = await repository.saveHealthLog(tHealthLogEntity);

      result.fold(
        (failure) => fail('Expected success'),
        (log) => expect(log, tHealthLogEntity),
      );
      verify(() =>
              mockLocalDataSource.saveHealthLog(HealthLogModel.fromEntity(
                tHealthLogEntity,
              ))).called(1);
    });

    test('should return CacheFailure on exception', () async {
      when(() => mockLocalDataSource.saveHealthLog(any()))
          .thenThrow(CacheException());

      final result = await repository.saveHealthLog(tHealthLogEntity);

      expect(result, const Left(CacheFailure()));
    });
  });

  group('getAllHealthLogs', () {
    test('should return logs sorted by timestamp descending', () async {
      final olderModel = HealthLogModel(
        id: 'log-0',
        timestamp: tTimestamp.subtract(const Duration(hours: 1)),
        vitals: tHealthLogModel.vitals,
        notes: tHealthLogModel.notes,
        createdAt: tHealthLogModel.createdAt,
        updatedAt: tHealthLogModel.updatedAt,
      );
      when(() => mockLocalDataSource.getAllHealthLogs())
          .thenAnswer((_) async => [olderModel, tHealthLogModel]);

      final result = await repository.getAllHealthLogs();

      result.fold(
        (failure) => fail('Expected success'),
        (logs) {
          expect(logs.length, 2);
          expect(logs.first.id, 'log-1');
          expect(logs.last.id, 'log-0');
        },
      );
    });

    test('should return CacheFailure when data source throws', () async {
      when(() => mockLocalDataSource.getAllHealthLogs())
          .thenThrow(CacheException());

      final result = await repository.getAllHealthLogs();

      expect(result, const Left(CacheFailure()));
    });
  });

  group('getHealthLogById', () {
    test('should return entity when found', () async {
      when(() => mockLocalDataSource.getHealthLogById('log-1'))
          .thenAnswer((_) async => tHealthLogModel);

      final result = await repository.getHealthLogById('log-1');

      result.fold(
        (failure) => fail('Expected success'),
        (log) => expect(log, tHealthLogEntity),
      );
    });

    test('should return CacheFailure when data source throws', () async {
      when(() => mockLocalDataSource.getHealthLogById(any()))
          .thenThrow(CacheException());

      final result = await repository.getHealthLogById('log-1');

      expect(result, const Left(CacheFailure()));
    });
  });

  group('deleteHealthLog', () {
    test('should call datasource delete and return Right(null)', () async {
      when(() => mockLocalDataSource.deleteHealthLog('log-1'))
          .thenAnswer((_) async {});

      final result = await repository.deleteHealthLog('log-1');

      expect(result, const Right(null));
      verify(() => mockLocalDataSource.deleteHealthLog('log-1')).called(1);
    });

    test('should return CacheFailure on exception', () async {
      when(() => mockLocalDataSource.deleteHealthLog(any()))
          .thenThrow(CacheException());

      final result = await repository.deleteHealthLog('log-1');

      expect(result, const Left(CacheFailure()));
    });
  });

  group('updateHealthLog', () {
    test('should update log and return Right(null)', () async {
      when(() => mockLocalDataSource.updateHealthLog(any()))
          .thenAnswer((_) async {});

      final result = await repository.updateHealthLog(tHealthLogEntity);

      expect(result, const Right(null));
      verify(() =>
              mockLocalDataSource.updateHealthLog(HealthLogModel.fromEntity(
                tHealthLogEntity,
              ))).called(1);
    });

    test('should return CacheFailure on exception', () async {
      when(() => mockLocalDataSource.updateHealthLog(any()))
          .thenThrow(CacheException());

      final result = await repository.updateHealthLog(tHealthLogEntity);

      expect(result, const Left(CacheFailure()));
    });
  });

  group('getHealthLogsByDateRange', () {
    final withinRangeModel = tHealthLogModel;
    final outsideRangeModel = HealthLogModel(
      id: 'log-2',
      timestamp: tTimestamp.subtract(const Duration(days: 10)),
      vitals: tHealthLogModel.vitals,
      notes: tHealthLogModel.notes,
      createdAt: tHealthLogModel.createdAt,
      updatedAt: tHealthLogModel.updatedAt,
    );

    test('should filter logs by inclusive date range', () async {
      when(() => mockLocalDataSource.getAllHealthLogs())
          .thenAnswer((_) async => [withinRangeModel, outsideRangeModel]);

      final result = await repository.getHealthLogsByDateRange(
        tTimestamp.subtract(const Duration(days: 1)),
        tTimestamp.add(const Duration(days: 1)),
      );

      result.fold(
        (failure) => fail('Expected success'),
        (logs) {
          expect(logs.length, 1);
          expect(logs.single.id, withinRangeModel.id);
        },
      );
    });

    test('should return CacheFailure when data source throws', () async {
      when(() => mockLocalDataSource.getAllHealthLogs())
          .thenThrow(CacheException());

      final result = await repository.getHealthLogsByDateRange(
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now(),
      );

      expect(result, const Left(CacheFailure()));
    });
  });

  group('getVitalTrend', () {
    final secondLog = HealthLogModel(
      id: 'log-2',
      timestamp: tTimestamp.add(const Duration(hours: 2)),
      vitals: [
        VitalMeasurementModel(
          id: 'vital-2',
          vitalTypeIndex: VitalType.heartRate.index,
          value: 90,
          unit: 'bpm',
          statusIndex: VitalStatus.normal.index,
          referenceRange: const ReferenceRangeModel(min: 60, max: 100),
        ),
      ],
      notes: tHealthLogModel.notes,
      createdAt: tHealthLogModel.createdAt,
      updatedAt: tHealthLogModel.updatedAt,
    );

    test('should return measurements sorted by timestamp', () async {
      when(() => mockLocalDataSource.getAllHealthLogs())
          .thenAnswer((_) async => [secondLog, tHealthLogModel]);

      final result = await repository.getVitalTrend(VitalType.heartRate);

      result.fold(
        (failure) => fail('Expected success'),
        (measurements) {
          expect(measurements, hasLength(2));
          expect(measurements.first.value, 82);
          expect(measurements.last.value, 90);
        },
      );
    });

    test('should filter measurements by date range when provided', () async {
      when(() => mockLocalDataSource.getAllHealthLogs())
          .thenAnswer((_) async => [secondLog, tHealthLogModel]);

      final result = await repository.getVitalTrend(
        VitalType.heartRate,
        startDate: tTimestamp.add(const Duration(hours: 1)),
      );

      result.fold(
        (failure) => fail('Expected success'),
        (measurements) {
          expect(measurements, hasLength(1));
          expect(measurements.single.value, 90);
        },
      );
    });

    test('should return CacheFailure when data source throws', () async {
      when(() => mockLocalDataSource.getAllHealthLogs())
          .thenThrow(CacheException());

      final result = await repository.getVitalTrend(VitalType.heartRate);

      expect(result, const Left(CacheFailure()));
    });
  });
}
