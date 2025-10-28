import 'dart:async';

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
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
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

class _StubReportsNotifier extends ReportsNotifier {
  _StubReportsNotifier(List<Report> reports)
      : super(
          getAllReports: _DummyGetAllReports(reports),
          saveReportProvider: () => _DummySaveReport(),
        ) {
    state = AsyncValue.data(reports);
  }

  @override
  Future<void> loadReports() async {
    // no-op
  }
}

class _DummyGetAllReports extends GetAllReports {
  _DummyGetAllReports(this._reports)
      : super(repository: _FakeReportRepository(_reports));

  final List<Report> _reports;

  @override
  Future<Either<Failure, List<Report>>> call() async => Right(_reports);
}

class _DummySaveReport extends SaveReport {
  _DummySaveReport() : super(repository: _FakeReportRepository(const []));

  @override
  Future<Either<Failure, Report>> call(Report report) async => Right(report);
}

class _FakeReportRepository implements ReportRepository {
  _FakeReportRepository(this._reports);

  final List<Report> _reports;

  @override
  Future<Either<Failure, List<Report>>> getAllReports() async => Right(_reports);

  @override
  Future<Either<Failure, Report>> saveReport(Report report) async => Right(report);

  @override
  Future<Either<Failure, Report>> getReportById(String id) async =>
      Left(const CacheFailure());

  @override
  Future<Either<Failure, void>> deleteReport(String id) async => const Right(null);

