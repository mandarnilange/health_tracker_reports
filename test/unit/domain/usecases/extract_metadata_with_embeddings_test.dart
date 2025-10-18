import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/services/metadata_embedding_matcher.dart';
import 'package:health_tracker_reports/domain/usecases/extract_metadata_with_embeddings.dart';
import 'package:mocktail/mocktail.dart';

class MockMetadataEmbeddingMatcher extends Mock
    implements MetadataEmbeddingMatcher {}

void main() {
  setUpAll(() {
    registerFallbackValue(MetadataFieldType.patientName);
  });

  group('ExtractMetadataWithEmbeddings', () {
    late ExtractMetadataWithEmbeddings usecase;
    late MockMetadataEmbeddingMatcher mockMatcher;

    setUp(() {
      mockMatcher = MockMetadataEmbeddingMatcher();
      usecase = ExtractMetadataWithEmbeddings(embeddingMatcher: mockMatcher);
    });

    group('extractWithConfidence', () {
      test('should return metadata with confidence scores from embeddings',
          () async {
        // Arrange
        final rawMetadata = {
          'patientName': 'John Doe',
          'labName': 'City Hospital Lab',
          'reportDate': '2024-01-15',
        };

        when(() => mockMatcher.matchConfidence(any(), any()))
            .thenAnswer((invocation) async {
          final text = invocation.positionalArguments[0] as String;
          final fieldType = invocation.positionalArguments[1] as MetadataFieldType;

          if (text.toLowerCase().contains('john') &&
              fieldType == MetadataFieldType.patientName) {
            return 0.92;
          }
          if (text.toLowerCase().contains('hospital') &&
              fieldType == MetadataFieldType.labName) {
            return 0.88;
          }
          if (text.contains('2024') && fieldType == MetadataFieldType.reportDate) {
            return 0.85;
          }
          return 0.3;
        });

        // Act
        final result = await usecase.extractWithConfidence(rawMetadata);

        // Assert
        expect(result.isRight(), isTrue);
        final metadata = result.getOrElse(() => throw Exception());

        expect(metadata.length, equals(3));
        expect(metadata['patientName']?.value, equals('John Doe'));
        expect(metadata['patientName']?.confidence, equals(0.92));
        expect(metadata['labName']?.value, equals('City Hospital Lab'));
        expect(metadata['labName']?.confidence, equals(0.88));
        expect(metadata['reportDate']?.value, equals('2024-01-15'));
        expect(metadata['reportDate']?.confidence, equals(0.85));
      });

      test('should handle empty metadata map', () async {
        // Arrange
        final rawMetadata = <String, String>{};

        // Act
        final result = await usecase.extractWithConfidence(rawMetadata);

        // Assert
        expect(result.isRight(), isTrue);
        final metadata = result.getOrElse(() => throw Exception());
        expect(metadata.isEmpty, isTrue);
      });

      test('should handle metadata with empty values', () async {
        // Arrange
        final rawMetadata = {
          'patientName': '',
          'labName': 'City Hospital',
        };

        when(() => mockMatcher.matchConfidence(any(), any())).thenAnswer((_) async => 0.8);

        // Act
        final result = await usecase.extractWithConfidence(rawMetadata);

        // Assert
        expect(result.isRight(), isTrue);
        final metadata = result.getOrElse(() => throw Exception());

        // Empty values should have 0.0 confidence
        expect(metadata['patientName']?.value, equals(''));
        expect(metadata['patientName']?.confidence, equals(0.0));
        expect(metadata['labName']?.value, equals('City Hospital'));
        expect(metadata['labName']?.confidence, equals(0.8));
      });

      test('should return failure if matcher throws exception', () async {
        // Arrange
        final rawMetadata = {'patientName': 'John Doe'};

        when(() => mockMatcher.matchConfidence(any(), any()))
            .thenThrow(Exception('Embeddings not loaded'));

        // Act
        final result = await usecase.extractWithConfidence(rawMetadata);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<EmbeddingFailure>());
            expect(failure.message, contains('Embeddings not loaded'));
          },
          (_) => fail('Should return failure'),
        );
      });

      test('should map metadata field names to embedding field types correctly',
          () async {
        // Arrange
        final rawMetadata = {
          'patientName': 'John Doe',
          'labName': 'City Lab',
          'reportDate': '2024-01-15',
          'collectedDate': '2024-01-14',
          'biomarkerName': 'Hemoglobin',
        };

        final capturedFieldTypes = <MetadataFieldType>[];
        when(() => mockMatcher.matchConfidence(any(), any()))
            .thenAnswer((invocation) async {
          final fieldType = invocation.positionalArguments[1] as MetadataFieldType;
          capturedFieldTypes.add(fieldType);
          return 0.8;
        });

        // Act
        await usecase.extractWithConfidence(rawMetadata);

        // Assert
        expect(capturedFieldTypes.contains(MetadataFieldType.patientName), isTrue);
        expect(capturedFieldTypes.contains(MetadataFieldType.labName), isTrue);
        expect(capturedFieldTypes.contains(MetadataFieldType.reportDate), isTrue);
        expect(capturedFieldTypes.contains(MetadataFieldType.collectedDate), isTrue);
        expect(capturedFieldTypes.contains(MetadataFieldType.biomarkerName), isTrue);
      });

      test('should handle unknown metadata field names', () async {
        // Arrange
        final rawMetadata = {
          'unknownField': 'some value',
          'patientName': 'John Doe',
        };

        when(() => mockMatcher.matchConfidence(any(), any())).thenAnswer((_) async => 0.8);

        // Act
        final result = await usecase.extractWithConfidence(rawMetadata);

        // Assert
        expect(result.isRight(), isTrue);
        final metadata = result.getOrElse(() => throw Exception());

        // Unknown fields should still be included but with 0.0 confidence
        expect(metadata['unknownField']?.value, equals('some value'));
        expect(metadata['unknownField']?.confidence, equals(0.0));
        expect(metadata['patientName']?.value, equals('John Doe'));
        expect(metadata['patientName']?.confidence, equals(0.8));
      });
    });

    group('suggestFieldTypes', () {
      test('should suggest field types for unstructured text', () async {
        // Arrange
        final texts = [
          'Patient Name: John Doe',
          'Lab: City Hospital',
          'Report Date: 2024-01-15',
        ];

        when(() => mockMatcher.suggestFieldType(any(), threshold: any(named: 'threshold')))
            .thenAnswer((invocation) async {
          final text = invocation.positionalArguments[0] as String;
          if (text.toLowerCase().contains('patient')) {
            return FieldTypeSuggestion(
              fieldType: MetadataFieldType.patientName,
              confidence: 0.9,
            );
          }
          if (text.toLowerCase().contains('lab')) {
            return FieldTypeSuggestion(
              fieldType: MetadataFieldType.labName,
              confidence: 0.85,
            );
          }
          if (text.toLowerCase().contains('report date')) {
            return FieldTypeSuggestion(
              fieldType: MetadataFieldType.reportDate,
              confidence: 0.8,
            );
          }
          return null;
        });

        // Act
        final result = await usecase.suggestFieldTypes(texts);

        // Assert
        expect(result.isRight(), isTrue);
        final suggestions = result.getOrElse(() => throw Exception());

        expect(suggestions.length, equals(3));
        expect(suggestions[0]?.fieldType, equals(MetadataFieldType.patientName));
        expect(suggestions[1]?.fieldType, equals(MetadataFieldType.labName));
        expect(suggestions[2]?.fieldType, equals(MetadataFieldType.reportDate));
      });

      test('should return null suggestion for unrecognized text', () async {
        // Arrange
        final texts = [
          'random text',
          'Patient Name: John Doe',
        ];

        when(() => mockMatcher.suggestFieldType(any(), threshold: any(named: 'threshold')))
            .thenAnswer((invocation) async {
          final text = invocation.positionalArguments[0] as String;
          if (text.toLowerCase().contains('patient')) {
            return FieldTypeSuggestion(
              fieldType: MetadataFieldType.patientName,
              confidence: 0.9,
            );
          }
          return null;
        });

        // Act
        final result = await usecase.suggestFieldTypes(texts);

        // Assert
        expect(result.isRight(), isTrue);
        final suggestions = result.getOrElse(() => throw Exception());

        expect(suggestions.length, equals(2));
        expect(suggestions[0], isNull);
        expect(suggestions[1]?.fieldType, equals(MetadataFieldType.patientName));
      });

      test('should handle empty text list', () async {
        // Arrange
        final texts = <String>[];

        // Act
        final result = await usecase.suggestFieldTypes(texts);

        // Assert
        expect(result.isRight(), isTrue);
        final suggestions = result.getOrElse(() => throw Exception());
        expect(suggestions.isEmpty, isTrue);
      });

      test('should respect custom threshold parameter', () async {
        // Arrange
        final texts = ['Patient Name: John Doe'];

        when(() => mockMatcher.suggestFieldType(any(), threshold: 0.9))
            .thenAnswer((_) async => null);
        when(() => mockMatcher.suggestFieldType(any(), threshold: 0.5))
            .thenAnswer((_) async => FieldTypeSuggestion(
              fieldType: MetadataFieldType.patientName,
              confidence: 0.6,
            ));

        // Act
        final resultHigh = await usecase.suggestFieldTypes(texts, threshold: 0.9);
        final resultLow = await usecase.suggestFieldTypes(texts, threshold: 0.5);

        // Assert
        expect(resultHigh.isRight(), isTrue);
        expect(resultLow.isRight(), isTrue);

        final suggestionsHigh = resultHigh.getOrElse(() => throw Exception());
        final suggestionsLow = resultLow.getOrElse(() => throw Exception());

        expect(suggestionsHigh[0], isNull);
        expect(suggestionsLow[0]?.fieldType, equals(MetadataFieldType.patientName));
      });

      test('should return failure if matcher throws exception', () async {
        // Arrange
        final texts = ['Patient Name: John Doe'];

        when(() => mockMatcher.suggestFieldType(any(), threshold: any(named: 'threshold')))
            .thenThrow(Exception('Embeddings not loaded'));

        // Act
        final result = await usecase.suggestFieldTypes(texts);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<EmbeddingFailure>());
            expect(failure.message, contains('Embeddings not loaded'));
          },
          (_) => fail('Should return failure'),
        );
      });
    });

    group('extractWithFallback', () {
      test('should return embedding-based extraction when available', () async {
        // Arrange
        final rawMetadata = {'patientName': 'John Doe'};
        final fallbackMetadata = {'patientName': 'Jane Smith'};

        when(() => mockMatcher.matchConfidence(any(), any())).thenAnswer((_) async => 0.85);

        // Act
        final result = await usecase.extractWithFallback(
          rawMetadata: rawMetadata,
          fallbackMetadata: fallbackMetadata,
        );

        // Assert
        expect(result.isRight(), isTrue);
        final metadata = result.getOrElse(() => throw Exception());

        expect(metadata['patientName']?.value, equals('John Doe'));
        expect(metadata['patientName']?.confidence, equals(0.85));
      });

      test(
          'should use fallback metadata when embedding confidence is below threshold',
          () async {
        // Arrange
        final rawMetadata = {'patientName': 'uncertain value'};
        final fallbackMetadata = {'patientName': 'John Doe'};

        when(() => mockMatcher.matchConfidence(any(), any())).thenAnswer((_) async => 0.5);

        // Act
        final result = await usecase.extractWithFallback(
          rawMetadata: rawMetadata,
          fallbackMetadata: fallbackMetadata,
          confidenceThreshold: 0.7,
        );

        // Assert
        expect(result.isRight(), isTrue);
        final metadata = result.getOrElse(() => throw Exception());

        expect(metadata['patientName']?.value, equals('John Doe'));
        expect(metadata['patientName']?.confidence, equals(0.5));
        expect(metadata['patientName']?.usedFallback, isTrue);
      });

      test('should use fallback when embedding extraction fails', () async {
        // Arrange
        final rawMetadata = {'patientName': 'John Doe'};
        final fallbackMetadata = {'patientName': 'Fallback Name'};

        when(() => mockMatcher.matchConfidence(any(), any()))
            .thenThrow(Exception('Embeddings error'));

        // Act
        final result = await usecase.extractWithFallback(
          rawMetadata: rawMetadata,
          fallbackMetadata: fallbackMetadata,
        );

        // Assert
        expect(result.isRight(), isTrue);
        final metadata = result.getOrElse(() => throw Exception());

        expect(metadata['patientName']?.value, equals('Fallback Name'));
        expect(metadata['patientName']?.usedFallback, isTrue);
      });

      test('should merge fields from both raw and fallback metadata', () async {
        // Arrange
        final rawMetadata = {
          'patientName': 'John Doe',
          'labName': 'City Lab',
        };
        final fallbackMetadata = {
          'reportDate': '2024-01-15',
        };

        when(() => mockMatcher.matchConfidence(any(), any())).thenAnswer((_) async => 0.8);

        // Act
        final result = await usecase.extractWithFallback(
          rawMetadata: rawMetadata,
          fallbackMetadata: fallbackMetadata,
        );

        // Assert
        expect(result.isRight(), isTrue);
        final metadata = result.getOrElse(() => throw Exception());

        expect(metadata.length, equals(3));
        expect(metadata['patientName']?.value, equals('John Doe'));
        expect(metadata['labName']?.value, equals('City Lab'));
        expect(metadata['reportDate']?.value, equals('2024-01-15'));
      });
    });
  });
}
