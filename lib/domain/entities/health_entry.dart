/// Abstract interface for unified timeline entries (reports and health logs).
///
/// This interface allows displaying different types of health entries
/// (lab reports and health logs) in a unified timeline view.
abstract class HealthEntry {
  /// Unique identifier for this entry
  String get id;

  /// Timestamp when this entry was recorded
  DateTime get timestamp;

  /// Type of health entry (lab report or health log)
  HealthEntryType get entryType;

  /// Display title for this entry type
  String get displayTitle;

  /// Display subtitle with summary information
  String get displaySubtitle;

  /// Whether this entry has any warnings or out-of-range values
  bool get hasWarnings;
}

/// Types of health entries supported in the timeline
enum HealthEntryType {
  /// Lab report with biomarker measurements
  labReport,

  /// Daily health log with vital signs
  healthLog,
}
