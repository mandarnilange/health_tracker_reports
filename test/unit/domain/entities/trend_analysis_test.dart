import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';

void main() {
  group('TrendAnalysis', () {
    const tDirection = TrendDirection.increasing;
    const tPercentageChange = 15.5;
    const tFirstValue = 100.0;
    const tLastValue = 115.5;
    const tDataPointsCount = 5;

    test('should create a valid TrendAnalysis with all fields', () {
      // Act
      const analysis = TrendAnalysis(
        direction: tDirection,
        percentageChange: tPercentageChange,
        firstValue: tFirstValue,
        lastValue: tLastValue,
        dataPointsCount: tDataPointsCount,
      );

      // Assert
      expect(analysis.direction, tDirection);
      expect(analysis.percentageChange, tPercentageChange);
      expect(analysis.firstValue, tFirstValue);
      expect(analysis.lastValue, tLastValue);
      expect(analysis.dataPointsCount, tDataPointsCount);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      const analysis1 = TrendAnalysis(
        direction: tDirection,
        percentageChange: tPercentageChange,
        firstValue: tFirstValue,
        lastValue: tLastValue,
        dataPointsCount: tDataPointsCount,
      );
      const analysis2 = TrendAnalysis(
        direction: tDirection,
        percentageChange: tPercentageChange,
        firstValue: tFirstValue,
        lastValue: tLastValue,
        dataPointsCount: tDataPointsCount,
      );

      // Assert
      expect(analysis1, analysis2);
    });

    test('should not be equal when properties are different', () {
      // Arrange
      const analysis1 = TrendAnalysis(
        direction: tDirection,
        percentageChange: tPercentageChange,
        firstValue: tFirstValue,
        lastValue: tLastValue,
        dataPointsCount: tDataPointsCount,
      );
      const analysis2 = TrendAnalysis(
        direction: TrendDirection.decreasing,
        percentageChange: -10.5,
        firstValue: tFirstValue,
        lastValue: 89.5,
        dataPointsCount: tDataPointsCount,
      );

      // Assert
      expect(analysis1, isNot(analysis2));
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const analysis = TrendAnalysis(
        direction: tDirection,
        percentageChange: tPercentageChange,
        firstValue: tFirstValue,
        lastValue: tLastValue,
        dataPointsCount: tDataPointsCount,
      );

      // Assert
      expect(
        analysis.props,
        [
          tDirection,
          tPercentageChange,
          tFirstValue,
          tLastValue,
          tDataPointsCount,
        ],
      );
    });

    group('copyWith', () {
      const originalAnalysis = TrendAnalysis(
        direction: tDirection,
        percentageChange: tPercentageChange,
        firstValue: tFirstValue,
        lastValue: tLastValue,
        dataPointsCount: tDataPointsCount,
      );

      test('should return a copy with updated direction', () {
        // Act
        final updated = originalAnalysis.copyWith(
          direction: TrendDirection.decreasing,
        );

        // Assert
        expect(updated.direction, TrendDirection.decreasing);
        expect(updated.percentageChange, tPercentageChange);
        expect(updated.firstValue, tFirstValue);
        expect(updated.lastValue, tLastValue);
        expect(updated.dataPointsCount, tDataPointsCount);
      });

      test('should return a copy with updated percentageChange', () {
        // Act
        final updated = originalAnalysis.copyWith(percentageChange: 25.0);

        // Assert
        expect(updated.percentageChange, 25.0);
        expect(updated.direction, tDirection);
      });

      test('should return a copy with updated firstValue', () {
        // Act
        final updated = originalAnalysis.copyWith(firstValue: 50.0);

        // Assert
        expect(updated.firstValue, 50.0);
        expect(updated.direction, tDirection);
      });

      test('should return a copy with updated lastValue', () {
        // Act
        final updated = originalAnalysis.copyWith(lastValue: 200.0);

        // Assert
        expect(updated.lastValue, 200.0);
        expect(updated.direction, tDirection);
      });

      test('should return a copy with updated dataPointsCount', () {
        // Act
        final updated = originalAnalysis.copyWith(dataPointsCount: 10);

        // Assert
        expect(updated.dataPointsCount, 10);
        expect(updated.direction, tDirection);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = originalAnalysis.copyWith();

        // Assert
        expect(copy, originalAnalysis);
      });

      test('should return a copy with multiple fields updated', () {
        // Act
        final updated = originalAnalysis.copyWith(
          direction: TrendDirection.stable,
          percentageChange: 2.5,
          dataPointsCount: 8,
        );

        // Assert
        expect(updated.direction, TrendDirection.stable);
        expect(updated.percentageChange, 2.5);
        expect(updated.dataPointsCount, 8);
        expect(updated.firstValue, tFirstValue);
        expect(updated.lastValue, tLastValue);
      });
    });

    group('absoluteChange getter', () {
      test('should return absolute difference between last and first values',
          () {
        // Arrange
        const analysis = TrendAnalysis(
          direction: TrendDirection.increasing,
          percentageChange: 15.5,
          firstValue: 100.0,
          lastValue: 115.5,
          dataPointsCount: 5,
        );

        // Act & Assert
        expect(analysis.absoluteChange, 15.5);
      });

      test('should return positive value for increasing trend', () {
        // Arrange
        const analysis = TrendAnalysis(
          direction: TrendDirection.increasing,
          percentageChange: 20.0,
          firstValue: 100.0,
          lastValue: 120.0,
          dataPointsCount: 3,
        );

        // Act & Assert
        expect(analysis.absoluteChange, 20.0);
      });

      test('should return negative value for decreasing trend', () {
        // Arrange
        const analysis = TrendAnalysis(
          direction: TrendDirection.decreasing,
          percentageChange: -15.0,
          firstValue: 100.0,
          lastValue: 85.0,
          dataPointsCount: 4,
        );

        // Act & Assert
        expect(analysis.absoluteChange, -15.0);
      });

      test('should return zero for stable trend', () {
        // Arrange
        const analysis = TrendAnalysis(
          direction: TrendDirection.stable,
          percentageChange: 0.0,
          firstValue: 100.0,
          lastValue: 100.0,
          dataPointsCount: 2,
        );

        // Act & Assert
        expect(analysis.absoluteChange, 0.0);
      });
    });

    group('isSignificantChange getter', () {
      test('should return true when percentage change is greater than 5%', () {
        // Arrange
        const analysis = TrendAnalysis(
          direction: TrendDirection.increasing,
          percentageChange: 10.0,
          firstValue: 100.0,
          lastValue: 110.0,
          dataPointsCount: 3,
        );

        // Act & Assert
        expect(analysis.isSignificantChange, true);
      });

      test('should return true when percentage change is less than -5%', () {
        // Arrange
        const analysis = TrendAnalysis(
          direction: TrendDirection.decreasing,
          percentageChange: -10.0,
          firstValue: 100.0,
          lastValue: 90.0,
          dataPointsCount: 3,
        );

        // Act & Assert
        expect(analysis.isSignificantChange, true);
      });

      test('should return false when percentage change is between -5% and 5%',
          () {
        // Arrange
        const analysis = TrendAnalysis(
          direction: TrendDirection.stable,
          percentageChange: 3.0,
          firstValue: 100.0,
          lastValue: 103.0,
          dataPointsCount: 3,
        );

        // Act & Assert
        expect(analysis.isSignificantChange, false);
      });

      test('should return false when percentage change is exactly 5%', () {
        // Arrange
        const analysis = TrendAnalysis(
          direction: TrendDirection.stable,
          percentageChange: 5.0,
          firstValue: 100.0,
          lastValue: 105.0,
          dataPointsCount: 2,
        );

        // Act & Assert
        expect(analysis.isSignificantChange, false);
      });

      test('should return false when percentage change is exactly -5%', () {
        // Arrange
        const analysis = TrendAnalysis(
          direction: TrendDirection.stable,
          percentageChange: -5.0,
          firstValue: 100.0,
          lastValue: 95.0,
          dataPointsCount: 2,
        );

        // Act & Assert
        expect(analysis.isSignificantChange, false);
      });
    });
  });

  group('TrendDirection', () {
    test('should have increasing direction', () {
      expect(TrendDirection.increasing, isNotNull);
    });

    test('should have decreasing direction', () {
      expect(TrendDirection.decreasing, isNotNull);
    });

    test('should have stable direction', () {
      expect(TrendDirection.stable, isNotNull);
    });

    test('should have exactly 3 directions', () {
      expect(TrendDirection.values.length, 3);
    });
  });
}
