import 'package:equatable/equatable.dart';
import 'biomarker.dart';

/// Represents a complete blood test report containing multiple biomarkers.
///
/// A report aggregates all biomarkers measured during a single lab visit,
/// along with metadata about when and where the test was performed.
class Report extends Equatable {
  /// Unique identifier for this report
  final String id;

  /// Date when the report was created/collected
  final DateTime date;

  /// Name of the laboratory that performed the tests
  final String labName;

  /// List of biomarkers included in this report
  final List<Biomarker> biomarkers;

  /// Path to the original file (PDF or image) from which this report was extracted
  final String originalFilePath;

  /// Optional notes or comments about this report
  final String? notes;

  /// Timestamp when this report was created in the system
  final DateTime createdAt;

  /// Timestamp when this report was last updated
  final DateTime updatedAt;

  /// Creates a [Report] with the given properties.
  const Report({
    required this.id,
    required this.date,
    required this.labName,
    required this.biomarkers,
    required this.originalFilePath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Gets all biomarkers that are outside their reference ranges.
  ///
  /// Returns a list of biomarkers where the value is either below the minimum
  /// or above the maximum of the reference range.
  List<Biomarker> get outOfRangeBiomarkers {
    return biomarkers.where((biomarker) => biomarker.isOutOfRange).toList();
  }

  /// Checks if this report has any biomarkers outside their reference ranges.
  ///
  /// Returns `true` if at least one biomarker is out of range, `false` otherwise.
  bool get hasOutOfRangeBiomarkers {
    return outOfRangeBiomarkers.isNotEmpty;
  }

  /// Gets the count of biomarkers that are outside their reference ranges.
  int get outOfRangeCount {
    return outOfRangeBiomarkers.length;
  }

  /// Gets the total count of biomarkers in this report.
  int get totalBiomarkerCount {
    return biomarkers.length;
  }

  /// Creates a copy of this report with the given fields replaced with new values.
  Report copyWith({
    String? id,
    DateTime? date,
    String? labName,
    List<Biomarker>? biomarkers,
    String? originalFilePath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      date: date ?? this.date,
      labName: labName ?? this.labName,
      biomarkers: biomarkers ?? this.biomarkers,
      originalFilePath: originalFilePath ?? this.originalFilePath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        labName,
        biomarkers,
        originalFilePath,
        notes,
        createdAt,
        updatedAt,
      ];
}
