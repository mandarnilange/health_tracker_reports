import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_comparison.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CompareBiomarkerAcrossReports {
  final ReportRepository repository;

  CompareBiomarkerAcrossReports({
    required this.repository,
  });

  /// Compares a specific biomarker across multiple reports.
  ///
  /// Biomarker names are expected to be already normalized by the LLM
  /// during extraction, so no additional normalization is needed.
  ///
  /// Returns a [BiomarkerComparison] containing:
  /// - All comparison data points sorted chronologically by report date
  /// - Calculated deltas and percentage changes between consecutive reports
  /// - Overall trend direction
  ///
  /// Returns [ValidationFailure] if no reports are selected.
  /// Returns [NotFoundFailure] if the biomarker is not found in any report.
  /// Returns [CacheFailure] if there's an issue accessing the repository.
  Future<Either<Failure, BiomarkerComparison>> call(
    String biomarkerName,
    List<String> reportIds,
  ) async {
    // Validate input
    if (reportIds.isEmpty) {
      return const Left(
        ValidationFailure(message: 'At least one report must be selected'),
      );
    }

    // Fetch all reports
    final reports = <Report>[];
    for (final reportId in reportIds) {
      final reportResult = await repository.getReportById(reportId);
      final report = reportResult.fold(
        (failure) => null,
        (report) => report,
      );

      if (report == null) {
        return reportResult.fold(
          (failure) => Left(failure),
          (report) => throw Exception('Unreachable'),
        );
      }

      reports.add(report);
    }

    // Sort reports chronologically
    reports.sort((a, b) => a.date.compareTo(b.date));

    // Extract biomarker from each report
    final comparisons = <ComparisonDataPoint>[];
    for (var i = 0; i < reports.length; i++) {
      final report = reports[i];

      // Try to find biomarker in this report
      try {
        final biomarker = report.biomarkers.firstWhere(
          (b) => b.name == biomarkerName,
        );

        // Calculate delta and percentage change from previous report
        double? delta;
        double? percentageChange;

        if (comparisons.isNotEmpty) {
          final previousValue = comparisons.last.value;
          delta = biomarker.value - previousValue;
          percentageChange = (delta / previousValue) * 100;
        }

        comparisons.add(ComparisonDataPoint(
          reportId: report.id,
          reportDate: report.date,
          value: biomarker.value,
          unit: biomarker.unit,
          status: biomarker.status,
          deltaFromPrevious: delta,
          percentageChangeFromPrevious: percentageChange,
        ));
      } catch (_) {
        // Biomarker not found in this report, skip it
        continue;
      }
    }

    // Check if biomarker was found in at least one report
    if (comparisons.isEmpty) {
      return Left(
        NotFoundFailure(
          message: 'Biomarker "$biomarkerName" not found in any report',
        ),
      );
    }

    // Determine overall trend
    final trend = _determineTrend(comparisons);

    return Right(
      BiomarkerComparison(
        biomarkerName: biomarkerName,
        comparisons: comparisons,
        overallTrend: trend,
      ),
    );
  }

  /// Determines the overall trend direction based on the comparison data points.
  TrendDirection _determineTrend(List<ComparisonDataPoint> comparisons) {
    if (comparisons.length < 2) {
      return TrendDirection.insufficient;
    }

    // Calculate if values are consistently increasing or decreasing
    var increasingCount = 0;
    var decreasingCount = 0;
    var stableCount = 0;
    const stableThreshold = 2.0; // 2% variance considered stable

    for (var i = 1; i < comparisons.length; i++) {
      final percentageChange = comparisons[i].percentageChangeFromPrevious!;

      if (percentageChange.abs() <= stableThreshold) {
        // Within stable threshold
        stableCount++;
      } else if (percentageChange > 0) {
        increasingCount++;
      } else {
        decreasingCount++;
      }
    }

    // All changes are within stable threshold
    if (increasingCount == 0 && decreasingCount == 0) {
      return TrendDirection.stable;
    }

    // Consistently increasing (no decreases)
    if (increasingCount > 0 && decreasingCount == 0) {
      return TrendDirection.increasing;
    }

    // Consistently decreasing (no increases)
    if (decreasingCount > 0 && increasingCount == 0) {
      return TrendDirection.decreasing;
    }

    // Mixed pattern
    return TrendDirection.fluctuating;
  }
}
