import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/csv_export_service.dart';
import 'package:health_tracker_reports/data/datasources/external/file_writer_service.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/usecases/export_reports_to_csv.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';
import 'package:health_tracker_reports/domain/usecases/export_vitals_to_csv.dart';
import 'package:health_tracker_reports/presentation/providers/export_provider.dart';
import 'package:health_tracker_reports/presentation/pages/export/export_page.dart';

class _SpyExportProvider extends ExportProvider {
  _SpyExportProvider()
      : super(
          csvExportService: CsvExportService(
            exportReportsToCsv: ExportReportsToCsv(),
            exportVitalsToCsv: ExportVitalsToCsv(),
            exportTrendsToCsv: ExportTrendsToCsv(),
          ),
          fileWriterService: FileWriterService(
            downloadsPathProvider: _StubDownloadsPathProvider(),
            fileWriter: (_, __) async {},
          ),
        );

  bool exportReportsCalled = false;
  bool exportVitalsCalled = false;
  bool exportTrendsCalled = false;
  bool exportAllCalled = false;

  List<Report>? capturedReports;
  List<HealthLog>? capturedLogs;
  List<TrendMetricSeries>? capturedTrends;

  @override
  Future<void> exportReports(List<Report> reports) async {
    exportReportsCalled = true;
    capturedReports = reports;
  }

  @override
  Future<void> exportVitals(List<HealthLog> logs) async {
    exportVitalsCalled = true;
    capturedLogs = logs;
  }

  @override
  Future<void> exportTrends(List<TrendMetricSeries> series) async {
    exportTrendsCalled = true;
    capturedTrends = series;
  }

  @override
  Future<void> exportAll({
    required List<Report> reports,
    required List<HealthLog> healthLogs,
    required List<TrendMetricSeries> trends,
  }) async {
    exportAllCalled = true;
    capturedReports = reports;
    capturedLogs = healthLogs;
    capturedTrends = trends;
  }
}

class _StubDownloadsPathProvider implements DownloadsPathProvider {
  @override
  Future<String> getDownloadsPath() async => '.';
}

void main() {
  final tReport = Report(
    id: 'r1',
    date: DateTime(2026, 1, 10),
    labName: 'Quest',
    biomarkers: [
      Biomarker(
        id: 'b1',
        name: 'Glucose',
        value: 110,
        unit: 'mg/dL',
        referenceRange: const ReferenceRange(min: 70, max: 100),
        measuredAt: DateTime(2026, 1, 10),
      ),
    ],
    originalFilePath: '/files/report.pdf',
    notes: null,
    createdAt: DateTime(2026, 1, 10),
    updatedAt: DateTime(2026, 1, 10),
  );

  final tLog = HealthLog(
    id: 'log_1',
    timestamp: DateTime(2026, 1, 15),
    vitals: [
      const VitalMeasurement(
        id: 'v1',
        type: VitalType.heartRate,
        value: 72,
        unit: 'bpm',
        status: VitalStatus.normal,
        referenceRange: ReferenceRange(min: 60, max: 100),
      ),
    ],
    notes: null,
    createdAt: DateTime(2026, 1, 15),
    updatedAt: DateTime(2026, 1, 15),
  );

  final tTrendSeries = TrendMetricSeries(
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

  Future<void> _pumpPage(
    WidgetTester tester, {
    required _SpyExportProvider provider,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exportNotifierProvider.overrideWith((ref) => provider),
        ],
        child: MaterialApp(
          home: ExportPage(
            reports: [tReport],
            healthLogs: [tLog],
            trendSeries: [tTrendSeries],
          ),
        ),
      ),
    );
  }

  testWidgets('renders export buttons', (tester) async {
    final provider = _SpyExportProvider();
    await _pumpPage(tester, provider: provider);

    expect(find.text('Export Reports CSV'), findsOneWidget);
    expect(find.text('Export Vitals CSV'), findsOneWidget);
    expect(find.text('Export Trends CSV'), findsOneWidget);
    expect(find.text('Export All CSVs'), findsOneWidget);
  });

  testWidgets('tapping Export All triggers provider', (tester) async {
    final provider = _SpyExportProvider();
    await _pumpPage(tester, provider: provider);

    await tester.tap(find.text('Export All CSVs'));
    await tester.pump();

    expect(provider.exportAllCalled, isTrue);
    expect(provider.capturedReports, isNotNull);
    expect(provider.capturedLogs, isNotNull);
    expect(provider.capturedTrends, isNotNull);
  });

  testWidgets('shows progress indicator during export', (tester) async {
    final provider = _SpyExportProvider();
    await _pumpPage(tester, provider: provider);

    provider.state = provider.state.asProgress(
      completed: 1,
      total: 3,
      results: const [],
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Exporting 1 of 3 files (33%)…'), findsOneWidget);
  });

  testWidgets('shows success snackbar when export completes', (tester) async {
    final provider = _SpyExportProvider();
    await _pumpPage(tester, provider: provider);

    provider.state = provider.state.asSuccess(
      const [
        ExportResult(
          target: ExportTarget.reports,
          path: '/tmp/reports.csv',
        ),
      ],
      total: 1,
    );
    await tester.pump();

    expect(find.text('Saved to: /tmp/reports.csv'), findsOneWidget);
  });

  testWidgets('shows error snackbar when export fails', (tester) async {
    final provider = _SpyExportProvider();
    await _pumpPage(tester, provider: provider);

    provider.state = provider.state.asError(
      const PermissionFailure(message: 'Permission denied'),
      const [],
      total: 1,
      completed: 0,
    );
    await tester.pump();

    expect(find.text('Permission denied'), findsOneWidget);
  });
}
