import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';

void main() {
  group('VitalMeasurement', () {
    const tId = 'vital-123';
    const tType = VitalType.bloodPressureSystolic;
    const tValue = 120.0;
    const tUnit = 'mmHg';
    const tStatus = VitalStatus.normal;
    const tReferenceRange = ReferenceRange(min: 90.0, max: 120.0);

    group('constructor', () {
      test('should create instance with all required properties', () {
        // Act
        const vitalMeasurement = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
          referenceRange: tReferenceRange,
        );

        // Assert
        expect(vitalMeasurement.id, tId);
        expect(vitalMeasurement.type, tType);
        expect(vitalMeasurement.value, tValue);
        expect(vitalMeasurement.unit, tUnit);
        expect(vitalMeasurement.status, tStatus);
        expect(vitalMeasurement.referenceRange, tReferenceRange);
      });

      test('should create instance without reference range', () {
        // Act
        const vitalMeasurement = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
        );

        // Assert
        expect(vitalMeasurement.id, tId);
        expect(vitalMeasurement.type, tType);
        expect(vitalMeasurement.value, tValue);
        expect(vitalMeasurement.unit, tUnit);
        expect(vitalMeasurement.status, tStatus);
        expect(vitalMeasurement.referenceRange, isNull);
      });
    });

    group('isOutOfRange getter', () {
      test('should return false when status is normal', () {
        // Arrange
        const vitalMeasurement = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: VitalStatus.normal,
          referenceRange: tReferenceRange,
        );

        // Act
        final result = vitalMeasurement.isOutOfRange;

        // Assert
        expect(result, false);
      });

      test('should return true when status is warning', () {
        // Arrange
        const vitalMeasurement = VitalMeasurement(
          id: tId,
          type: tType,
          value: 125.0,
          unit: tUnit,
          status: VitalStatus.warning,
          referenceRange: tReferenceRange,
        );

        // Act
        final result = vitalMeasurement.isOutOfRange;

        // Assert
        expect(result, true);
      });

      test('should return true when status is critical', () {
        // Arrange
        const vitalMeasurement = VitalMeasurement(
          id: tId,
          type: tType,
          value: 160.0,
          unit: tUnit,
          status: VitalStatus.critical,
          referenceRange: tReferenceRange,
        );

        // Act
        final result = vitalMeasurement.isOutOfRange;

        // Assert
        expect(result, true);
      });
    });

    group('copyWith', () {
      const baseVitalMeasurement = VitalMeasurement(
        id: tId,
        type: tType,
        value: tValue,
        unit: tUnit,
        status: tStatus,
        referenceRange: tReferenceRange,
      );

      test('should return same instance when no parameters provided', () {
        // Act
        final result = baseVitalMeasurement.copyWith();

        // Assert
        expect(result, baseVitalMeasurement);
      });

      test('should copy with new id', () {
        // Act
        const newId = 'vital-456';
        final result = baseVitalMeasurement.copyWith(id: newId);

        // Assert
        expect(result.id, newId);
        expect(result.type, tType);
        expect(result.value, tValue);
        expect(result.unit, tUnit);
        expect(result.status, tStatus);
        expect(result.referenceRange, tReferenceRange);
      });

      test('should copy with new type', () {
        // Act
        const newType = VitalType.heartRate;
        final result = baseVitalMeasurement.copyWith(type: newType);

        // Assert
        expect(result.id, tId);
        expect(result.type, newType);
        expect(result.value, tValue);
        expect(result.unit, tUnit);
        expect(result.status, tStatus);
        expect(result.referenceRange, tReferenceRange);
      });

      test('should copy with new value', () {
        // Act
        const newValue = 115.0;
        final result = baseVitalMeasurement.copyWith(value: newValue);

        // Assert
        expect(result.id, tId);
        expect(result.type, tType);
        expect(result.value, newValue);
        expect(result.unit, tUnit);
        expect(result.status, tStatus);
        expect(result.referenceRange, tReferenceRange);
      });

      test('should copy with new unit', () {
        // Act
        const newUnit = 'bpm';
        final result = baseVitalMeasurement.copyWith(unit: newUnit);

        // Assert
        expect(result.id, tId);
        expect(result.type, tType);
        expect(result.value, tValue);
        expect(result.unit, newUnit);
        expect(result.status, tStatus);
        expect(result.referenceRange, tReferenceRange);
      });

      test('should copy with new status', () {
        // Act
        const newStatus = VitalStatus.warning;
        final result = baseVitalMeasurement.copyWith(status: newStatus);

        // Assert
        expect(result.id, tId);
        expect(result.type, tType);
        expect(result.value, tValue);
        expect(result.unit, tUnit);
        expect(result.status, newStatus);
        expect(result.referenceRange, tReferenceRange);
      });

      test('should copy with new reference range', () {
        // Act
        const newReferenceRange = ReferenceRange(min: 60.0, max: 100.0);
        final result = baseVitalMeasurement.copyWith(
          referenceRange: newReferenceRange,
        );

        // Assert
        expect(result.id, tId);
        expect(result.type, tType);
        expect(result.value, tValue);
        expect(result.unit, tUnit);
        expect(result.status, tStatus);
        expect(result.referenceRange, newReferenceRange);
      });

      test('should copy with multiple properties', () {
        // Act
        const newType = VitalType.oxygenSaturation;
        const newValue = 98.0;
        const newUnit = '%';
        final result = baseVitalMeasurement.copyWith(
          type: newType,
          value: newValue,
          unit: newUnit,
        );

        // Assert
        expect(result.id, tId);
        expect(result.type, newType);
        expect(result.value, newValue);
        expect(result.unit, newUnit);
        expect(result.status, tStatus);
        expect(result.referenceRange, tReferenceRange);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        const vitalMeasurement1 = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
          referenceRange: tReferenceRange,
        );

        const vitalMeasurement2 = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
          referenceRange: tReferenceRange,
        );

        // Assert
        expect(vitalMeasurement1, vitalMeasurement2);
        expect(vitalMeasurement1.hashCode, vitalMeasurement2.hashCode);
      });

      test('should not be equal when id is different', () {
        // Arrange
        const vitalMeasurement1 = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
          referenceRange: tReferenceRange,
        );

        const vitalMeasurement2 = VitalMeasurement(
          id: 'vital-456',
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
          referenceRange: tReferenceRange,
        );

        // Assert
        expect(vitalMeasurement1, isNot(vitalMeasurement2));
      });

      test('should not be equal when type is different', () {
        // Arrange
        const vitalMeasurement1 = VitalMeasurement(
          id: tId,
          type: VitalType.bloodPressureSystolic,
          value: tValue,
          unit: tUnit,
          status: tStatus,
          referenceRange: tReferenceRange,
        );

        const vitalMeasurement2 = VitalMeasurement(
          id: tId,
          type: VitalType.heartRate,
          value: tValue,
          unit: tUnit,
          status: tStatus,
          referenceRange: tReferenceRange,
        );

        // Assert
        expect(vitalMeasurement1, isNot(vitalMeasurement2));
      });

      test('should not be equal when value is different', () {
        // Arrange
        const vitalMeasurement1 = VitalMeasurement(
          id: tId,
          type: tType,
          value: 120.0,
          unit: tUnit,
          status: tStatus,
          referenceRange: tReferenceRange,
        );

        const vitalMeasurement2 = VitalMeasurement(
          id: tId,
          type: tType,
          value: 115.0,
          unit: tUnit,
          status: tStatus,
          referenceRange: tReferenceRange,
        );

        // Assert
        expect(vitalMeasurement1, isNot(vitalMeasurement2));
      });

      test('should not be equal when status is different', () {
        // Arrange
        const vitalMeasurement1 = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: VitalStatus.normal,
          referenceRange: tReferenceRange,
        );

        const vitalMeasurement2 = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: VitalStatus.warning,
          referenceRange: tReferenceRange,
        );

        // Assert
        expect(vitalMeasurement1, isNot(vitalMeasurement2));
      });

      test('should not be equal when reference range is different', () {
        // Arrange
        const vitalMeasurement1 = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
          referenceRange: ReferenceRange(min: 90.0, max: 120.0),
        );

        const vitalMeasurement2 = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
          referenceRange: ReferenceRange(min: 60.0, max: 100.0),
        );

        // Assert
        expect(vitalMeasurement1, isNot(vitalMeasurement2));
      });

      test('should be equal when both have null reference range', () {
        // Arrange
        const vitalMeasurement1 = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
        );

        const vitalMeasurement2 = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
        );

        // Assert
        expect(vitalMeasurement1, vitalMeasurement2);
      });

      test('should not be equal when one has reference range and other does not', () {
        // Arrange
        const vitalMeasurement1 = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
          referenceRange: tReferenceRange,
        );

        const vitalMeasurement2 = VitalMeasurement(
          id: tId,
          type: tType,
          value: tValue,
          unit: tUnit,
          status: tStatus,
        );

        // Assert
        expect(vitalMeasurement1, isNot(vitalMeasurement2));
      });
    });

    group('VitalType enum', () {
      test('should contain all expected vital types', () {
        // Assert
        expect(VitalType.values, contains(VitalType.bloodPressureSystolic));
        expect(VitalType.values, contains(VitalType.bloodPressureDiastolic));
        expect(VitalType.values, contains(VitalType.oxygenSaturation));
        expect(VitalType.values, contains(VitalType.heartRate));
        expect(VitalType.values, contains(VitalType.bodyTemperature));
        expect(VitalType.values, contains(VitalType.weight));
        expect(VitalType.values, contains(VitalType.bloodGlucose));
        expect(VitalType.values, contains(VitalType.sleepHours));
        expect(VitalType.values, contains(VitalType.medicationAdherence));
        expect(VitalType.values, contains(VitalType.respiratoryRate));
        expect(VitalType.values, contains(VitalType.energyLevel));
      });

      test('should have exactly 11 vital types', () {
        // Assert
        expect(VitalType.values.length, 11);
      });
    });

    group('VitalStatus enum', () {
      test('should contain all expected statuses', () {
        // Assert
        expect(VitalStatus.values, contains(VitalStatus.normal));
        expect(VitalStatus.values, contains(VitalStatus.warning));
        expect(VitalStatus.values, contains(VitalStatus.critical));
      });

      test('should have exactly 3 statuses', () {
        // Assert
        expect(VitalStatus.values.length, 3);
      });
    });

    group('different vital types', () {
      test('should work with blood pressure systolic', () {
        // Arrange
        const vitalMeasurement = VitalMeasurement(
          id: 'bp-sys-1',
          type: VitalType.bloodPressureSystolic,
          value: 120.0,
          unit: 'mmHg',
          status: VitalStatus.normal,
          referenceRange: ReferenceRange(min: 90.0, max: 120.0),
        );

        // Assert
        expect(vitalMeasurement.type, VitalType.bloodPressureSystolic);
        expect(vitalMeasurement.value, 120.0);
        expect(vitalMeasurement.unit, 'mmHg');
        expect(vitalMeasurement.isOutOfRange, false);
      });

      test('should work with oxygen saturation', () {
        // Arrange
        const vitalMeasurement = VitalMeasurement(
          id: 'spo2-1',
          type: VitalType.oxygenSaturation,
          value: 98.0,
          unit: '%',
          status: VitalStatus.normal,
          referenceRange: ReferenceRange(min: 95.0, max: 100.0),
        );

        // Assert
        expect(vitalMeasurement.type, VitalType.oxygenSaturation);
        expect(vitalMeasurement.value, 98.0);
        expect(vitalMeasurement.unit, '%');
        expect(vitalMeasurement.isOutOfRange, false);
      });

      test('should work with heart rate', () {
        // Arrange
        const vitalMeasurement = VitalMeasurement(
          id: 'hr-1',
          type: VitalType.heartRate,
          value: 72.0,
          unit: 'bpm',
          status: VitalStatus.normal,
          referenceRange: ReferenceRange(min: 60.0, max: 100.0),
        );

        // Assert
        expect(vitalMeasurement.type, VitalType.heartRate);
        expect(vitalMeasurement.value, 72.0);
        expect(vitalMeasurement.unit, 'bpm');
        expect(vitalMeasurement.isOutOfRange, false);
      });

      test('should work with weight without reference range', () {
        // Arrange
        const vitalMeasurement = VitalMeasurement(
          id: 'weight-1',
          type: VitalType.weight,
          value: 70.0,
          unit: 'kg',
          status: VitalStatus.normal,
        );

        // Assert
        expect(vitalMeasurement.type, VitalType.weight);
        expect(vitalMeasurement.value, 70.0);
        expect(vitalMeasurement.unit, 'kg');
        expect(vitalMeasurement.referenceRange, isNull);
        expect(vitalMeasurement.isOutOfRange, false);
      });

      test('should work with critical status', () {
        // Arrange
        const vitalMeasurement = VitalMeasurement(
          id: 'bp-critical-1',
          type: VitalType.bloodPressureSystolic,
          value: 180.0,
          unit: 'mmHg',
          status: VitalStatus.critical,
          referenceRange: ReferenceRange(min: 90.0, max: 120.0),
        );

        // Assert
        expect(vitalMeasurement.status, VitalStatus.critical);
        expect(vitalMeasurement.isOutOfRange, true);
      });

      test('should work with warning status', () {
        // Arrange
        const vitalMeasurement = VitalMeasurement(
          id: 'bp-warning-1',
          type: VitalType.bloodPressureSystolic,
          value: 135.0,
          unit: 'mmHg',
          status: VitalStatus.warning,
          referenceRange: ReferenceRange(min: 90.0, max: 120.0),
        );

        // Assert
        expect(vitalMeasurement.status, VitalStatus.warning);
        expect(vitalMeasurement.isOutOfRange, true);
      });
    });
  });
}
