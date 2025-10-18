import 'dart:convert';
import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/services/metadata_embedding_matcher.dart';
import 'package:injectable/injectable.dart';

/// Implementation using bundled medical term embeddings.
@LazySingleton(as: MetadataEmbeddingMatcher)
class MetadataEmbeddingMatcherImpl implements MetadataEmbeddingMatcher {
  static const String _assetPath =
      'assets/models/embeddings/medical_terms_v1.json';

  Map<String, List<double>> _embeddings = {};
  bool _initialized = false;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;

      final embeddingsData = data['embeddings'] as Map<String, dynamic>?;
      if (embeddingsData == null) {
        return const Left(
          CacheFailure('Invalid embeddings format: missing embeddings key'),
        );
      }

      _embeddings = embeddingsData.map((key, value) {
        final list = (value as List).cast<double>();
        return MapEntry(key, list);
      });

      _initialized = true;
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure('Failed to load embeddings: $e'));
    }
  }

  @override
  Future<double> matchConfidence(
    String text,
    MetadataFieldType fieldType,
  ) async {
    if (!_initialized) {
      return 0.0;
    }

    if (text.trim().isEmpty) {
      return 0.0;
    }

    // Get embedding key for field type
    final embeddingKey = _getEmbeddingKey(fieldType);
    final fieldEmbedding = _embeddings[embeddingKey];

    if (fieldEmbedding == null) {
      // Fallback to pattern-based matching
      return _fallbackPatternMatch(text, fieldType);
    }

    // Get pattern-based confidence first
    final patternConfidence = _fallbackPatternMatch(text, fieldType);

    // Generate text embedding (simplified - would use real embeddings in production)
    final textEmbedding = _generateTextEmbedding(text, fieldType);

    // Calculate cosine similarity
    final embeddingSimilarity = calculateCosineSimilarity(textEmbedding, fieldEmbedding);

    // Blend pattern-based and embedding-based confidence (weighted average)
    // In production with real embeddings, we'd rely more on embedding similarity
    return (patternConfidence * 0.6) + (embeddingSimilarity * 0.4);
  }

  @override
  Future<FieldTypeSuggestion?> suggestFieldType(
    String text, {
    double threshold = 0.7,
  }) async {
    if (!_initialized || text.trim().isEmpty) {
      return null;
    }

    double bestConfidence = 0.0;
    MetadataFieldType? bestType;

    for (final fieldType in MetadataFieldType.values) {
      final confidence = await matchConfidence(text, fieldType);
      if (confidence > bestConfidence) {
        bestConfidence = confidence;
        bestType = fieldType;
      }
    }

    if (bestType != null && bestConfidence >= threshold) {
      return FieldTypeSuggestion(
        fieldType: bestType,
        confidence: bestConfidence,
      );
    }

    return null;
  }

  String _getEmbeddingKey(MetadataFieldType fieldType) {
    switch (fieldType) {
      case MetadataFieldType.patientName:
        return 'patient_name';
      case MetadataFieldType.labName:
        return 'lab_name';
      case MetadataFieldType.reportDate:
        return 'report_date';
      case MetadataFieldType.collectedDate:
        return 'collected_date';
      case MetadataFieldType.biomarkerName:
        return 'biomarker_name';
      case MetadataFieldType.labReference:
        return 'lab_reference';
      case MetadataFieldType.ageGender:
        return 'age_gender';
    }
  }

  /// Simplified embedding generation (placeholder for real embeddings).
  /// In production, this would use a proper word embedding model.
  List<double> _generateTextEmbedding(String text, MetadataFieldType fieldType) {
    final normalized = text.toLowerCase().trim();
    final hash = normalized.hashCode.abs();
    final random = math.Random(hash);

    // Get the field embedding to create a biased pseudo-embedding
    final embeddingKey = _getEmbeddingKey(fieldType);
    final fieldEmbedding = _embeddings[embeddingKey];

    if (fieldEmbedding == null) {
      // Generate generic pseudo-embedding based on text features
      return List.generate(128, (i) {
        final charInfluence = i < normalized.length
            ? normalized.codeUnitAt(i) / 255.0
            : 0.0;
        final randomComponent = random.nextDouble();
        return (charInfluence + randomComponent) / 2.0;
      });
    }

    // Generate pseudo-embedding that is influenced by the field embedding
    // to simulate embeddings that are closer to the correct field type
    final patternMatch = _fallbackPatternMatch(text, fieldType);

    return List.generate(128, (i) {
      final charInfluence = i < normalized.length
          ? normalized.codeUnitAt(i) / 255.0
          : 0.0;
      final randomComponent = random.nextDouble();
      final baseValue = (charInfluence + randomComponent) / 2.0;

      // If pattern matches well, bias towards field embedding
      if (patternMatch > 0.7) {
        return (baseValue * 0.3) + (fieldEmbedding[i] * 0.7);
      } else if (patternMatch > 0.5) {
        return (baseValue * 0.5) + (fieldEmbedding[i] * 0.5);
      } else {
        return (baseValue * 0.7) + (fieldEmbedding[i] * 0.3);
      }
    });
  }

  /// Fallback pattern matching when embeddings are unavailable.
  double _fallbackPatternMatch(String text, MetadataFieldType fieldType) {
    final normalized = text.toLowerCase().trim();

    switch (fieldType) {
      case MetadataFieldType.patientName:
        // Name patterns: multiple words, capitalized, no numbers
        final words = text.split(' ');
        final hasMultipleWords = words.length >= 2;
        final hasNoNumbers = !RegExp(r'\d').hasMatch(text);
        final hasCapitals = RegExp(r'[A-Z]').hasMatch(text);
        return (hasMultipleWords && hasNoNumbers && hasCapitals) ? 0.75 : 0.3;

      case MetadataFieldType.labName:
        // Lab name patterns: contains keywords
        final keywords = [
          'clinic',
          'hospital',
          'diagnostic',
          'laboratory',
          'lab',
          'centre',
          'center',
          'foundation'
        ];
        final hasKeyword = keywords.any(normalized.contains);
        return hasKeyword ? 0.8 : 0.2;

      case MetadataFieldType.reportDate:
      case MetadataFieldType.collectedDate:
        // Date patterns: contains numbers and separators
        final datePattern = RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}');
        return datePattern.hasMatch(text) ? 0.85 : 0.1;

      case MetadataFieldType.biomarkerName:
        // Biomarker patterns: medical terms
        final medicalKeywords = [
          'hemoglobin',
          'glucose',
          'cholesterol',
          'creatinine',
          'bilirubin',
          'protein',
          'albumin'
        ];
        final hasMedicalTerm = medicalKeywords.any(normalized.contains);
        return hasMedicalTerm ? 0.8 : 0.3;

      case MetadataFieldType.labReference:
        // Lab reference patterns: alphanumeric codes
        final codePattern = RegExp(r'[A-Z0-9]{5,}');
        return codePattern.hasMatch(text) ? 0.75 : 0.2;

      case MetadataFieldType.ageGender:
        // Age/gender patterns
        final ageGenderPattern =
            RegExp(r'\d{1,3}\s*(y|yr|years?|m|male|f|female)', caseSensitive: false);
        return ageGenderPattern.hasMatch(text) ? 0.8 : 0.2;
    }
  }
}

/// Calculate cosine similarity between two vectors.
double calculateCosineSimilarity(List<double> vec1, List<double> vec2) {
  if (vec1.length != vec2.length) {
    throw ArgumentError('Vectors must have the same length');
  }

  double dotProduct = 0.0;
  double norm1 = 0.0;
  double norm2 = 0.0;

  for (int i = 0; i < vec1.length; i++) {
    dotProduct += vec1[i] * vec2[i];
    norm1 += vec1[i] * vec1[i];
    norm2 += vec2[i] * vec2[i];
  }

  if (norm1 == 0.0 || norm2 == 0.0) {
    return 0.0;
  }

  return dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
}
