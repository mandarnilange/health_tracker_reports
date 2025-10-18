import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/services/metadata_embedding_matcher.dart';
import 'package:injectable/injectable.dart';

/// Represents a metadata field with its value and confidence score.
class MetadataField {
  const MetadataField({
    required this.value,
    required this.confidence,
    this.usedFallback = false,
  });

  /// The extracted metadata value
  final String value;

  /// Confidence score (0.0 to 1.0) from embedding similarity matching
  final double confidence;

  /// Whether fallback metadata was used
  final bool usedFallback;
}

/// Represents a suggested field type for unstructured text.
class FieldSuggestion {
  const FieldSuggestion({
    required this.text,
    required this.fieldType,
  });

  /// The original text
  final String text;

  /// The suggested field type
  final MetadataFieldType fieldType;
}

/// Wrapper around existing metadata extraction that adds embedding-based confidence scoring.
///
/// This usecase enhances metadata extraction with semantic understanding using
/// bundled medical term embeddings. It provides:
/// - Confidence scores for extracted metadata fields
/// - Field type suggestions for unstructured text
/// - Fallback to rule-based extraction when embeddings fail
///
/// Usage:
/// ```dart
/// final result = await extractWithConfidence(rawMetadata);
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (metadata) {
///     for (final entry in metadata.entries) {
///       print('${entry.key}: ${entry.value.value} (${entry.value.confidence})');
///     }
///   },
/// );
/// ```
@lazySingleton
class ExtractMetadataWithEmbeddings {
  final MetadataEmbeddingMatcher embeddingMatcher;

  const ExtractMetadataWithEmbeddings({
    required this.embeddingMatcher,
  });

  /// Extracts metadata with confidence scores using embeddings.
  ///
  /// Takes [rawMetadata] map with field names as keys and returns a map
  /// with [MetadataField] objects containing values and confidence scores.
  ///
  /// Returns [EmbeddingFailure] if embedding matching fails.
  Future<Either<Failure, Map<String, MetadataField>>> extractWithConfidence(
    Map<String, String> rawMetadata,
  ) async {
    try {
      final result = <String, MetadataField>{};

      for (final entry in rawMetadata.entries) {
        final fieldName = entry.key;
        final value = entry.value;

        // Empty values get 0.0 confidence
        if (value.trim().isEmpty) {
          result[fieldName] = MetadataField(
            value: value,
            confidence: 0.0,
          );
          continue;
        }

        // Map field names to embedding field types
        final embeddingFieldType = _mapFieldNameToEmbeddingType(fieldName);

        // Get confidence score from embeddings
        final confidence = embeddingFieldType != null
            ? await embeddingMatcher.matchConfidence(value, embeddingFieldType)
            : 0.0;

        result[fieldName] = MetadataField(
          value: value,
          confidence: confidence,
        );
      }

      return Right(result);
    } catch (e) {
      return Left(EmbeddingFailure(message: e.toString()));
    }
  }

  /// Suggests field types for a list of unstructured text strings.
  ///
  /// Returns a list of [FieldSuggestion] objects (or null for unrecognized text).
  /// The [threshold] parameter controls the minimum confidence required (default 0.7).
  ///
  /// Returns [EmbeddingFailure] if embedding matching fails.
  Future<Either<Failure, List<FieldSuggestion?>>> suggestFieldTypes(
    List<String> texts, {
    double threshold = 0.7,
  }) async {
    try {
      final suggestions = <FieldSuggestion?>[];

      for (final text in texts) {
        final suggestion = await embeddingMatcher.suggestFieldType(
          text,
          threshold: threshold,
        );

        if (suggestion != null) {
          suggestions.add(FieldSuggestion(
            text: text,
            fieldType: suggestion.fieldType,
          ));
        } else {
          suggestions.add(null);
        }
      }

      return Right(suggestions);
    } catch (e) {
      return Left(EmbeddingFailure(message: e.toString()));
    }
  }

  /// Extracts metadata with embedding-based confidence scoring and fallback support.
  ///
  /// Attempts embedding-based extraction first. If confidence is below [confidenceThreshold]
  /// or if embedding extraction fails, falls back to [fallbackMetadata].
  ///
  /// The [fallbackMetadata] typically comes from rule-based extraction.
  ///
  /// Returns a merged map containing fields from both sources, with the [usedFallback]
  /// flag indicating which fields used fallback values.
  Future<Either<Failure, Map<String, MetadataField>>> extractWithFallback({
    required Map<String, String> rawMetadata,
    required Map<String, String> fallbackMetadata,
    double confidenceThreshold = 0.7,
  }) async {
    // Try embedding-based extraction first
    final embeddingResult = await extractWithConfidence(rawMetadata);

    // If embeddings fail, use fallback for all fields
    if (embeddingResult.isLeft()) {
      return Right(_convertToMetadataFields(fallbackMetadata, usedFallback: true));
    }

    final embeddingMetadata = embeddingResult.getOrElse(() => {});
    final result = <String, MetadataField>{};

    // Process fields from raw metadata with confidence checking
    for (final entry in embeddingMetadata.entries) {
      final fieldName = entry.key;
      final field = entry.value;

      // Use fallback if confidence is below threshold
      if (field.confidence < confidenceThreshold &&
          fallbackMetadata.containsKey(fieldName)) {
        result[fieldName] = MetadataField(
          value: fallbackMetadata[fieldName]!,
          confidence: field.confidence,
          usedFallback: true,
        );
      } else {
        result[fieldName] = field;
      }
    }

    // Add any fields that only exist in fallback metadata
    for (final entry in fallbackMetadata.entries) {
      if (!result.containsKey(entry.key)) {
        final embeddingFieldType = _mapFieldNameToEmbeddingType(entry.key);
        final confidence = embeddingFieldType != null
            ? await embeddingMatcher.matchConfidence(entry.value, embeddingFieldType)
            : 0.0;

        result[entry.key] = MetadataField(
          value: entry.value,
          confidence: confidence,
          usedFallback: false,
        );
      }
    }

    return Right(result);
  }

  /// Maps field names from metadata extraction to embedding field types.
  ///
  /// Examples:
  /// - 'patientName' -> MetadataFieldType.patientName
  /// - 'labName' -> MetadataFieldType.labName
  /// - 'reportDate' -> MetadataFieldType.reportDate
  MetadataFieldType? _mapFieldNameToEmbeddingType(String fieldName) {
    final mapping = {
      'patientName': MetadataFieldType.patientName,
      'labName': MetadataFieldType.labName,
      'labReference': MetadataFieldType.labReference,
      'reportDate': MetadataFieldType.reportDate,
      'collectedDate': MetadataFieldType.collectedDate,
      'biomarkerName': MetadataFieldType.biomarkerName,
    };

    return mapping[fieldName];
  }

  /// Converts a string map to MetadataField map with default confidence.
  Map<String, MetadataField> _convertToMetadataFields(
    Map<String, String> metadata, {
    bool usedFallback = false,
  }) {
    return metadata.map(
      (key, value) => MapEntry(
        key,
        MetadataField(
          value: value,
          confidence: 0.0,
          usedFallback: usedFallback,
        ),
      ),
    );
  }
}
