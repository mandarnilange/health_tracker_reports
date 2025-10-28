import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_trend_summary.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';

void main() {
  group('BiomarkerTrendSummary', () {
    const trend = TrendAnalysis(
      direction: TrendDirection.decreasing,
      percentageChange: -12.5,
      firstValue: 15.0,
      lastValue: 13.125,
      dataPointsCount: 6,
    );

    test('supports equality comparison', () {
      const summary = BiomarkerTrendSummary(
        biomarkerName: 'Hemoglobin',
        trend: trend,
      );

      const identical = BiomarkerTrendSummary(
        biomarkerName: 'Hemoglobin',
        trend: trend,
      );

      const different = BiomarkerTrendSummary(
        biomarkerName: 'Cholesterol',
        trend: trend,
      );

      expect(summary, equals(identical));
      expect(summary == different, isFalse);
    });

    test('permits null trend', () {
      const summary = BiomarkerTrendSummary(biomarkerName: 'Platelets');

      expect(summary.trend, isNull);
      expect(summary.biomarkerName, 'Platelets');
    });
  });
}
