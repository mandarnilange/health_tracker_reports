import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_trend.dart';
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart';
import 'package:health_tracker_reports/presentation/providers/trend_provider.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockGetBiomarkerTrend extends Mock implements GetBiomarkerTrend {}

class MockCalculateTrend extends Mock implements CalculateTrend {}

void main() {
  late ProviderContainer container;
  late MockGetBiomarkerTrend mockGetBiomarkerTrend;
  late MockCalculateTrend mockCalculateTrend;
  final fixedNow = DateTime(2024, 6, 15);

  final hemoglobinPoint = TrendDataPoint(
    date: DateTime(2024, 6, 1),
    value: 14.5,
    unit: 'g/dL',
    referenceRange: const ReferenceRange(min: 13.0, max: 17.0),
    reportId: 'report-1',
    status: BiomarkerStatus.normal,
  );

  final trendAnalysis = const TrendAnalysis(
    direction: TrendDirection.increasing,
    percentageChange: 15.5,
    firstValue: 100.0,
    lastValue: 115.5,
    dataPointsCount: 2,
  );

  setUp(() {
    mockGetBiomarkerTrend = MockGetBiomarkerTrend();
    mockCalculateTrend = MockCalculateTrend();

    // Default behavior for calculateTrend
    when(() => mockCalculateTrend(any())).thenReturn(Right(trendAnalysis));

    container = ProviderContainer(
      overrides: [
        getBiomarkerTrendProvider.overrideWithValue(mockGetBiomarkerTrend),
        calculateTrendProvider.overrideWithValue(mockCalculateTrend),
        nowProvider.overrideWithValue(fixedNow),
      ],
    );

    addTearDown(container.dispose);
  });

  group('TrendNotifier', () {
    test('initial state has no biomarker selected and empty trend data', () {
      final state = container.read(trendProvider);

      expect(state.selectedBiomarkerName, isNull);
      expect(state.selectedTimeRange, TimeRange.all);
      expect(state.trendData, const AsyncValue<List<TrendDataPoint>>.data([]));
    });

    test('selectBiomarker loads trend data on success', () async {
      when(
        () => mockGetBiomarkerTrend(
          'Hemoglobin',
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right([hemoglobinPoint]));

      final notifier = container.read(trendProvider.notifier);
      await notifier.selectBiomarker('Hemoglobin');

      final state = container.read(trendProvider);
      expect(state.selectedBiomarkerName, 'Hemoglobin');
      expect(state.trendData.asData?.value, [hemoglobinPoint]);
      verify(
        () => mockGetBiomarkerTrend(
          'Hemoglobin',
          startDate: null,
          endDate: null,
        ),
      ).called(1);
    });

    test('selectBiomarker handles failures', () async {
      when(
        () => mockGetBiomarkerTrend(
          'Hemoglobin',
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Left(const CacheFailure()));

      final notifier = container.read(trendProvider.notifier);
      await notifier.selectBiomarker('Hemoglobin');

      final state = container.read(trendProvider);
      expect(state.trendData.hasError, isTrue);
      expect(state.trendData.error, isA<CacheFailure>());
    });

    test('selectTimeRange reloads data with cutoff date', () async {
      when(
        () => mockGetBiomarkerTrend(
          any(),
          startDate: captureAny(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right([hemoglobinPoint]));

      final notifier = container.read(trendProvider.notifier);
      await notifier.selectBiomarker('Hemoglobin');

      await notifier.selectTimeRange(TimeRange.threeMonths);

      final expectedCutoff =
          DateTime(fixedNow.year, fixedNow.month - 3, fixedNow.day);

      expect(container.read(trendProvider).selectedTimeRange,
          TimeRange.threeMonths);
      verifyInOrder([
        () => mockGetBiomarkerTrend(
              'Hemoglobin',
              startDate: null,
              endDate: null,
            ),
        () => mockGetBiomarkerTrend(
              'Hemoglobin',
              startDate: expectedCutoff,
              endDate: null,
            ),
      ]);
    });

    test('selectBiomarker(null) clears selection and data', () async {
      when(
        () => mockGetBiomarkerTrend(
          'Hemoglobin',
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right([hemoglobinPoint]));

      final notifier = container.read(trendProvider.notifier);
      await notifier.selectBiomarker('Hemoglobin');
      await notifier.selectBiomarker(null);

      final state = container.read(trendProvider);
      expect(state.selectedBiomarkerName, isNull);
      expect(state.trendData.asData?.value, isEmpty);
    });
  });
}
