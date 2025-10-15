import 'package:health_tracker_reports/domain/entities/biomarker.dart';

/// Use case for searching biomarkers by name.
///
/// Performs case-insensitive partial matching on biomarker names.
/// Returns all biomarkers if the query is empty or contains only whitespace.
class SearchBiomarkers {
  /// Searches for biomarkers whose names contain the query string.
  ///
  /// The search is case-insensitive and matches partial strings.
  /// For example, "hemo" will match "Hemoglobin" and "Hemoglobin A1c".
  ///
  /// Parameters:
  /// - [biomarkers]: List of biomarkers to search through
  /// - [query]: Search query string
  ///
  /// Returns:
  /// - List of biomarkers matching the query
  /// - All biomarkers if query is empty or whitespace-only
  /// - Empty list if no matches found
  List<Biomarker> call(List<Biomarker> biomarkers, String query) {
    // Trim whitespace from query
    final trimmedQuery = query.trim();

    // Return all biomarkers if query is empty
    if (trimmedQuery.isEmpty) {
      return biomarkers;
    }

    // Convert query to lowercase for case-insensitive search
    final lowerCaseQuery = trimmedQuery.toLowerCase();

    // Filter biomarkers where name contains the query
    return biomarkers.where((biomarker) {
      final lowerCaseName = biomarker.name.toLowerCase();
      return lowerCaseName.contains(lowerCaseQuery);
    }).toList();
  }
}
