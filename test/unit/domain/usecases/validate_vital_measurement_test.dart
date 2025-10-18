import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_reference_defaults.dart';
import 'package:health_tracker_reports/domain/usecases/validate_vital_measurement.dart';

void main() {
  late ValidateVitalMeasurement usecase;

  setUp(() {
    usecase = ValidateVitalMeasurement();
  });

  group('ValidateVitalMeasurement', () {
    test('should return normal status when value within default range', () {
      // Act
      final result = usecase(
        type: VitalType.heartRate,
        value: 70,
      );

      // Assert
      expect(result, isA<Right<Failure, ValidatedVitalMeasurement>>());
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (validated) {
          expect(validated.type, VitalType.heartRate);
          expect(validated.value, 70);
          expect(validated.status, VitalStatus.normal);
          expect(validated.unit, VitalReferenceDefaults.getUnit(VitalType.heartRate));
          expect(
            validated.referenceRange,
            const ReferenceRange(min: 60, max: 100),
          );
        },
      );
    });

    test('should return warning status when slightly above reference range', () {
      // Act
      final result = usecase(
        type: VitalType.heartRate,
        value: 110, // 10% above max
      );

      // Assert
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (validated) {
          expect(validated.status, VitalStatus.warning);
          expect(
            validated.referenceRange,
            const ReferenceRange(min: 60, max: 100),
          );
        },
      );
    });

    test('should return critical status when significantly above range', () {
      // Act
      final result = usecase(
        type: VitalType.heartRate,
        value: 130, // 30% above max
      );

      // Assert
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (validated) {
          expect(validated.status, VitalStatus.critical);
        },
      );
    });

    test('should use custom reference range when provided', () {
      // Arrange
      const customRange = ReferenceRange(min: 50, max: 70);

      // Act
      final result = usecase(
        type: VitalType.heartRate,
        value: 75,
        referenceRange: customRange,
        unit: 'custom-unit',
      );

      // Assert
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (validated) {
          expect(validated.referenceRange, customRange);
          expect(validated.unit, 'custom-unit');
          expect(validated.status, VitalStatus.warning);
        },
      );
    });

    test('should return normal status when no reference range available', () {
      // Act
      final result = usecase(
        type: VitalType.weight,
        value: 150,
      );

      // Assert
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (validated) {
          expect(validated.status, VitalStatus.normal);
          expect(validated.referenceRange, isNull);
          expect(validated.unit, VitalReferenceDefaults.getUnit(VitalType.weight));
        },
      );
    });

    test('should return ValidationFailure when value is NaN', () {
      // Act
      final result = usecase(
        type: VitalType.heartRate,
        value: double.nan,
      );

      // Assert
      expect(result, isA<Left<Failure, ValidatedVitalMeasurement>>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected failure for NaN value'),
      );
    });

    test('should return ValidationFailure when value is infinite', () {
      // Act
      final result = usecase(
        type: VitalType.heartRate,
        value: double.infinity,
      );

      // Assert
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected failure for infinite value'),
      );
    });
  });
}
