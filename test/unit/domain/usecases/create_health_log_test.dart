import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_reference_defaults.dart';
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/usecases/create_health_log.dart';
import 'package:health_tracker_reports/domain/usecases/validate_vital_measurement.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class MockHealthLogRepository extends Mock implements HealthLogRepository {}

class MockValidateVitalMeasurement extends Mock
    implements ValidateVitalMeasurement {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late MockHealthLogRepository mockRepository;
  late MockValidateVitalMeasurement mockValidate;
  late MockUuid mockUuid;
  late CreateHealthLog usecase;

  final fixedNow = DateTime(2025, 10, 20, 8, 30);
  final logTimestamp = DateTime(2025, 10, 19, 7);

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

    var callIndex = 0;
    final generatedIds = ['log-id', 'vital-1', 'vital-2', 'vital-3'];
    when(() => mockUuid.v4()).thenAnswer((_) => generatedIds[callIndex++]);

    usecase = CreateHealthLog(
      repository: mockRepository,
      validateVitalMeasurement: mockValidate,
      uuid: mockUuid,
      now: () => fixedNow,
    );
  });

  ValidatedVitalMeasurement buildValidated({
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

  group('CreateHealthLog', () {
    test('should validate vitals, create log, and save via repository', () async {
      // Arrange
      final params = CreateHealthLogParams(
        timestamp: logTimestamp,
        vitals: const [
          VitalMeasurementInput(type: VitalType.heartRate, value: 72),
          VitalMeasurementInput(type: VitalType.oxygenSaturation, value: 98),
        ],
        notes: 'Morning check',
      );

      final validatedHeartRate = buildValidated(
        type: VitalType.heartRate,
        value: 72,
        status: VitalStatus.normal,
        referenceRange: const ReferenceRange(min: 60, max: 100),
      );
      final validatedSpo2 = buildValidated(
        type: VitalType.oxygenSaturation,
        value: 98,
        status: VitalStatus.normal,
        referenceRange: const ReferenceRange(min: 95, max: 100),
      );

      when(() => mockValidate(
            type: VitalType.heartRate,
            value: 72,
            unit: null,
            referenceRange: null,
          )).thenReturn(Right(validatedHeartRate));
      when(() => mockValidate(
            type: VitalType.oxygenSaturation,
            value: 98,
            unit: null,
            referenceRange: null,
          )).thenReturn(Right(validatedSpo2));

      when(() => mockRepository.saveHealthLog(any())).thenAnswer(
        (invocation) async =>
            Right(invocation.positionalArguments.first as HealthLog),
      );

      // Act
      final result = await usecase(params);

      // Assert
      HealthLog? savedLog;
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (log) => savedLog = log,
      );
      final log = savedLog!;

      expect(log.id, 'log-id');
      expect(log.timestamp, logTimestamp);
      expect(log.notes, 'Morning check');
      expect(log.createdAt, fixedNow);
      expect(log.updatedAt, fixedNow);
      expect(log.vitals.length, 2);
      expect(log.vitals[0].id, 'vital-1');
      expect(log.vitals[0].type, VitalType.heartRate);
      expect(log.vitals[0].status, VitalStatus.normal);
      expect(log.vitals[0].referenceRange, validatedHeartRate.referenceRange);
      expect(log.vitals[1].id, 'vital-2');
      verify(() => mockRepository.saveHealthLog(log)).called(1);
    });

    test('should return ValidationFailure when no vitals provided', () async {
      // Arrange
      final params = CreateHealthLogParams(
        timestamp: logTimestamp,
        vitals: const [],
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Left<Failure, HealthLog>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('At least one vital'));
        },
        (_) => fail('Expected validation failure when vitals are empty'),
      );
      verifyNever(() => mockRepository.saveHealthLog(any()));
    });

    test('should return failure when validation fails for any vital', () async {
      // Arrange
      final params = CreateHealthLogParams(
        timestamp: logTimestamp,
        vitals: const [
          VitalMeasurementInput(type: VitalType.heartRate, value: 72),
        ],
      );

      when(() => mockValidate(
            type: VitalType.heartRate,
            value: 72,
            unit: null,
            referenceRange: null,
          )).thenReturn(
        const Left(ValidationFailure(message: 'Invalid value')),
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, isA<Left<Failure, HealthLog>>());
      verifyNever(() => mockRepository.saveHealthLog(any()));
    });

    test('should propagate repository failure', () async {
      // Arrange
      final params = CreateHealthLogParams(
        timestamp: logTimestamp,
        vitals: const [
          VitalMeasurementInput(type: VitalType.heartRate, value: 72),
        ],
      );

      final validatedVital = buildValidated(
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

      when(() => mockRepository.saveHealthLog(any())).thenAnswer(
        (_) async => const Left(CacheFailure()),
      );

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, const Left(CacheFailure()));
    });
  });
}
