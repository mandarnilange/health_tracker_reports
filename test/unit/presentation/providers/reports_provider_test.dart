import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllReports extends Mock implements GetAllReports {}

class MockSaveReport extends Mock implements SaveReport {}

void main() {
  late MockGetAllReports mockGetAllReports;
  late MockSaveReport mockSaveReport;

  final testReports = [
    Report(
      id: 'report-1',
      date: DateTime(2025, 10, 15),
      labName: 'Test Lab',
      biomarkers: [
        Biomarker(
          id: 'bio-1',
          name: 'Hemoglobin',
          value: 14.2,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 17.0),
          measuredAt: DateTime(2025, 10, 15),
        ),
      ],
      originalFilePath: '/tmp/report-1.pdf',
      createdAt: DateTime(2025, 10, 15),
      updatedAt: DateTime(2025, 10, 15),
    ),
  ];

  setUp(() {
    mockGetAllReports = MockGetAllReports();
    mockSaveReport = MockSaveReport();
  });

  test('initial state should be loading', () {
    when(() => mockGetAllReports()).thenAnswer((_) async => Future.delayed(
          const Duration(milliseconds: 10),
          () => Right(testReports),
        ));

    final notifier = ReportsNotifier(
      getAllReports: mockGetAllReports,
      saveReportProvider: () => mockSaveReport,
    );

    expect(notifier.state, isA<AsyncLoading<List<Report>>>());
  });

  test('loadReports should emit data state on success', () async {
    when(() => mockGetAllReports()).thenAnswer((_) async => Right(testReports));

    final notifier = ReportsNotifier(
      getAllReports: mockGetAllReports,
      saveReportProvider: () => mockSaveReport,
    );

    await notifier.loadReports();

    expect(notifier.state, isA<AsyncData<List<Report>>>());
    final state = notifier.state as AsyncData<List<Report>>;
    expect(state.value, equals(testReports));
    verify(() => mockGetAllReports()).called(greaterThanOrEqualTo(1));
  });

  test('loadReports should emit error state on failure', () async {
    when(() => mockGetAllReports())
        .thenAnswer((_) async => const Left(CacheFailure('Failed')));

    final notifier = ReportsNotifier(
      getAllReports: mockGetAllReports,
      saveReportProvider: () => mockSaveReport,
    );

    await notifier.loadReports();

    expect(notifier.state, isA<AsyncError<List<Report>>>());
  });

  test('saveReport should persist and refresh on success', () async {
    final report = testReports.first;

    when(() => mockGetAllReports()).thenAnswer((_) async => Right(testReports));

    final notifier = ReportsNotifier(
      getAllReports: mockGetAllReports,
      saveReportProvider: () => mockSaveReport,
    );

    when(() => mockSaveReport(report)).thenAnswer((_) async => Right(report));

    final result = await notifier.saveReport(report);

    expect(result, equals(Right(report)));
    verify(() => mockSaveReport(report)).called(1);
    verify(() => mockGetAllReports()).called(greaterThanOrEqualTo(1));
  });

  test('saveReport should emit error state on failure', () async {
    final report = testReports.first;
    const failure = CacheFailure('Unable to save');

    when(() => mockGetAllReports()).thenAnswer((_) async => Right(testReports));

    final notifier = ReportsNotifier(
      getAllReports: mockGetAllReports,
      saveReportProvider: () => mockSaveReport,
    );

    await Future<void>.delayed(Duration.zero);

    when(() => mockSaveReport(report))
        .thenAnswer((_) async => const Left(failure));

    final result = await notifier.saveReport(report);

    expect(result, equals(const Left(failure)));
    expect(notifier.state, isA<AsyncError<List<Report>>>());
  });

  test('refresh should delegate to loadReports', () async {
    when(() => mockGetAllReports()).thenAnswer((_) async => Right(testReports));

    final notifier = ReportsNotifier(
      getAllReports: mockGetAllReports,
      saveReportProvider: () => mockSaveReport,
    );

    await notifier.refresh();

    verify(() => mockGetAllReports()).called(greaterThanOrEqualTo(1));
  });

  group('Report Sorting', () {
    late List<Report> testReportsForSorting;

    setUp(() {
      // Create reports with different dates and out-of-range counts
      testReportsForSorting = [
        Report(
          id: 'report-1',
          date: DateTime(2025, 10, 15), // Newest
          labName: 'Beta Lab',
          biomarkers: [
            Biomarker(
              id: 'bio-1',
              name: 'Hemoglobin',
              value: 14.2,
              unit: 'g/dL',
              referenceRange: const ReferenceRange(min: 12.0, max: 17.0),
              measuredAt: DateTime(2025, 10, 15),
            ),
            Biomarker(
              id: 'bio-2',
              name: 'Glucose',
              value: 120.0, // Out of range
              unit: 'mg/dL',
              referenceRange: const ReferenceRange(min: 70.0, max: 100.0),
              measuredAt: DateTime(2025, 10, 15),
            ),
          ],
          originalFilePath: '/tmp/report-1.pdf',
          createdAt: DateTime(2025, 10, 15),
          updatedAt: DateTime(2025, 10, 15),
        ),
        Report(
          id: 'report-2',
          date: DateTime(2025, 9, 10), // Middle date
          labName: 'Alpha Lab',
          biomarkers: [
            Biomarker(
              id: 'bio-3',
              name: 'Hemoglobin',
              value: 14.2,
              unit: 'g/dL',
              referenceRange: const ReferenceRange(min: 12.0, max: 17.0),
              measuredAt: DateTime(2025, 9, 10),
            ),
            Biomarker(
              id: 'bio-4',
              name: 'Cholesterol',
              value: 250.0, // Out of range
              unit: 'mg/dL',
              referenceRange: const ReferenceRange(min: 0.0, max: 200.0),
              measuredAt: DateTime(2025, 9, 10),
            ),
            Biomarker(
              id: 'bio-5',
              name: 'Triglycerides',
              value: 180.0, // Out of range
              unit: 'mg/dL',
              referenceRange: const ReferenceRange(min: 0.0, max: 150.0),
              measuredAt: DateTime(2025, 9, 10),
            ),
          ],
          originalFilePath: '/tmp/report-2.pdf',
          createdAt: DateTime(2025, 9, 10),
          updatedAt: DateTime(2025, 9, 10),
        ),
        Report(
          id: 'report-3',
          date: DateTime(2025, 8, 5), // Oldest
          labName: 'Gamma Lab',
          biomarkers: [
            Biomarker(
              id: 'bio-6',
              name: 'Hemoglobin',
              value: 10.0, // Out of range
              unit: 'g/dL',
              referenceRange: const ReferenceRange(min: 12.0, max: 17.0),
              measuredAt: DateTime(2025, 8, 5),
            ),
            Biomarker(
              id: 'bio-7',
              name: 'WBC',
              value: 12000.0, // Out of range
              unit: 'cells/uL',
              referenceRange: const ReferenceRange(min: 4000.0, max: 11000.0),
              measuredAt: DateTime(2025, 8, 5),
            ),
            Biomarker(
              id: 'bio-8',
              name: 'Platelets',
              value: 450000.0, // Out of range
              unit: 'cells/uL',
              referenceRange:
                  const ReferenceRange(min: 150000.0, max: 400000.0),
              measuredAt: DateTime(2025, 8, 5),
            ),
          ],
          originalFilePath: '/tmp/report-3.pdf',
          createdAt: DateTime(2025, 8, 5),
          updatedAt: DateTime(2025, 8, 5),
        ),
      ];
    });

    test('should sort by newest first (default)', () async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReportsForSorting));

      final notifier = ReportsNotifier(
        getAllReports: mockGetAllReports,
        saveReportProvider: () => mockSaveReport,
      );

      await notifier.loadReports();

      final state = notifier.state as AsyncData<List<Report>>;
      final sorted = state.value;

      // Should be sorted: report-1 (Oct 15), report-2 (Sep 10), report-3 (Aug 5)
      expect(sorted[0].id, equals('report-1'));
      expect(sorted[1].id, equals('report-2'));
      expect(sorted[2].id, equals('report-3'));
    });

    test('should sort by oldest first', () async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReportsForSorting));

      final notifier = ReportsNotifier(
        getAllReports: mockGetAllReports,
        saveReportProvider: () => mockSaveReport,
      );

      await notifier.loadReports();
      notifier.setSortOption(ReportSortOption.oldestFirst);

      final state = notifier.state as AsyncData<List<Report>>;
      final sorted = state.value;

      // Should be sorted: report-3 (Aug 5), report-2 (Sep 10), report-1 (Oct 15)
      expect(sorted[0].id, equals('report-3'));
      expect(sorted[1].id, equals('report-2'));
      expect(sorted[2].id, equals('report-1'));
    });

    test('should sort by most out-of-range biomarkers', () async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReportsForSorting));

      final notifier = ReportsNotifier(
        getAllReports: mockGetAllReports,
        saveReportProvider: () => mockSaveReport,
      );

      await notifier.loadReports();
      notifier.setSortOption(ReportSortOption.mostOutOfRange);

      final state = notifier.state as AsyncData<List<Report>>;
      final sorted = state.value;

      // Should be sorted: report-3 (3 out of range), report-2 (2 out of range), report-1 (1 out of range)
      expect(sorted[0].id, equals('report-3'));
      expect(sorted[1].id, equals('report-2'));
      expect(sorted[2].id, equals('report-1'));
    });

    test('should sort by lab name alphabetically', () async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReportsForSorting));

      final notifier = ReportsNotifier(
        getAllReports: mockGetAllReports,
        saveReportProvider: () => mockSaveReport,
      );

      await notifier.loadReports();
      notifier.setSortOption(ReportSortOption.labName);

      final state = notifier.state as AsyncData<List<Report>>;
      final sorted = state.value;

      // Should be sorted alphabetically: Alpha Lab, Beta Lab, Gamma Lab
      expect(sorted[0].labName, equals('Alpha Lab'));
      expect(sorted[1].labName, equals('Beta Lab'));
      expect(sorted[2].labName, equals('Gamma Lab'));
    });

    test('should handle empty list when sorting', () async {
      when(() => mockGetAllReports()).thenAnswer((_) async => const Right([]));

      final notifier = ReportsNotifier(
        getAllReports: mockGetAllReports,
        saveReportProvider: () => mockSaveReport,
      );

      await notifier.loadReports();
      notifier.setSortOption(ReportSortOption.mostOutOfRange);

      final state = notifier.state as AsyncData<List<Report>>;
      expect(state.value, isEmpty);
    });

    test('should maintain sort option when refreshing reports', () async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReportsForSorting));

      final notifier = ReportsNotifier(
        getAllReports: mockGetAllReports,
        saveReportProvider: () => mockSaveReport,
      );

      await notifier.loadReports();
      notifier.setSortOption(ReportSortOption.labName);

      // Verify initial sort
      var state = notifier.state as AsyncData<List<Report>>;
      expect(state.value[0].labName, equals('Alpha Lab'));

      // Refresh
      await notifier.refresh();

      // Verify sort is maintained
      state = notifier.state as AsyncData<List<Report>>;
      expect(state.value[0].labName, equals('Alpha Lab'));
    });

    test('should get current sort option', () async {
      when(() => mockGetAllReports())
          .thenAnswer((_) async => Right(testReportsForSorting));

      final notifier = ReportsNotifier(
        getAllReports: mockGetAllReports,
        saveReportProvider: () => mockSaveReport,
      );

      await notifier.loadReports();

      // Default should be newestFirst
      expect(notifier.currentSortOption, equals(ReportSortOption.newestFirst));

      // Change sort option
      notifier.setSortOption(ReportSortOption.labName);
      expect(notifier.currentSortOption, equals(ReportSortOption.labName));
    });
  });
}
