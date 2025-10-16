import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_trend.dart';

void main() {
  late CalculateTrend usecase;

  setUp(() {
    usecase = CalculateTrend();
  });

  final tDate1 = DateTime(2023, 1, 1);
  final tDate2 = DateTime(2023, 2, 1);
  final tDate3 = DateTime(2023, 3, 1);
  final tDate4 = DateTime(2023, 4, 1);
  final tDate5 = DateTime(2023, 5, 1);

  final tTrendPoint1 = TrendDataPoint(
    date: tDate1,
    value: 100.0,
    unit: 'g/dL',
    referenceRange: null,
    reportId: 'r1',
    status: BiomarkerStatus.normal,
  );

  final tTrendPoint2 = TrendDataPoint(
    date: tDate2,
    value: 105.0,
    unit: 'g/dL',
    referenceRange: null,
    reportId: 'r2',
    status: BiomarkerStatus.normal,
  );

  final tTrendPoint3 = TrendDataPoint(
    date: tDate3,
    value: 108.0,
    unit: 'g/dL',
    referenceRange: null,
    reportId: 'r3',
    status: BiomarkerStatus.normal,
  );

  final tTrendPoint4 = TrendDataPoint(
    date: tDate4,
    value: 112.0,
    unit: 'g/dL',
    referenceRange: null,
    reportId: 'r4',
    status: BiomarkerStatus.normal,
  );

  final tTrendPoint5 = TrendDataPoint(
    date: tDate5,
    value: 115.0,
    unit: 'g/dL',
    referenceRange: null,
    reportId: 'r5',
    status: BiomarkerStatus.normal,
  );

  group('CalculateTrend', () {
    test('should calculate increasing trend for multiple data points', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1, // 100
        tTrendPoint2, // 105
        tTrendPoint3, // 108
        tTrendPoint4, // 112
        tTrendPoint5, // 115
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          expect(r.direction, TrendDirection.increasing);
          expect(r.percentageChange, 15.0); // (115 - 100) / 100 * 100
          expect(r.firstValue, 100.0);
          expect(r.lastValue, 115.0);
          expect(r.dataPointsCount, 5);
        },
      );
    });

    test('should calculate decreasing trend for multiple data points', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 100.0), // 100
        tTrendPoint2.copyWith(value: 95.0), // 95
        tTrendPoint3.copyWith(value: 90.0), // 90
        tTrendPoint4.copyWith(value: 88.0), // 88
        tTrendPoint5.copyWith(value: 85.0), // 85
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          expect(r.direction, TrendDirection.decreasing);
          expect(r.percentageChange, -15.0); // (85 - 100) / 100 * 100
          expect(r.firstValue, 100.0);
          expect(r.lastValue, 85.0);
          expect(r.dataPointsCount, 5);
        },
      );
    });

    test('should calculate stable trend when change is between -5% and 5%', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 100.0), // 100
        tTrendPoint2.copyWith(value: 101.0), // 101
        tTrendPoint3.copyWith(value: 102.0), // 102
        tTrendPoint4.copyWith(value: 103.0), // 103
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          expect(r.direction, TrendDirection.stable);
          expect(r.percentageChange, 3.0); // (103 - 100) / 100 * 100
          expect(r.firstValue, 100.0);
          expect(r.lastValue, 103.0);
          expect(r.dataPointsCount, 4);
        },
      );
    });

    test('should calculate trend with only 2 data points', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 100.0),
        tTrendPoint2.copyWith(value: 120.0),
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          expect(r.direction, TrendDirection.increasing);
          expect(r.percentageChange, 20.0); // (120 - 100) / 100 * 100
          expect(r.firstValue, 100.0);
          expect(r.lastValue, 120.0);
          expect(r.dataPointsCount, 2);
        },
      );
    });

    test('should return increasing when percentage change is exactly 5.01%',
        () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 100.0),
        tTrendPoint2.copyWith(value: 105.01),
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          expect(r.direction, TrendDirection.increasing);
          expect(r.percentageChange, closeTo(5.01, 0.01));
        },
      );
    });

    test('should return decreasing when percentage change is exactly -5.01%',
        () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 100.0),
        tTrendPoint2.copyWith(value: 94.99),
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          expect(r.direction, TrendDirection.decreasing);
          expect(r.percentageChange, closeTo(-5.01, 0.01));
        },
      );
    });

    test('should return stable when percentage change is exactly 5%', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 100.0),
        tTrendPoint2.copyWith(value: 105.0),
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          expect(r.direction, TrendDirection.stable);
          expect(r.percentageChange, 5.0);
        },
      );
    });

    test('should return stable when percentage change is exactly -5%', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 100.0),
        tTrendPoint2.copyWith(value: 95.0),
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          expect(r.direction, TrendDirection.stable);
          expect(r.percentageChange, -5.0);
        },
      );
    });

    test('should return stable when values are identical', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 100.0),
        tTrendPoint2.copyWith(value: 100.0),
        tTrendPoint3.copyWith(value: 100.0),
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          expect(r.direction, TrendDirection.stable);
          expect(r.percentageChange, 0.0);
          expect(r.firstValue, 100.0);
          expect(r.lastValue, 100.0);
        },
      );
    });

    test('should return failure when given empty list', () {
      // Arrange
      final dataPoints = <TrendDataPoint>[];

      // Act
      final result = usecase(dataPoints);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('should return a failure'),
      );
    });

    test('should return failure when given only 1 data point', () {
      // Arrange
      final dataPoints = [tTrendPoint1];

      // Act
      final result = usecase(dataPoints);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('should return a failure'),
      );
    });

    test('should handle negative values correctly', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: -50.0),
        tTrendPoint2.copyWith(value: -40.0),
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          // From -50 to -40 is a 20% increase in absolute terms
          // (-40 - (-50)) / -50 * 100 = 10 / -50 * 100 = -20%
          expect(r.percentageChange, closeTo(-20.0, 0.01));
          expect(r.firstValue, -50.0);
          expect(r.lastValue, -40.0);
        },
      );
    });

    test('should handle very small values correctly', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 0.5),
        tTrendPoint2.copyWith(value: 0.6),
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          // (0.6 - 0.5) / 0.5 * 100 = 20%
          expect(r.percentageChange, closeTo(20.0, 0.01));
          expect(r.direction, TrendDirection.increasing);
        },
      );
    });

    test('should handle very large values correctly', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 10000.0),
        tTrendPoint2.copyWith(value: 11000.0),
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          // (11000 - 10000) / 10000 * 100 = 10%
          expect(r.percentageChange, closeTo(10.0, 0.01));
          expect(r.direction, TrendDirection.increasing);
        },
      );
    });

    test('should handle decimal percentages correctly', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 100.0),
        tTrendPoint2.copyWith(value: 107.5),
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          // (107.5 - 100) / 100 * 100 = 7.5%
          expect(r.percentageChange, closeTo(7.5, 0.01));
          expect(r.direction, TrendDirection.increasing);
          expect(r.firstValue, 100.0);
          expect(r.lastValue, 107.5);
        },
      );
    });

    test(
        'should calculate based on first and last values, not intermediate ones',
        () {
      // Arrange - values fluctuate but end up higher
      final dataPoints = [
        tTrendPoint1.copyWith(value: 100.0), // Start
        tTrendPoint2.copyWith(value: 80.0), // Dip
        tTrendPoint3.copyWith(value: 90.0), // Recovery
        tTrendPoint4.copyWith(value: 120.0), // Peak
        tTrendPoint5.copyWith(value: 110.0), // End
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      result.fold(
        (l) => fail('should not return a failure'),
        (r) {
          // Should calculate based on first (100) and last (110)
          expect(r.percentageChange, 10.0); // (110 - 100) / 100 * 100
          expect(r.direction, TrendDirection.increasing);
          expect(r.firstValue, 100.0);
          expect(r.lastValue, 110.0);
          expect(r.dataPointsCount, 5);
        },
      );
    });

    test('should return failure when first value is zero', () {
      // Arrange
      final dataPoints = [
        tTrendPoint1.copyWith(value: 0.0),
        tTrendPoint2.copyWith(value: 10.0),
      ];

      // Act
      final result = usecase(dataPoints);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('should return a failure when first value is zero'),
      );
    });
  });
}
