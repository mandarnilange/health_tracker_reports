import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';

void main() {
  group('HealthEntryType', () {
    test('should have labReport value', () {
      expect(HealthEntryType.labReport, isNotNull);
    });

    test('should have healthLog value', () {
      expect(HealthEntryType.healthLog, isNotNull);
    });

    test('should have exactly two values', () {
      expect(HealthEntryType.values.length, 2);
    });

    test('values should be ordered correctly', () {
      expect(HealthEntryType.values[0], HealthEntryType.labReport);
      expect(HealthEntryType.values[1], HealthEntryType.healthLog);
    });
  });
}
