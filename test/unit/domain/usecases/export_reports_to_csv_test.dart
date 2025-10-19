import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/export_reports_to_csv.dart';

String stripBom(String value) {
  const bom = '\ufeff';
  if (value.startsWith(bom)) {
    return value.substring(1);
  }
  return value;
}

void main() {
  late ExportReportsToCsv usecase;

  setUp(() {
    usecase = ExportReportsToCsv();
  });

  final tDate1 = DateTime(2026, 1, 10, 14, 23, 0);
  final tDate2 = DateTime(2026, 1, 15, 9, 30, 0);

  final tBiomarker1 = Biomarker(
    id: 'bio_123',
    name: 'Glucose',
    value: 112.0,
    unit: 'mg/dL',
    referenceRange: const ReferenceRange(min: 70.0, max: 100.0),
    measuredAt: tDate1,
  );

  final tBiomarker2 = Biomarker(
    id: 'bio_124',
    name: 'Hemoglobin',
    value: 15.5,
    unit: 'g/dL',
    referenceRange: const ReferenceRange(min: 13.5, max: 17.5),
    measuredAt: tDate1,
  );

  final tBiomarker3 = Biomarker(
    id: 'bio_125',
    name: 'Cholesterol',
    value: 180.0,
    unit: 'mg/dL',
    referenceRange: const ReferenceRange(min: 100.0, max: 200.0),
    measuredAt: tDate2,
  );

  final tReport1 = Report(
    id: 'rpt_001',
    date: tDate1,
    labName: 'Quest',
    biomarkers: [tBiomarker1],
    originalFilePath: '/files/report.pdf',
    notes: null,
    createdAt: tDate1,
    updatedAt: tDate1,
  );

  final tReport2 = Report(
    id: 'rpt_002',
    date: tDate1,
    labName: 'Quest',
    biomarkers: [tBiomarker1, tBiomarker2],
    originalFilePath: '/files/report2.pdf',
    notes: null,
    createdAt: tDate1,
    updatedAt: tDate1,
  );

  final tReport3 = Report(
    id: 'rpt_003',
    date: tDate2,
    labName: 'LabCorp',
    biomarkers: [tBiomarker3],
    originalFilePath: '/files/report3.pdf',
    notes: null,
    createdAt: tDate2,
    updatedAt: tDate2,
  );

  group('ExportReportsToCsv', () {
    test('should export single report with one biomarker to CSV', () {
      // Arrange
      final reports = [tReport1];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('report_id,report_date,lab_name,biomarker_id,biomarker_name,value,unit,ref_min,ref_max,status,notes,file_path,created_at,updated_at'));
          expect(csvContent, contains('rpt_001'));
          expect(csvContent, contains('2026-01-10 14:23:00'));
          expect(csvContent, contains('Quest'));
          expect(csvContent, contains('bio_123'));
          expect(csvContent, contains('Glucose'));
          expect(csvContent, contains('112.00'));
          expect(csvContent, contains('mg/dL'));
          expect(csvContent, contains('70.00'));
          expect(csvContent, contains('100.00'));
          expect(csvContent, contains('HIGH'));
          expect(csvContent, contains('/files/report.pdf'));
        },
      );
    });

    test('should export single report with multiple biomarkers (denormalized)', () {
      // Arrange
      final reports = [tReport2];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          // Should have 2 data rows (one per biomarker) plus header
          final lines = csvContent.split('\r\n');
          expect(lines.length, 4); // header + 2 biomarkers + trailing newline

          // Both biomarkers should have the same report info
          expect(csvContent, contains('bio_123'));
          expect(csvContent, contains('Glucose'));
          expect(csvContent, contains('bio_124'));
          expect(csvContent, contains('Hemoglobin'));

          // Both rows should reference rpt_002
          final dataLines = lines.where((line) => line.contains('rpt_002')).toList();
          expect(dataLines.length, 2);
        },
      );
    });

    test('should export multiple reports to CSV', () {
      // Arrange
      final reports = [tReport1, tReport3];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('rpt_001'));
          expect(csvContent, contains('Quest'));
          expect(csvContent, contains('rpt_003'));
          expect(csvContent, contains('LabCorp'));
          expect(csvContent, contains('Glucose'));
          expect(csvContent, contains('Cholesterol'));
        },
      );
    });

    test('should generate CSV with correct headers', () {
      // Arrange
      final reports = [tReport1];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final lines = csvContent.split('\r\n');
          expect(
            stripBom(lines.first),
            'report_id,report_date,lab_name,biomarker_id,biomarker_name,value,unit,ref_min,ref_max,status,notes,file_path,created_at,updated_at',
          );
        },
      );
    });

    test('should escape comma in lab name', () {
      // Arrange
      final reportWithComma = tReport1.copyWith(
        labName: 'Quest Diagnostics, Inc.',
      );
      final reports = [reportWithComma];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          // Field with comma should be quoted
          expect(csvContent, contains('"Quest Diagnostics, Inc."'));
        },
      );
    });

    test('should escape quote in notes', () {
      // Arrange
      final reportWithQuote = tReport1.copyWith(
        notes: 'Patient said "I feel fine"',
      );
      final reports = [reportWithQuote];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          // Quote should be doubled and field quoted
          expect(csvContent, contains('"Patient said ""I feel fine"""'));
        },
      );
    });

    test('should escape newline in notes', () {
      // Arrange
      final reportWithNewline = tReport1.copyWith(
        notes: 'Line 1\nLine 2',
      );
      final reports = [reportWithNewline];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          // Field with newline should be quoted
          expect(csvContent, contains('"Line 1\nLine 2"'));
        },
      );
    });

    test('should format dates as ISO 8601', () {
      // Arrange
      final reports = [tReport1];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('2026-01-10 14:23:00'));
        },
      );
    });

    test('should handle null notes as empty string', () {
      // Arrange
      final reports = [tReport1]; // tReport1 has null notes

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final lines = csvContent.split('\r\n');
          final dataLine = lines[1];
          final fields = dataLine.split(',');
          // Notes field (index 10) should be empty
          expect(fields[10], '');
        },
      );
    });

    test('should format numeric values with two decimal places', () {
      // Arrange
      final reports = [tReport2];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final normalized = stripBom(csvContent);
          final lines = normalized
              .split('\r\n')
              .where((line) => line.isNotEmpty)
              .toList();
          final dataLines = lines.skip(1).toList();

          expect(dataLines.length, 2);
          expect(dataLines.first, contains(',112.00,'));
          expect(dataLines.first, contains(',70.00,'));
          expect(dataLines.first, contains(',100.00,'));
          expect(dataLines[1], contains(',15.50,'));
          expect(dataLines[1], contains(',13.50,'));
          expect(dataLines[1], contains(',17.50,'));
        },
      );
    });

    test('should return headers only for empty reports list', () {
      // Arrange
      final reports = <Report>[];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          final lines = csvContent.split('\r\n');
          // Should have only header and trailing newline
          expect(lines.length, 2);
          expect(stripBom(lines.first), contains('report_id,report_date,lab_name'));
        },
      );
    });

    test('should use CRLF line endings', () {
      // Arrange
      final reports = [tReport1];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          // Should contain CRLF, not just LF
          expect(csvContent, contains('\r\n'));
          expect(csvContent.contains('\n') && !csvContent.contains('\r\n'), isFalse);
        },
      );
    });

    test('should prefix UTF-8 BOM for Excel compatibility', () {
      // Arrange
      final reports = [tReport1];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent.startsWith('\ufeff'), isTrue);
        },
      );
    });

    test('should correctly identify biomarker status HIGH', () {
      // Arrange
      final reports = [tReport1]; // Glucose 112 > 100 max

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('HIGH'));
        },
      );
    });

    test('should correctly identify biomarker status NORMAL', () {
      // Arrange
      final reports = [tReport2]; // Hemoglobin 15.5 is within 13.5-17.5

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('NORMAL'));
        },
      );
    });

    test('should correctly identify biomarker status LOW', () {
      // Arrange
      final lowBiomarker = Biomarker(
        id: 'bio_low',
        name: 'Iron',
        value: 50.0,
        unit: 'μg/dL',
        referenceRange: const ReferenceRange(min: 60.0, max: 170.0),
        measuredAt: tDate1,
      );
      final reportWithLow = tReport1.copyWith(biomarkers: [lowBiomarker]);
      final reports = [reportWithLow];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('LOW'));
        },
      );
    });

    test('should handle multiple special characters together', () {
      // Arrange
      final complexReport = tReport1.copyWith(
        labName: 'Lab "A, B & C", LLC',
        notes: 'Test notes with "quotes", commas, and\nnewlines',
      );
      final reports = [complexReport];

      // Act
      final result = usecase(reports);

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (l) => fail('should not return a failure'),
        (csvContent) {
          expect(csvContent, contains('"Lab ""A, B & C"", LLC"'));
          expect(csvContent, contains('"Test notes with ""quotes"", commas, and\nnewlines"'));
        },
      );
    });
  });
}
