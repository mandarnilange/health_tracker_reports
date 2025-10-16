import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_comparison.dart';
import 'package:health_tracker_reports/domain/usecases/compare_biomarker_across_reports.dart';
import 'package:health_tracker_reports/presentation/providers/comparison_provider.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockCompareBiomarkerAcrossReports extends Mock
    implements CompareBiomarkerAcrossReports {}

void main() {
  late ProviderContainer container;
  late MockCompareBiomarkerAcrossReports mockCompareUsecase;

  final comparison = BiomarkerComparison(
    biomarkerName: 'Hemoglobin',
    comparisons: [
      ComparisonDataPoint(
        reportId: 'r1',
        reportDate: DateTime(2024, 1, 15),
        value: 14.5,
        unit: 'g/dL',
        status: BiomarkerStatus.normal,
        deltaFromPrevious: null,
        percentageChangeFromPrevious: null,
      ),
      ComparisonDataPoint(
        reportId: 'r2',
        reportDate: DateTime(2024, 2, 15),
        value: 15.2,
        unit: 'g/dL',
        status: BiomarkerStatus.high,
        deltaFromPrevious: 0.7,
        percentageChangeFromPrevious: 4.83,
      ),
    ],
    overallTrend: TrendDirection.increasing,
  );

  setUp(() {
    mockCompareUsecase = MockCompareBiomarkerAcrossReports();
    container = ProviderContainer(
      overrides: [
        compareBiomarkerAcrossReportsProvider
            .overrideWithValue(mockCompareUsecase),
      ],
    );

    addTearDown(container.dispose);
  });

  group('ComparisonNotifier', () {
    test('initial state has no selections and no data', () {
      final state = container.read(comparisonProvider);

      expect(state.selectedReportIds, isEmpty);
      expect(state.selectedBiomarkerName, isNull);
      expect(state.comparisonData, const AsyncValue<BiomarkerComparison?>.data(null));
    });

    test('toggleReportSelection adds report when not selected', () {
      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');

      final state = container.read(comparisonProvider);
      expect(state.selectedReportIds, {'r1'});
    });

    test('toggleReportSelection removes report when already selected', () {
      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r1');

      final state = container.read(comparisonProvider);
      expect(state.selectedReportIds, isEmpty);
    });

    test('toggleReportSelection supports multiple reports', () {
      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r2');
      notifier.toggleReportSelection('r3');

      final state = container.read(comparisonProvider);
      expect(state.selectedReportIds, {'r1', 'r2', 'r3'});
    });

    test('selectBiomarker updates selected biomarker', () {
      final notifier = container.read(comparisonProvider.notifier);
      notifier.selectBiomarker('Hemoglobin');

      final state = container.read(comparisonProvider);
      expect(state.selectedBiomarkerName, 'Hemoglobin');
    });

    test('selectBiomarker clears data when set to null', () async {
      when(() => mockCompareUsecase('Hemoglobin', any()))
          .thenAnswer((_) async => Right(comparison));

      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r2');
      notifier.selectBiomarker('Hemoglobin');
      await notifier.loadComparison();

      notifier.selectBiomarker(null);

      final state = container.read(comparisonProvider);
      expect(state.selectedBiomarkerName, isNull);
      expect(state.comparisonData.asData?.value, isNull);
    });

    test('loadComparison does nothing when no reports selected', () async {
      final notifier = container.read(comparisonProvider.notifier);
      notifier.selectBiomarker('Hemoglobin');
      await notifier.loadComparison();

      final state = container.read(comparisonProvider);
      expect(state.comparisonData.asData?.value, isNull);
      verifyNever(() => mockCompareUsecase(any(), any()));
    });

    test('loadComparison does nothing when no biomarker selected', () async {
      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r2');
      await notifier.loadComparison();

      final state = container.read(comparisonProvider);
      expect(state.comparisonData.asData?.value, isNull);
      verifyNever(() => mockCompareUsecase(any(), any()));
    });

    test('loadComparison calls usecase with correct parameters', () async {
      when(() => mockCompareUsecase('Hemoglobin', ['r1', 'r2']))
          .thenAnswer((_) async => Right(comparison));

      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r2');
      notifier.selectBiomarker('Hemoglobin');
      await notifier.loadComparison();

      verify(() => mockCompareUsecase('Hemoglobin', ['r1', 'r2'])).called(1);
    });

    test('loadComparison updates state with comparison data on success',
        () async {
      when(() => mockCompareUsecase('Hemoglobin', any()))
          .thenAnswer((_) async => Right(comparison));

      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r2');
      notifier.selectBiomarker('Hemoglobin');
      await notifier.loadComparison();

      final state = container.read(comparisonProvider);
      expect(state.comparisonData.asData?.value, comparison);
      expect(state.comparisonData.asData?.value?.biomarkerName, 'Hemoglobin');
      expect(state.comparisonData.asData?.value?.comparisons.length, 2);
    });

    test('loadComparison sets loading state during execution', () async {
      when(() => mockCompareUsecase('Hemoglobin', any()))
          .thenAnswer((_) async {
        // Simulate delay
        await Future.delayed(const Duration(milliseconds: 10));
        return Right(comparison);
      });

      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r2');
      notifier.selectBiomarker('Hemoglobin');

      final loadFuture = notifier.loadComparison();

      // Check loading state immediately
      await Future.delayed(Duration.zero);
      final loadingState = container.read(comparisonProvider);
      expect(loadingState.comparisonData.isLoading, isTrue);

      await loadFuture;

      // Check final state
      final finalState = container.read(comparisonProvider);
      expect(finalState.comparisonData.hasValue, isTrue);
    });

    test('loadComparison handles validation failure', () async {
      when(() => mockCompareUsecase('Hemoglobin', any())).thenAnswer(
        (_) async => const Left(
          ValidationFailure(message: 'At least 2 reports required'),
        ),
      );

      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.selectBiomarker('Hemoglobin');
      await notifier.loadComparison();

      final state = container.read(comparisonProvider);
      expect(state.comparisonData.hasError, isTrue);
      expect(state.comparisonData.error, isA<ValidationFailure>());
    });

    test('loadComparison handles not found failure', () async {
      when(() => mockCompareUsecase('Vitamin D', any())).thenAnswer(
        (_) async => const Left(
          NotFoundFailure(message: 'Biomarker not found in any report'),
        ),
      );

      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r2');
      notifier.selectBiomarker('Vitamin D');
      await notifier.loadComparison();

      final state = container.read(comparisonProvider);
      expect(state.comparisonData.hasError, isTrue);
      expect(state.comparisonData.error, isA<NotFoundFailure>());
    });

    test('loadComparison handles cache failure', () async {
      when(() => mockCompareUsecase('Hemoglobin', any()))
          .thenAnswer((_) async => Left(const CacheFailure()));

      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r2');
      notifier.selectBiomarker('Hemoglobin');
      await notifier.loadComparison();

      final state = container.read(comparisonProvider);
      expect(state.comparisonData.hasError, isTrue);
      expect(state.comparisonData.error, isA<CacheFailure>());
    });

    test('clearSelection clears all selections and data', () async {
      when(() => mockCompareUsecase('Hemoglobin', any()))
          .thenAnswer((_) async => Right(comparison));

      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r2');
      notifier.selectBiomarker('Hemoglobin');
      await notifier.loadComparison();

      notifier.clearSelection();

      final state = container.read(comparisonProvider);
      expect(state.selectedReportIds, isEmpty);
      expect(state.selectedBiomarkerName, isNull);
      expect(state.comparisonData.asData?.value, isNull);
    });

    test('selecting new biomarker reloads comparison automatically', () async {
      when(() => mockCompareUsecase('Hemoglobin', any()))
          .thenAnswer((_) async => Right(comparison));
      when(() => mockCompareUsecase('Glucose', any())).thenAnswer(
        (_) async => Right(
          comparison.copyWith(biomarkerName: 'Glucose'),
        ),
      );

      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r2');
      notifier.selectBiomarker('Hemoglobin');
      await notifier.loadComparison();

      notifier.selectBiomarker('Glucose');
      await notifier.loadComparison();

      final state = container.read(comparisonProvider);
      expect(state.selectedBiomarkerName, 'Glucose');
      verify(() => mockCompareUsecase('Hemoglobin', any())).called(1);
      verify(() => mockCompareUsecase('Glucose', any())).called(1);
    });

    test('toggling report selection after loading triggers reload', () async {
      when(() => mockCompareUsecase('Hemoglobin', ['r1', 'r2']))
          .thenAnswer((_) async => Right(comparison));
      when(() => mockCompareUsecase('Hemoglobin', ['r1', 'r2', 'r3']))
          .thenAnswer((_) async => Right(comparison));

      final notifier = container.read(comparisonProvider.notifier);
      notifier.toggleReportSelection('r1');
      notifier.toggleReportSelection('r2');
      notifier.selectBiomarker('Hemoglobin');
      await notifier.loadComparison();

      notifier.toggleReportSelection('r3');
      await notifier.loadComparison();

      verify(() => mockCompareUsecase('Hemoglobin', ['r1', 'r2'])).called(1);
      verify(() => mockCompareUsecase('Hemoglobin', ['r1', 'r2', 'r3']))
          .called(1);
    });
  });
}
