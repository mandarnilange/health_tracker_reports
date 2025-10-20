import 'package:equatable/equatable.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';

/// Represents a daily health log entry containing vital measurements.
class HealthLog extends Equatable implements HealthEntry {
  /// Unique identifier for this log entry.
  @override
  final String id;

  /// Timestamp when the vitals were recorded.
  @override
  final DateTime timestamp;

  /// Collection of vital measurements captured in this log.
  final List<VitalMeasurement> vitals;

  /// Optional notes associated with the entry.
  final String? notes;

  /// Timestamp when the log was created in the system.
  final DateTime createdAt;

  /// Timestamp when the log was last updated.
  final DateTime updatedAt;

  const HealthLog({
    required this.id,
    required this.timestamp,
    required this.vitals,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns vitals that are outside their reference range.
  List<VitalMeasurement> get outOfRangeVitals =>
      vitals.where((vital) => vital.isOutOfRange).toList();

  /// Copy helper for immutable updates.
  HealthLog copyWith({
    String? id,
    DateTime? timestamp,
    List<VitalMeasurement>? vitals,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      vitals: vitals ?? this.vitals,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  HealthEntryType get entryType => HealthEntryType.healthLog;

  @override
  String get displayTitle => 'Health Log';

  /// Display subtitle summarising key vitals for timeline cards.
  @override
  String get displaySubtitle {
    if (vitals.isEmpty) return '';
    final names = vitals.map((v) => v.type.displayName).toList();
    final visible = names.take(3).toList();
    final remaining = names.length - visible.length;
    final suffix = remaining > 0 ? ' +$remaining' : '';
    return '${visible.join(', ')}$suffix';
  }

  @override
  bool get hasWarnings => vitals.any((v) => v.isOutOfRange);

  @override
  List<Object?> get props => [id, timestamp, vitals, notes, createdAt, updatedAt];
}
