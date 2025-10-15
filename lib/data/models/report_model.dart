import 'package:health_tracker_reports/data/models/biomarker_model.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';

/// Data model for [Report] entity with JSON serialization support.
///
/// Extends [Report] to inherit domain logic while adding
/// serialization capabilities for data layer operations.
class ReportModel extends Report {
  /// Creates a [ReportModel] with the given properties
  const ReportModel({
    required super.id,
    required super.date,
    required super.labName,
    required super.biomarkers,
    required super.originalFilePath,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

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
      'biomarkers': biomarkers
          .map((biomarker) => BiomarkerModel.fromEntity(biomarker).toJson())
          .toList(),
      'originalFilePath': originalFilePath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
