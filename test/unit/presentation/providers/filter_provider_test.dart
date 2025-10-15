import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/presentation/providers/filter_provider.dart';

void main() {
  // Test data: create report with mix of normal and out-of-range biomarkers
  final testReport = Report(
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
      Biomarker(
        id: 'bio-2',
        name: 'Glucose',
        value: 150.0,
        unit: 'mg/dL',
        referenceRange: const ReferenceRange(min: 70.0, max: 100.0),
        measuredAt: DateTime(2025, 10, 15),
      ),
      Biomarker(
        id: 'bio-3',
        name: 'Cholesterol',
        value: 180.0,
        unit: 'mg/dL',
        referenceRange: const ReferenceRange(min: 100.0, max: 200.0),
        measuredAt: DateTime(2025, 10, 15),
      ),
      Biomarker(
        id: 'bio-4',
        name: 'Sodium',
        value: 120.0,
        unit: 'mmol/L',
        referenceRange: const ReferenceRange(min: 135.0, max: 145.0),
        measuredAt: DateTime(2025, 10, 15),
      ),
    ],
    originalFilePath: '/tmp/report-1.pdf',
    createdAt: DateTime(2025, 10, 15),
    updatedAt: DateTime(2025, 10, 15),
  );

  // Report with all normal biomarkers
  final allNormalReport = Report(
    id: 'report-2',
    date: DateTime(2025, 10, 15),
    labName: 'Test Lab',
    biomarkers: [
      Biomarker(
        id: 'bio-5',
        name: 'Hemoglobin',
        value: 14.2,
        unit: 'g/dL',
        referenceRange: const ReferenceRange(min: 12.0, max: 17.0),
        measuredAt: DateTime(2025, 10, 15),
      ),
      Biomarker(
        id: 'bio-6',
        name: 'Glucose',
        value: 85.0,
        unit: 'mg/dL',
        referenceRange: const ReferenceRange(min: 70.0, max: 100.0),
        measuredAt: DateTime(2025, 10, 15),
      ),
    ],
    originalFilePath: '/tmp/report-2.pdf',
    createdAt: DateTime(2025, 10, 15),
    updatedAt: DateTime(2025, 10, 15),
  );

  group('FilterNotifier', () {
    test('initial state should be showAll', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filter = container.read(filterProvider);

      expect(filter, equals(BiomarkerFilter.showAll));
    });

    test('toggleFilter should change state from showAll to outOfRangeOnly',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(filterProvider.notifier).toggleFilter();

      final filter = container.read(filterProvider);
      expect(filter, equals(BiomarkerFilter.outOfRangeOnly));
    });

    test('toggleFilter should change state from outOfRangeOnly to showAll',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Toggle once to get to outOfRangeOnly
      container.read(filterProvider.notifier).toggleFilter();

      // Toggle again to get back to showAll
      container.read(filterProvider.notifier).toggleFilter();

      final filter = container.read(filterProvider);
      expect(filter, equals(BiomarkerFilter.showAll));
    });

    test('multiple toggles should alternate between states', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(filterProvider.notifier);

      // Start with showAll
      expect(container.read(filterProvider), equals(BiomarkerFilter.showAll));

      // Toggle to outOfRangeOnly
      notifier.toggleFilter();
      expect(
          container.read(filterProvider), equals(BiomarkerFilter.outOfRangeOnly));

      // Toggle back to showAll
      notifier.toggleFilter();
      expect(container.read(filterProvider), equals(BiomarkerFilter.showAll));

      // Toggle to outOfRangeOnly
      notifier.toggleFilter();
      expect(
          container.read(filterProvider), equals(BiomarkerFilter.outOfRangeOnly));
    });
  });

  group('filteredBiomarkersProvider', () {
    test('should return all biomarkers when filter is showAll', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filteredBiomarkers =
          container.read(filteredBiomarkersProvider(testReport));

      expect(filteredBiomarkers.length, equals(4));
      expect(filteredBiomarkers, equals(testReport.biomarkers));
    });

    test('should return only out-of-range biomarkers when filter is outOfRangeOnly',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Toggle filter to outOfRangeOnly
      container.read(filterProvider.notifier).toggleFilter();

      final filteredBiomarkers =
          container.read(filteredBiomarkersProvider(testReport));

      // Should only have Glucose (150.0, high) and Sodium (120.0, low)
      expect(filteredBiomarkers.length, equals(2));
      expect(filteredBiomarkers[0].name, equals('Glucose'));
      expect(filteredBiomarkers[0].status, equals(BiomarkerStatus.high));
      expect(filteredBiomarkers[1].name, equals('Sodium'));
      expect(filteredBiomarkers[1].status, equals(BiomarkerStatus.low));
    });

    test('should return empty list when all biomarkers are normal and filter is outOfRangeOnly',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Toggle filter to outOfRangeOnly
      container.read(filterProvider.notifier).toggleFilter();

      final filteredBiomarkers =
          container.read(filteredBiomarkersProvider(allNormalReport));

      expect(filteredBiomarkers.length, equals(0));
      expect(filteredBiomarkers, isEmpty);
    });

    test('should update filtered list when filter state changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state: showAll
      final allBiomarkers =
          container.read(filteredBiomarkersProvider(testReport));
      expect(allBiomarkers.length, equals(4));

      // Toggle to outOfRangeOnly
      container.read(filterProvider.notifier).toggleFilter();

      final outOfRangeBiomarkers =
          container.read(filteredBiomarkersProvider(testReport));
      expect(outOfRangeBiomarkers.length, equals(2));

      // Toggle back to showAll
      container.read(filterProvider.notifier).toggleFilter();

      final allBiomarkersAgain =
          container.read(filteredBiomarkersProvider(testReport));
      expect(allBiomarkersAgain.length, equals(4));
    });

    test('should correctly identify out-of-range biomarkers by status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Toggle to outOfRangeOnly
      container.read(filterProvider.notifier).toggleFilter();

      final filteredBiomarkers =
          container.read(filteredBiomarkersProvider(testReport));

      // All filtered biomarkers should have status != normal
      for (final biomarker in filteredBiomarkers) {
        expect(biomarker.status, isNot(equals(BiomarkerStatus.normal)));
      }
    });
  });
}
