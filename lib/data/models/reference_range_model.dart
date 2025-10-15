import 'package:health_tracker_reports/domain/entities/reference_range.dart';

/// Data model for [ReferenceRange] entity with JSON serialization support.
///
/// Extends [ReferenceRange] to inherit domain logic while adding
/// serialization capabilities for data layer operations.
class ReferenceRangeModel extends ReferenceRange {
  /// Creates a [ReferenceRangeModel] with the given min and max values
  const ReferenceRangeModel({
    required super.min,
    required super.max,
  });

  /// Creates a [ReferenceRangeModel] from a [ReferenceRange] entity
  factory ReferenceRangeModel.fromEntity(ReferenceRange entity) {
    return ReferenceRangeModel(
      min: entity.min,
      max: entity.max,
    );
  }

  /// Creates a [ReferenceRangeModel] from a JSON map
  factory ReferenceRangeModel.fromJson(Map<String, dynamic> json) {
    return ReferenceRangeModel(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }
}
