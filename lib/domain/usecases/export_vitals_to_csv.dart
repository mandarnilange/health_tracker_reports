import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

/// Use case for exporting health logs and their vitals to CSV format.
///
/// The CSV is denormalized so that each row represents a single vital
/// measurement with the associated health log metadata repeated.
///
/// CSV Output Format:
/// - UTF-8 encoding with BOM
/// - CRLF line endings (\r\n)
/// - ISO 8601 date format (YYYY-MM-DD HH:MM:SS)
/// - Numeric values formatted with two decimal places
/// - Empty strings for null optional fields
@lazySingleton
class ExportVitalsToCsv {
  static const String _csvHeader = 'log_id,log_timestamp,vital_id,vital_type,value,unit,ref_min,ref_max,status,notes,created_at,updated_at';
  static const String _utf8Bom = '\ufeff';

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final NumberFormat _numberFormat = NumberFormat('0.00');

  /// Exports a list of health logs to CSV format.
  ///
  /// Returns a CSV string with headers and denormalized vital data.
  /// If the logs list is empty, returns only the CSV header.
  Either<Failure, String> call(List<HealthLog> logs) {
    try {
      final buffer = StringBuffer();

      // Prefix UTF-8 BOM for spreadsheet compatibility.
      buffer.write(_utf8Bom);

      // Write header
      buffer.write(_csvHeader);
      buffer.write('\r\n');

      for (final log in logs) {
        for (final vital in log.vitals) {
          buffer.write(_buildCsvRow(log, vital));
          buffer.write('\r\n');
        }
      }

      return Right(buffer.toString());
    } catch (e) {
      return Left(ValidationFailure(message: 'Failed to export vitals to CSV: $e'));
    }
  }

  /// Builds a single CSV row for a health log and vital combination.
  String _buildCsvRow(HealthLog log, VitalMeasurement vital) {
    final referenceRange = vital.referenceRange;

    final fields = [
      log.id,
      _dateFormat.format(log.timestamp),
      vital.id,
      vital.type.displayName,
      _formatDouble(vital.value),
      vital.unit,
      referenceRange != null ? _formatDouble(referenceRange.min) : '',
      referenceRange != null ? _formatDouble(referenceRange.max) : '',
      _formatVitalStatus(vital.status),
      log.notes ?? '',
      _dateFormat.format(log.createdAt),
      _dateFormat.format(log.updatedAt),
    ];

    return fields.map(_escapeCsvField).join(',');
  }

  /// Formats a [VitalStatus] into its uppercase string representation.
  String _formatVitalStatus(VitalStatus status) {
    switch (status) {
      case VitalStatus.normal:
        return 'NORMAL';
      case VitalStatus.warning:
        return 'WARNING';
      case VitalStatus.critical:
        return 'CRITICAL';
    }
  }

  /// Formats a double with two decimal places.
  String _formatDouble(double value) {
    return _numberFormat.format(value);
  }

  /// Escapes a CSV field according to RFC 4180 rules.
  ///
  /// - Wraps in double quotes if the field contains comma, quote, or newline.
  /// - Doubles any existing double quotes inside the field.
  /// - Returns empty string when [value] is null or empty.
  String _escapeCsvField(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }

    return value;
  }
}
