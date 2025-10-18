import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

void main() {
  group('LlmProvider', () {
    test('should have three provider options', () {
      expect(LlmProvider.values.length, 3);
      expect(LlmProvider.values, contains(LlmProvider.claude));
      expect(LlmProvider.values, contains(LlmProvider.openai));
      expect(LlmProvider.values, contains(LlmProvider.gemini));
    });
  });

  group('ExtractedBiomarker', () {
    const tBiomarker = ExtractedBiomarker(
      name: 'Hemoglobin',
      value: '13.5',
      unit: 'g/dL',
      referenceRange: '12.0-16.0',
      confidence: 0.95,
    );

    test('should be a subclass of Equatable', () {
      expect(tBiomarker, isA<Object>());
    });

    test('should support value equality', () {
      const biomarker1 = ExtractedBiomarker(
        name: 'Hemoglobin',
        value: '13.5',
        unit: 'g/dL',
        referenceRange: '12.0-16.0',
        confidence: 0.95,
      );

      const biomarker2 = ExtractedBiomarker(
        name: 'Hemoglobin',
        value: '13.5',
        unit: 'g/dL',
        referenceRange: '12.0-16.0',
        confidence: 0.95,
      );

      expect(biomarker1, biomarker2);
    });

    test('should not be equal when values differ', () {
      const biomarker1 = ExtractedBiomarker(
        name: 'Hemoglobin',
        value: '13.5',
      );

      const biomarker2 = ExtractedBiomarker(
        name: 'Hemoglobin',
        value: '14.0',
      );

      expect(biomarker1, isNot(biomarker2));
    });

    test('should handle nullable fields', () {
      const biomarker = ExtractedBiomarker(
        name: 'Test',
        value: '10',
      );

      expect(biomarker.unit, isNull);
      expect(biomarker.referenceRange, isNull);
      expect(biomarker.confidence, isNull);
    });
  });

  group('ExtractedMetadata', () {
    final tMetadata = ExtractedMetadata(
      patientName: 'John Doe',
      reportDate: DateTime(2025, 1, 15),
      collectionDate: DateTime(2025, 1, 14),
      labName: 'Quest Diagnostics',
      labReference: 'REF123456',
    );

    test('should support value equality', () {
      final metadata1 = ExtractedMetadata(
        patientName: 'John Doe',
        reportDate: DateTime(2025, 1, 15),
        collectionDate: DateTime(2025, 1, 14),
        labName: 'Quest Diagnostics',
        labReference: 'REF123456',
      );

      final metadata2 = ExtractedMetadata(
        patientName: 'John Doe',
        reportDate: DateTime(2025, 1, 15),
        collectionDate: DateTime(2025, 1, 14),
        labName: 'Quest Diagnostics',
        labReference: 'REF123456',
      );

      expect(metadata1, metadata2);
    });

    test('should handle all nullable fields', () {
      const metadata = ExtractedMetadata();

      expect(metadata.patientName, isNull);
      expect(metadata.reportDate, isNull);
      expect(metadata.collectionDate, isNull);
      expect(metadata.labName, isNull);
      expect(metadata.labReference, isNull);
    });
  });

  group('LlmExtractionResult', () {
    final tResult = LlmExtractionResult(
      biomarkers: const [
        ExtractedBiomarker(name: 'Hemoglobin', value: '13.5'),
        ExtractedBiomarker(name: 'WBC', value: '7000'),
      ],
      metadata: ExtractedMetadata(
        patientName: 'John Doe',
        reportDate: DateTime(2025, 1, 15),
      ),
      confidence: 0.92,
      rawResponse: '{"biomarkers": [...]}',
      provider: LlmProvider.claude,
    );

    test('should contain all required fields', () {
      expect(tResult.biomarkers.length, 2);
      expect(tResult.metadata, isNotNull);
      expect(tResult.confidence, 0.92);
      expect(tResult.rawResponse, '{"biomarkers": [...]}');
      expect(tResult.provider, LlmProvider.claude);
    });

    test('should support value equality', () {
      final result1 = LlmExtractionResult(
        biomarkers: const [
          ExtractedBiomarker(name: 'Hemoglobin', value: '13.5'),
        ],
        confidence: 0.9,
        provider: LlmProvider.claude,
      );

      final result2 = LlmExtractionResult(
        biomarkers: const [
          ExtractedBiomarker(name: 'Hemoglobin', value: '13.5'),
        ],
        confidence: 0.9,
        provider: LlmProvider.claude,
      );

      expect(result1, result2);
    });

    test('should handle empty biomarkers list', () {
      final result = LlmExtractionResult(
        biomarkers: const [],
        confidence: 0.5,
        provider: LlmProvider.gemini,
      );

      expect(result.biomarkers, isEmpty);
    });

    test('should handle null metadata and rawResponse', () {
      final result = LlmExtractionResult(
        biomarkers: const [ExtractedBiomarker(name: 'Test', value: '1')],
        confidence: 0.8,
        provider: LlmProvider.openai,
      );

      expect(result.metadata, isNull);
      expect(result.rawResponse, isNull);
    });
  });
}
