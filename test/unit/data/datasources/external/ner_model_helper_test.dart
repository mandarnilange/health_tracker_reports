import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/external/ner_model_helper.dart';
import 'package:health_tracker_reports/domain/entities/extracted_entity.dart';

void main() {
  late NerModelHelper helper;

  setUp(() {
    helper = NerModelHelper();
  });

  group('NerModelHelper', () {
    group('labelToEntityType', () {
      test('should map label 0 to EntityType.other', () {
        expect(helper.labelToEntityType(0), EntityType.other);
      });

      test('should map label 1 to EntityType.person (B-PERSON)', () {
        expect(helper.labelToEntityType(1), EntityType.person);
      });

      test('should map label 2 to EntityType.person (I-PERSON)', () {
        expect(helper.labelToEntityType(2), EntityType.person);
      });

      test('should map label 3 to EntityType.date (B-DATE)', () {
        expect(helper.labelToEntityType(3), EntityType.date);
      });

      test('should map label 5 to EntityType.organization (B-ORG)', () {
        expect(helper.labelToEntityType(5), EntityType.organization);
      });

      test('should map label 7 to EntityType.labValue (B-LAB_VALUE)', () {
        expect(helper.labelToEntityType(7), EntityType.labValue);
      });

      test('should map label 9 to EntityType.biomarkerName (B-BIOMARKER)', () {
        expect(helper.labelToEntityType(9), EntityType.biomarkerName);
      });

      test('should map unknown label to EntityType.other', () {
        expect(helper.labelToEntityType(99), EntityType.other);
      });
    });

    group('getConfidenceScore', () {
      test('should return correct confidence for label 1', () {
        expect(helper.getConfidenceScore(1), 0.85);
      });

      test('should return correct confidence for label 3', () {
        expect(helper.getConfidenceScore(3), 0.9);
      });

      test('should return default confidence for unknown label', () {
        expect(helper.getConfidenceScore(99), 0.5);
      });
    });

    group('extractWithPatterns', () {
      test('should extract person names from text', () {
        const text = 'Patient: John Doe';
        final entities = helper.extractWithPatterns(text);

        final personEntities =
            entities.where((e) => e.type == EntityType.person).toList();
        expect(personEntities, isNotEmpty);
        expect(personEntities.first.text, contains('John Doe'));
      });

      test('should extract dates from text', () {
        const text = 'Date: 2024-01-15';
        final entities = helper.extractWithPatterns(text);

        final dateEntities =
            entities.where((e) => e.type == EntityType.date).toList();
        expect(dateEntities, isNotEmpty);
        expect(dateEntities.first.text, contains('2024-01-15'));
      });

      test('should extract lab values from text', () {
        const text = 'Hemoglobin: 14.5 g/dL';
        final entities = helper.extractWithPatterns(text);

        final labEntities =
            entities.where((e) => e.type == EntityType.labValue).toList();
        expect(labEntities, isNotEmpty);
        expect(labEntities.first.text, contains('g/dL'));
      });

      test('should extract biomarker names from text', () {
        const text = 'Hemoglobin level is normal';
        final entities = helper.extractWithPatterns(text);

        final biomarkerEntities = entities
            .where((e) => e.type == EntityType.biomarkerName)
            .toList();
        expect(biomarkerEntities, isNotEmpty);
        expect(biomarkerEntities.first.text, 'Hemoglobin');
      });

      test('should extract organization names from text', () {
        const text = 'Lab: Quest Diagnostics';
        final entities = helper.extractWithPatterns(text);

        final orgEntities =
            entities.where((e) => e.type == EntityType.organization).toList();
        expect(orgEntities, isNotEmpty);
        expect(orgEntities.first.text, contains('Quest'));
      });

      test('should extract reference ranges from text', () {
        const text = 'Normal: 13.5-17.5 g/dL';
        final entities = helper.extractWithPatterns(text);

        final rangeEntities = entities
            .where((e) => e.type == EntityType.referenceRange)
            .toList();
        expect(rangeEntities, isNotEmpty);
      });

      test('should return empty list for text with no entities', () {
        const text = 'No entities here';
        final entities = helper.extractWithPatterns(text);

        expect(entities, isEmpty);
      });

      test('should sort entities by start offset', () {
        const text = '''
        Patient: John Doe
        Date: 2024-01-15
        Hemoglobin: 14.5 g/dL
        ''';
        final entities = helper.extractWithPatterns(text);

        expect(entities, isNotEmpty);
        for (int i = 1; i < entities.length; i++) {
          expect(
            entities[i].startOffset,
            greaterThanOrEqualTo(entities[i - 1].startOffset),
          );
        }
      });

      test('should extract multiple dates in different formats', () {
        const text = '''
        Date1: 2024-01-15
        Date2: 01/15/2024
        Date3: Jan 15, 2024
        ''';
        final entities = helper.extractWithPatterns(text);

        final dateEntities =
            entities.where((e) => e.type == EntityType.date).toList();
        expect(dateEntities.length, greaterThanOrEqualTo(3));
      });

      test('should extract multiple biomarkers', () {
        const text = 'Glucose, Cholesterol, HDL, and LDL levels';
        final entities = helper.extractWithPatterns(text);

        final biomarkerEntities = entities
            .where((e) => e.type == EntityType.biomarkerName)
            .toList();
        expect(biomarkerEntities.length, greaterThanOrEqualTo(4));
      });
    });

    group('validateEntities', () {
      test('should filter entities below confidence threshold', () {
        final entities = [
          const ExtractedEntity(
            text: 'test1',
            type: EntityType.person,
            confidence: 0.8,
            startOffset: 0,
            endOffset: 5,
          ),
          const ExtractedEntity(
            text: 'test2',
            type: EntityType.date,
            confidence: 0.5,
            startOffset: 6,
            endOffset: 11,
          ),
        ];

        final validated = helper.validateEntities(entities, minConfidence: 0.6);

        expect(validated.length, 1);
        expect(validated.first.text, 'test1');
      });

      test('should filter entities with invalid offsets', () {
        final entities = [
          const ExtractedEntity(
            text: 'valid',
            type: EntityType.person,
            confidence: 0.8,
            startOffset: 0,
            endOffset: 5,
          ),
          const ExtractedEntity(
            text: 'invalid',
            type: EntityType.date,
            confidence: 0.8,
            startOffset: -1,
            endOffset: 5,
          ),
        ];

        final validated = helper.validateEntities(entities);

        expect(validated.length, 1);
        expect(validated.first.text, 'valid');
      });

      test('should filter entities with text exceeding max length', () {
        final entities = [
          ExtractedEntity(
            text: 'a' * 50,
            type: EntityType.person,
            confidence: 0.8,
            startOffset: 0,
            endOffset: 50,
          ),
          ExtractedEntity(
            text: 'a' * 250,
            type: EntityType.date,
            confidence: 0.8,
            startOffset: 51,
            endOffset: 301,
          ),
        ];

        final validated =
            helper.validateEntities(entities, maxEntityLength: 200);

        expect(validated.length, 1);
        expect(validated.first.text.length, 50);
      });

      test('should return empty list when all entities are invalid', () {
        final entities = [
          const ExtractedEntity(
            text: 'low',
            type: EntityType.person,
            confidence: 0.3,
            startOffset: 0,
            endOffset: 3,
          ),
          const ExtractedEntity(
            text: 'invalid',
            type: EntityType.date,
            confidence: 0.4,
            startOffset: -5,
            endOffset: 2,
          ),
        ];

        final validated = helper.validateEntities(entities, minConfidence: 0.6);

        expect(validated, isEmpty);
      });
    });

    group('mergeAdjacentEntities', () {
      test('should merge adjacent entities of the same type', () {
        final entities = [
          const ExtractedEntity(
            text: 'John',
            type: EntityType.person,
            confidence: 0.9,
            startOffset: 0,
            endOffset: 4,
          ),
          const ExtractedEntity(
            text: 'Doe',
            type: EntityType.person,
            confidence: 0.9,
            startOffset: 5,
            endOffset: 8,
          ),
        ];

        final merged = helper.mergeAdjacentEntities(entities);

        expect(merged.length, 1);
        expect(merged.first.text, 'John Doe');
        expect(merged.first.startOffset, 0);
        expect(merged.first.endOffset, 8);
      });

      test('should not merge entities of different types', () {
        final entities = [
          const ExtractedEntity(
            text: 'John',
            type: EntityType.person,
            confidence: 0.9,
            startOffset: 0,
            endOffset: 4,
          ),
          const ExtractedEntity(
            text: '2024-01-15',
            type: EntityType.date,
            confidence: 0.9,
            startOffset: 5,
            endOffset: 15,
          ),
        ];

        final merged = helper.mergeAdjacentEntities(entities);

        expect(merged.length, 2);
      });

      test('should not merge non-adjacent entities of the same type', () {
        final entities = [
          const ExtractedEntity(
            text: 'John',
            type: EntityType.person,
            confidence: 0.9,
            startOffset: 0,
            endOffset: 4,
          ),
          const ExtractedEntity(
            text: 'Doe',
            type: EntityType.person,
            confidence: 0.9,
            startOffset: 10,
            endOffset: 13,
          ),
        ];

        final merged = helper.mergeAdjacentEntities(entities);

        expect(merged.length, 2);
      });

      test('should average confidence scores when merging', () {
        final entities = [
          const ExtractedEntity(
            text: 'John',
            type: EntityType.person,
            confidence: 0.8,
            startOffset: 0,
            endOffset: 4,
          ),
          const ExtractedEntity(
            text: 'Doe',
            type: EntityType.person,
            confidence: 0.9,
            startOffset: 5,
            endOffset: 8,
          ),
        ];

        final merged = helper.mergeAdjacentEntities(entities);

        expect(merged.first.confidence, closeTo(0.85, 0.001));
      });

      test('should return empty list for empty input', () {
        final merged = helper.mergeAdjacentEntities([]);

        expect(merged, isEmpty);
      });

      test('should handle single entity', () {
        final entities = [
          const ExtractedEntity(
            text: 'John',
            type: EntityType.person,
            confidence: 0.9,
            startOffset: 0,
            endOffset: 4,
          ),
        ];

        final merged = helper.mergeAdjacentEntities(entities);

        expect(merged.length, 1);
        expect(merged.first.text, 'John');
      });

      test('should merge multiple consecutive entities', () {
        final entities = [
          const ExtractedEntity(
            text: 'Quest',
            type: EntityType.organization,
            confidence: 0.8,
            startOffset: 0,
            endOffset: 5,
          ),
          const ExtractedEntity(
            text: 'Diagnostics',
            type: EntityType.organization,
            confidence: 0.8,
            startOffset: 6,
            endOffset: 17,
          ),
          const ExtractedEntity(
            text: 'Center',
            type: EntityType.organization,
            confidence: 0.8,
            startOffset: 18,
            endOffset: 24,
          ),
        ];

        final merged = helper.mergeAdjacentEntities(entities);

        expect(merged.length, 1);
        expect(merged.first.text, contains('Quest'));
        expect(merged.first.text, contains('Diagnostics'));
        expect(merged.first.text, contains('Center'));
      });
    });
  });
}
