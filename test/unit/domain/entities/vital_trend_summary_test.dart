import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/vital_trend_summary.dart';

void main() {
  test('supports equality for identical summaries', () {
    const summaryA = VitalTrendSummary();
    const summaryB = VitalTrendSummary();

    expect(summaryA, summaryB);
    expect(summaryA.props, isEmpty);
  });
}
