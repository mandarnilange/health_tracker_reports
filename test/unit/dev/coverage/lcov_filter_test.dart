import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/dev/coverage/lcov_filter.dart';

void main() {
  group('filterLcov', () {
    const sample = '''
TN:
SF:lib/domain/entities/first.dart
DA:1,1
LF:1
LH:1
end_of_record
SF:lib/domain/entities/second.g.dart
DA:1,1
LF:1
LH:1
end_of_record
SF:lib/domain/entities/third.freezed.dart
DA:5,0
LF:5
LH:0
end_of_record
''';

    test('excludes generated files with configured suffixes', () {
      final result = filterLcov(sample);

      expect(result, contains('first.dart'));
      expect(result, isNot(contains('second.g.dart')));
      expect(result, isNot(contains('third.freezed.dart')));
      expect(result.trim().endsWith('end_of_record'), isTrue);
    });

    test('allows overriding excluded suffixes', () {
      final result =
          filterLcov(sample, excludeSuffixes: const ['.super.dart']);

      expect(result, contains('second.g.dart'));
      expect(result, contains('third.freezed.dart'));
    });
  });
}
