import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/usecases/export_reports_to_csv.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';
import 'package:health_tracker_reports/domain/usecases/export_vitals_to_csv.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/data/datasources/external/csv_export_service.dart';

String stripBom(String value) {
  const bom = '\ufeff';
  if (value.startsWith(bom)) {
    return value.substring(1);
  }
  return value;
}

void main() {
  late CsvExportService service;

  setUp(() {
    service = CsvExportService(
      exportReportsToCsv: ExportReportsToCsv(),
      exportVitalsToCsv: ExportVitalsToCsv(),
      exportTrendsToCsv: ExportTrendsToCsv(),
    );
  });

  group('CsvExportService - Reports', () {
    final tDate = DateTime(2026, 1, 10, 14, 23, 0);
    final biomarker = Biomarker(
      id: 'bio_1',
      name: 'Glucose',
      value: 112.0,
      unit: 'mg/dL',
      referenceRange: const ReferenceRange(min: 70.0, max: 100.0),
      measuredAt: tDate,
    );
    final report = Report(
      id: 'rpt_1',
      date: tDate,
      labName: 'Quest Diagnostics, Inc.',
      biomarkers: [biomarker],
      originalFilePath: '/files/report.pdf',
      notes: 'Patient said "I feel fine"',
      createdAt: tDate,
      updatedAt: tDate,
    );

    test('returns CSV string with BOM, headers, and escaped content', () {
      final result = service.generateReportsCsv([report]);

      expect(result, isA<Right>());

      result.fold(
        (l) => fail('expected success'),
        (csv) {
          expect(csv.startsWith('\ufeff'), isTrue);
          expect(csv.contains('\r\n'), isTrue);
          final lines = csv.split('\r\n');
          expect(
            stripBom(lines.first),
            'report_id,report_date,lab_name,biomarker_id,biomarker_name,value,unit,ref_min,ref_max,status,notes,file_path,created_at,updated_at',
          );
          expect(lines[1], contains('"Quest Diagnostics, Inc."'));
          expect(lines[1], contains('"Patient said ""I feel fine"""'));
          expect(lines[1], contains('112.00'));
          expect(lines[1], contains('70.00'));
          expect(lines[1], contains('100.00'));
        },
      );
    });

    test('returns header row when no reports provided', () {
      final result = service.generateReportsCsv([]);

      expect(result, isA<Right>());
      result.fold(
        (l) => fail('expected success'),
        (csv) {
          final lines = csv.split('\r\n');
          expect(lines.length, 2);
          expect(lines.first.contains('report_id'), isTrue);
        },
      );
    });
  });

  group('CsvExportService - Vitals', () {
    final timestamp = DateTime(2026, 1, 15, 7, 30, 0);
    final created = DateTime(2026, 1, 15, 7, 31, 0);

    final vitalWithRange = VitalMeasurement(
      id: 'vit_1',
      type: VitalType.bloodPressureSystolic,
      value: 125.0,
      unit: 'mmHg',
      status: VitalStatus.warning,
      referenceRange: const ReferenceRange(min: 90.0, max: 120.0),
    );

    final vitalNoRange = VitalMeasurement(
      id: 'vit_2',
      type: VitalType.heartRate,
      value: 72.0,
      unit: 'bpm',
      status: VitalStatus.normal,
      referenceRange: null,
    );

    final log = HealthLog(
      id: 'log_1',
      timestamp: timestamp,
      vitals: [vitalWithRange, vitalNoRange],
      notes: 'Morning reading with newline\nand comma, ok?',
      createdAt: created,
      updatedAt: created,
    );

    test('returns CSV string for vitals with proper formatting', () {
      final result = service.generateVitalsCsv([log]);

      expect(result, isA<Right>());

      result.fold(
        (l) => fail('expected success'),
        (csv) {
          expect(csv.startsWith('\ufeff'), isTrue);
          final lines = stripBom(csv).split('\r\n').where((line) => line.isNotEmpty).toList();
          expect(lines.length, 3); // header + 2 vitals
          expect(
            lines.first,
            'log_id,log_timestamp,vital_id,vital_type,value,unit,ref_min,ref_max,status,notes,created_at,updated_at',
          );
          expect(lines[1], contains(',125.00,'));
          expect(lines[1], contains(',90.00,'));
          expect(lines[1], contains(',120.00,'));
          expect(lines[1], contains('WARNING'));
          expect(lines[1], contains('"Morning reading with newline\nand comma, ok?"'));

          final fields = lines[2].split(',');
          expect(fields[6], ''); // ref_min
          expect(fields[7], ''); // ref_max
          expect(fields[8], 'NORMAL');
        },
      );
    });

    test('returns header only when no logs provided', () {
      final result = service.generateVitalsCsv([]);

      expect(result, isA<Right>());
      result.fold(
        (l) => fail('expected success'),
        (csv) {
          final lines = csv.split('\r\n');
          expect(lines.length, 2);
          expect(stripBom(lines.first), startsWith('log_id'));
        },
      );
    });
  });

  group('CsvExportService - Trends', () {
    final start = DateTime(2025, 10, 1, 8, 0);
    final end = DateTime(2026, 1, 10, 14, 45);

    final series = TrendMetricSeries(
      type: TrendMetricType.biomarker,
      name: 'Glucose',
      points: [
        TrendMetricPoint(
          timestamp: start,
          value: 93.0,
          unit: 'mg/dL',
          isOutOfRange: false,
        ),
        TrendMetricPoint(
          timestamp: DateTime(2025, 11, 15, 9, 30),
          value: 105.0,
          unit: 'mg/dL',
          isOutOfRange: true,
        ),
        TrendMetricPoint(
          timestamp: end,
          value: 112.0,
          unit: 'mg/dL',
          isOutOfRange: true,
        ),
      ],
    );

    test('returns CSV string with statistics for trend series', () {
      final result = service.generateTrendsCsv([series]);

      expect(result, isA<Right>());

      result.fold(
        (l) => fail('expected success'),
        (csv) {
          final lines = stripBom(csv).split('\r\n').where((line) => line.isNotEmpty).toList();
          expect(lines.length, 2);
          final header = lines.first;
          final data = lines[1].split(',');
          expect(
            header,
            'metric_type,metric_name,period_start,period_end,num_readings,avg_value,min_value,max_value,std_dev,trend_direction,trend_slope,first_value,last_value,pct_change,out_of_range_count,unit',
          );
          expect(data[0], 'biomarker');
          expect(data[1], 'Glucose');
          expect(data[2], '2025-10-01 08:00:00');
          expect(data[3], '2026-01-10 14:45:00');
          expect(data[4], '3');
          expect(data[5], '103.33');
          expect(data[9], 'INCREASING');
          expect(data[10], '9.50');
          expect(data[13], '20.43');
          expect(data[14], '2');
          expect(data[15], 'mg/dL');
        },
      );
    });

    test('returns header only when no series provided', () {
      final result = service.generateTrendsCsv([]);

      expect(result, isA<Right>());
      result.fold(
        (l) => fail('expected success'),
        (csv) {
          final lines = csv.split('\r\n');
          expect(lines.length, 2);
          expect(stripBom(lines.first), startsWith('metric_type'));
        },
      );
    });
  });
}
