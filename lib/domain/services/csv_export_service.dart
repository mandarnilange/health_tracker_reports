import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';

/// Centralized service for generating CSV payloads used during exports.
///
/// This service composes the domain-level CSV use cases so higher layers
/// (data writing, sharing) can request specific CSV formats without duplicating
/// formatting logic.
abstract class CsvExportService {
  /// Generates the reports CSV string (reports_biomarkers.csv).
  Either<Failure, String> generateReportsCsv(List<Report> reports);

  /// Generates the vitals CSV string (health_logs_vitals.csv).
  Either<Failure, String> generateVitalsCsv(List<HealthLog> healthLogs);

  /// Generates the trends CSV string (trends_statistics.csv).
  Either<Failure, String> generateTrendsCsv(List<TrendMetricSeries> series);
}
