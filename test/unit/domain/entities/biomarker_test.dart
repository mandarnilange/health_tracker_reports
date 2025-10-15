import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';

void main() {
  group('Biomarker', () {
    const tId = 'biomarker-123';
    const tName = 'Hemoglobin';
    const tValue = 15.5;
    const tUnit = 'g/dL';
    final tMeasuredAt = DateTime(2025, 10, 15);
    const tReferenceRange = ReferenceRange(min: 13.0, max: 17.0);

    test('should create a valid Biomarker with all fields', () {
      // Act
      final biomarker = Biomarker(
        id: tId,
        name: tName,
        value: tValue,
        unit: tUnit,
        referenceRange: tReferenceRange,
        measuredAt: tMeasuredAt,
      );

      // Assert
      expect(biomarker.id, tId);
      expect(biomarker.name, tName);
      expect(biomarker.value, tValue);
      expect(biomarker.unit, tUnit);
      expect(biomarker.referenceRange, tReferenceRange);
      expect(biomarker.measuredAt, tMeasuredAt);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      final biomarker1 = Biomarker(
        id: tId,
        name: tName,
        value: tValue,
        unit: tUnit,
        referenceRange: tReferenceRange,
        measuredAt: tMeasuredAt,
      );
      final biomarker2 = Biomarker(
        id: tId,
        name: tName,
        value: tValue,
        unit: tUnit,
        referenceRange: tReferenceRange,
        measuredAt: tMeasuredAt,
      );

      // Assert
      expect(biomarker1, biomarker2);
    });

    test('should not be equal when properties are different', () {
      // Arrange
      final biomarker1 = Biomarker(
        id: tId,
        name: tName,
        value: tValue,
        unit: tUnit,
        referenceRange: tReferenceRange,
        measuredAt: tMeasuredAt,
      );
      final biomarker2 = Biomarker(
        id: 'different-id',
        name: tName,
        value: tValue,
        unit: tUnit,
        referenceRange: tReferenceRange,
        measuredAt: tMeasuredAt,
      );

      // Assert
      expect(biomarker1, isNot(biomarker2));
    });

    group('isOutOfRange getter', () {
      test('should return false when value is within range', () {
        // Arrange
        final biomarker = Biomarker(
          id: tId,
          name: tName,
          value: 15.0, // Within 13.0-17.0
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: tMeasuredAt,
        );

        // Assert
        expect(biomarker.isOutOfRange, false);
      });

      test('should return true when value is below minimum', () {
        // Arrange
        final biomarker = Biomarker(
          id: tId,
          name: tName,
          value: 12.0, // Below 13.0
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: tMeasuredAt,
        );

        // Assert
        expect(biomarker.isOutOfRange, true);
      });

      test('should return true when value is above maximum', () {
        // Arrange
        final biomarker = Biomarker(
          id: tId,
          name: tName,
          value: 18.0, // Above 17.0
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: tMeasuredAt,
        );

        // Assert
        expect(biomarker.isOutOfRange, true);
      });
    });

    group('status getter', () {
      test('should return normal when value is within range', () {
        // Arrange
        final biomarker = Biomarker(
          id: tId,
          name: tName,
          value: 15.0,
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: tMeasuredAt,
        );

        // Assert
        expect(biomarker.status, BiomarkerStatus.normal);
      });

      test('should return low when value is below minimum', () {
        // Arrange
        final biomarker = Biomarker(
          id: tId,
          name: tName,
          value: 12.0,
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: tMeasuredAt,
        );

        // Assert
        expect(biomarker.status, BiomarkerStatus.low);
      });

      test('should return high when value is above maximum', () {
        // Arrange
        final biomarker = Biomarker(
          id: tId,
          name: tName,
          value: 18.0,
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: tMeasuredAt,
        );

        // Assert
        expect(biomarker.status, BiomarkerStatus.high);
      });

      test('should return normal when value equals minimum', () {
        // Arrange
        final biomarker = Biomarker(
          id: tId,
          name: tName,
          value: 13.0,
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: tMeasuredAt,
        );

        // Assert
        expect(biomarker.status, BiomarkerStatus.normal);
      });

      test('should return normal when value equals maximum', () {
        // Arrange
        final biomarker = Biomarker(
          id: tId,
          name: tName,
          value: 17.0,
          unit: tUnit,
          referenceRange: tReferenceRange,
          measuredAt: tMeasuredAt,
        );

        // Assert
        expect(biomarker.status, BiomarkerStatus.normal);
      });
    });

    group('copyWith', () {
      final originalBiomarker = Biomarker(
        id: tId,
        name: tName,
        value: tValue,
        unit: tUnit,
        referenceRange: tReferenceRange,
        measuredAt: tMeasuredAt,
      );

      test('should return a copy with updated id', () {
        // Act
        final updated = originalBiomarker.copyWith(id: 'new-id');

        // Assert
        expect(updated.id, 'new-id');
        expect(updated.name, tName);
        expect(updated.value, tValue);
      });

      test('should return a copy with updated name', () {
        // Act
        final updated = originalBiomarker.copyWith(name: 'Glucose');

        // Assert
        expect(updated.id, tId);
        expect(updated.name, 'Glucose');
        expect(updated.value, tValue);
      });

      test('should return a copy with updated value', () {
        // Act
        final updated = originalBiomarker.copyWith(value: 20.0);

        // Assert
        expect(updated.id, tId);
        expect(updated.value, 20.0);
        expect(updated.name, tName);
      });

      test('should return a copy with updated unit', () {
        // Act
        final updated = originalBiomarker.copyWith(unit: 'mg/dL');

        // Assert
        expect(updated.unit, 'mg/dL');
        expect(updated.id, tId);
      });

      test('should return a copy with updated referenceRange', () {
        // Arrange
        const newRange = ReferenceRange(min: 10.0, max: 15.0);

        // Act
        final updated = originalBiomarker.copyWith(referenceRange: newRange);

        // Assert
        expect(updated.referenceRange, newRange);
        expect(updated.id, tId);
      });

      test('should return a copy with updated measuredAt', () {
        // Arrange
        final newDate = DateTime(2025, 11, 15);

        // Act
        final updated = originalBiomarker.copyWith(measuredAt: newDate);

        // Assert
        expect(updated.measuredAt, newDate);
        expect(updated.id, tId);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = originalBiomarker.copyWith();

        // Assert
        expect(copy, originalBiomarker);
      });
    });

    test('should have correct props for Equatable', () {
      // Arrange
      final biomarker = Biomarker(
        id: tId,
        name: tName,
        value: tValue,
        unit: tUnit,
        referenceRange: tReferenceRange,
        measuredAt: tMeasuredAt,
      );

      // Assert
      expect(
        biomarker.props,
        [tId, tName, tValue, tUnit, tReferenceRange, tMeasuredAt],
      );
    });
  });
}
