import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/usecases/export_vitals_to_csv.dart';

String stripBom(String value) {
  const bom = '\ufeff';
  if (value.startsWith(bom)) {
    return value.substring(1);
  }
  return value;
}

void main() {
  late ExportVitalsToCsv usecase;

  setUp(() {
    usecase = ExportVitalsToCsv();
  });

  final tTimestamp1 = DateTime(2026, 1, 15, 7, 30, 0);
  final tCreatedAt1 = DateTime(2026, 1, 15, 7, 32, 0);
  final tTimestamp2 = DateTime(2026, 1, 16, 6, 45, 0);
  final tCreatedAt2 = DateTime(2026, 1, 16, 6, 46, 0);

  final tVitalSystolicWarning = VitalMeasurement(
    id: 'vit_101',
    type: VitalType.bloodPressureSystolic,
    value: 125.0,
    unit: 'mmHg',
    status: VitalStatus.warning,
    referenceRange: const ReferenceRange(min: 90.0, max: 120.0),
  );

  final tVitalDiastolicNormal = VitalMeasurement(
    id: 'vit_102',
    type: VitalType.bloodPressureDiastolic,
    value: 78.0,
    unit: 'mmHg',
    status: VitalStatus.normal,
    referenceRange: const ReferenceRange(min: 60.0, max: 80.0),
  );

  final tVitalSpO2Critical = VitalMeasurement(
    id: 'vit_103',
    type: VitalType.oxygenSaturation,
    value: 88.0,
    unit: '%',
    status: VitalStatus.critical,
    referenceRange: const ReferenceRange(min: 95.0, max: 100.0),
  );

  final tVitalHeartRateNoRange = VitalMeasurement(
    id: 'vit_104',
    type: VitalType.heartRate,
    value: 72.0,
    unit: 'bpm',
    status: VitalStatus.normal,
    referenceRange: null,
  );

  final tHealthLogSingle = HealthLog(
    id: 'log_001',
    timestamp: tTimestamp1,
    vitals: [tVitalSystolicWarning],
    notes: 'Morning reading',
    createdAt: tCreatedAt1,
    updatedAt: tCreatedAt1,
  );

  final tHealthLogMultiple = HealthLog(
    id: 'log_002',
    timestamp: tTimestamp1,
    vitals: [tVitalSystolicWarning, tVitalDiastolicNormal, tVitalSpO2Critical],
    notes: 'Pre-workout check',
    createdAt: tCreatedAt1,
    updatedAt: tCreatedAt1,
  );

  final tHealthLogNoRange = HealthLog(
    id: 'log_003',
    timestamp: tTimestamp2,
    vitals: [tVitalHeartRateNoRange],
    notes: null,
    createdAt: tCreatedAt2,
    updatedAt: tCreatedAt2,
  );

  group('ExportVitalsToCsv', () {
    test('should export single health log with one vital to CSV', () {
      // Arrange
      final logs = [tHealthLogSingle];

      // Act
      final result = usecase(logs);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('log_id,log_timestamp,vital_id,vital_type,value,unit,ref_min,ref_max,status,notes,created_at,updated_at'));
          expect(csvContent, contains('log_001'));
          expect(csvContent, contains('2026-01-15 07:30:00'));
          expect(csvContent, contains('vit_101'));
          expect(csvContent, contains('BP Systolic'));
          expect(csvContent, contains('125.00'));
          expect(csvContent, contains('mmHg'));
          expect(csvContent, contains('90.00'));
          expect(csvContent, contains('120.00'));
          expect(csvContent, contains('WARNING'));
          expect(csvContent, contains('Morning reading'));
        },
      );
    });

    test('should export single health log with multiple vitals (denormalized)', () {
      // Arrange
      final logs = [tHealthLogMultiple];

      // Act
      final result = usecase(logs);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final normalized = stripBom(csvContent);
          final lines = normalized.split('\r\n').where((line) => line.isNotEmpty).toList();
          expect(lines.length, 4); // header + 3 vitals

          final dataLines = lines.skip(1).toList();
          expect(dataLines[0], contains('BP Systolic'));
          expect(dataLines[1], contains('BP Diastolic'));
          expect(dataLines[2], contains('SpO2'));
        },
      );
    });

    test('should export multiple health logs to CSV', () {
      // Arrange
      final logs = [tHealthLogSingle, tHealthLogNoRange];

      // Act
      final result = usecase(logs);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('log_001'));
          expect(csvContent, contains('log_003'));
          expect(csvContent, contains('BP Systolic'));
          expect(csvContent, contains('Heart Rate'));
        },
      );
    });

    test('should escape special characters in notes', () {
      // Arrange
      final logWithSpecialNotes = tHealthLogSingle.copyWith(
        notes: 'Quoted "note", with comma\nand newline',
      );
      final logs = [logWithSpecialNotes];

      // Act
      final result = usecase(logs);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('"Quoted ""note"", with comma\nand newline"'));
        },
      );
    });

    test('should format timestamps as ISO 8601', () {
      // Arrange
      final logs = [tHealthLogSingle];

      // Act
      final result = usecase(logs);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('2026-01-15 07:30:00'));
          expect(csvContent, contains('2026-01-15 07:32:00'));
        },
      );
    });

    test('should handle missing notes and reference ranges as empty strings', () {
      // Arrange
      final logs = [tHealthLogNoRange];

      // Act
      final result = usecase(logs);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final normalized = stripBom(csvContent);
          final lines = normalized.split('\r\n');
          final dataLine = lines[1];
          final fields = dataLine.split(',');
          expect(fields[6], ''); // ref_min
          expect(fields[7], ''); // ref_max
          expect(fields[8], 'NORMAL'); // status
          expect(fields[9], ''); // notes
        },
      );
    });

    test('should format numeric values with two decimal places', () {
      // Arrange
      final logs = [tHealthLogMultiple];

      // Act
      final result = usecase(logs);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final normalized = stripBom(csvContent);
          final lines = normalized.split('\r\n').where((line) => line.isNotEmpty).toList();
          final dataLines = lines.skip(1).toList();

          expect(dataLines[0], contains(',125.00,'));
          expect(dataLines[0], contains(',90.00,'));
          expect(dataLines[0], contains(',120.00,'));
          expect(dataLines[1], contains(',78.00,'));
          expect(dataLines[1], contains(',60.00,'));
          expect(dataLines[1], contains(',80.00,'));
          expect(dataLines[2], contains(',88.00,'));
          expect(dataLines[2], contains(',95.00,'));
          expect(dataLines[2], contains(',100.00,'));
        },
      );
    });

    test('should return headers only when no logs provided', () {
      // Arrange
      final logs = <HealthLog>[];

      // Act
      final result = usecase(logs);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final lines = csvContent.split('\r\n');
          expect(lines.length, 2);
          expect(stripBom(lines.first), 'log_id,log_timestamp,vital_id,vital_type,value,unit,ref_min,ref_max,status,notes,created_at,updated_at');
        },
      );
    });

    test('should use CRLF line endings', () {
      // Arrange
      final logs = [tHealthLogSingle];

      // Act
      final result = usecase(logs);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent.contains('\r\n'), isTrue);
          expect(csvContent.contains('\n') && !csvContent.contains('\r\n'), isFalse);
        },
      );
    });

    test('should prefix UTF-8 BOM for Excel compatibility', () {
      // Arrange
      final logs = [tHealthLogSingle];

      // Act
      final result = usecase(logs);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent.startsWith('\ufeff'), isTrue);
        },
      );
    });
  });
}
