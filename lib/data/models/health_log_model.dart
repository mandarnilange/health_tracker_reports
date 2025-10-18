import 'package:health_tracker_reports/data/models/vital_measurement_model.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:hive/hive.dart';

part 'health_log_model.g.dart';

@HiveType(typeId: 11)
class HealthLogModel extends HealthLog {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final DateTime timestamp;

  @override
  @HiveField(2)
  final List<VitalMeasurementModel> vitals;

  @override
  @HiveField(3)
  final String? notes;

  @override
  @HiveField(4)
  final DateTime createdAt;

  @override
  @HiveField(5)
  final DateTime updatedAt;

  const HealthLogModel({
    required this.id,
    required this.timestamp,
    required this.vitals,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : super(
          id: id,
          timestamp: timestamp,
          vitals: vitals,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory HealthLogModel.fromEntity(HealthLog entity) {
    return HealthLogModel(
      id: entity.id,
      timestamp: entity.timestamp,
      vitals: entity.vitals
          .map((measurement) => VitalMeasurementModel.fromEntity(measurement))
          .toList(),
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory HealthLogModel.fromJson(Map<String, dynamic> json) {
    return HealthLogModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      vitals: (json['vitals'] as List)
          .map(
            (value) => VitalMeasurementModel.fromJson(
              value as Map<String, dynamic>,
            ),
          )
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'vitals': vitals.map((measurement) => measurement.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  HealthLog toEntity() {
    return HealthLog(
      id: id,
      timestamp: timestamp,
      vitals: vitals.map((measurement) => measurement.toEntity()).toList(),
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
