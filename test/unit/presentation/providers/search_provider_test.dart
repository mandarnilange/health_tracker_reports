import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/presentation/providers/filter_provider.dart';
import 'package:health_tracker_reports/presentation/providers/search_provider.dart';

void main() {
  group('SearchQueryNotifier', () {
    test('updateQuery sets state', () {
      final notifier = SearchQueryNotifier();
      notifier.updateQuery('glucose');
      expect(notifier.state, 'glucose');
    });

    test('clearQuery resets state', () {
      final notifier = SearchQueryNotifier();
      notifier.updateQuery('test');
      notifier.clearQuery();
      expect(notifier.state, isEmpty);
    });
  });

  group('searchedAndFilteredBiomarkersProvider', () {
    late Report report;
    late ProviderContainer container;

    setUp(() {
      report = Report(
        id: 'r1',
        date: DateTime(2024, 1, 1),
        labName: 'Lab',
        biomarkers: [
          Biomarker(
            id: 'b1',
            name: 'Glucose',
            value: 105,
            unit: 'mg/dL',
            referenceRange: ReferenceRange(min: 70, max: 100),
            measuredAt: DateTime(2024, 1, 1),
          ),
          Biomarker(
            id: 'b2',
            name: 'Hemoglobin',
            value: 13.5,
            unit: 'g/dL',
            referenceRange: ReferenceRange(min: 12, max: 15),
            measuredAt: DateTime(2024, 1, 1),
          ),
        ],
        originalFilePath: 'path',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('returns all biomarkers when query empty and filter showAll', () {
      final results = container.read(searchedAndFilteredBiomarkersProvider(report));
      expect(results.length, 2);
    });

    test('applies search query on filtered biomarkers', () {
      container.read(searchQueryProvider.notifier).updateQuery('gluc');

      final results = container.read(searchedAndFilteredBiomarkersProvider(report));
      expect(results.length, 1);
      expect(results.single.name, 'Glucose');
    });

    test('respects out-of-range filter before searching', () {
      container.read(filterProvider.notifier).toggleFilter();
      container.read(searchQueryProvider.notifier).updateQuery('hemo');

      final results = container.read(searchedAndFilteredBiomarkersProvider(report));
      // Hemoglobin is in range, should be filtered out before search, so result empty.
      expect(results, isEmpty);
    });
  });
}
