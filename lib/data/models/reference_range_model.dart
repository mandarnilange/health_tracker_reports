import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:hive/hive.dart';

part 'reference_range_model.g.dart';

@HiveType(typeId: 2)
class ReferenceRangeModel extends ReferenceRange {
  @override
  @HiveField(0)
  final double min;

  @override
  @HiveField(1)
  final double max;

  /// Creates a [ReferenceRangeModel] with the given min and max values
  const ReferenceRangeModel({
    required this.min,
    required this.max,
  }) : super(min: min, max: max);

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

  ReferenceRange toEntity() {
    return ReferenceRange(
      min: min,
      max: max,
    );
  }
}
