import 'package:equatable/equatable.dart';

/// Represents a named entity extracted from text by NER model.
///
/// This entity stores information about recognized medical entities
/// like person names, dates, lab values, etc., along with their position
/// and confidence scores.
class ExtractedEntity extends Equatable {
  /// The extracted text content
  final String text;

  /// Entity type (PERSON, DATE, ORG, LAB_VALUE, etc.)
  final EntityType type;

  /// Confidence score (0.0 to 1.0)
  final double confidence;

  /// Start character offset in the original text
  final int startOffset;

  /// End character offset in the original text
  final int endOffset;

  /// Creates an [ExtractedEntity] with the given properties.
  const ExtractedEntity({
    required this.text,
    required this.type,
    required this.confidence,
    required this.startOffset,
    required this.endOffset,
  });

  /// Check if confidence is above threshold (default 0.7)
  bool isHighConfidence([double threshold = 0.7]) {
    return confidence >= threshold;
  }

  /// Get the length of the extracted text
  int get length => endOffset - startOffset;

  @override
  List<Object?> get props => [text, type, confidence, startOffset, endOffset];

  @override
  String toString() {
    return 'ExtractedEntity(text: $text, type: ${type.name}, confidence: ${confidence.toStringAsFixed(2)})';
  }
}

/// Enum representing types of entities that can be extracted
enum EntityType {
  /// Person name (patient, doctor)
  person,

  /// Date values
  date,

  /// Organization names (lab, hospital)
  organization,

  /// Lab test value with units
  labValue,

  /// Biomarker/test name
  biomarkerName,

  /// Reference range
  referenceRange,

  /// Other/unknown entity type
  other,
}

/// Extension to convert string to EntityType
extension EntityTypeExtension on String {
  EntityType toEntityType() {
    switch (toLowerCase()) {
      case 'person':
        return EntityType.person;
      case 'date':
        return EntityType.date;
      case 'org':
      case 'organization':
        return EntityType.organization;
      case 'lab_value':
      case 'labvalue':
        return EntityType.labValue;
      case 'biomarker_name':
      case 'biomarkername':
        return EntityType.biomarkerName;
      case 'reference_range':
      case 'referencerange':
        return EntityType.referenceRange;
      default:
        return EntityType.other;
    }
  }
}
