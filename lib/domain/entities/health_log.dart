import 'package:equatable/equatable.dart';
import 'health_entry.dart';
import 'vital_measurement.dart';

/// Represents a daily health log with vital sign measurements.
///
/// A health log contains one or more vital measurements (e.g., blood pressure,
/// heart rate, SpO2) taken at a specific time, along with optional notes.
/// It implements [HealthEntry] to support unified timeline display.
class HealthLog extends Equatable implements HealthEntry {
  /// Unique identifier for this health log
  @override
  final String id;

  /// Timestamp when these vitals were recorded
  @override
  final DateTime timestamp;

  /// List of vital measurements in this log entry
  final List<VitalMeasurement> vitals;

  /// Optional notes about this health log entry
  final String? notes;

  /// Timestamp when this log was created
  final DateTime createdAt;

  /// Timestamp when this log was last updated
  final DateTime updatedAt;

  /// Creates a [HealthLog] with the given properties.
  const HealthLog({
    required this.id,
    required this.timestamp,
    required this.vitals,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns [HealthEntryType.healthLog] to identify this as a health log entry.
  @override
  HealthEntryType get entryType => HealthEntryType.healthLog;

  /// Returns "Health Log" as the display title.
  @override
  String get displayTitle => 'Health Log';

  /// Returns a subtitle showing the top 3 vital names, with count if more than 3.
  ///
  /// Examples:
  /// - "BP Systolic, BP Diastolic, SpO2" (exactly 3 vitals)
  /// - "BP Systolic, BP Diastolic, SpO2 +2" (5 vitals)
  /// - "Heart Rate, SpO2" (2 vitals)
  /// - "" (no vitals)
  @override
  String get displaySubtitle {
    if (vitals.isEmpty) {
      return '';
    }

    final vitalNames = vitals.take(3).map((v) => v.type.displayName).join(', ');
    return vitals.length <= 3 ? vitalNames : '$vitalNames +${vitals.length - 3}';
  }

  /// Returns true if any vital measurement has a warning or critical status.
  ///
  /// This indicates that at least one vital is outside the normal reference range.
  @override
  bool get hasWarnings {
    return vitals.any((v) => v.status != VitalStatus.normal);
  }

  /// Returns a list of all vitals that are outside the normal range.
  ///
  /// This includes vitals with either warning or critical status.
  List<VitalMeasurement> get outOfRangeVitals {
    return vitals.where((v) => v.status != VitalStatus.normal).toList();
  }

  /// Creates a copy of this health log with the given fields replaced with new values.
  HealthLog copyWith({
    String? id,
    DateTime? timestamp,
    List<VitalMeasurement>? vitals,
    Object? notes = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      vitals: vitals ?? this.vitals,
      notes: notes == _sentinel ? this.notes : notes as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, timestamp, vitals, notes, createdAt, updatedAt];

  static const _sentinel = Object();
}
