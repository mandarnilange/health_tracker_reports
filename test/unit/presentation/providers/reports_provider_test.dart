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
}
