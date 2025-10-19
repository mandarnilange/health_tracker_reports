import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

/// Use case for exporting reports with biomarkers to CSV format.
///
/// The CSV format is denormalized - one row per biomarker, meaning reports
/// with multiple biomarkers will have multiple rows with duplicate report info.
///
/// CSV Output Format:
/// - UTF-8 encoding with BOM
/// - CRLF line endings (\r\n)
/// - ISO 8601 date format (YYYY-MM-DD HH:MM:SS)
/// - Escapes commas, quotes, newlines per CSV RFC 4180
/// - Empty string for null/optional fields
@lazySingleton
class ExportReportsToCsv {
  static const String _csvHeader = 'report_id,report_date,lab_name,biomarker_id,biomarker_name,value,unit,ref_min,ref_max,status,notes,file_path,created_at,updated_at';

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Exports a list of reports to CSV format.
  ///
  /// Returns a CSV string with headers and denormalized biomarker data.
  /// If the reports list is empty, returns only the CSV header.
  ///
  /// Each biomarker in each report becomes a separate row in the CSV.
  Either<Failure, String> call(List<Report> reports) {
    try {
      final buffer = StringBuffer();

      // Write header
      buffer.write(_csvHeader);
      buffer.write('\r\n');

      // Write data rows (denormalized - one row per biomarker)
      for (final report in reports) {
        for (final biomarker in report.biomarkers) {
          buffer.write(_buildCsvRow(report, biomarker));
          buffer.write('\r\n');
        }
      }

      return Right(buffer.toString());
    } catch (e) {
      return Left(ValidationFailure(message: 'Failed to export reports to CSV: $e'));
    }
  }

  /// Builds a single CSV row for a report-biomarker combination.
  String _buildCsvRow(Report report, Biomarker biomarker) {
    final fields = [
      report.id,
      _dateFormat.format(report.date),
      report.labName,
      biomarker.id,
      biomarker.name,
      biomarker.value.toString(),
      biomarker.unit,
      biomarker.referenceRange.min.toString(),
      biomarker.referenceRange.max.toString(),
      _getBiomarkerStatus(biomarker),
      report.notes ?? '',
      report.originalFilePath,
      _dateFormat.format(report.createdAt),
      _dateFormat.format(report.updatedAt),
    ];

    return fields.map(_escapeCsvField).join(',');
  }

  /// Gets the status of a biomarker as a string (HIGH, LOW, NORMAL).
  String _getBiomarkerStatus(Biomarker biomarker) {
    switch (biomarker.status) {
      case BiomarkerStatus.high:
        return 'HIGH';
      case BiomarkerStatus.low:
        return 'LOW';
      case BiomarkerStatus.normal:
        return 'NORMAL';
    }
  }

  /// Escapes a CSV field according to RFC 4180.
  ///
  /// Rules:
  /// - If field contains comma, quote, or newline, wrap in double quotes
  /// - Double any quotes within the field (escape quotes)
  /// - Return empty string for null values
  String _escapeCsvField(String? value) {
    if (value == null || value.isEmpty) return '';

    // Check if field needs quoting
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      // Escape quotes by doubling them
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }

    return value;
  }
}
