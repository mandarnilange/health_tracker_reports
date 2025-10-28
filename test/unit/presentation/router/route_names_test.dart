import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';

void main() {
  test('reportDetailWithId builds correct path', () {
    expect(RouteNames.reportDetailWithId('123'), '/report/123');
  });

  test('healthLogDetailWithId builds correct path', () {
    expect(RouteNames.healthLogDetailWithId('log-1'), '/health-log/log-1');
  });
}
