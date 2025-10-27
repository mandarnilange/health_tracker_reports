import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/vital_trend_summary.dart';

void main() {
  test('const instances are equal', () {
    const summary1 = VitalTrendSummary();
    const summary2 = VitalTrendSummary();

    expect(summary1, summary2);
    expect(summary1.props, isEmpty);
  });
}
