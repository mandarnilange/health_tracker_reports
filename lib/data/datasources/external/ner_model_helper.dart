import 'package:health_tracker_reports/domain/entities/extracted_entity.dart';

/// Helper class for NER model configuration and pattern-based extraction.
///
/// This class provides:
/// - Model input/output shape documentation
/// - Entity label mappings
/// - Fallback pattern-based extraction for testing and offline use
class NerModelHelper {
  /// Expected model input shape: [batch_size, max_sequence_length]
  ///
  /// For medical NER model:
  /// - batch_size: 1 (single text at a time)
  /// - max_sequence_length: 128 (maximum tokens per input)
  static const modelInputShape = [1, 128];

  /// Expected model output shape: [batch_size, max_sequence_length]
  ///
  /// Output contains label indices for each token:
  /// - 0: O (Other/No entity)
  /// - 1: B-PERSON (Begin person name)
  /// - 2: I-PERSON (Inside person name)
  /// - 3: B-DATE (Begin date)
  /// - 4: I-DATE (Inside date)
  /// - 5: B-ORG (Begin organization)
  /// - 6: I-ORG (Inside organization)
  /// - 7: B-LAB_VALUE (Begin lab value)
  /// - 8: I-LAB_VALUE (Inside lab value)
  /// - 9: B-BIOMARKER (Begin biomarker name)
  /// - 10: I-BIOMARKER (Inside biomarker name)
  /// - 11: B-REF_RANGE (Begin reference range)
  /// - 12: I-REF_RANGE (Inside reference range)
  static const modelOutputShape = [1, 128];

  /// Maps model output label indices to EntityType
  ///
  /// Uses BIO tagging scheme (Begin, Inside, Other)
  static const Map<int, EntityType> labelMapping = {
    0: EntityType.other, // O
    1: EntityType.person, // B-PERSON
    2: EntityType.person, // I-PERSON
    3: EntityType.date, // B-DATE
    4: EntityType.date, // I-DATE
    5: EntityType.organization, // B-ORG
    6: EntityType.organization, // I-ORG
    7: EntityType.labValue, // B-LAB_VALUE
    8: EntityType.labValue, // I-LAB_VALUE
    9: EntityType.biomarkerName, // B-BIOMARKER
    10: EntityType.biomarkerName, // I-BIOMARKER
    11: EntityType.referenceRange, // B-REF_RANGE
    12: EntityType.referenceRange, // I-REF_RANGE
  };

  /// Confidence scores for each label
  ///
  /// In production, these would come from model's softmax output
  static const Map<int, double> defaultConfidenceScores = {
    0: 0.5, // O (low confidence for "other")
    1: 0.85, // B-PERSON
    2: 0.85, // I-PERSON
    3: 0.9, // B-DATE
    4: 0.9, // I-DATE
    5: 0.8, // B-ORG
    6: 0.8, // I-ORG
    7: 0.88, // B-LAB_VALUE
    8: 0.88, // I-LAB_VALUE
    9: 0.87, // B-BIOMARKER
    10: 0.87, // I-BIOMARKER
    11: 0.82, // B-REF_RANGE
    12: 0.82, // I-REF_RANGE
  };

  /// Pattern-based extraction rules for fallback
  static final Map<EntityType, RegExp> entityPatterns = {
    EntityType.person: RegExp(
      r'(?:Patient|Dr\.|Doctor|Mr\.|Mrs\.|Ms\.)\s*:?\s*([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',
      caseSensitive: true,
    ),
    EntityType.date: RegExp(
      r'\b(?:\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|\d{4}[-/]\d{1,2}[-/]\d{1,2}|'
      r'(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4})\b',
      caseSensitive: false,
    ),
    EntityType.organization: RegExp(
      r'(?:Lab|Laboratory|Hospital|Clinic|Center|Institute)\s*:?\s*([A-Z][A-Za-z\s&]+)',
      caseSensitive: true,
    ),
    EntityType.labValue: RegExp(
      r'\b\d+\.?\d*\s*(?:g/dL|mg/dL|mmol/L|IU/L|%|cells/μL|/μL)\b',
      caseSensitive: false,
    ),
    EntityType.biomarkerName: RegExp(
      r'\b(?:Hemoglobin|Glucose|Cholesterol|HDL|LDL|Triglycerides|'
      r'WBC|RBC|Platelets|Creatinine|ALT|AST|TSH|T3|T4|Vitamin\s+[A-D]|'
      r'HbA1c|Urea|BUN|Bilirubin)\b',
      caseSensitive: false,
    ),
    EntityType.referenceRange: RegExp(
      r'(?:Normal|Range|Reference)\s*:?\s*(\d+\.?\d*\s*-\s*\d+\.?\d*(?:\s*[a-zA-Z/μ]+)?)',
      caseSensitive: false,
    ),
  };

