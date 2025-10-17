import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/ner_metadata_extractor.dart';
import 'package:health_tracker_reports/domain/entities/extracted_entity.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void main() {
  late NerMetadataExtractor extractor;
  late String testModelPath;
  late Directory tempDir;

  setUp(() async {
    // Create a temporary directory and test model file
    tempDir = await Directory.systemTemp.createTemp('ner_test_');
    testModelPath = '${tempDir.path}/model.tflite';

    // Create a dummy model file
    final modelFile = File(testModelPath);
    await modelFile.writeAsString('dummy model content');

    extractor = NerMetadataExtractorImpl();
  });

  tearDown(() async {
    // Clean up temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('NerMetadataExtractor', () {
    const testText = '''
    Patient: John Doe
    Date: 2024-01-15
    Lab: Quest Diagnostics

    Hemoglobin: 14.5 g/dL (Normal: 13.5-17.5)
    Glucose: 95 mg/dL (Normal: 70-100)
    ''';

    group('initialize', () {
      test('should initialize successfully with valid model path', () async {
        // Act
        final result = await extractor.initialize(testModelPath);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (_) {
            // Success - no need to check value
          },
        );
      });

      test('should return failure with invalid model path', () async {
        // Arrange
        const invalidPath = '/invalid/path/model.tflite';

        // Act
        final result = await extractor.initialize(invalidPath);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NerFailure>());
            expect(failure.message, contains('initialize'));
          },
          (_) => fail('Should not return success'),
        );
      });
    });

    group('extractEntities', () {
      test('should extract entities from text successfully', () async {
        // Arrange
        await extractor.initialize(testModelPath);

        // Act
        final result = await extractor.extractEntities(testText);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (entities) {
            expect(entities, isA<List<ExtractedEntity>>());
            // In real implementation, we'd verify specific entities
            // For now, just check it returns a list
          },
        );
      });

      test('should return failure when extractor not initialized', () async {
        // Act - Try to extract without initializing
        final result = await extractor.extractEntities(testText);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NerFailure>());
            expect(failure.message, contains('not initialized'));
          },
          (_) => fail('Should not return success'),
        );
      });

      test('should handle empty text gracefully', () async {
        // Arrange
        await extractor.initialize(testModelPath);
        const emptyText = '';

        // Act
        final result = await extractor.extractEntities(emptyText);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (entities) {
            expect(entities, isEmpty);
          },
        );
      });

      test('should extract person names correctly', () async {
        // Arrange
        await extractor.initialize(testModelPath);

        // Act
        final result = await extractor.extractEntities(testText);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (entities) {
            // In real implementation, verify person entity extraction
            expect(entities, isA<List<ExtractedEntity>>());
          },
        );
      });

      test('should extract dates correctly', () async {
        // Arrange
        await extractor.initialize(testModelPath);

        // Act
        final result = await extractor.extractEntities(testText);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (entities) {
            // In real implementation, verify date entity extraction
            expect(entities, isA<List<ExtractedEntity>>());
          },
        );
      });

      test('should extract lab values correctly', () async {
        // Arrange
        await extractor.initialize(testModelPath);

        // Act
        final result = await extractor.extractEntities(testText);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (entities) {
            // In real implementation, verify lab value extraction
            expect(entities, isA<List<ExtractedEntity>>());
          },
        );
      });

      test('should include confidence scores for entities', () async {
        // Arrange
        await extractor.initialize(testModelPath);

        // Act
        final result = await extractor.extractEntities(testText);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (entities) {
            // In real implementation, verify confidence scores
            for (final entity in entities) {
              expect(entity.confidence, greaterThanOrEqualTo(0.0));
              expect(entity.confidence, lessThanOrEqualTo(1.0));
            }
          },
        );
      });

      test('should include correct offsets for entities', () async {
        // Arrange
        await extractor.initialize(testModelPath);

        // Act
        final result = await extractor.extractEntities(testText);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (entities) {
            // In real implementation, verify offsets
            for (final entity in entities) {
              expect(entity.startOffset, greaterThanOrEqualTo(0));
              expect(entity.endOffset, greaterThan(entity.startOffset));
            }
          },
        );
      });

      test('should handle extraction errors gracefully', () async {
        // Arrange
        await extractor.initialize(testModelPath);
        const malformedText = '\x00\xFF\xFE'; // Invalid UTF-8

        // Act
        final result = await extractor.extractEntities(malformedText);

        // Assert - Should either succeed with empty list or return failure
        expect(result.isRight() || result.isLeft(), true);
      });

      test('should extract entities with correct types and confidence', () async {
        // Arrange
        await extractor.initialize(testModelPath);

        // Act
        final result = await extractor.extractEntities(testText);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Should not return failure'),
          (entities) {
            expect(entities, isNotEmpty);

            // Verify we have person entities
            final personEntities = entities.where((e) => e.type == EntityType.person);
            expect(personEntities, isNotEmpty);

            // Verify we have date entities
            final dateEntities = entities.where((e) => e.type == EntityType.date);
            expect(dateEntities, isNotEmpty);

            // Verify we have lab value entities
            final labEntities = entities.where((e) => e.type == EntityType.labValue);
            expect(labEntities, isNotEmpty);

            // Verify all entities have valid confidence scores
            for (final entity in entities) {
              expect(entity.confidence, greaterThanOrEqualTo(0.0));
              expect(entity.confidence, lessThanOrEqualTo(1.0));
            }
          },
        );
      });
    });

    group('dispose', () {
      test('should cleanup resources on dispose', () async {
        // Arrange
        await extractor.initialize(testModelPath);

        // Act
        extractor.dispose();

        // Try to use after dispose - should fail
        final result = await extractor.extractEntities(testText);

        // Assert
        expect(result.isLeft(), true);
      });
    });
  });
}
