import 'package:health_tracker_reports/data/models/reference_range_model.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:hive/hive.dart';

part 'vital_measurement_model.g.dart';

@HiveType(typeId: 12)
class VitalMeasurementModel extends VitalMeasurement {
  @override
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int vitalTypeIndex;

  @override
  VitalType get type => VitalType.values[vitalTypeIndex];

  @override
  @HiveField(2)
  final double value;

  @override
  @HiveField(3)
  final String unit;

  @HiveField(4)
  final int statusIndex;

  @override
  VitalStatus get status => VitalStatus.values[statusIndex];

  @override
  @HiveField(5)
  final ReferenceRangeModel? referenceRange;

  const VitalMeasurementModel({
    required this.id,
    required this.vitalTypeIndex,
    required this.value,
    required this.unit,
    required this.statusIndex,
    this.referenceRange,
  }) : super(
          id: id,
          type: VitalType.values[vitalTypeIndex],
          value: value,
          unit: unit,
          status: VitalStatus.values[statusIndex],
          referenceRange: referenceRange,
        );

  factory VitalMeasurementModel.fromEntity(VitalMeasurement entity) {
    return VitalMeasurementModel(
      id: entity.id,
      vitalTypeIndex: entity.type.index,
      value: entity.value,
      unit: entity.unit,
      statusIndex: entity.status.index,
      referenceRange: entity.referenceRange != null
          ? ReferenceRangeModel.fromEntity(entity.referenceRange!)
          : null,
    );
  }

  factory VitalMeasurementModel.fromJson(Map<String, dynamic> json) {
    return VitalMeasurementModel(
      id: json['id'] as String,
      vitalTypeIndex: json['vitalTypeIndex'] as int,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      statusIndex: json['statusIndex'] as int,
      referenceRange: json['referenceRange'] == null
          ? null
          : ReferenceRangeModel.fromJson(
              json['referenceRange'] as Map<String, dynamic>,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vitalTypeIndex': vitalTypeIndex,
      'value': value,
      'unit': unit,
      'statusIndex': statusIndex,
      'referenceRange': referenceRange?.toJson(),
    };
  }

  VitalMeasurement toEntity() {
    return VitalMeasurement(
      id: id,
      type: type,
      value: value,
      unit: unit,
      status: status,
      referenceRange: referenceRange?.toEntity(),
    );
  }
}
