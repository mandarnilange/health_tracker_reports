import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_comparison.dart';
import 'package:health_tracker_reports/presentation/providers/comparison_provider.dart';
import 'package:health_tracker_reports/domain/usecases/compare_biomarker_across_reports.dart';
import 'package:mocktail/mocktail.dart';

class _MockCompareBiomarker extends Mock
    implements CompareBiomarkerAcrossReports {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  late ComparisonNotifier notifier;
  late _MockCompareBiomarker compareBiomarker;

  setUp(() {
    compareBiomarker = _MockCompareBiomarker();
    notifier = ComparisonNotifier(compareBiomarker);
  });

  test('toggleReportSelection adds and removes ids', () {
    notifier.toggleReportSelection('a');
    expect(notifier.state.selectedReportIds, contains('a'));

    notifier.toggleReportSelection('a');
    expect(notifier.state.selectedReportIds, isEmpty);
  });

  test('selectBiomarker clears selection when null provided', () {
    notifier.selectBiomarker('Glucose');
    notifier.selectBiomarker(null);

    expect(notifier.state.selectedBiomarkerName, isNull);
    expect(notifier.state.comparisonData, const AsyncValue<BiomarkerComparison?>.data(null));
  });

  test('loadComparison early returns when requirements missing', () async {
    await notifier.loadComparison();
    verifyNever(() => compareBiomarker(any(), any()));

    notifier.selectBiomarker('Glucose');
    await notifier.loadComparison();
    verifyNever(() => compareBiomarker(any(), any()));
  });

  test('loadComparison success updates state', () async {
    notifier
      ..toggleReportSelection('r1')
      ..toggleReportSelection('r2')
      ..selectBiomarker('Glucose');

    const comparison = BiomarkerComparison(
      biomarkerName: 'Glucose',
      comparisons: [],
      overallTrend: TrendDirection.insufficient,
    );

    when(() => compareBiomarker(any(), any()))
        .thenAnswer((_) async => const Right(comparison));

    await notifier.loadComparison();

    expect(notifier.state.comparisonData.requireValue, comparison);
    final captured = verify(() => compareBiomarker('Glucose', captureAny())).captured.single as List<String>;
    expect(captured.toSet(), equals({'r1', 'r2'}));
  });

  test('loadComparison failure sets AsyncError', () async {
    notifier
      ..toggleReportSelection('r1')
      ..selectBiomarker('HbA1c');

    when(() => compareBiomarker(any(), any()))
        .thenAnswer((_) async => const Left(CacheFailure()));

    await notifier.loadComparison();

    expect(notifier.state.comparisonData, isA<AsyncError<BiomarkerComparison?>>());
  });

  test('clearSelection resets state', () {
    notifier
      ..toggleReportSelection('r1')
      ..selectBiomarker('Glucose');

    notifier.clearSelection();

    expect(notifier.state.selectedReportIds, isEmpty);
    expect(notifier.state.selectedBiomarkerName, isNull);
  });
}
