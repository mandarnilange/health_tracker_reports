import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/vital_statistics.dart';

void main() {
  const stats = VitalStatistics(
    average: 72.5,
    min: 68,
    max: 80,
    firstValue: 70,
    lastValue: 75,
    count: 5,
    percentageChange: 7.1,
    trendDirection: TrendDirection.increasing,
  );

  test('absoluteChange returns difference between last and first values', () {
    expect(stats.absoluteChange, 5);
  });

  test('supports value equality', () {
    const other = VitalStatistics(
      average: 72.5,
      min: 68,
      max: 80,
      firstValue: 70,
      lastValue: 75,
      count: 5,
      percentageChange: 7.1,
      trendDirection: TrendDirection.increasing,
    );

    expect(stats, other);
  });
}
