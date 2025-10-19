import 'package:equatable/equatable.dart';

/// Represents the configuration for generating a doctor summary PDF.
class DoctorSummaryConfig extends Equatable {
  /// The start date of the period for the summary.
  final DateTime startDate;

  /// The end date of the period for the summary.
  final DateTime endDate;

  /// A list of specific report IDs to include.
  /// If empty, all reports within the date range will be considered.
  final List<String> selectedReportIds;

  /// A flag to indicate whether to include vitals data in the summary.
  /// Defaults to `true`.
  final bool includeVitals;

  /// A flag to indicate whether to include the full data table on a separate page.
  /// Defaults to `false`.
  final bool includeFullDataTable;

  const DoctorSummaryConfig({
    required this.startDate,
    required this.endDate,
    this.selectedReportIds = const [],
    this.includeVitals = true,
    this.includeFullDataTable = false,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        selectedReportIds,
        includeVitals,
        includeFullDataTable,
      ];

  /// Creates a copy of this [DoctorSummaryConfig] but with the given fields
  /// replaced with the new values.
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
}