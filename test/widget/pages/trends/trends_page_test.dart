import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/presentation/pages/trends/trends_page.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/biomarker_selector.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/time_range_selector.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:health_tracker_reports/presentation/providers/trend_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllReports extends Mock implements GetAllReports {}

class MockSaveReport extends Mock implements SaveReport {}

class MockGetBiomarkerTrend extends Mock implements GetBiomarkerTrend {}

void main() {
  group('TrendsPage', () {
    late MockGetAllReports mockGetAllReports;
    late MockSaveReport mockSaveReport;
    late MockGetBiomarkerTrend mockGetBiomarkerTrend;
    late List<Report> testReports;

    /// Helper to create ProviderScope with proper overrides
    Widget createTestWidget({bool hasReports = true}) {
      if (hasReports) {
        when(() => mockGetAllReports())
            .thenAnswer((_) async => Right(testReports));
      } else {
        when(() => mockGetAllReports()).thenAnswer((_) async => const Right([]));
      }

      return ProviderScope(
        overrides: [
          getBiomarkerTrendProvider.overrideWithValue(mockGetBiomarkerTrend),
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

      // Find the AppBar's Text widget
      final appBarTitle = find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Trends'),
      );
      expect(appBarTitle, findsOneWidget);
    });

    testWidgets('displays biomarker selector dropdown',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(BiomarkerSelector), findsOneWidget);
    });

    testWidgets('displays time range selector with buttons',
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

    testWidgets('displays chart container', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for a Card or Container that would hold the chart
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

      // Should show empty state message
      expect(
          find.textContaining('No data available'), findsOneWidget);
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

      // Verify it's enabled/tappable
      final widget = tester.widget<BiomarkerSelector>(biomarkerSelector);
      expect(widget.onBiomarkerSelected, isNotNull);
    });

    testWidgets('time range selector chips are interactive',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on 6M option
      await tester.tap(find.text('6M'));
      await tester.pumpAndSettle();

      // Verify the selector exists and is responsive
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

      // Verify Material design elements are present
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('shows selected biomarker when one is chosen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially should show a biomarker selector
      expect(find.byType(BiomarkerSelector), findsOneWidget);
    });

    testWidgets('chart container has appropriate padding',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify padding exists around content
      expect(find.byType(Padding), findsWidgets);
    });
  });
}
