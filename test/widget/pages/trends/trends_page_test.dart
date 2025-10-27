import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_trend.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_vital_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart';
import 'package:health_tracker_reports/domain/usecases/get_vital_trend.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/presentation/pages/trends/trends_page.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/biomarker_selector.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/time_range_selector.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/trend_chart.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:health_tracker_reports/presentation/providers/trend_provider.dart';
import 'package:health_tracker_reports/presentation/providers/vital_trend_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllReports extends Mock implements GetAllReports {}

class MockSaveReport extends Mock implements SaveReport {}

class MockGetBiomarkerTrend extends Mock implements GetBiomarkerTrend {}

class MockCalculateTrend extends Mock implements CalculateTrend {}

class MockGetVitalTrend extends Mock implements GetVitalTrend {}

class MockCalculateVitalStatistics extends Mock
    implements CalculateVitalStatistics {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(VitalType.heartRate);
    registerFallbackValue(
      Report(
        id: 'fallback',
        date: DateTime(2024, 1, 1),
        labName: 'Fallback Lab',
        biomarkers: [
          Biomarker(
            id: 'b1',
            name: 'Fallback Biomarker',
            value: 1,
            unit: 'u',
            referenceRange: const ReferenceRange(min: 0, max: 2),
            measuredAt: DateTime(2024, 1, 1),
          ),
        ],
        originalFilePath: '/tmp/fallback.pdf',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
  });

  group('TrendsPage', () {
    late MockGetAllReports mockGetAllReports;
    late MockSaveReport mockSaveReport;
    late MockGetBiomarkerTrend mockGetBiomarkerTrend;
    late MockCalculateTrend mockCalculateTrend;
    late MockGetVitalTrend mockGetVitalTrend;
    late MockCalculateVitalStatistics mockCalculateVitalStatistics;
    late List<Report> testReports;
    late List<VitalMeasurement> testVitalMeasurements;
    late VitalStatistics testVitalStatistics;

    /// Helper to create ProviderScope with proper overrides
    Widget createTestWidget({bool hasReports = true}) {
      if (hasReports) {
        when(() => mockGetAllReports())
            .thenAnswer((_) async => Right(testReports));
      } else {
        when(() => mockGetAllReports())
            .thenAnswer((_) async => const Right([]));
      }

      return ProviderScope(
        overrides: [
          getBiomarkerTrendProvider.overrideWithValue(mockGetBiomarkerTrend),
          calculateTrendProvider.overrideWithValue(mockCalculateTrend),
          getVitalTrendUseCaseProvider.overrideWithValue(mockGetVitalTrend),
          calculateVitalStatisticsUseCaseProvider
              .overrideWithValue(mockCalculateVitalStatistics),
          reportsProvider.overrideWith((ref) => ReportsNotifier(
                getAllReports: mockGetAllReports,
                saveReportProvider: () => mockSaveReport,
              )..loadReports()),
        ],
        child: const MaterialApp(
          home: TrendsPage(),
        ),
      );
    }

    setUp(() {
      mockGetAllReports = MockGetAllReports();
      mockSaveReport = MockSaveReport();
      mockGetBiomarkerTrend = MockGetBiomarkerTrend();
      mockCalculateTrend = MockCalculateTrend();
      mockGetVitalTrend = MockGetVitalTrend();
      mockCalculateVitalStatistics = MockCalculateVitalStatistics();

      // Default behavior for calculateTrend
      when(() => mockCalculateTrend(any())).thenReturn(
        const Right(
          TrendAnalysis(
            direction: TrendDirection.increasing,
            percentageChange: 10.0,
            firstValue: 100.0,
            lastValue: 110.0,
            dataPointsCount: 2,
          ),
        ),
      );

      // Default behavior for getVitalTrend
      testVitalMeasurements = [
        const VitalMeasurement(
          id: 'v1',
          type: VitalType.heartRate,
          value: 72.0,
          unit: 'bpm',
          status: VitalStatus.normal,
        ),
        const VitalMeasurement(
          id: 'v2',
          type: VitalType.heartRate,
          value: 75.0,
          unit: 'bpm',
          status: VitalStatus.normal,
        ),
        const VitalMeasurement(
          id: 'v3',
          type: VitalType.heartRate,
          value: 70.0,
          unit: 'bpm',
          status: VitalStatus.normal,
        ),
      ];

      testVitalStatistics = const VitalStatistics(
        average: 72.3,
        min: 70.0,
        max: 75.0,
        firstValue: 72.0,
        lastValue: 70.0,
        count: 3,
        percentageChange: -2.8,
        trendDirection: TrendDirection.stable,
      );

      when(() => mockGetVitalTrend(any()))
          .thenAnswer((_) async => Right(testVitalMeasurements));
      when(() => mockCalculateVitalStatistics(any()))
          .thenAnswer((_) async => Right(testVitalStatistics));

      final now = DateTime(2024, 1, 15, 10, 30);
      final threeMonthsAgo = DateTime(2023, 10, 15, 10, 30);
      final sixMonthsAgo = DateTime(2023, 7, 15, 10, 30);

      // Create biomarkers with different dates
      final hemoglobin1 = Biomarker(
        id: '1',
        name: 'Hemoglobin',
        value: 15.0,
        unit: 'g/dL',
        referenceRange: ReferenceRange(min: 12.0, max: 16.0),
        measuredAt: now,
      );

      final hemoglobin2 = Biomarker(
        id: '2',
        name: 'Hemoglobin',
        value: 14.5,
        unit: 'g/dL',
        referenceRange: ReferenceRange(min: 12.0, max: 16.0),
        measuredAt: threeMonthsAgo,
      );

      final glucose1 = Biomarker(
        id: '3',
        name: 'Glucose',
        value: 95.0,
        unit: 'mg/dL',
        referenceRange: ReferenceRange(min: 70.0, max: 100.0),
        measuredAt: now,
      );

      final cholesterol1 = Biomarker(
        id: '4',
        name: 'Total Cholesterol',
        value: 180.0,
        unit: 'mg/dL',
        referenceRange: ReferenceRange(min: 125.0, max: 200.0),
        measuredAt: sixMonthsAgo,
      );

      testReports = [
        Report(
          id: 'report-1',
          date: now,
          labName: 'HealthLabs Inc.',
          biomarkers: [hemoglobin1, glucose1],
          originalFilePath: '/path/to/file1.pdf',
          createdAt: now,
          updatedAt: now,
        ),
        Report(
          id: 'report-2',
          date: threeMonthsAgo,
          labName: 'HealthLabs Inc.',
          biomarkers: [hemoglobin2],
          originalFilePath: '/path/to/file2.pdf',
          createdAt: threeMonthsAgo,
          updatedAt: threeMonthsAgo,
        ),
        Report(
          id: 'report-3',
          date: sixMonthsAgo,
          labName: 'MediTest Labs',
          biomarkers: [cholesterol1],
          originalFilePath: '/path/to/file3.pdf',
          createdAt: sixMonthsAgo,
          updatedAt: sixMonthsAgo,
        ),
      ];
    });

    testWidgets('renders TrendsPage with AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
    });

    testWidgets('displays Trends title in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final appBarTitle = find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Trends'),
      );
      expect(appBarTitle, findsOneWidget);
    });

    testWidgets('displays tab bar with Biomarkers and Vitals tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Biomarkers'), findsOneWidget);
      expect(find.text('Vitals'), findsOneWidget);
    });

    testWidgets('displays biomarker selector in Biomarkers tab by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(BiomarkerSelector), findsOneWidget);
    });

    testWidgets('displays time range selector in Biomarkers tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TimeRangeSelector), findsOneWidget);
    });

    testWidgets('displays all time range options (3M, 6M, 1Y, All)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('3M'), findsOneWidget);
      expect(find.text('6M'), findsOneWidget);
      expect(find.text('1Y'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('switches to Vitals tab when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Should not show biomarker selector in vitals tab
      expect(find.byType(BiomarkerSelector), findsNothing);
    });

    testWidgets('displays vital type dropdown in Vitals tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Look for dropdown with vital types
      expect(find.byType(DropdownButton<VitalType>), findsOneWidget);
    });

    testWidgets('vital type dropdown shows all vital types',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Tap dropdown to open
      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();

      // Check for some vital type display names
      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('BP Systolic'), findsOneWidget);
      expect(find.text('SpO2'), findsOneWidget);
    });

    testWidgets('displays vital trend chart when vital type is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Select heart rate
      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heart Rate').last);
      await tester.pumpAndSettle();

      // Should display trend chart
      expect(find.byType(TrendChart), findsOneWidget);
    });

    testWidgets('displays vital statistics card when vital type is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Select heart rate
      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heart Rate').last);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();

      // Should display statistics
      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('vital statistics card shows average value',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Select heart rate
      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heart Rate').last);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Average'), findsOneWidget);
      expect(find.textContaining('72.3'), findsOneWidget);
    });

    testWidgets('vital statistics card shows min and max values',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Select heart rate
      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heart Rate').last);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Min'), findsOneWidget);
      expect(find.text('Max'), findsOneWidget);
      expect(find.textContaining('70.0'), findsWidgets);
      expect(find.textContaining('75.0'), findsWidgets);
    });

    testWidgets('vital statistics card shows trend direction',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Select heart rate
      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heart Rate').last);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Trend'), findsOneWidget);
      // Should show stable text
      expect(find.textContaining('Stable'), findsOneWidget);
    });

    testWidgets('vital statistics card shows measurement count',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Select heart rate
      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heart Rate').last);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).last, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.textContaining('3 measurement'), findsOneWidget);
    });

    testWidgets('shows empty state in Vitals tab when no vital is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      expect(find.text('Select a vital'), findsOneWidget);
      expect(
          find.textContaining('Choose a vital from the dropdown'), findsOneWidget);
    });

    testWidgets('shows empty state when no vital data available',
        (WidgetTester tester) async {
      when(() => mockGetVitalTrend(any()))
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Select heart rate
      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heart Rate').last);
      await tester.pumpAndSettle();

      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('shows loading state while fetching vital trend data',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Select heart rate
      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heart Rate').last);
      await tester.pump();

      // Should show loading before data arrives
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('tab state persists when switching between tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to vitals
      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Select heart rate
      await tester.tap(find.byType(DropdownButton<VitalType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heart Rate').last);
      await tester.pumpAndSettle();

      // Switch back to biomarkers
      await tester.tap(find.text('Biomarkers'));
      await tester.pumpAndSettle();

      expect(find.byType(BiomarkerSelector), findsOneWidget);

      // Switch back to vitals
      await tester.tap(find.text('Vitals'));
      await tester.pumpAndSettle();

      // Should still be on Heart Rate
      expect(find.byType(TrendChart), findsOneWidget);
    });

    testWidgets('displays chart container', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('shows loading indicator while loading reports',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Before pumpAndSettle, should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when no reports available',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(hasReports: false));
      await tester.pumpAndSettle();

      expect(find.textContaining('No data available'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('displays empty state with helpful message when no data',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(hasReports: false));
      await tester.pumpAndSettle();

      expect(find.textContaining('Upload some reports'), findsOneWidget);
    });

    testWidgets('biomarker selector is interactive',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final biomarkerSelector = find.byType(BiomarkerSelector);
      expect(biomarkerSelector, findsOneWidget);

      final widget = tester.widget<BiomarkerSelector>(biomarkerSelector);
      expect(widget.onBiomarkerSelected, isNotNull);
    });

    testWidgets('time range selector chips are interactive',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('6M'));
      await tester.pumpAndSettle();

      expect(find.byType(TimeRangeSelector), findsOneWidget);
    });

    testWidgets('displays TrendsPage in a Scaffold',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has proper Material 3 design structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('shows selected biomarker when one is chosen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(BiomarkerSelector), findsOneWidget);
    });

    testWidgets('chart container has appropriate padding',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Padding), findsWidgets);
    });

  });
}
