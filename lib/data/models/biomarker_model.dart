import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:hive/hive.dart';

part 'biomarker_model.g.dart';

@HiveType(typeId: 1)
class BiomarkerModel extends Biomarker {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String name;

  @override
  @HiveField(2)
  final double value;

  @override
  @HiveField(3)
  final String unit;

  @override
  @HiveField(4)
  final ReferenceRangeModel referenceRange;

  @override
  @HiveField(5)
  final DateTime measuredAt;

  /// Creates a [BiomarkerModel] with the given properties
  const BiomarkerModel({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.referenceRange,
    required this.measuredAt,
  }) : super(
          id: id,
          name: name,
          value: value,
          unit: unit,
          referenceRange: referenceRange,
          measuredAt: measuredAt,
        );

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
      'referenceRange': referenceRange.toJson(),
      'measuredAt': measuredAt.toIso8601String(),
    };
  }

  Biomarker toEntity() {
    return Biomarker(
      id: id,
      name: name,
      value: value,
      unit: unit,
      referenceRange: referenceRange.toEntity(),
      measuredAt: measuredAt,
    );
  }
}
