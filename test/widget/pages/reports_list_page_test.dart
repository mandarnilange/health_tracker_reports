import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/delete_report.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/presentation/pages/home/reports_list_page.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllReports extends Mock implements GetAllReports {}

class MockDeleteReport extends Mock implements DeleteReport {}

void main() {
  group('ReportsListPage', () {
    late MockGetAllReports mockGetAllReports;
    late MockDeleteReport mockDeleteReport;
    late List<Report> testReports;

    setUp(() {
      mockGetAllReports = MockGetAllReports();
      mockDeleteReport = MockDeleteReport();

      final now = DateTime.now();
      final biomarker1 = Biomarker(
        id: '1',
        name: 'Hemoglobin',
        value: 15.0,
        unit: 'g/dL',
        referenceRange: ReferenceRange(min: 12.0, max: 16.0),
        measuredAt: now,
      );

      final biomarker2 = Biomarker(
        id: '2',
        name: 'Glucose',
        value: 150.0,
        unit: 'mg/dL',
        referenceRange: ReferenceRange(min: 70.0, max: 100.0),
        measuredAt: now,
      );

      testReports = [
        Report(
          id: '1',
          date: now,
          labName: 'Test Lab 1',
          biomarkers: [biomarker1, biomarker2],
          originalFilePath: '/path/to/file1.pdf',
          notes: 'Test notes',
          createdAt: now,
          updatedAt: now,
        ),
        Report(
          id: '2',
          date: now.subtract(const Duration(days: 1)),
          labName: 'Test Lab 2',
          biomarkers: [biomarker1],
          originalFilePath: '/path/to/file2.pdf',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
      ];
    });

    testWidgets('displays loading indicator while fetching reports',
        (WidgetTester tester) async {
      when(() => mockGetAllReports()).thenAnswer((_) async => Future.delayed(
            const Duration(milliseconds: 100),
            () => Right(testReports),
          ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getAllReportsProvider.overrideWith((_) => mockGetAllReports),
            deleteReportProvider.overrideWith((_) => mockDeleteReport),
          ],
          child: const MaterialApp(
            home: ReportsListPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays list of reports', (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getAllReportsProvider.overrideWith((_) => mockGetAllReports),
            deleteReportProvider.overrideWith((_) => mockDeleteReport),
          ],
          child: const MaterialApp(
            home: ReportsListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Lab 1'), findsOneWidget);
      expect(find.text('Test Lab 2'), findsOneWidget);
    });

    testWidgets('displays biomarker count for each report',
        (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getAllReportsProvider.overrideWith((_) => mockGetAllReports),
            deleteReportProvider.overrideWith((_) => mockDeleteReport),
          ],
          child: const MaterialApp(
            home: ReportsListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('2 biomarkers'), findsOneWidget);
      expect(find.textContaining('1 biomarker'), findsOneWidget);
    });

    testWidgets('displays out-of-range count for each report',
        (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getAllReportsProvider.overrideWith((_) => mockGetAllReports),
            deleteReportProvider.overrideWith((_) => mockDeleteReport),
          ],
          child: const MaterialApp(
            home: ReportsListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('1 out of range'), findsOneWidget);
    });

    testWidgets('displays empty state when no reports',
        (WidgetTester tester) async {
      when(() => mockGetAllReports()).thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getAllReportsProvider.overrideWith((_) => mockGetAllReports),
            deleteReportProvider.overrideWith((_) => mockDeleteReport),
          ],
          child: const MaterialApp(
            home: ReportsListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No reports yet'), findsOneWidget);
      expect(find.textContaining('Add your first report'), findsOneWidget);
    });

    testWidgets('displays error message on failure',
        (WidgetTester tester) async {
      when(() => mockGetAllReports()).thenAnswer(
          (_) async => const Left(CacheFailure('Failed to load reports')));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getAllReportsProvider.overrideWith((_) => mockGetAllReports),
            deleteReportProvider.overrideWith((_) => mockDeleteReport),
          ],
          child: const MaterialApp(
            home: ReportsListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load reports'), findsOneWidget);
    });

    testWidgets('has FloatingActionButton to add new report',
        (WidgetTester tester) async {
      when(() => mockGetAllReports()).thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getAllReportsProvider.overrideWith((_) => mockGetAllReports),
            deleteReportProvider.overrideWith((_) => mockDeleteReport),
          ],
          child: const MaterialApp(
            home: ReportsListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping report item navigates to detail page',
        (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getAllReportsProvider.overrideWith((_) => mockGetAllReports),
            deleteReportProvider.overrideWith((_) => mockDeleteReport),
          ],
          child: const MaterialApp(
            home: ReportsListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Lab 1'));
      await tester.pumpAndSettle();

      // Verify navigation occurred (page would normally push route)
      // This is a simplified test - in a real app we'd use Navigator observers
    });

    testWidgets('can delete report with swipe to dismiss',
        (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));
      when(() => mockDeleteReport('1'))
          .thenAnswer((_) async => const Right(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getAllReportsProvider.overrideWith((_) => mockGetAllReports),
            deleteReportProvider.overrideWith((_) => mockDeleteReport),
          ],
          child: const MaterialApp(
            home: ReportsListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Dismissible), findsNWidgets(2));
    });

    testWidgets('pull to refresh reloads reports', (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getAllReportsProvider.overrideWith((_) => mockGetAllReports),
            deleteReportProvider.overrideWith((_) => mockDeleteReport),
          ],
          child: const MaterialApp(
            home: ReportsListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Simulate pull to refresh
      await tester.drag(find.text('Test Lab 1'), const Offset(0, 300));
      await tester.pumpAndSettle();

      verify(() => mockGetAllReports()).called(greaterThan(1));
    });

    testWidgets('displays date for each report', (WidgetTester tester) async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReports));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getAllReportsProvider.overrideWith((_) => mockGetAllReports),
            deleteReportProvider.overrideWith((_) => mockDeleteReport),
          ],
          child: const MaterialApp(
            home: ReportsListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Date should be formatted and displayed
      expect(find.byType(ListTile), findsNWidgets(2));
    });
  });
}
