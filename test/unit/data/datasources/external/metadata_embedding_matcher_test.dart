import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/services/metadata_embedding_matcher.dart';
import 'package:health_tracker_reports/data/datasources/external/metadata_embedding_matcher.dart';

void main() {
  late MetadataEmbeddingMatcher matcher;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    matcher = MetadataEmbeddingMatcherImpl();
  });

  group('initialize', () {
    test('loads embeddings from asset successfully', () async {
      final result = await matcher.initialize();

      expect(result, isA<Right<Failure, void>>());
    });
  });

  group('matchConfidence', () {
    setUp(() async {
      await matcher.initialize();
    });

    test('returns high confidence for patient name patterns', () async {
      final confidence = await matcher.matchConfidence(
        'John Doe',
        MetadataFieldType.patientName,
      );

      expect(confidence, greaterThan(0.7));
    });

    test('returns high confidence for lab name patterns', () async {
      final confidence = await matcher.matchConfidence(
        'City Hospital Diagnostic Center',
        MetadataFieldType.labName,
      );

      expect(confidence, greaterThan(0.7));
    });

    test('returns high confidence for date patterns', () async {
      final confidence = await matcher.matchConfidence(
        '15/01/2025',
        MetadataFieldType.reportDate,
      );

      expect(confidence, greaterThan(0.7));
    });

    test('returns low confidence for mismatched field types', () async {
      final confidence = await matcher.matchConfidence(
        'John Doe',
        MetadataFieldType.reportDate,
      );

      expect(confidence, lessThan(0.5));
    });

    test('handles empty text gracefully', () async {
      final confidence = await matcher.matchConfidence(
        '',
        MetadataFieldType.patientName,
      );

      expect(confidence, equals(0.0));
    });
  });

  group('suggestFieldType', () {
    setUp(() async {
      await matcher.initialize();
    });

    test('suggests patient name for name-like text', () async {
      final suggestion = await matcher.suggestFieldType('John Doe');

      expect(suggestion, isNotNull);
      expect(suggestion!.fieldType, MetadataFieldType.patientName);
      expect(suggestion.confidence, greaterThan(0.7));
    });

    test('suggests lab name for organization text', () async {
      final suggestion = await matcher.suggestFieldType(
        'City Diagnostic Laboratory',
      );

      expect(suggestion, isNotNull);
      expect(suggestion!.fieldType, MetadataFieldType.labName);
    });

    test('returns null when confidence below threshold', () async {
      final suggestion = await matcher.suggestFieldType(
        'xyz123',
        threshold: 0.9,
      );

      expect(suggestion, isNull);
    });

    test('returns null for empty text', () async {
      final suggestion = await matcher.suggestFieldType('');

      expect(suggestion, isNull);
    });
  });

  group('cosine similarity calculation', () {
    test('returns 1.0 for identical vectors', () {
      final vec1 = List.generate(128, (i) => i * 0.1);
      final vec2 = List.generate(128, (i) => i * 0.1);

      final similarity = calculateCosineSimilarity(vec1, vec2);

      expect(similarity, closeTo(1.0, 0.001));
    });

    test('returns 0.0 for orthogonal vectors', () {
      final vec1 = List.generate(128, (i) => i % 2 == 0 ? 1.0 : 0.0);
      final vec2 = List.generate(128, (i) => i % 2 == 0 ? 0.0 : 1.0);

      final similarity = calculateCosineSimilarity(vec1, vec2);

      expect(similarity, closeTo(0.0, 0.001));
    });

    test('handles zero vectors gracefully', () {
      final vec1 = List.generate(128, (_) => 0.0);
      final vec2 = List.generate(128, (i) => i * 0.1);

      final similarity = calculateCosineSimilarity(vec1, vec2);

      expect(similarity, equals(0.0));
    });
  });
}
