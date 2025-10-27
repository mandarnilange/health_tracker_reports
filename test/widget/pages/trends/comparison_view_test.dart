import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_comparison.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/compare_biomarker_across_reports.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/presentation/pages/trends/comparison_view.dart';
import 'package:health_tracker_reports/presentation/providers/comparison_provider.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:mocktail/mocktail.dart';

void _registerComparisonFallbacks() {}

class _MockGetAllReports extends Mock implements GetAllReports {}

class _MockSaveReport extends Mock implements SaveReport {}

class _MockCompareBiomarkerAcrossReports extends Mock
    implements CompareBiomarkerAcrossReports {}

Report _createReport({
  required String id,
  required DateTime date,
  required double value,
}) {
  return Report(
    id: id,
    date: date,
    labName: 'Quest Diagnostics',
    biomarkers: [
      Biomarker(
        id: 'bio-$id',
        name: 'Hemoglobin',
        value: value,
        unit: 'g/dL',
        referenceRange: const ReferenceRange(min: 12, max: 16),
        measuredAt: date,
      ),
    ],
    originalFilePath: '/tmp/$id.pdf',
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockGetAllReports mockGetAllReports;
  late _MockSaveReport mockSaveReport;
  late _MockCompareBiomarkerAcrossReports mockCompareUsecase;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      _createReport(
        id: 'fallback',
        date: DateTime(2024, 1, 1),
        value: 13.5,
      ),
    );
  });

  setUp(() {
    mockGetAllReports = _MockGetAllReports();
    mockSaveReport = _MockSaveReport();
    mockCompareUsecase = _MockCompareBiomarkerAcrossReports();
    when(() => mockSaveReport.call(any()))
        .thenAnswer((_) async => Left(CacheFailure()));
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> _pumpWithOverrides(
    WidgetTester tester, {
    required Future<Either<Failure, List<Report>>> Function() loadReports,
  }) async {
    when(() => mockGetAllReports.call()).thenAnswer((_) => loadReports());

    container = ProviderContainer(
      overrides: [
        getAllReportsProvider.overrideWithValue(mockGetAllReports),
        saveReportUseCaseProvider.overrideWithValue(mockSaveReport),
        compareBiomarkerAcrossReportsProvider
            .overrideWithValue(mockCompareUsecase),
      ],
    );

    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ComparisonView(),
        ),
      ),
    );
  }

  testWidgets('shows loading indicator while reports load', (tester) async {
    final completer = Completer<Either<Failure, List<Report>>>();
    await _pumpWithOverrides(
      tester,
      loadReports: () => completer.future,
    );

    // Allow the notifier microtask to trigger the load
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Right([]));
  });

  testWidgets('shows empty state when no reports available', (tester) async {
    await _pumpWithOverrides(
      tester,
      loadReports: () async => const Right([]),
    );

    await tester.pump(); // allow async load to finish

    expect(find.text('No data available'), findsOneWidget);
    expect(
      find.text('Upload some reports to start comparing biomarkers'),
      findsOneWidget,
    );
  });

  testWidgets('renders comparison table when data available', (tester) async {
    final reports = [
      _createReport(id: 'R1', date: DateTime(2024, 1, 1), value: 13.5),
      _createReport(id: 'R2', date: DateTime(2024, 2, 1), value: 17),
    ];

    await _pumpWithOverrides(
      tester,
      loadReports: () async => Right(reports),
    );

    await tester.pump(); // finish load

    final comparison = BiomarkerComparison(
      biomarkerName: 'Hemoglobin',
      comparisons: [
        ComparisonDataPoint(
          reportId: 'R1',
          reportDate: reports[0].date,
          value: 13.5,
          unit: 'g/dL',
          status: BiomarkerStatus.normal,
          deltaFromPrevious: null,
          percentageChangeFromPrevious: null,
        ),
        ComparisonDataPoint(
          reportId: 'R2',
          reportDate: reports[1].date,
          value: 17,
          unit: 'g/dL',
          status: BiomarkerStatus.high,
          deltaFromPrevious: 3.5,
          percentageChangeFromPrevious: 25.9,
        ),
      ],
      overallTrend: TrendDirection.increasing,
    );

    container.read(comparisonProvider.notifier).state = ComparisonState(
      selectedReportIds: {'R1', 'R2'},
      selectedBiomarkerName: 'Hemoglobin',
      comparisonData: AsyncValue.data(comparison),
    );

    await tester.pump();

    expect(find.text('Hemoglobin'), findsWidgets);
    expect(find.text('Increasing'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
  });

  testWidgets('shows guidance when not enough reports selected', (tester) async {
    final reports = [
      _createReport(id: 'R1', date: DateTime(2024, 1, 1), value: 13.5),
      _createReport(id: 'R2', date: DateTime(2024, 2, 1), value: 14.5),
    ];

    await _pumpWithOverrides(
      tester,
      loadReports: () async => Right(reports),
    );

    await tester.pump();

    container.read(comparisonProvider.notifier).state = ComparisonState(
      selectedReportIds: {'R1'},
      selectedBiomarkerName: 'Hemoglobin',
      comparisonData: const AsyncValue.data(null),
    );

    await tester.pump();

    expect(find.text('Need more reports'), findsOneWidget);
    expect(find.textContaining('Select at least one more report'), findsOneWidget);
  });
}
