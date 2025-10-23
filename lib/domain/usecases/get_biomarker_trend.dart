import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetBiomarkerTrend {
  final ReportRepository repository;

  GetBiomarkerTrend({
    required this.repository,
  });

  /// Gets trend data for a specific biomarker across all reports.
  ///
  /// Biomarker names are expected to be already normalized by the LLM
  /// during extraction, so no additional normalization is needed.
  ///
  /// Returns a list of [TrendDataPoint] sorted chronologically by date.
  /// Each data point represents one occurrence of the biomarker in a report.
  ///
  /// If [startDate] is provided, only includes data points on or after this date.
  /// If [endDate] is provided, only includes data points on or before this date.
  ///
  /// Returns an empty list if the biomarker is not found in any report.
  Future<Either<Failure, List<TrendDataPoint>>> call(
    String biomarkerName, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final trendResult = await repository.getBiomarkerTrend(
      biomarkerName,
      startDate: startDate,
      endDate: endDate,
    );

    return trendResult.map((dataPoints) {
      final sorted = List<TrendDataPoint>.from(dataPoints)
        ..sort((a, b) => a.date.compareTo(b.date));
      return sorted;
    });
  }
}
