import 'package:health_tracker_reports/data/models/biomarker_model.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:hive/hive.dart';

part 'report_model.g.dart';

@HiveType(typeId: 3)
class ReportModel extends Report {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final DateTime date;

  @override
  @HiveField(2)
  final String labName;

  @override
  @HiveField(3)
  final List<BiomarkerModel> biomarkers;

  @override
  @HiveField(4)
  final String originalFilePath;

  @override
  @HiveField(5)
  final String? notes;

  @override
  @HiveField(6)
  final DateTime createdAt;

  @override
  @HiveField(7)
  final DateTime updatedAt;

  /// Creates a [ReportModel] with the given properties
  const ReportModel({
    required this.id,
    required this.date,
    required this.labName,
    required this.biomarkers,
    required this.originalFilePath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : super(
          id: id,
          date: date,
          labName: labName,
          biomarkers: biomarkers,
          originalFilePath: originalFilePath,
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Creates a [ReportModel] from a [Report] entity
  factory ReportModel.fromEntity(Report entity) {
    return ReportModel(
      id: entity.id,
      date: entity.date,
      labName: entity.labName,
      biomarkers: entity.biomarkers
          .map((biomarker) => BiomarkerModel.fromEntity(biomarker))
          .toList(),
      originalFilePath: entity.originalFilePath,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Creates a [ReportModel] from a JSON map
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      labName: json['labName'] as String,
      biomarkers: (json['biomarkers'] as List)
          .map((biomarkerJson) =>
              BiomarkerModel.fromJson(biomarkerJson as Map<String, dynamic>))
          .toList(),
      originalFilePath: json['originalFilePath'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'labName': labName,
      'biomarkers': biomarkers.map((biomarker) => biomarker.toJson()).toList(),
      'originalFilePath': originalFilePath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Report toEntity() {
    return Report(
      id: id,
      date: date,
      labName: labName,
      biomarkers: biomarkers.map((e) => e.toEntity()).toList(),
      originalFilePath: originalFilePath,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
