import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_statistics.dart';
import 'package:health_tracker_reports/domain/entities/vital_reference_defaults.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_vital_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/get_vital_trend.dart';
import 'package:health_tracker_reports/presentation/providers/vital_trend_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetVitalTrend extends Mock implements GetVitalTrend {}

class MockCalculateVitalStatistics extends Mock
    implements CalculateVitalStatistics {}

void main() {
  late MockGetVitalTrend mockGetVitalTrend;
  late MockCalculateVitalStatistics mockCalculateVitalStatistics;
  late ProviderContainer container;

  setUp(() {
    mockGetVitalTrend = MockGetVitalTrend();
    mockCalculateVitalStatistics = MockCalculateVitalStatistics();

    container = ProviderContainer(
      overrides: [
        getVitalTrendUseCaseProvider.overrideWithValue(mockGetVitalTrend),
        calculateVitalStatisticsUseCaseProvider
            .overrideWithValue(mockCalculateVitalStatistics),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('vitalTrendProvider', () {
    final measurement = VitalMeasurement(
      id: 'm1',
      type: VitalType.heartRate,
      value: 80,
      unit: 'bpm',
      status: VitalStatus.normal,
      referenceRange: const ReferenceRange(min: 60, max: 100),
    );

    test('returns measurements when use case succeeds', () async {
      when(() => mockGetVitalTrend(
            VitalType.heartRate,
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => Right([measurement]));

      final result =
          await container.read(vitalTrendProvider(VitalType.heartRate).future);

      expect(result, [measurement]);
    });

    test('throws failure when use case returns Left', () async {
      when(() => mockGetVitalTrend(
            VitalType.heartRate,
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => const Left(CacheFailure()));

      expect(
        container.read(vitalTrendProvider(VitalType.heartRate).future),
        throwsA(isA<CacheFailure>()),
      );
    });
  });

  group('vitalStatisticsProvider', () {
    final stats = VitalStatistics(
      average: 80,
      min: 75,
      max: 85,
      firstValue: 75,
      lastValue: 85,
      count: 3,
      percentageChange: 13.3,
      trendDirection: TrendDirection.increasing,
    );

    test('returns stats when use case succeeds', () async {
      when(() => mockCalculateVitalStatistics(
            VitalType.heartRate,
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => Right(stats));

      final result = await container
          .read(vitalStatisticsProvider(VitalType.heartRate).future);

      expect(result, stats);
    });

    test('throws failure when use case returns Left', () async {
      when(() => mockCalculateVitalStatistics(
            VitalType.heartRate,
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => const Left(CacheFailure()));

      expect(
        container.read(vitalStatisticsProvider(VitalType.heartRate).future),
        throwsA(isA<CacheFailure>()),
      );
    });
  });
}
