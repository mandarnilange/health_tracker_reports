import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';

/// Supported metadata field types for embedding matching.
enum MetadataFieldType {
  patientName,
  labName,
  reportDate,
  collectedDate,
  biomarkerName,
  labReference,
  ageGender,
}

/// Result of field type suggestion.
class FieldTypeSuggestion {
  const FieldTypeSuggestion({
    required this.fieldType,
    required this.confidence,
  });

  final MetadataFieldType fieldType;
  final double confidence;
}

/// Domain service for metadata embedding-based matching.
///
/// This service provides semantic understanding of metadata fields using
/// embeddings to:
/// - Calculate confidence scores for field type matching
/// - Suggest field types for unstructured text
/// - Enable intelligent metadata extraction
///
/// This is a domain abstraction - implementations should be in the data layer.
abstract class MetadataEmbeddingMatcher {
  /// Initialize the matcher by loading embeddings.
  ///
  /// Must be called before using matching methods.
  /// Returns [Failure] if initialization fails.
  Future<Either<Failure, void>> initialize();

  /// Calculate confidence score for text matching a specific field type.
  ///
  /// Returns value between 0.0 (no match) and 1.0 (perfect match).
  /// Higher scores indicate better semantic similarity to the field type.
  ///
  /// Example:
  /// ```dart
  /// final confidence = await matcher.matchConfidence(
  ///   'John Doe',
  ///   MetadataFieldType.patientName
  /// );
  /// // Returns ~0.85 if "John Doe" matches patient name pattern
  /// ```
  Future<double> matchConfidence(String text, MetadataFieldType fieldType);

  /// Suggest the most likely field type for given text.
  ///
  /// Returns [FieldTypeSuggestion] with the best matching field type
  /// and its confidence score, or null if confidence is below threshold.
  ///
  /// Example:
  /// ```dart
  /// final suggestion = await matcher.suggestFieldType(
  ///   'City Hospital Laboratory',
  ///   threshold: 0.7,
  /// );
  /// // Returns FieldTypeSuggestion(
  /// //   fieldType: MetadataFieldType.labName,
  /// //   confidence: 0.82
  /// // )
  /// ```
  Future<FieldTypeSuggestion?> suggestFieldType(
    String text, {
    double threshold = 0.7,
  });
}
