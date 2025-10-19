import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/core/utils/clock.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_reference_defaults.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/usecases/create_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/update_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/validate_vital_measurement.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class MockHealthLogRepository extends Mock implements HealthLogRepository {}

class MockValidateVitalMeasurement extends Mock
    implements ValidateVitalMeasurement {}

class MockUuid extends Mock implements Uuid {}

class MockClock extends Mock implements Clock {}

void main() {
  late MockHealthLogRepository mockRepository;
  late MockValidateVitalMeasurement mockValidate;
  late MockUuid mockUuid;
  late UpdateHealthLog usecase;

  final createdAt = DateTime(2025, 10, 18, 7);
  final timestamp = DateTime(2025, 10, 18, 9);
  final updatedNow = DateTime(2025, 10, 18, 10);

  setUpAll(() {
    registerFallbackValue(
      HealthLog(
        id: 'fallback',
        timestamp: DateTime(2024),
        vitals: const [],
        notes: null,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    );
  });

  setUp(() {
    mockRepository = MockHealthLogRepository();
    mockValidate = MockValidateVitalMeasurement();
    mockUuid = MockUuid();
    final mockClock = MockClock();

    var callIndex = 0;
    final generatedIds = ['generated-vital'];
    when(() => mockUuid.v4()).thenAnswer((_) => generatedIds[callIndex++]);

    when(() => mockClock.now()).thenReturn(updatedNow);

    usecase = UpdateHealthLog(
      repository: mockRepository,
      validateVitalMeasurement: mockValidate,
      uuid: mockUuid,
      clock: mockClock,
    );
  });

  ValidatedVitalMeasurement validated({
    required VitalType type,
    required double value,
    required VitalStatus status,
    ReferenceRange? referenceRange,
    String? unit,
  }) {
    return ValidatedVitalMeasurement(
      type: type,
      value: value,
      unit: unit ?? VitalReferenceDefaults.getUnit(type),
      status: status,
      referenceRange: referenceRange,
    );
  }

  group('UpdateHealthLog', () {
    test('should validate vitals and update health log', () async {
      // Arrange
      final params = UpdateHealthLogParams(
        id: 'log-id',
        timestamp: timestamp,
        createdAt: createdAt,
        notes: 'Updated notes',
        vitals: const [
          VitalMeasurementInput(
            id: 'existing-vital',
            type: VitalType.heartRate,
            value: 75,
          ),
          VitalMeasurementInput(
            type: VitalType.oxygenSaturation,
            value: 96,
          ),
        ],
      );

      final validatedHeartRate = validated(
        type: VitalType.heartRate,
        value: 75,
        status: VitalStatus.warning,
        referenceRange: const ReferenceRange(min: 60, max: 100),
      );
      final validatedSpO2 = validated(
        type: VitalType.oxygenSaturation,
        value: 96,
        status: VitalStatus.normal,
        referenceRange: const ReferenceRange(min: 95, max: 100),
      );

      when(() => mockValidate(
            type: VitalType.heartRate,
            value: 75,
            unit: null,
            referenceRange: null,
          )).thenReturn(Right(validatedHeartRate));
      when(() => mockValidate(
            type: VitalType.oxygenSaturation,
            value: 96,
            unit: null,
            referenceRange: null,
          )).thenReturn(Right(validatedSpO2));

      when(() => mockRepository.updateHealthLog(any())).thenAnswer(
        (_) async => const Right(null),
      );

      // Act
      final result = await usecase(params);

      // Assert
      HealthLog? updatedLog;
      result.fold(
        (failure) => fail('Expected success but got ${failure.message}'),
        (log) => updatedLog = log,
      );

      final log = updatedLog!;
      expect(log.id, 'log-id');
      expect(log.createdAt, createdAt);
      expect(log.updatedAt, updatedNow);
      expect(log.timestamp, timestamp);
      expect(log.notes, 'Updated notes');
      expect(log.vitals.length, 2);
      expect(log.vitals[0].id, 'existing-vital');
      expect(log.vitals[0].status, VitalStatus.warning);
      expect(log.vitals[1].id, 'generated-vital');
      expect(log.vitals[1].status, VitalStatus.normal);

      verify(() => mockRepository.updateHealthLog(log)).called(1);
    });

    test('should return ValidationFailure when id is empty', () async {
      // Arrange
      final params = UpdateHealthLogParams(
        id: '',
        timestamp: timestamp,
        createdAt: createdAt,
        vitals: const [
          VitalMeasurementInput(type: VitalType.heartRate, value: 70),
        ],
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Left<Failure, HealthLog>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('id'));
        },
        (_) => fail('Expected validation failure for empty id'),
      );
      verifyNever(() => mockRepository.updateHealthLog(any()));
    });

    test('should return ValidationFailure when vitals are empty', () async {
      // Arrange
      final params = UpdateHealthLogParams(
        id: 'log-id',
        timestamp: timestamp,
        createdAt: createdAt,
        vitals: const [],
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Left<Failure, HealthLog>>());
      verifyNever(() => mockRepository.updateHealthLog(any()));
    });

    test('should return failure when validation fails for any vital', () async {
      // Arrange
      final params = UpdateHealthLogParams(
        id: 'log-id',
        timestamp: timestamp,
        createdAt: createdAt,
        vitals: const [
          VitalMeasurementInput(type: VitalType.heartRate, value: 200),
        ],
      );

      when(() => mockValidate(
            type: VitalType.heartRate,
            value: 200,
            unit: null,
            referenceRange: null,
          )).thenReturn(
        const Left(ValidationFailure(message: 'Out of range')),
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Left<Failure, HealthLog>>());
      verifyNever(() => mockRepository.updateHealthLog(any()));
    });

    test('should propagate repository failure', () async {
      // Arrange
      final params = UpdateHealthLogParams(
        id: 'log-id',
        timestamp: timestamp,
        createdAt: createdAt,
        vitals: const [
          VitalMeasurementInput(type: VitalType.heartRate, value: 72),
        ],
      );

      final validatedVital = validated(
        type: VitalType.heartRate,
        value: 72,
        status: VitalStatus.normal,
        referenceRange: const ReferenceRange(min: 60, max: 100),
      );

      when(() => mockValidate(
            type: VitalType.heartRate,
            value: 72,
            unit: null,
            referenceRange: null,
          )).thenReturn(Right(validatedVital));

      when(() => mockRepository.updateHealthLog(any())).thenAnswer(
        (_) async => const Left(CacheFailure()),
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, const Left(CacheFailure()));
    });
  });
}
