import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';

void main() {
  group('RouteNames', () {
    test('exposes expected static paths', () {
      expect(RouteNames.home, '/');
      expect(RouteNames.review, '/review');
      expect(RouteNames.healthLogDetail, '/health-log/:id');
      expect(RouteNames.exportName, 'export');
      expect(RouteNames.doctorPdfConfig, '/export/doctor-pdf');
    });

    test('formats dynamic report routes correctly', () {
      expect(RouteNames.reportDetailWithId('abc'), '/report/abc');
      expect(
        RouteNames.healthLogDetailWithId('log-42'),
        '/health-log/log-42',
      );
    });
  });
}
