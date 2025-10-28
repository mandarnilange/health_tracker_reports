import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

void main() {
  group('ExtractedBiomarker', () {
    test('supports equality and toString', () {
      const biomarkerA = ExtractedBiomarker(
        name: 'Glucose',
        value: '95',
        unit: 'mg/dL',
        referenceRange: '70-100',
        confidence: 0.9,
      );
      const biomarkerB = ExtractedBiomarker(
        name: 'Glucose',
        value: '95',
        unit: 'mg/dL',
        referenceRange: '70-100',
        confidence: 0.9,
      );

      expect(biomarkerA, equals(biomarkerB));
      expect(
        biomarkerA.toString(),
        contains('ExtractedBiomarker(name: Glucose'),
      );
    });
  });

  group('ExtractedMetadata', () {
    test('supports equality and toString', () {
      final metadata = ExtractedMetadata(
        patientName: 'Jane Doe',
        reportDate: DateTime(2024, 1, 1),
        collectionDate: DateTime(2023, 12, 31),
        labName: 'Acme Labs',
        labReference: 'REF-123',
      );

      final other = ExtractedMetadata(
        patientName: 'Jane Doe',
        reportDate: DateTime(2024, 1, 1),
        collectionDate: DateTime(2023, 12, 31),
        labName: 'Acme Labs',
        labReference: 'REF-123',
      );

      expect(metadata, equals(other));
      expect(metadata.toString(), contains('ExtractedMetadata')); // coverage check
    });
  });

  group('LlmExtractionResult', () {
    test('supports equality and exposes summary', () {
      const biomarker = ExtractedBiomarker(name: 'HbA1c', value: '5.6');
      final metadata = ExtractedMetadata(patientName: 'Alex');
      final resultA = LlmExtractionResult(
        biomarkers: [biomarker],
        metadata: metadata,
        confidence: 0.8,
        rawResponse: '{"data":[]}',
        provider: LlmProvider.openai,
      );
      final resultB = LlmExtractionResult(
        biomarkers: [biomarker],
        metadata: metadata,
        confidence: 0.8,
        rawResponse: '{"data":[]}',
        provider: LlmProvider.openai,
      );

      expect(resultA, equals(resultB));
      expect(resultA.toString(), contains('LlmExtractionResult(provider')); // coverage
    });
  });
}
