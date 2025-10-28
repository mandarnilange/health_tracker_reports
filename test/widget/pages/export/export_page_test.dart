import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/services/csv_export_service.dart';
import 'package:health_tracker_reports/domain/services/file_writer_service.dart';
import 'package:health_tracker_reports/domain/services/share_service.dart';
import 'package:health_tracker_reports/data/datasources/external/csv_export_service.dart';
import 'package:health_tracker_reports/data/datasources/external/file_writer_service.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/export_reports_to_csv.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';
import 'package:health_tracker_reports/domain/usecases/export_vitals_to_csv.dart';
import 'package:health_tracker_reports/presentation/providers/export_provider.dart';
import 'package:health_tracker_reports/presentation/pages/export/export_page.dart';
import 'package:health_tracker_reports/presentation/providers/share_provider.dart';
import 'package:share_plus/share_plus.dart';

class _SpyExportProvider extends ExportProvider {
  _SpyExportProvider()
      : super(
          csvExportService: CsvExportServiceImpl(
            exportReportsToCsv: ExportReportsToCsv(),
            exportVitalsToCsv: ExportVitalsToCsv(),
            exportTrendsToCsv: ExportTrendsToCsv(),
          ),
          fileWriterService: FileWriterServiceImpl.test(
            downloadsPathProvider: _StubDownloadsPathProvider(),
            stringWriter: (_, __) async {},
            bytesWriter: (_, __) async {},
          ),
          reportsLoader: () async => Right<Failure, List<Report>>([]),
          healthLogsLoader: () async => Right<Failure, List<HealthLog>>([]),
        );

  bool exportReportsCalled = false;
  bool exportVitalsCalled = false;
  bool exportTrendsCalled = false;
  bool exportAllCalled = false;

  @override
  Future<void> exportReports() async {
    exportReportsCalled = true;
  }

  @override
  Future<void> exportVitals() async {
    exportVitalsCalled = true;
  }

  @override
  Future<void> exportTrends() async {
    exportTrendsCalled = true;
  }

  @override
  Future<void> exportAll() async {
    exportAllCalled = true;
  }
}

class _StubDownloadsPathProvider implements DownloadsPathProvider {
  @override
  Future<String> getDownloadsPath() async => '.';
}

class _StubShareService implements ShareService {
  bool called = false;
  final sharedFiles = <String>[];

  @override
  Future<Either<Failure, void>> shareFile(dynamic file) async {
    if (file is XFile) {
      called = true;
      sharedFiles.add(file.path);
    }
    return const Right(null);
  }
}

void main() {
  Future<void> _pumpPage(
    WidgetTester tester, {
    required _SpyExportProvider provider,
    ShareService? shareService,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exportNotifierProvider.overrideWith((ref) => provider),
          if (shareService != null)
            shareServiceProvider.overrideWithValue(shareService),
        ],
        child: const MaterialApp(
          home: ExportPage(),
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
    expect(find.text('Doctor PDF Summary'), findsOneWidget);
  });

  testWidgets('tapping Export All triggers provider', (tester) async {
    final provider = _SpyExportProvider();
    await _pumpPage(tester, provider: provider);

    await tester.tap(find.text('Export All CSVs'));
    await tester.pump();

    expect(provider.exportAllCalled, isTrue);
  });

  testWidgets('disables buttons and shows progress while exporting',
      (tester) async {
    final provider = _SpyExportProvider();
    await _pumpPage(tester, provider: provider);

    provider.state = provider.state.asProgress(
      action: ExportAction.all,
      completed: 1,
      total: 3,
      results: const [],
    );
    await tester.pump();

    final allButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Export All CSVs'),
    );
    expect(allButton.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
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

  testWidgets('share action shares exported files', (tester) async {
    final provider = _SpyExportProvider();
    final shareService = _StubShareService();
    await _pumpPage(tester, provider: provider, shareService: shareService);

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

    final shareActionFinder = find.byType(SnackBarAction);
    expect(shareActionFinder, findsOneWidget);
    final SnackBarAction action =
        tester.widget<SnackBarAction>(shareActionFinder);
    action.onPressed();
    await tester.pumpAndSettle();

    expect(shareService.called, isTrue);
    expect(shareService.sharedFiles, contains('/tmp/reports.csv'));
  });
}
