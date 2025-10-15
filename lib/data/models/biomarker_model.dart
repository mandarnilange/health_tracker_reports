import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';

/// Data model for [Biomarker] entity with JSON serialization support.
///
/// Extends [Biomarker] to inherit domain logic while adding
/// serialization capabilities for data layer operations.
class BiomarkerModel extends Biomarker {
  /// Creates a [BiomarkerModel] with the given properties
  const BiomarkerModel({
    required super.id,
    required super.name,
    required super.value,
    required super.unit,
    required super.referenceRange,
    required super.measuredAt,
  });

  /// Creates a [BiomarkerModel] from a [Biomarker] entity
  factory BiomarkerModel.fromEntity(Biomarker entity) {
    return BiomarkerModel(
      id: entity.id,
      name: entity.name,
      value: entity.value,
      unit: entity.unit,
      referenceRange: ReferenceRangeModel.fromEntity(entity.referenceRange),
      measuredAt: entity.measuredAt,
    );
  }

  /// Creates a [BiomarkerModel] from a JSON map
  factory BiomarkerModel.fromJson(Map<String, dynamic> json) {
    return BiomarkerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      referenceRange: ReferenceRangeModel.fromJson(
        json['referenceRange'] as Map<String, dynamic>,
      ),
      measuredAt: DateTime.parse(json['measuredAt'] as String),
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'unit': unit,
      'referenceRange': ReferenceRangeModel.fromEntity(referenceRange).toJson(),
      'measuredAt': measuredAt.toIso8601String(),
    };
  }
}