  /// Converts label index to EntityType
  EntityType labelToEntityType(int label) {
    return labelMapping[label] ?? EntityType.other;
  }

  /// Gets confidence score for a label
  double getConfidenceScore(int label) {
    return defaultConfidenceScores[label] ?? 0.5;
  }

  /// Fallback pattern-based entity extraction
  ///
  /// Used when TFLite model is unavailable or fails
  List<ExtractedEntity> extractWithPatterns(String text) {
    final entities = <ExtractedEntity>[];

    entityPatterns.forEach((type, pattern) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final matchedText = match.group(0) ?? '';
        if (matchedText.isNotEmpty) {
          entities.add(
            ExtractedEntity(
              text: matchedText.trim(),
              type: type,
              confidence: _getPatternConfidence(type),
              startOffset: match.start,
              endOffset: match.end,
            ),
          );
        }
      }
    });

    // Sort by start offset
    entities.sort((a, b) => a.startOffset.compareTo(b.startOffset));

    return entities;
  }

  /// Gets confidence score for pattern-based extraction
  double _getPatternConfidence(EntityType type) {
    // Pattern-based extraction has lower confidence than model
    switch (type) {
      case EntityType.date:
        return 0.85; // Dates have high pattern reliability
      case EntityType.labValue:
        return 0.82; // Lab values with units are reliable
      case EntityType.biomarkerName:
        return 0.78; // Medical terms are fairly reliable
      case EntityType.person:
        return 0.70; // Names are less reliable via patterns
      case EntityType.organization:
        return 0.72; // Organizations are moderately reliable
      case EntityType.referenceRange:
        return 0.75; // Ranges are moderately reliable
      case EntityType.other:
        return 0.5;
    }
  }

  /// Validates entity extraction results
  ///
  /// Checks for:
  /// - Confidence threshold
  /// - Valid offset ranges
  /// - Reasonable entity text length
  List<ExtractedEntity> validateEntities(
    List<ExtractedEntity> entities, {
    double minConfidence = 0.6,
    int maxEntityLength = 200,
  }) {
    return entities.where((entity) {
      // Check confidence
      if (entity.confidence < minConfidence) return false;

      // Check offset validity
      if (entity.startOffset < 0 || entity.endOffset <= entity.startOffset) {
        return false;
      }

      // Check text length
      if (entity.text.length > maxEntityLength) return false;

      return true;
    }).toList();
  }

  /// Merges adjacent entities of the same type
  ///
  /// Useful for handling BIO tagging where a single entity
  /// might be split across multiple tokens
  List<ExtractedEntity> mergeAdjacentEntities(List<ExtractedEntity> entities) {
    if (entities.isEmpty) return [];

    final merged = <ExtractedEntity>[];
    ExtractedEntity? current;

    for (final entity in entities) {
      if (current == null) {
        current = entity;
        continue;
      }

      // Check if entities are adjacent and same type
      if (current.type == entity.type &&
          entity.startOffset <= current.endOffset + 1) {
        // Merge entities
        current = ExtractedEntity(
          text: '${current.text} ${entity.text}',
          type: current.type,
          confidence: (current.confidence + entity.confidence) / 2,
          startOffset: current.startOffset,
          endOffset: entity.endOffset,
        );
      } else {
        merged.add(current);
        current = entity;
      }
    }

    if (current != null) {
      merged.add(current);
    }

    return merged;
  }
}
