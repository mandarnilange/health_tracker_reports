import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/csv_export_service.dart';
import 'package:health_tracker_reports/data/datasources/external/file_writer_service.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';
import 'package:health_tracker_reports/presentation/providers/export_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockCsvExportService extends Mock implements CsvExportService {}

class _MockFileWriterService extends Mock implements FileWriterService {}

void main() {
  late _MockCsvExportService csvExportService;
  late _MockFileWriterService fileWriterService;
  late ExportProvider provider;

  final tDate = DateTime(2026, 1, 10, 14, 0);

  final biomarker = Biomarker(
    id: 'bio_1',
    name: 'Glucose',
    value: 110.0,
    unit: 'mg/dL',
    referenceRange: const ReferenceRange(min: 70.0, max: 100.0),
    measuredAt: tDate,
  );

  final report = Report(
    id: 'rpt_1',
    date: tDate,
    labName: 'Quest',
    biomarkers: [biomarker],
    originalFilePath: '/files/report.pdf',
    notes: null,
    createdAt: tDate,
    updatedAt: tDate,
  );

  final vital = VitalMeasurement(
    id: 'vit_1',
    type: VitalType.heartRate,
    value: 72,
    unit: 'bpm',
    status: VitalStatus.normal,
    referenceRange: const ReferenceRange(min: 60, max: 100),
  );

  final healthLog = HealthLog(
    id: 'log_1',
    timestamp: tDate,
    vitals: [vital],
    notes: null,
    createdAt: tDate,
    updatedAt: tDate,
  );

  final trendSeries = TrendMetricSeries(
    type: TrendMetricType.biomarker,
    name: 'Glucose',
    points: [
      TrendMetricPoint(
        timestamp: DateTime(2025, 10, 1),
        value: 95,
        unit: 'mg/dL',
        isOutOfRange: false,
      ),
      TrendMetricPoint(
        timestamp: DateTime(2026, 1, 10),
        value: 110,
        unit: 'mg/dL',
        isOutOfRange: true,
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(<Report>[]);
    registerFallbackValue(<HealthLog>[]);
    registerFallbackValue(<TrendMetricSeries>[]);
  });

  setUp(() {
    csvExportService = _MockCsvExportService();
    fileWriterService = _MockFileWriterService();
    provider = ExportProvider(
      csvExportService: csvExportService,
      fileWriterService: fileWriterService,
    );
  });

  group('initial state', () {
    test('should be idle with no progress', () {
      expect(provider.state.status, ExportStatus.idle);
      expect(provider.state.completed, 0);
      expect(provider.state.total, 0);
      expect(provider.state.results, isEmpty);
      expect(provider.state.failure, isNull);
    });
  });

  group('single export', () {
    test('should export reports CSV and update state to success', () async {
      when(() => csvExportService.generateReportsCsv(any())).thenReturn(
        const Right('csv-data'),
      );
      when(
        () => fileWriterService.writeCsv(
          filenamePrefix: any(named: 'filenamePrefix'),
          contents: any(named: 'contents'),
        ),
      ).thenAnswer((_) async => const Right('/tmp/reports.csv'));

      final states = <ExportState>[];
      provider.addListener(states.add, fireImmediately: true);

      await provider.exportReports([report]);

      expect(states.map((s) => s.status), [
        ExportStatus.idle,
        ExportStatus.inProgress,
        ExportStatus.success,
      ]);
      final successState = provider.state;
      expect(successState.results.length, 1);
      expect(successState.results.first.target, ExportTarget.reports);
      expect(successState.results.first.path, '/tmp/reports.csv');
      expect(successState.completed, 1);
      expect(successState.total, 1);
    });
  });

  group('multi export', () {
    test('should track progress across all CSV exports', () async {
      when(() => csvExportService.generateReportsCsv(any()))
          .thenReturn(const Right('reports'));
      when(() => csvExportService.generateVitalsCsv(any()))
          .thenReturn(const Right('vitals'));
      when(() => csvExportService.generateTrendsCsv(any()))
          .thenReturn(const Right('trends'));

      when(
        () => fileWriterService.writeCsv(
          filenamePrefix: any(named: 'filenamePrefix'),
          contents: any(named: 'contents'),
        ),
      ).thenAnswer((invocation) async {
        final prefix = invocation.namedArguments[#filenamePrefix] as String;
        return Right('/tmp/$prefix.csv');
      });

      final states = <ExportState>[];
      provider.addListener(states.add, fireImmediately: true);

      await provider.exportAll(
        reports: [report],
        healthLogs: [healthLog],
        trends: [trendSeries],
      );

      expect(states.length, greaterThanOrEqualTo(4));
      expect(states.first.status, ExportStatus.idle);
      expect(states[1].completed, 0);
      expect(states[1].total, 3);

      expect(provider.state.status, ExportStatus.success);
      expect(provider.state.completed, 3);
      expect(provider.state.total, 3);
      expect(provider.state.results.map((r) => r.target), [
        ExportTarget.reports,
        ExportTarget.vitals,
        ExportTarget.trends,
      ]);
    });
  });

  group('failure handling', () {
    test('should set error state when writer fails', () async {
      when(() => csvExportService.generateReportsCsv(any()))
          .thenReturn(const Right('csv'));
      when(
        () => fileWriterService.writeCsv(
          filenamePrefix: any(named: 'filenamePrefix'),
          contents: any(named: 'contents'),
        ),
      ).thenAnswer(
        (_) async => const Left(
          PermissionFailure(
            message: 'Storage permission denied',
          ),
        ),
      );

      final states = <ExportState>[];
      provider.addListener(states.add, fireImmediately: true);

      await provider.exportReports([report]);

      expect(provider.state.status, ExportStatus.error);
      expect(provider.state.failure, isA<PermissionFailure>());
      expect(provider.state.results, isEmpty);
    });
  });
}
