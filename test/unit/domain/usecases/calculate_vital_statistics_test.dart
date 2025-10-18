import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_vital_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/get_vital_trend.dart';
import 'package:mocktail/mocktail.dart';

class MockGetVitalTrend extends Mock implements GetVitalTrend {}

void main() {
  late CalculateVitalStatistics usecase;
  late MockGetVitalTrend mockGetVitalTrend;

  setUp(() {
    mockGetVitalTrend = MockGetVitalTrend();
    usecase = CalculateVitalStatistics(getVitalTrend: mockGetVitalTrend);
  });

  const measurementA = VitalMeasurement(
    id: '2025-10-17T07:00:00',
    type: VitalType.heartRate,
    value: 80,
    unit: 'bpm',
    status: VitalStatus.normal,
  );
  const measurementB = VitalMeasurement(
    id: '2025-10-18T07:00:00',
    type: VitalType.heartRate,
    value: 85,
    unit: 'bpm',
    status: VitalStatus.warning,
  );
  const measurementC = VitalMeasurement(
    id: '2025-10-19T07:00:00',
    type: VitalType.heartRate,
    value: 90,
    unit: 'bpm',
    status: VitalStatus.critical,
  );

  group('CalculateVitalStatistics', () {
    test('should calculate statistics and trend information', () async {
      // Arrange
      when(
        () => mockGetVitalTrend(
          VitalType.heartRate,
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => const Right([measurementA, measurementB, measurementC]),
      );

      // Act
      final result = await usecase(
        VitalType.heartRate,
        startDate: DateTime(2025, 10, 17),
        endDate: DateTime(2025, 10, 19),
      );

      // Assert
      result.fold(
        (failure) => fail('Expected success but got ${failure.message}'),
        (stats) {
          expect(stats.count, 3);
          expect(stats.average, closeTo(85, 0.001));
          expect(stats.min, 80);
          expect(stats.max, 90);
          expect(stats.firstValue, 80);
          expect(stats.lastValue, 90);
          expect(stats.percentageChange, closeTo(12.5, 0.001));
          expect(stats.trendDirection, TrendDirection.increasing);
        },
      );
    });

    test('should handle single measurement gracefully', () async {
      // Arrange
      when(
        () => mockGetVitalTrend(
          VitalType.heartRate,
          startDate: null,
          endDate: null,
        ),
      ).thenAnswer(
        (_) async => const Right([measurementB]),
      );

      // Act
      final result = await usecase(VitalType.heartRate);

      // Assert
      result.fold(
        (failure) => fail('Expected success but got ${failure.message}'),
        (stats) {
          expect(stats.count, 1);
          expect(stats.average, 85);
          expect(stats.min, 85);
          expect(stats.max, 85);
          expect(stats.percentageChange, 0);
          expect(stats.trendDirection, TrendDirection.stable);
        },
      );
    });

    test('should return NotFoundFailure when no measurements available', () async {
      // Arrange
      when(
        () => mockGetVitalTrend(
          VitalType.heartRate,
          startDate: null,
          endDate: null,
        ),
      ).thenAnswer(
        (_) async => const Right(<VitalMeasurement>[]),
      );

      // Act
      final result = await usecase(VitalType.heartRate);

      // Assert
      expect(
        result,
        const Left(NotFoundFailure(message: 'No measurements found for vital')),
      );
    });

    test('should propagate failure from trend retrieval', () async {
      // Arrange
      when(
        () => mockGetVitalTrend(
          VitalType.heartRate,
          startDate: null,
          endDate: null,
        ),
      ).thenAnswer(
        (_) async => const Left(CacheFailure()),
      );

      // Act
      final result = await usecase(VitalType.heartRate);

      // Assert
      expect(result, const Left(CacheFailure()));
    });
  });
}