  @override
  Future<Either<Failure, void>> updateReport(Report report) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<TrendDataPoint>>> getBiomarkerTrend(
    String biomarkerName, {
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      Right(const []);

  @override
  Future<Either<Failure, List<String>>> getDistinctBiomarkerNames() async =>
      Right(const []);

  @override
  Future<Either<Failure, List<Report>>> getReportsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async =>
      Right(_reports);
}

class _ManualTrendNotifier extends TrendNotifier {
  _ManualTrendNotifier(Ref ref)
      : super(
          ref,
          _FakeGetBiomarkerTrend(),
          CalculateTrend(),
        );

  void setState(TrendState newState) => state = newState;
}

class _FakeGetBiomarkerTrend extends GetBiomarkerTrend {
  _FakeGetBiomarkerTrend()
      : super(repository: _FakeReportRepository(const []));

  @override
  Future<Either<Failure, List<TrendDataPoint>>> call(
    String biomarkerName, {
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      const Right([]);
}

Report _buildReport() => Report(
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

List<TrendDataPoint> _trendData() => [
      TrendDataPoint(
        date: DateTime(2024, 1, 1),
        value: 95,
        unit: 'mg/dL',
        referenceRange: const ReferenceRange(min: 70, max: 110),
        reportId: 'r1',
        status: BiomarkerStatus.normal,
      ),
      TrendDataPoint(
        date: DateTime(2024, 2, 1),
        value: 110,
        unit: 'mg/dL',
        referenceRange: const ReferenceRange(min: 70, max: 110),
        reportId: 'r2',
        status: BiomarkerStatus.high,
      ),
    ];

const TrendAnalysis _trendAnalysis = TrendAnalysis(
  direction: TrendDirection.increasing,
  percentageChange: 15,
  firstValue: 95,
  lastValue: 110,
  dataPointsCount: 2,
);

Future<void> _selectVital(WidgetTester tester, VitalType type) async {
  await tester.tap(find.byType(DropdownButton<VitalType>));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(find.text(type.displayName).last);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

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
  testWidgets('biomarker chart container reacts to trend states', (tester) async {
    final report = _buildReport();
    final container = ProviderContainer(
      overrides: [
        reportsProvider.overrideWith((ref) => _StubReportsNotifier([report])),
        trendProvider.overrideWith((ref) => _ManualTrendNotifier(ref)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TrendsPage()),
      ),
    );

    await tester.pump();

    final notifier = container.read(trendProvider.notifier) as _ManualTrendNotifier;
    notifier.setState(const TrendState());
    await tester.pump();

    expect(find.text('Select a biomarker'), findsWidgets);

    notifier.setState(
      const TrendState(
        selectedBiomarkerName: 'Glucose',
        trendData: AsyncValue.loading(),
      ),
    );
    await tester.pump();
    expect(find.text('Loading trend data...'), findsOneWidget);

    notifier.setState(
      TrendState(
        selectedBiomarkerName: 'Glucose',
        trendData: AsyncValue.error(const CacheFailure('boom'), StackTrace.empty),
      ),
    );
    await tester.pump();
    expect(find.text('Failed to load trend data'), findsOneWidget);
    expect(find.text('boom'), findsOneWidget);

    notifier.setState(
      const TrendState(
        selectedBiomarkerName: 'Glucose',
        trendData: AsyncValue.data([]),
      ),
    );
    await tester.pump();
    expect(find.text('No data available'), findsOneWidget);

    notifier.setState(
      TrendState(
        selectedBiomarkerName: 'Glucose',
        trendData: AsyncValue.data(_trendData()),
        trendAnalysis: _trendAnalysis,
      ),
    );
    await tester.pump();

    expect(find.text('Glucose'), findsWidgets);
    expect(find.textContaining('data points'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Latest'), findsOneWidget);
    expect(find.text('Earliest'), findsOneWidget);
  });

  testWidgets('vital trend container handles loading and empty states',
      (tester) async {
    final getVitalTrend = _MockGetVitalTrend();
    final calculateStats = _MockCalculateVitalStatistics();
    final completer = Completer<Either<Failure, List<VitalMeasurement>>>();

    when(() => getVitalTrend(any())).thenAnswer((_) => completer.future);
    when(() => calculateStats(any())).thenAnswer(
      (_) async => const Right(
        VitalStatistics(
          average: 0,
          min: 0,
          max: 0,
          firstValue: 0,
          lastValue: 0,
          count: 0,
          percentageChange: 0,
          trendDirection: TrendDirection.stable,
        ),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        reportsProvider.overrideWith((ref) => _StubReportsNotifier([_buildReport()])),
        trendProvider.overrideWith((ref) => _ManualTrendNotifier(ref)),
        getVitalTrendUseCaseProvider.overrideWithValue(getVitalTrend),
        calculateVitalStatisticsUseCaseProvider.overrideWithValue(
          calculateStats,
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TrendsPage()),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Vitals'));
    await tester.pumpAndSettle();
    await _selectVital(tester, VitalType.heartRate);
    await tester.pump();

    expect(find.text('Loading trend data...'), findsOneWidget);

    completer.complete(const Right([]));
    await tester.pumpAndSettle();

    expect(find.text('No data available'), findsOneWidget);
  });

  testWidgets('vital trend container shows error state when fetch fails',
      (tester) async {
    final getVitalTrend = _MockGetVitalTrend();
    final calculateStats = _MockCalculateVitalStatistics();

    when(() => getVitalTrend(any())).thenAnswer(
      (_) async => const Left(CacheFailure('vital fail')),
    );
    when(() => calculateStats(any())).thenAnswer(
      (_) async => const Right(
        VitalStatistics(
          average: 0,
          min: 0,
          max: 0,
          firstValue: 0,
          lastValue: 0,
          count: 0,
          percentageChange: 0,
          trendDirection: TrendDirection.stable,
        ),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        reportsProvider.overrideWith((ref) => _StubReportsNotifier([_buildReport()])),
        trendProvider.overrideWith((ref) => _ManualTrendNotifier(ref)),
        getVitalTrendUseCaseProvider.overrideWithValue(getVitalTrend),
        calculateVitalStatisticsUseCaseProvider.overrideWithValue(
          calculateStats,
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TrendsPage()),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Vitals'));
    await tester.pumpAndSettle();
    await _selectVital(tester, VitalType.heartRate);
    await tester.pumpAndSettle();

    expect(find.text('Failed to load trend data'), findsOneWidget);
    expect(find.text('vital fail'), findsOneWidget);
  });

  testWidgets('vital trend container shows chart and statistics when data available',
      (tester) async {
    final getVitalTrend = _MockGetVitalTrend();
    final calculateStats = _MockCalculateVitalStatistics();

    when(() => getVitalTrend(any())).thenAnswer(
      (_) async => const Right([
        VitalMeasurement(
          id: 'v1',
          type: VitalType.heartRate,
          value: 72,
          unit: 'bpm',
          status: VitalStatus.normal,
        ),
        VitalMeasurement(
          id: 'v2',
          type: VitalType.heartRate,
          value: 90,
          unit: 'bpm',
          status: VitalStatus.warning,
        ),
      ]),
    );
    when(() => calculateStats(any())).thenAnswer(
      (_) async => const Right(
        VitalStatistics(
          average: 81,
          min: 72,
          max: 90,
          firstValue: 72,
          lastValue: 90,
          count: 2,
          percentageChange: 25,
          trendDirection: TrendDirection.increasing,
        ),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        reportsProvider.overrideWith((ref) => _StubReportsNotifier([_buildReport()])),
        trendProvider.overrideWith((ref) => _ManualTrendNotifier(ref)),
        getVitalTrendUseCaseProvider.overrideWithValue(getVitalTrend),
        calculateVitalStatisticsUseCaseProvider.overrideWithValue(
          calculateStats,
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TrendsPage()),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Vitals'));
    await tester.pumpAndSettle();
    await _selectVital(tester, VitalType.heartRate);
    await tester.pumpAndSettle();

    expect(find.textContaining('data points'), findsOneWidget);
    expect(find.textContaining('Heart Rate'), findsWidgets);
  });
}
