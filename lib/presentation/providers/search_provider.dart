import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/search_biomarkers.dart';
import 'package:health_tracker_reports/presentation/providers/filter_provider.dart';

/// StateNotifier that manages the search query state.
///
/// Holds the current search query string that is used to filter biomarkers.
class SearchQueryNotifier extends StateNotifier<String> {
  /// Creates a [SearchQueryNotifier] with an empty initial search query.
  SearchQueryNotifier() : super('');

  /// Updates the search query.
  ///
  /// This will trigger a rebuild of any providers watching this state.
  void updateQuery(String query) {
    state = query;
  }

  /// Clears the search query.
  void clearQuery() {
    state = '';
  }
}

/// Provider for the [SearchQueryNotifier].
///
/// This provider manages the current search query state for biomarkers across the app.
final searchQueryProvider =
    StateNotifierProvider<SearchQueryNotifier, String>((ref) {
  return SearchQueryNotifier();
});

/// Provider that returns the [SearchBiomarkers] use case.
///
/// This is a simple provider that creates an instance of the use case.
/// It doesn't use dependency injection since SearchBiomarkers is a pure function
/// with no dependencies.
final searchBiomarkersProvider = Provider<SearchBiomarkers>((ref) {
  return SearchBiomarkers();
});

/// Provider that returns biomarkers filtered by BOTH search query AND filter state.
///
/// This is a family provider that takes a [Report] and returns a list of biomarkers
/// that match both:
/// 1. The current search query from [searchQueryProvider]
/// 2. The current filter state from [filterProvider]
///
/// The filtering is applied in this order:
/// 1. First, apply the filter (all/out-of-range)
/// 2. Then, apply the search query
///
/// This ensures that search only operates on the currently filtered set of biomarkers.
final searchedAndFilteredBiomarkersProvider =
    Provider.family<List<Biomarker>, Report>((ref, report) {
  // Get the current filter state and filtered biomarkers
  final filteredBiomarkers = ref.watch(filteredBiomarkersProvider(report));

  // Get the current search query
  final searchQuery = ref.watch(searchQueryProvider);

  // Get the search use case
  final searchUseCase = ref.watch(searchBiomarkersProvider);

  // Apply search to the filtered biomarkers
  return searchUseCase(filteredBiomarkers, searchQuery);
});
