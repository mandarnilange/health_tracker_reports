import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/vital_statistics.dart';

void main() {
  group('VitalStatistics', () {
    const stats = VitalStatistics(
      average: 98.6,
      min: 96.0,
      max: 101.2,
      firstValue: 97.0,
      lastValue: 99.0,
      count: 5,
      percentageChange: 2.061855,
      trendDirection: TrendDirection.increasing,
    );

    test('computes absolute change from first to last value', () {
      expect(stats.absoluteChange, closeTo(2.0, 1e-6));
    });

    test('supports value equality via Equatable', () {
      const identicalStats = VitalStatistics(
        average: 98.6,
        min: 96.0,
        max: 101.2,
        firstValue: 97.0,
        lastValue: 99.0,
        count: 5,
        percentageChange: 2.061855,
        trendDirection: TrendDirection.increasing,
      );

      const differentStats = VitalStatistics(
        average: 97.5,
        min: 95.0,
        max: 100.0,
        firstValue: 98.0,
        lastValue: 97.0,
        count: 5,
        percentageChange: -1.020408,
        trendDirection: TrendDirection.decreasing,
      );

      expect(stats, equals(identicalStats));
      expect(stats == differentStats, isFalse);
    });
  });
}
