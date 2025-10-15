import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';

void main() {
  group('ReferenceRange', () {
    test('should create a valid ReferenceRange with min and max values', () {
      // Arrange
      const min = 80.0;
      const max = 120.0;

      // Act
      const referenceRange = ReferenceRange(min: min, max: max);

      // Assert
      expect(referenceRange.min, min);
      expect(referenceRange.max, max);
    });

    test('should be equal when min and max values are the same', () {
      // Arrange
      const referenceRange1 = ReferenceRange(min: 80.0, max: 120.0);
      const referenceRange2 = ReferenceRange(min: 80.0, max: 120.0);

      // Assert
      expect(referenceRange1, referenceRange2);
    });

    test('should not be equal when values are different', () {
      // Arrange
      const referenceRange1 = ReferenceRange(min: 80.0, max: 120.0);
      const referenceRange2 = ReferenceRange(min: 70.0, max: 110.0);

      // Assert
      expect(referenceRange1, isNot(referenceRange2));
    });

    group('isOutOfRange', () {
      const referenceRange = ReferenceRange(min: 80.0, max: 120.0);

      test('should return true when value is below minimum', () {
        // Act
        final result = referenceRange.isOutOfRange(70.0);

        // Assert
        expect(result, true);
      });

      test('should return true when value is above maximum', () {
        // Act
        final result = referenceRange.isOutOfRange(130.0);

        // Assert
        expect(result, true);
      });

      test('should return false when value is within range', () {
        // Act
        final result = referenceRange.isOutOfRange(100.0);

        // Assert
        expect(result, false);
      });

      test('should return false when value equals minimum', () {
        // Act
        final result = referenceRange.isOutOfRange(80.0);

        // Assert
        expect(result, false);
      });

      test('should return false when value equals maximum', () {
        // Act
        final result = referenceRange.isOutOfRange(120.0);

        // Assert
        expect(result, false);
      });
    });

    group('edge cases', () {
      test('should handle zero values correctly', () {
        // Arrange
        const referenceRange = ReferenceRange(min: 0.0, max: 10.0);

        // Assert
        expect(referenceRange.isOutOfRange(0.0), false);
        expect(referenceRange.isOutOfRange(5.0), false);
        expect(referenceRange.isOutOfRange(-1.0), true);
      });

      test('should handle negative ranges correctly', () {
        // Arrange
        const referenceRange = ReferenceRange(min: -10.0, max: -5.0);

        // Assert
        expect(referenceRange.isOutOfRange(-7.0), false);
        expect(referenceRange.isOutOfRange(-11.0), true);
        expect(referenceRange.isOutOfRange(-4.0), true);
      });

      test('should handle very small ranges correctly', () {
        // Arrange
        const referenceRange = ReferenceRange(min: 0.001, max: 0.002);

        // Assert
        expect(referenceRange.isOutOfRange(0.0015), false);
        expect(referenceRange.isOutOfRange(0.0005), true);
        expect(referenceRange.isOutOfRange(0.003), true);
      });

      test('should handle same min and max values', () {
        // Arrange
        const referenceRange = ReferenceRange(min: 100.0, max: 100.0);

        // Assert
        expect(referenceRange.isOutOfRange(100.0), false);
        expect(referenceRange.isOutOfRange(99.9), true);
        expect(referenceRange.isOutOfRange(100.1), true);
      });
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const referenceRange = ReferenceRange(min: 80.0, max: 120.0);

      // Assert
      expect(referenceRange.props, [80.0, 120.0]);
    });
  });
}
