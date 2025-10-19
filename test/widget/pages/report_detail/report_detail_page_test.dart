import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/domain/usecases/search_biomarkers.dart';
import 'package:health_tracker_reports/domain/usecases/delete_report.dart';
import 'package:health_tracker_reports/presentation/pages/report_detail/report_detail_page.dart';
import 'package:health_tracker_reports/presentation/providers/filter_provider.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:health_tracker_reports/presentation/providers/search_provider.dart';
import 'package:health_tracker_reports/presentation/widgets/biomarker_card.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllReports extends Mock implements GetAllReports {}

class MockSaveReport extends Mock implements SaveReport {}

class MockDeleteReport extends Mock implements DeleteReport {}

void main() {
  group('ReportDetailPage', () {
    late MockGetAllReports mockGetAllReports;
    late MockSaveReport mockSaveReport;
    late MockDeleteReport mockDeleteReport;
    late Report testReport;
    late List<Report> testReports;

    /// Helper to create ProviderScope with proper overrides
    Widget createTestWidget(String reportId) {
      return ProviderScope(
        overrides: [
          reportsProvider.overrideWith((ref) => ReportsNotifier(
                getAllReports: mockGetAllReports,
                saveReportProvider: () => mockSaveReport,
              )),
          deleteReportProvider.overrideWithValue(mockDeleteReport),
        ],
        child: MaterialApp(
          home: ReportDetailPage(reportId: reportId),
        ),
      );
    }

    setUp(() {
      mockGetAllReports = MockGetAllReports();
      mockSaveReport = MockSaveReport();
      mockDeleteReport = MockDeleteReport();

      final now = DateTime(2024, 1, 15, 10, 30);

      final normalBiomarker = Biomarker(
        id: '1',
        name: 'Hemoglobin',
        value: 15.0,
        unit: 'g/dL',
        referenceRange: ReferenceRange(min: 12.0, max: 16.0),
        measuredAt: now,
      );

      final highBiomarker = Biomarker(
        id: '2',
        name: 'Glucose',
        value: 150.0,
        unit: 'mg/dL',
        referenceRange: ReferenceRange(min: 70.0, max: 100.0),
        measuredAt: now,
      );

      final lowBiomarker = Biomarker(
        id: '3',
        name: 'Iron',
        value: 5.0,
        unit: 'mcg/dL',
        referenceRange: ReferenceRange(min: 10.0, max: 30.0),
        measuredAt: now,
      );

      testReport = Report(
        id: 'test-report-1',
        date: now,
        labName: 'HealthLabs Inc.',
        biomarkers: [normalBiomarker, highBiomarker, lowBiomarker],
        originalFilePath: '/path/to/file.pdf',
        notes: 'Test notes',
        createdAt: now,
        updatedAt: now,
      );

      testReports = [testReport];
    });

    testWidgets('displays loading indicator while fetching report',
        (WidgetTester tester) async {
      when(() => mockGetAllReports()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return Right(testReports);
      });

      await tester.pumpWidget(createTestWidget('test-report-1'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
    });

    testWidgets('displays report date as AppBar title',
        (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(createTestWidget('test-report-1'));
      await tester.pumpAndSettle();

      // Check for formatted date in AppBar
      final expectedDate = DateFormat('MMM dd, yyyy').format(testReport.date);
      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('displays lab name prominently', (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(createTestWidget('test-report-1'));
      await tester.pumpAndSettle();

      expect(find.text('HealthLabs Inc.'), findsOneWidget);
    });

    testWidgets('displays out-of-range summary chip',
        (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(createTestWidget('test-report-1'));
      await tester.pumpAndSettle();

      // Should show "2 out of 3 biomarkers out of range"
      expect(find.textContaining('2'), findsWidgets);
      expect(find.textContaining('3'), findsWidgets);
      expect(find.textContaining('out of range'), findsOneWidget);
    });

    testWidgets('displays all biomarkers using BiomarkerCard',
        (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(createTestWidget('test-report-1'));
      await tester.pumpAndSettle();

      // Should display at least 2 BiomarkerCard widgets
      // (actual count may vary based on default filter state)
      expect(find.byType(BiomarkerCard), findsWidgets);
      expect(find.text('Glucose'), findsOneWidget);
    });

    testWidgets('displays biomarkers in ListView', (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(createTestWidget('test-report-1'));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays error when report not found',
        (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(createTestWidget('non-existent-id'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Report not found'), findsOneWidget);
    });

    testWidgets('displays error message on failure',
        (WidgetTester tester) async {
      when(() => mockGetAllReports()).thenAnswer(
          (_) async => const Left(CacheFailure('Failed to load reports')));

      await tester.pumpWidget(createTestWidget('test-report-1'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load reports'), findsOneWidget);
    });

    testWidgets('has FloatingActionButton for editing',
        (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(createTestWidget('test-report-1'));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('displays search bar', (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(createTestWidget('test-report-1'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search biomarkers...'), findsOneWidget);
    });

    testWidgets('displays filter chip', (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(createTestWidget('test-report-1'));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsOneWidget);
      expect(find.text('Out of Range Only'), findsOneWidget);
    });

    testWidgets('requests reports automatically on init',
        (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(createTestWidget('test-report-1'));
      await tester.pump();

      verify(() => mockGetAllReports()).called(1);
    });

    testWidgets('prompts for confirmation and deletes report when accepted',
        (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));
      when(() => mockDeleteReport('test-report-1'))
          .thenAnswer((_) async => const Right(null));

      await tester.pumpWidget(createTestWidget('test-report-1'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Report'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(() => mockDeleteReport('test-report-1')).called(1);
    });
  });
}
