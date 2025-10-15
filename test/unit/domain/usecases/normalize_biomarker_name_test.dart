import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/usecases/normalize_biomarker_name.dart';

void main() {
  late NormalizeBiomarkerName usecase;

  setUp(() {
    usecase = NormalizeBiomarkerName();
  });

  group('NormalizeBiomarkerName', () {
    test('should normalize "Na" to "Sodium"', () {
      // Act
      final result = usecase('Na');

      // Assert
      expect(result, 'Sodium');
    });

    test('should normalize variations of a biomarker name', () {
      // Act
      final result1 = usecase('NA');
      final result2 = usecase('na');
      final result3 = usecase('Na+');
      final result4 = usecase('SODIUM');

      // Assert
      expect(result1, 'Sodium');
      expect(result2, 'Sodium');
      expect(result3, 'Sodium');
      expect(result4, 'Sodium');
    });

    test('should return the same name if no normalization is found', () {
      // Act
      final result = usecase('UnknownBiomarker');

      // Assert
      expect(result, 'UnknownBiomarker');
    });

    test('should return an empty string for empty or null input', () {
      // Act
      final result1 = usecase('');
      final result2 = usecase(null);

      // Assert
      expect(result1, '');
      expect(result2, '');
    });
  });
}
