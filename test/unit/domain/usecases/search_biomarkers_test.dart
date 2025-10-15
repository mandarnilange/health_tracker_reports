import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/usecases/search_biomarkers.dart';

void main() {
  late SearchBiomarkers usecase;
  late List<Biomarker> testBiomarkers;

  setUp(() {
    usecase = SearchBiomarkers();

    // Create test biomarkers
    testBiomarkers = [
      Biomarker(
        id: '1',
        name: 'Hemoglobin',
        value: 14.5,
        unit: 'g/dL',
        referenceRange: const ReferenceRange(min: 13.0, max: 17.0),
        measuredAt: DateTime(2024, 1, 1),
      ),
      Biomarker(
        id: '2',
        name: 'Glucose',
        value: 95.0,
        unit: 'mg/dL',
        referenceRange: const ReferenceRange(min: 70.0, max: 100.0),
        measuredAt: DateTime(2024, 1, 1),
      ),
      Biomarker(
        id: '3',
        name: 'White Blood Cells',
        value: 7500.0,
        unit: 'cells/μL',
        referenceRange: const ReferenceRange(min: 4000.0, max: 11000.0),
        measuredAt: DateTime(2024, 1, 1),
      ),
      Biomarker(
        id: '4',
        name: 'Total Cholesterol',
        value: 180.0,
        unit: 'mg/dL',
        referenceRange: const ReferenceRange(min: 0.0, max: 200.0),
        measuredAt: DateTime(2024, 1, 1),
      ),
      Biomarker(
        id: '5',
        name: 'Hemoglobin A1c',
        value: 5.5,
        unit: '%',
        referenceRange: const ReferenceRange(min: 4.0, max: 5.6),
        measuredAt: DateTime(2024, 1, 1),
      ),
    ];
  });

  group('SearchBiomarkers', () {
    test('should return biomarker matching exact name', () {
      // Act
      final result = usecase(testBiomarkers, 'Glucose');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.name, 'Glucose');
    });

    test('should perform case-insensitive search', () {
      // Act
      final result1 = usecase(testBiomarkers, 'hemoglobin');
      final result2 = usecase(testBiomarkers, 'HEMOGLOBIN');
      final result3 = usecase(testBiomarkers, 'HeMoGlObIn');

      // Assert
      expect(result1, hasLength(2)); // Hemoglobin and Hemoglobin A1c
      expect(result2, hasLength(2));
      expect(result3, hasLength(2));
    });

    test('should perform partial match search', () {
      // Act
      final result = usecase(testBiomarkers, 'hemo');

      // Assert
      expect(result, hasLength(2)); // Hemoglobin and Hemoglobin A1c
      expect(result.any((b) => b.name == 'Hemoglobin'), true);
      expect(result.any((b) => b.name == 'Hemoglobin A1c'), true);
    });

    test('should return all biomarkers when query is empty', () {
      // Act
      final result = usecase(testBiomarkers, '');

      // Assert
      expect(result, hasLength(5));
      expect(result, equals(testBiomarkers));
    });

    test('should return empty list when no matches found', () {
      // Act
      final result = usecase(testBiomarkers, 'NonExistentBiomarker');

      // Assert
      expect(result, isEmpty);
    });

    test('should search multiple biomarkers with different queries', () {
      // Act
      final result1 = usecase(testBiomarkers, 'blood');
      final result2 = usecase(testBiomarkers, 'cholesterol');
      final result3 = usecase(testBiomarkers, 'gluc');

      // Assert
      expect(result1, hasLength(1)); // White Blood Cells
      expect(result1.first.name, 'White Blood Cells');

      expect(result2, hasLength(1)); // Total Cholesterol
      expect(result2.first.name, 'Total Cholesterol');

      expect(result3, hasLength(1)); // Glucose
      expect(result3.first.name, 'Glucose');
    });

    test('should handle whitespace in query', () {
      // Act
      final result1 = usecase(testBiomarkers, ' hemoglobin ');
      final result2 = usecase(testBiomarkers, '  ');

      // Assert
      expect(result1, hasLength(2)); // Should trim and match
      expect(result2, hasLength(5)); // Whitespace-only should return all
    });

    test('should return empty list when biomarkers list is empty', () {
      // Act
      final result = usecase([], 'Hemoglobin');

      // Assert
      expect(result, isEmpty);
    });

    test('should match biomarkers containing query as substring', () {
      // Act
      final result = usecase(testBiomarkers, 'a1c');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.name, 'Hemoglobin A1c');
    });
  });
}
