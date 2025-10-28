import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_trend.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_vital_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart';
import 'package:health_tracker_reports/domain/usecases/get_vital_trend.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/presentation/pages/trends/trends_page.dart';
import 'package:health_tracker_reports/presentation/pages/trends/trends_page_args.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:health_tracker_reports/presentation/providers/trend_provider.dart';
import 'package:health_tracker_reports/presentation/providers/vital_trend_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetAllReports extends Mock implements GetAllReports {}

class _MockSaveReport extends Mock implements SaveReport {}

class _MockGetBiomarkerTrend extends Mock implements GetBiomarkerTrend {}

class _MockCalculateTrend extends Mock implements CalculateTrend {}

class _MockGetVitalTrend extends Mock implements GetVitalTrend {}

class _MockCalculateVitalStatistics extends Mock
    implements CalculateVitalStatistics {}

void main() {
  setUpAll(() {
    registerFallbackValue(VitalType.heartRate);
  });

  testWidgets('shows loading indicator while reports load', (tester) async {
    final getAllReports = _MockGetAllReports();
    final saveReport = _MockSaveReport();
    when(() => getAllReports()).thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getAllReportsProvider.overrideWithValue(getAllReports),
          saveReportUseCaseProvider.overrideWithValue(saveReport),
        ],
        child: const MaterialApp(home: TrendsPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty state when no reports available', (tester) async {
    final getAllReports = _MockGetAllReports();
    final saveReport = _MockSaveReport();
    when(() => getAllReports()).thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getAllReportsProvider.overrideWithValue(getAllReports),
          saveReportUseCaseProvider.overrideWithValue(saveReport),
        ],
        child: const MaterialApp(home: TrendsPage()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('No data available'), findsOneWidget);
  });

  testWidgets('shows error state when loading reports fails', (tester) async {
    final getAllReports = _MockGetAllReports();
    final saveReport = _MockSaveReport();
    when(() => getAllReports()).thenAnswer(
      (_) async => const Left(CacheFailure('failed')),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getAllReportsProvider.overrideWithValue(getAllReports),
          saveReportUseCaseProvider.overrideWithValue(saveReport),
        ],
        child: const MaterialApp(home: TrendsPage()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Error'), findsOneWidget);
    expect(find.textContaining('failed'), findsOneWidget);
  });

  testWidgets('renders biomarker and vital tabs when data available',
      (tester) async {
    final getAllReports = _MockGetAllReports();
    final saveReport = _MockSaveReport();
    final getBiomarkerTrend = _MockGetBiomarkerTrend();
    final calculateTrend = _MockCalculateTrend();
    final getVitalTrend = _MockGetVitalTrend();
    final calculateVitalStats = _MockCalculateVitalStatistics();

    final report = Report(
      id: 'r1',
      date: DateTime(2024, 1, 1),
      labName: 'Acme Lab',
      biomarkers: [
        Biomarker(
          id: 'b1',
          name: 'Glucose',
          value: 100,
          unit: 'mg/dL',
          referenceRange: const ReferenceRange(min: 70, max: 110),
          measuredAt: DateTime(2024, 1, 1),
        ),
      ],
      originalFilePath: 'path',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    when(() => getAllReports()).thenAnswer((_) async => Right([report]));
    when(
      () => getBiomarkerTrend(
        any(),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer(
      (_) async => Right([
        TrendDataPoint(
          date: DateTime(2024, 1, 1),
          value: 95,
          unit: 'mg/dL',
          referenceRange: ReferenceRange(min: 70, max: 110),
          reportId: 'r1',
          status: BiomarkerStatus.normal,
        ),
        TrendDataPoint(
          date: DateTime(2024, 2, 1),
          value: 100,
          unit: 'mg/dL',
          referenceRange: ReferenceRange(min: 70, max: 110),
          reportId: 'r1',
          status: BiomarkerStatus.normal,
        ),
      ]),
    );
    when(() => calculateTrend(any())).thenReturn(
      const Right(
        TrendAnalysis(
          direction: TrendDirection.increasing,
          percentageChange: 5,
          firstValue: 95,
          lastValue: 100,
          dataPointsCount: 2,
        ),
      ),
    );
    when(() => getVitalTrend(any())).thenAnswer(
      (_) async => Right([
        VitalMeasurement(
          id: 'v1',
          type: VitalType.heartRate,
          value: 72,
          unit: 'bpm',
          status: VitalStatus.normal,
        ),
      ]),
    );
    when(() => calculateVitalStats(any())).thenAnswer(
      (_) async => Right(
        const VitalStatistics(
          average: 72,
          min: 70,
          max: 75,
          firstValue: 72,
          lastValue: 72,
          count: 1,
          percentageChange: 0,
          trendDirection: TrendDirection.stable,
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getAllReportsProvider.overrideWithValue(getAllReports),
          saveReportUseCaseProvider.overrideWithValue(saveReport),
          getBiomarkerTrendProvider.overrideWithValue(getBiomarkerTrend),
          calculateTrendProvider.overrideWithValue(calculateTrend),
          getVitalTrendUseCaseProvider.overrideWithValue(getVitalTrend),
          calculateVitalStatisticsUseCaseProvider
              .overrideWithValue(calculateVitalStats),
          selectedVitalTypeProvider.overrideWith((ref) => VitalType.heartRate),
        ],
        child: MaterialApp(
          home: TrendsPage(
            initialArgs: TrendsPageArgs(
              initialBiomarker: 'Glucose',
              initialVitalType: VitalType.heartRate,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Trends'), findsOneWidget);
    expect(find.text('Biomarkers'), findsOneWidget);
    expect(find.text('Vitals'), findsOneWidget);
    expect(find.text('Glucose'), findsWidgets);

    await tester.tap(find.text('Vitals'));
    await tester.pumpAndSettle();

    expect(find.text('Select Vital'), findsOneWidget);
  });
}
