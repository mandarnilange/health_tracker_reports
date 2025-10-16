import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_comparison.dart';
import 'package:health_tracker_reports/domain/usecases/compare_biomarker_across_reports.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';

/// State class for biomarker comparison across reports.
class ComparisonState {
  /// Set of selected report IDs to compare
  final Set<String> selectedReportIds;

  /// Name of the biomarker to compare across reports
  final String? selectedBiomarkerName;

  /// Async value holding the comparison data or error
  final AsyncValue<BiomarkerComparison?> comparisonData;

  const ComparisonState({
    this.selectedReportIds = const {},
    this.selectedBiomarkerName,
    this.comparisonData = const AsyncValue.data(null),
  });

  ComparisonState copyWith({
    Set<String>? selectedReportIds,
    String? selectedBiomarkerName,
    AsyncValue<BiomarkerComparison?>? comparisonData,
    bool clearBiomarkerName = false,
  }) {
    return ComparisonState(
      selectedReportIds: selectedReportIds ?? this.selectedReportIds,
      selectedBiomarkerName: clearBiomarkerName
          ? null
          : (selectedBiomarkerName ?? this.selectedBiomarkerName),
      comparisonData: comparisonData ?? this.comparisonData,
    );
  }
}

/// StateNotifier for managing comparison state and orchestrating comparison operations.
class ComparisonNotifier extends StateNotifier<ComparisonState> {
  ComparisonNotifier(
    this._compareBiomarkerAcrossReports,
  ) : super(const ComparisonState());

  final CompareBiomarkerAcrossReports _compareBiomarkerAcrossReports;

  /// Toggles selection of a report by ID.
  /// Adds the report if not selected, removes it if already selected.
  void toggleReportSelection(String reportId) {
    final currentSelection = Set<String>.from(state.selectedReportIds);

    if (currentSelection.contains(reportId)) {
      currentSelection.remove(reportId);
    } else {
      currentSelection.add(reportId);
    }

    state = state.copyWith(selectedReportIds: currentSelection);
  }

  /// Selects a biomarker to compare across the selected reports.
  /// If null is provided, clears the selection and comparison data.
  void selectBiomarker(String? biomarkerName) {
    if (biomarkerName == null) {
      state = state.copyWith(
        clearBiomarkerName: true,
        comparisonData: const AsyncValue.data(null),
      );
    } else {
      state = state.copyWith(selectedBiomarkerName: biomarkerName);
    }
  }

  /// Loads comparison data for the selected biomarker across selected reports.
  /// Does nothing if no biomarker or no reports are selected.
  Future<void> loadComparison() async {
    final biomarkerName = state.selectedBiomarkerName;
    final reportIds = state.selectedReportIds.toList();

    // Don't load if no biomarker or no reports selected
    if (biomarkerName == null || biomarkerName.isEmpty || reportIds.isEmpty) {
      return;
    }

    // Set loading state
    state = state.copyWith(comparisonData: const AsyncValue.loading());

    // Call use case
    final result = await _compareBiomarkerAcrossReports(
      biomarkerName,
      reportIds,
    );

    // Update state with result or error
    state = result.fold(
      (failure) => state.copyWith(
        comparisonData: AsyncValue.error(failure, StackTrace.current),
      ),
      (comparison) => state.copyWith(
        comparisonData: AsyncValue.data(comparison),
      ),
    );
  }

  /// Clears all selections and comparison data.
  void clearSelection() {
    state = const ComparisonState();
  }
}

/// Provider for the comparison state notifier.
final comparisonProvider =
    StateNotifierProvider<ComparisonNotifier, ComparisonState>((ref) {
  return ComparisonNotifier(
    ref.watch(compareBiomarkerAcrossReportsProvider),
  );
});
