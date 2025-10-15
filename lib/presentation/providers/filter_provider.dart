import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';

/// Enum representing the filter options for biomarkers.
enum BiomarkerFilter {
  /// Show all biomarkers regardless of their status
  showAll,

  /// Show only biomarkers that are outside their reference ranges
  outOfRangeOnly,
}

/// StateNotifier that manages the biomarker filter state.
///
/// Allows toggling between showing all biomarkers and showing only
/// biomarkers that are out of range.
class FilterNotifier extends StateNotifier<BiomarkerFilter> {
  /// Creates a [FilterNotifier] with initial state of [BiomarkerFilter.showAll].
  FilterNotifier() : super(BiomarkerFilter.showAll);

  /// Toggles the filter between [BiomarkerFilter.showAll] and
  /// [BiomarkerFilter.outOfRangeOnly].
  void toggleFilter() {
    state = state == BiomarkerFilter.showAll
        ? BiomarkerFilter.outOfRangeOnly
        : BiomarkerFilter.showAll;
  }
}

/// Provider for the [FilterNotifier].
///
/// This provider manages the current filter state for biomarkers across the app.
final filterProvider =
    StateNotifierProvider<FilterNotifier, BiomarkerFilter>((ref) {
  return FilterNotifier();
});

/// Provider that returns filtered biomarkers based on the current filter state.
///
/// This is a family provider that takes a [Report] and returns a filtered
/// list of biomarkers based on the current filter state from [filterProvider].
///
/// When the filter is [BiomarkerFilter.showAll], all biomarkers are returned.
/// When the filter is [BiomarkerFilter.outOfRangeOnly], only biomarkers with
/// status != [BiomarkerStatus.normal] are returned.
final filteredBiomarkersProvider =
    Provider.family<List<Biomarker>, Report>((ref, report) {
  final filter = ref.watch(filterProvider);

  switch (filter) {
    case BiomarkerFilter.showAll:
      return report.biomarkers;
    case BiomarkerFilter.outOfRangeOnly:
      return report.biomarkers
          .where((biomarker) => biomarker.status != BiomarkerStatus.normal)
          .toList();
  }
});
