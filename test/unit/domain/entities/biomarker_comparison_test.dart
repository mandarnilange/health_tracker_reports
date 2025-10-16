import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_comparison.dart';

void main() {
  group('ComparisonDataPoint', () {
    final testDate = DateTime(2024, 1, 15);

    test('should be properly instantiated with all required fields', () {
      final dataPoint = ComparisonDataPoint(
        reportId: 'r1',
        reportDate: testDate,
        value: 14.5,
        unit: 'g/dL',
        status: BiomarkerStatus.normal,
        deltaFromPrevious: null,
        percentageChangeFromPrevious: null,
      );

      expect(dataPoint.reportId, 'r1');
      expect(dataPoint.reportDate, testDate);
      expect(dataPoint.value, 14.5);
      expect(dataPoint.unit, 'g/dL');
      expect(dataPoint.status, BiomarkerStatus.normal);
      expect(dataPoint.deltaFromPrevious, null);
      expect(dataPoint.percentageChangeFromPrevious, null);
    });

    test('should support delta and percentage change for non-first points', () {
      final dataPoint = ComparisonDataPoint(
        reportId: 'r2',
        reportDate: testDate,
        value: 15.2,
        unit: 'g/dL',
        status: BiomarkerStatus.high,
        deltaFromPrevious: 0.7,
        percentageChangeFromPrevious: 4.83,
      );

      expect(dataPoint.deltaFromPrevious, 0.7);
      expect(dataPoint.percentageChangeFromPrevious, 4.83);
    });

    test('should support equality comparison', () {
      final dataPoint1 = ComparisonDataPoint(
        reportId: 'r1',
        reportDate: testDate,
        value: 14.5,
        unit: 'g/dL',
        status: BiomarkerStatus.normal,
        deltaFromPrevious: null,
        percentageChangeFromPrevious: null,
      );

      final dataPoint2 = ComparisonDataPoint(
        reportId: 'r1',
        reportDate: testDate,
        value: 14.5,
        unit: 'g/dL',
        status: BiomarkerStatus.normal,
        deltaFromPrevious: null,
        percentageChangeFromPrevious: null,
      );

      expect(dataPoint1, equals(dataPoint2));
    });

    test('should detect inequality when values differ', () {
      final dataPoint1 = ComparisonDataPoint(
        reportId: 'r1',
        reportDate: testDate,
        value: 14.5,
        unit: 'g/dL',
        status: BiomarkerStatus.normal,
        deltaFromPrevious: null,
        percentageChangeFromPrevious: null,
      );

      final dataPoint2 = ComparisonDataPoint(
        reportId: 'r1',
        reportDate: testDate,
        value: 15.0,
        unit: 'g/dL',
        status: BiomarkerStatus.normal,
        deltaFromPrevious: null,
        percentageChangeFromPrevious: null,
      );

      expect(dataPoint1, isNot(equals(dataPoint2)));
    });

    test('should support copyWith for creating modified copies', () {
      final original = ComparisonDataPoint(
        reportId: 'r1',
        reportDate: testDate,
        value: 14.5,
        unit: 'g/dL',
        status: BiomarkerStatus.normal,
        deltaFromPrevious: null,
        percentageChangeFromPrevious: null,
      );

      final modified = original.copyWith(
        value: 15.0,
        status: BiomarkerStatus.high,
      );

      expect(modified.reportId, 'r1');
      expect(modified.value, 15.0);
      expect(modified.status, BiomarkerStatus.high);
      expect(modified.unit, 'g/dL');
    });
  });

  group('TrendDirection', () {
    test('should have all expected trend directions', () {
      expect(
          TrendDirection.values,
          containsAll([
            TrendDirection.increasing,
            TrendDirection.decreasing,
            TrendDirection.stable,
            TrendDirection.fluctuating,
            TrendDirection.insufficient,
          ]));
    });
  });

  group('BiomarkerComparison', () {
    final date1 = DateTime(2024, 1, 15);
    final date2 = DateTime(2024, 2, 15);
    final date3 = DateTime(2024, 3, 15);

    final dataPoint1 = ComparisonDataPoint(
      reportId: 'r1',
      reportDate: date1,
      value: 14.5,
      unit: 'g/dL',
      status: BiomarkerStatus.normal,
      deltaFromPrevious: null,
      percentageChangeFromPrevious: null,
    );

    final dataPoint2 = ComparisonDataPoint(
      reportId: 'r2',
      reportDate: date2,
      value: 15.2,
      unit: 'g/dL',
      status: BiomarkerStatus.high,
      deltaFromPrevious: 0.7,
      percentageChangeFromPrevious: 4.83,
    );

    final dataPoint3 = ComparisonDataPoint(
      reportId: 'r3',
      reportDate: date3,
      value: 14.8,
      unit: 'g/dL',
      status: BiomarkerStatus.normal,
      deltaFromPrevious: -0.4,
      percentageChangeFromPrevious: -2.63,
    );

    test('should be properly instantiated with all required fields', () {
      final comparison = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [dataPoint1, dataPoint2, dataPoint3],
        overallTrend: TrendDirection.fluctuating,
      );

      expect(comparison.biomarkerName, 'Hemoglobin');
      expect(comparison.comparisons.length, 3);
      expect(comparison.overallTrend, TrendDirection.fluctuating);
    });

    test('should support single comparison point', () {
      final comparison = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [dataPoint1],
        overallTrend: TrendDirection.insufficient,
      );

      expect(comparison.comparisons.length, 1);
      expect(comparison.overallTrend, TrendDirection.insufficient);
    });

    test('should support equality comparison', () {
      final comparison1 = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [dataPoint1, dataPoint2],
        overallTrend: TrendDirection.increasing,
      );

      final comparison2 = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [dataPoint1, dataPoint2],
        overallTrend: TrendDirection.increasing,
      );

      expect(comparison1, equals(comparison2));
    });

    test('should detect inequality when biomarker names differ', () {
      final comparison1 = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [dataPoint1],
        overallTrend: TrendDirection.stable,
      );

      final comparison2 = BiomarkerComparison(
        biomarkerName: 'Glucose',
        comparisons: [dataPoint1],
        overallTrend: TrendDirection.stable,
      );

      expect(comparison1, isNot(equals(comparison2)));
    });

    test('should detect inequality when trends differ', () {
      final comparison1 = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [dataPoint1, dataPoint2],
        overallTrend: TrendDirection.increasing,
      );

      final comparison2 = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [dataPoint1, dataPoint2],
        overallTrend: TrendDirection.decreasing,
      );

      expect(comparison1, isNot(equals(comparison2)));
    });

    test('should detect inequality when comparisons differ', () {
      final comparison1 = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [dataPoint1, dataPoint2],
        overallTrend: TrendDirection.increasing,
      );

      final comparison2 = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [dataPoint1, dataPoint2, dataPoint3],
        overallTrend: TrendDirection.increasing,
      );

      expect(comparison1, isNot(equals(comparison2)));
    });

    test('should support copyWith for creating modified copies', () {
      final original = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [dataPoint1, dataPoint2],
        overallTrend: TrendDirection.increasing,
      );

      final modified = original.copyWith(
        overallTrend: TrendDirection.fluctuating,
      );

      expect(modified.biomarkerName, 'Hemoglobin');
      expect(modified.comparisons, [dataPoint1, dataPoint2]);
      expect(modified.overallTrend, TrendDirection.fluctuating);
    });

    test('should allow empty comparisons list', () {
      final comparison = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [],
        overallTrend: TrendDirection.insufficient,
      );

      expect(comparison.comparisons, isEmpty);
    });

    test('should preserve order of comparison data points', () {
      final comparison = BiomarkerComparison(
        biomarkerName: 'Hemoglobin',
        comparisons: [dataPoint1, dataPoint2, dataPoint3],
        overallTrend: TrendDirection.fluctuating,
      );

      expect(comparison.comparisons[0].reportDate, date1);
      expect(comparison.comparisons[1].reportDate, date2);
      expect(comparison.comparisons[2].reportDate, date3);
    });
  });
}
