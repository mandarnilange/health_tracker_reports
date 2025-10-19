import 'package:equatable/equatable.dart';

/// Configuration for generating a doctor-friendly summary report.
///
/// This entity defines the parameters for generating a summary PDF
/// that includes selected reports, vitals, and statistics within a date range.
class DoctorSummaryConfig extends Equatable {
  /// Start date of the summary period
  final DateTime startDate;

  /// End date of the summary period
  final DateTime endDate;

  /// List of specific report IDs to include.
  /// If empty, all reports within the date range are included.
  final List<String> selectedReportIds;

  /// Whether to include vital measurements in the summary.
  /// Defaults to true.
  final bool includeVitals;

  /// Whether to include the full data table on Page 4.
  /// Defaults to false.
  final bool includeFullDataTable;

  /// Creates a [DoctorSummaryConfig] with the given properties.
  ///
  /// Validates that [startDate] is before or equal to [endDate].
  DoctorSummaryConfig({
    required this.startDate,
    required this.endDate,
    required this.selectedReportIds,
    required this.includeVitals,
    required this.includeFullDataTable,
  }) {
    assert(
      !startDate.isAfter(endDate),
      'startDate must be before or equal to endDate',
    );
  }

  /// Creates a copy of this config with the given fields replaced with new values.
  DoctorSummaryConfig copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? selectedReportIds,
    bool? includeVitals,
    bool? includeFullDataTable,
  }) {
    return DoctorSummaryConfig(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedReportIds: selectedReportIds ?? this.selectedReportIds,
      includeVitals: includeVitals ?? this.includeVitals,
      includeFullDataTable: includeFullDataTable ?? this.includeFullDataTable,
    );
  }

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        selectedReportIds,
        includeVitals,
        includeFullDataTable,
      ];
}
