import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/utils/clock.dart';

void main() {
  group('SystemClock', () {
    test('now returns current time', () {
      final clock = SystemClock();

      final before = DateTime.now();
      final result = clock.now();
      final after = DateTime.now();

      expect(result.isAfter(before) || result.isAtSameMomentAs(before), isTrue);
      expect(result.isBefore(after) || result.isAtSameMomentAs(after), isTrue);
    });
  });
}
