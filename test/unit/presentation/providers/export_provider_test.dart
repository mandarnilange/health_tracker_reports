import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/services/csv_export_service.dart';
import 'package:health_tracker_reports/domain/services/file_writer_service.dart';
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
  setUpAll(() {
    registerFallbackValue(<Report>[]);
    registerFallbackValue(<HealthLog>[]);
    registerFallbackValue(<TrendMetricSeries>[]);
  });

  late _MockCsvExportService csvExportService;
  late _MockFileWriterService fileWriterService;

  setUp(() {
    csvExportService = _MockCsvExportService();
    fileWriterService = _MockFileWriterService();
  });

  ExportProvider _buildProvider({
    Future<Either<Failure, List<Report>>> Function()? reportsLoader,
    Future<Either<Failure, List<HealthLog>>> Function()? logsLoader,
  }) {
    return ExportProvider(
      csvExportService: csvExportService,
      fileWriterService: fileWriterService,
      reportsLoader: reportsLoader,
      healthLogsLoader: logsLoader,
    );
  }

  test('exportReports emits success when CSV generation and write succeed', () async {
    final provider = _buildProvider(
      reportsLoader: () async => const Right(<Report>[]),
    );

    when(() => csvExportService.generateReportsCsv(any())).thenReturn(const Right('csv'));
    when(
      () => fileWriterService.writeCsv(
        filenamePrefix: any(named: 'filenamePrefix'),
        contents: any(named: 'contents'),
      ),
    ).thenAnswer((invocation) async => const Right('/tmp/reports.csv'));

    await provider.exportReports();

    expect(provider.state.status, ExportStatus.success);
    expect(provider.state.results.single.target, ExportTarget.reports);
    expect(provider.state.results.single.path, '/tmp/reports.csv');
  });

  test('exportReports handles loader failure', () async {
    final provider = _buildProvider(
      reportsLoader: () async => const Left(CacheFailure()),
    );

    await provider.exportReports();

    expect(provider.state.status, ExportStatus.error);
    expect(provider.state.failure, isA<CacheFailure>());
  });

  test('exportReports handles CSV generator failure', () async {
    final provider = _buildProvider(
      reportsLoader: () async => const Right(<Report>[]),
    );

    when(() => csvExportService.generateReportsCsv(any()))
        .thenReturn(const Left(ValidationFailure(message: 'bad')));

    await provider.exportReports();

    expect(provider.state.status, ExportStatus.error);
    expect(provider.state.failure, isA<ValidationFailure>());
  });

  test('exportReports handles file write failure', () async {
    final provider = _buildProvider(
      reportsLoader: () async => const Right(<Report>[]),
    );

    when(() => csvExportService.generateReportsCsv(any()))
        .thenReturn(const Right('csv'));
    when(
      () => fileWriterService.writeCsv(
        filenamePrefix: any(named: 'filenamePrefix'),
        contents: any(named: 'contents'),
      ),
    ).thenAnswer((_) async => const Left(FileSystemFailure(message: 'disk')));

    await provider.exportReports();

    expect(provider.state.status, ExportStatus.error);
    expect(provider.state.failure, isA<FileSystemFailure>());
  });

  List<Report> _sampleReports() => [
        Report(
          id: 'r1',
          date: DateTime(2024, 1, 1),
          labName: 'Lab',
          biomarkers: [
            Biomarker(
              id: 'b1',
              name: 'Glucose',
              value: 95,
              unit: 'mg/dL',
              referenceRange: const ReferenceRange(min: 70, max: 110),
              measuredAt: DateTime(2024, 1, 1),
            ),
          ],
          originalFilePath: 'path',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];

  List<HealthLog> _sampleLogs() => [
        HealthLog(
          id: 'h1',
          timestamp: DateTime(2024, 1, 2),
          vitals: const [
            VitalMeasurement(
              id: 'v1',
              type: VitalType.heartRate,
              value: 72,
              unit: 'bpm',
              status: VitalStatus.normal,
              referenceRange: ReferenceRange(min: 60, max: 100),
            ),
          ],
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
        ),
      ];

  test('exportAll processes all steps successfully', () async {
    final reports = _sampleReports();
    final logs = _sampleLogs();

    final provider = _buildProvider(
      reportsLoader: () async => Right(reports),
      logsLoader: () async => Right(logs),
    );

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

    await provider.exportAll();

    expect(provider.state.status, ExportStatus.success);
    expect(provider.state.results.length, 3);
    expect(provider.state.results.map((r) => r.path), contains('/tmp/trends_statistics.csv'));
  });

  test('exportAll stops when reports loader fails', () async {
    final provider = _buildProvider(
      reportsLoader: () async => const Left(CacheFailure()),
      logsLoader: () async => const Right(<HealthLog>[]),
    );

    await provider.exportAll();

    expect(provider.state.status, ExportStatus.error);
    expect(provider.state.failure, isA<CacheFailure>());
  });

  test('exportAll stops when health log loader fails', () async {
    final provider = _buildProvider(
      reportsLoader: () async => Right(_sampleReports()),
      logsLoader: () async => const Left(CacheFailure('logs')),
    );

    when(() => csvExportService.generateReportsCsv(any()))
        .thenReturn(const Right('reports'));
    when(
      () => fileWriterService.writeCsv(
        filenamePrefix: any(named: 'filenamePrefix'),
        contents: any(named: 'contents'),
      ),
    ).thenAnswer((_) async => const Right('/tmp/reports.csv'));

    await provider.exportAll();

    expect(provider.state.status, ExportStatus.error);
    expect(provider.state.failure, isA<CacheFailure>());
  });

  test('exportAll handles vitals CSV generator failure', () async {
    final provider = _buildProvider(
      reportsLoader: () async => Right(_sampleReports()),
      logsLoader: () async => Right(_sampleLogs()),
    );

    when(() => csvExportService.generateReportsCsv(any()))
        .thenReturn(const Right('reports'));
    when(() => csvExportService.generateVitalsCsv(any()))
        .thenReturn(const Left(ValidationFailure(message: 'bad vitals')));
    when(
      () => fileWriterService.writeCsv(
        filenamePrefix: any(named: 'filenamePrefix'),
        contents: any(named: 'contents'),
      ),
    ).thenAnswer((_) async => const Right('/tmp/reports.csv'));

    await provider.exportAll();

    expect(provider.state.status, ExportStatus.error);
    expect(provider.state.failure, isA<ValidationFailure>());
    expect(provider.state.results.length, 1);
    expect(provider.state.results.first.target, ExportTarget.reports);
  });

  test('exportAll handles vitals file write failure', () async {
    final provider = _buildProvider(
      reportsLoader: () async => Right(_sampleReports()),
      logsLoader: () async => Right(_sampleLogs()),
    );

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
      if (prefix.contains('health_logs_vitals')) {
        return const Left(FileSystemFailure(message: 'disk'));
      }
      return Right('/tmp/$prefix.csv');
    });

    await provider.exportAll();

    expect(provider.state.status, ExportStatus.error);
    expect(provider.state.failure, isA<FileSystemFailure>());
    expect(provider.state.results.length, 1);
    expect(provider.state.results.first.target, ExportTarget.reports);
  });

  test('exportAll handles trends CSV generator failure', () async {
    final provider = _buildProvider(
      reportsLoader: () async => Right(_sampleReports()),
      logsLoader: () async => Right(_sampleLogs()),
    );

    when(() => csvExportService.generateReportsCsv(any()))
        .thenReturn(const Right('reports'));
    when(() => csvExportService.generateVitalsCsv(any()))
        .thenReturn(const Right('vitals'));
    when(() => csvExportService.generateTrendsCsv(any()))
        .thenReturn(const Left(ValidationFailure(message: 'bad trends')));

    when(
      () => fileWriterService.writeCsv(
        filenamePrefix: any(named: 'filenamePrefix'),
        contents: 'reports',
      ),
    ).thenAnswer((_) async => const Right('/tmp/reports.csv'));
    when(
      () => fileWriterService.writeCsv(
        filenamePrefix: any(named: 'filenamePrefix'),
        contents: 'vitals',
      ),
    ).thenAnswer((_) async => const Right('/tmp/vitals.csv'));

    await provider.exportAll();

    expect(provider.state.status, ExportStatus.error);
    expect(provider.state.failure, isA<ValidationFailure>());
    expect(provider.state.results.length, 2);
  });

  test('exportAll handles trends file write failure', () async {
    final provider = _buildProvider(
      reportsLoader: () async => Right(_sampleReports()),
      logsLoader: () async => Right(_sampleLogs()),
    );

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
      if (prefix.contains('trends_statistics')) {
        return const Left(FileSystemFailure(message: 'trends'));
      }
      return Right('/tmp/$prefix.csv');
    });

    await provider.exportAll();

    expect(provider.state.status, ExportStatus.error);
    expect(provider.state.failure, isA<FileSystemFailure>());
    expect(provider.state.results.length, 2);
  });
}
