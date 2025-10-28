import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/entities/vital_statistics.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart'
    as analysis;
import 'package:health_tracker_reports/domain/entities/biomarker_comparison.dart'
    as comparison;
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_trend.dart';
import 'package:health_tracker_reports/domain/usecases/calculate_vital_statistics.dart';
import 'package:health_tracker_reports/domain/usecases/get_vital_trend.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/domain/repositories/timeline_repository.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:health_tracker_reports/domain/usecases/compare_biomarker_across_reports.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file_llm.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/domain/usecases/get_unified_timeline.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';
import 'package:health_tracker_reports/domain/usecases/export_reports_to_csv.dart';
import 'package:health_tracker_reports/domain/usecases/export_vitals_to_csv.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart' as analysis;
import 'package:health_tracker_reports/presentation/pages/error/error_page.dart';
import 'package:health_tracker_reports/presentation/pages/home/reports_list_page.dart';
import 'package:health_tracker_reports/presentation/pages/report_detail/report_detail_page.dart';
import 'package:health_tracker_reports/presentation/pages/upload/review_page.dart';
import 'package:health_tracker_reports/presentation/pages/upload/upload_page.dart';
import 'package:health_tracker_reports/presentation/pages/trends/trends_page.dart';
import 'package:health_tracker_reports/presentation/pages/trends/trends_page_args.dart';
import 'package:health_tracker_reports/presentation/pages/trends/comparison_view.dart';
import 'package:health_tracker_reports/presentation/pages/settings/settings_page.dart';
import 'package:health_tracker_reports/presentation/pages/health_log/health_log_detail_page.dart';
import 'package:health_tracker_reports/presentation/pages/export/export_page.dart';
import 'package:health_tracker_reports/presentation/pages/export/doctor_pdf_config_page.dart';
import 'package:health_tracker_reports/presentation/providers/extraction_provider.dart';
import 'package:health_tracker_reports/presentation/providers/file_picker_provider.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:health_tracker_reports/presentation/providers/timeline_provider.dart';
import 'package:health_tracker_reports/presentation/providers/export_provider.dart';
import 'package:health_tracker_reports/presentation/providers/config_provider.dart';
import 'package:health_tracker_reports/presentation/providers/trend_provider.dart';
import 'package:health_tracker_reports/presentation/providers/vital_trend_provider.dart';
import 'package:health_tracker_reports/presentation/router/app_router.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:health_tracker_reports/data/datasources/external/csv_export_service.dart';
import 'package:health_tracker_reports/data/datasources/external/file_writer_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockExtractReportFromFileLlm extends Mock
    implements ExtractReportFromFileLlm {}

class _MockCompareBiomarkerAcrossReports extends Mock
    implements CompareBiomarkerAcrossReports {}

class _DummyReportRepository implements ReportRepository {
  @override
  Future<Either<Failure, Report>> saveReport(Report report) async =>
      Right(report);

  @override
  Future<Either<Failure, List<Report>>> getAllReports() async =>
      Right(<Report>[]);

  @override
  Future<Either<Failure, Report>> getReportById(String id) async =>
      Left(const CacheFailure());

  @override
  Future<Either<Failure, void>> deleteReport(String id) async => Right(null);

  @override
  Future<Either<Failure, void>> updateReport(Report report) async =>
      Right(null);

  @override
  Future<Either<Failure, List<TrendDataPoint>>> getBiomarkerTrend(
          String biomarkerName,
          {DateTime? startDate,
          DateTime? endDate}) async =>
      Right(<TrendDataPoint>[]);

  @override
  Future<Either<Failure, List<String>>> getDistinctBiomarkerNames() async =>
      Right(<String>[]);

  @override
  Future<Either<Failure, List<Report>>> getReportsByDateRange(
          DateTime startDate, DateTime endDate) async =>
      Right(<Report>[]);
}

class _DummyGetAllReports extends GetAllReports {
  _DummyGetAllReports() : super(repository: _DummyReportRepository());

  @override
  Future<Either<Failure, List<Report>>> call() async => Right(<Report>[]);
}

class _DummySaveReport extends SaveReport {
  _DummySaveReport() : super(repository: _DummyReportRepository());

  @override
  Future<Either<Failure, Report>> call(Report report) async => Right(report);
}

class _DummyTimelineRepository implements TimelineRepository {
  @override
  Future<Either<Failure, List<HealthEntry>>> getUnifiedTimeline({
    DateTime? startDate,
    DateTime? endDate,
    HealthEntryType? filterType,
  }) async =>
      Right(<HealthEntry>[]);
}

class _DummyGetUnifiedTimeline extends GetUnifiedTimeline {
  _DummyGetUnifiedTimeline() : super(repository: _DummyTimelineRepository());

  @override
  Future<Either<Failure, List<HealthEntry>>> call({
    DateTime? startDate,
    DateTime? endDate,
    HealthEntryType? filterType,
  }) async =>
      Right(<HealthEntry>[]);
}

class _FakeReportsNotifier extends ReportsNotifier {
  _FakeReportsNotifier({List<Report> initialReports = const []})
      : super(
          getAllReports: _DummyGetAllReports(),
          saveReportProvider: () => _DummySaveReport(),
        ) {
    state = AsyncValue.data(initialReports);
  }

  @override
  Future<void> loadReports() async {
    // no-op for tests
  }

  @override
  Future<Either<Failure, Report>> saveReport(Report report) async =>
      Right(report);
}

class _StubFilePicker extends FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus p1)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async =>
      null;

  @override
  Future<bool?> clearTemporaryFiles() async => true;

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async =>
      null;

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async =>
      null;
}

class _FakeReportFilePicker extends ReportFilePicker {
  _FakeReportFilePicker() : super(platform: _StubFilePicker());

  @override
  Future<String?> pickReportPath() async => null;
}

class _StubDownloadsPathProvider implements DownloadsPathProvider {
  const _StubDownloadsPathProvider();

  @override
  Future<String> getDownloadsPath() async => '/tmp';
}

class _StubConfigRepository implements ConfigRepository {
  AppConfig _config = const AppConfig();

  @override
  Future<Either<Failure, AppConfig>> getConfig() async => Right(_config);

  @override
  Future<Either<Failure, void>> saveConfig(AppConfig config) async {
    _config = config;
    return const Right(null);
  }
}

class _StubHealthLogRepository implements HealthLogRepository {
  @override
  Future<Either<Failure, void>> deleteHealthLog(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<HealthLog>>> getAllHealthLogs() async =>
      const Right([]);

  @override
  Future<Either<Failure, HealthLog>> getHealthLogById(String id) async =>
      Left(NotFoundFailure(message: 'not found'));

  @override
  Future<Either<Failure, List<HealthLog>>> getHealthLogsByDateRange(
    DateTime start,
    DateTime end,
  ) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<VitalMeasurement>>> getVitalTrend(
    VitalType type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      const Right([]);

  @override
  Future<Either<Failure, HealthLog>> saveHealthLog(HealthLog log) async =>
      Right(log);

  @override
  Future<Either<Failure, void>> updateHealthLog(HealthLog log) async =>
      const Right(null);
}


void main() {
  setUpAll(() {
    registerFallbackValue(const RouteSettings());
    registerFallbackValue(<String>[]);
  });

  final sampleReport = Report(
    id: 'report-123',
    date: DateTime(2024, 1, 1),
    labName: 'Test Lab',
    biomarkers: [
      Biomarker(
        id: 'bio',
        name: 'Hemoglobin',
        value: 13.5,
        unit: 'g/dL',
        referenceRange: const ReferenceRange(min: 12, max: 16),
        measuredAt: DateTime(2024, 1, 1),
      ),
    ],
    originalFilePath: '/tmp/report.pdf',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  Widget buildRouterApp(GoRouter router,
      {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        getUnifiedTimelineUseCaseProvider
            .overrideWithValue(_DummyGetUnifiedTimeline()),
        reportFilePickerProvider.overrideWithValue(_FakeReportFilePicker()),
        ...overrides,
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pumpAndSettleWithTimers(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 25));
  }

  group('AppRouter', () {
    testWidgets('initial route renders ReportsListPage', (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            reportsProvider.overrideWith((ref) => _FakeReportsNotifier()),
          ],
        ),
      );

      await pumpAndSettleWithTimers(tester);

      expect(find.byType(ReportsListPage), findsOneWidget);
    });

    testWidgets('upload route displays UploadPage', (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      final mockUsecase = _MockExtractReportFromFileLlm();
      when(() => mockUsecase(any()))
          .thenAnswer((_) async => const Left(CacheFailure()));

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            reportsProvider.overrideWith((ref) => _FakeReportsNotifier()),
            extractionProvider
                .overrideWith((ref) => ExtractionNotifier(mockUsecase)),
            reportFilePickerProvider
                .overrideWithValue(_FakeReportFilePicker()),
          ],
        ),
      );

      router.go(RouteNames.upload);
      await pumpAndSettleWithTimers(tester);

      expect(find.byType(UploadPage), findsOneWidget);
    });

    testWidgets('review route without report extra shows ErrorPage',
        (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            reportsProvider.overrideWith((ref) => _FakeReportsNotifier()),
          ],
        ),
      );

      router.go(RouteNames.review);
      await pumpAndSettleWithTimers(tester);

      expect(find.byType(ErrorPage), findsOneWidget);
      expect(find.textContaining('Report data is required'), findsOneWidget);
    });

    testWidgets('review route with report extra shows ReviewPage',
        (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            reportsProvider.overrideWith(
                (ref) => _FakeReportsNotifier(initialReports: [sampleReport])),
          ],
        ),
      );

      router.go(RouteNames.review, extra: sampleReport);
      await pumpAndSettleWithTimers(tester);

      expect(find.byType(ReviewPage), findsOneWidget);
    });

    testWidgets('report detail route with id shows ReportDetailPage',
        (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            reportsProvider.overrideWith(
                (ref) => _FakeReportsNotifier(initialReports: [sampleReport])),
          ],
        ),
      );

      router.go(RouteNames.reportDetail.replaceFirst(':id', sampleReport.id));
      await pumpAndSettleWithTimers(tester);

      expect(find.byType(ReportDetailPage), findsOneWidget);
    });

    testWidgets('unknown route falls back to ErrorPage', (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            reportsProvider.overrideWith((ref) => _FakeReportsNotifier()),
          ],
        ),
      );

      router.go('/some/unknown/path');
      await pumpAndSettleWithTimers(tester);

      expect(find.byType(ErrorPage), findsOneWidget);
    });

    testWidgets('trends route renders TrendsPage and passes initial args',
        (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      final healthLogRepository = _StubHealthLogRepository();
      final getVitalTrend = GetVitalTrend(repository: healthLogRepository);
      final calculateVitalStats =
          CalculateVitalStatistics(getVitalTrend: getVitalTrend);

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            reportsProvider.overrideWith(
              (ref) => _FakeReportsNotifier(initialReports: [sampleReport]),
            ),
            getBiomarkerTrendProvider.overrideWithValue(
              GetBiomarkerTrend(repository: _DummyReportRepository()),
            ),
            calculateTrendProvider.overrideWithValue(CalculateTrend()),
            getVitalTrendUseCaseProvider.overrideWithValue(getVitalTrend),
            calculateVitalStatisticsUseCaseProvider
                .overrideWithValue(calculateVitalStats),
            selectedVitalTypeProvider.overrideWith((ref) => null),
          ],
        ),
      );

      await tester.pump();
      const args = TrendsPageArgs(
        initialTab: TrendsTab.vitals,
        initialBiomarker: 'Hemoglobin',
      );

      router.go(RouteNames.trends, extra: args);
      await pumpAndSettleWithTimers(tester);

      final trendsPage = tester.widget<TrendsPage>(find.byType(TrendsPage));
      expect(trendsPage.initialArgs, args);
    });

    testWidgets('comparison route shows ComparisonView', (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      final mockCompare = _MockCompareBiomarkerAcrossReports();
      when(() => mockCompare(any(), any())).thenAnswer(
        (_) async => Right(
          comparison.BiomarkerComparison(
            biomarkerName: 'Hemoglobin',
            comparisons: [
              comparison.ComparisonDataPoint(
                reportId: 'report-123',
                reportDate: DateTime(2024, 1, 1),
                value: 13.5,
                unit: 'g/dL',
                status: BiomarkerStatus.normal,
                deltaFromPrevious: null,
                percentageChangeFromPrevious: null,
              ),
            ],
            overallTrend: comparison.TrendDirection.stable,
          ),
        ),
      );

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            reportsProvider.overrideWith(
              (ref) => _FakeReportsNotifier(initialReports: [sampleReport]),
            ),
            compareBiomarkerAcrossReportsProvider.overrideWithValue(
              mockCompare,
            ),
          ],
        ),
      );

      await tester.pump();
      router.go(RouteNames.comparison);
      await pumpAndSettleWithTimers(tester);

      expect(find.byType(ComparisonView), findsOneWidget);
    });

    testWidgets('settings route renders SettingsPage', (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      final configRepository = _StubConfigRepository();

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            configProvider.overrideWith(
              (ref) => ConfigNotifier(configRepository),
            ),
          ],
        ),
      );

      await tester.pump();
      router.go(RouteNames.settings);
      await pumpAndSettleWithTimers(tester);

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('health log detail route requires HealthLog extra',
        (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      final healthLog = HealthLog(
        id: 'log-1',
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
        notes: 'Felt good',
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      );

      await tester.pumpWidget(buildRouterApp(router));

      await tester.pump();
      router.go(RouteNames.healthLogDetail.replaceFirst(':id', healthLog.id));
      await pumpAndSettleWithTimers(tester);
      expect(find.byType(ErrorPage), findsOneWidget);

      router.go(
        RouteNames.healthLogDetail.replaceFirst(':id', healthLog.id),
        extra: healthLog,
      );
      await pumpAndSettleWithTimers(tester);

      expect(find.byType(HealthLogDetailPage), findsOneWidget);
    });

    testWidgets('export routes render export configuration pages',
        (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      final csvService = CsvExportServiceImpl(
        exportReportsToCsv: ExportReportsToCsv(),
        exportVitalsToCsv: ExportVitalsToCsv(),
        exportTrendsToCsv: ExportTrendsToCsv(),
      );
      final fileWriterService = FileWriterServiceImpl.test(
        downloadsPathProvider: const _StubDownloadsPathProvider(),
        stringWriter: (_, __) async {},
        bytesWriter: (_, __) async {},
      );

      final exportProvider = ExportProvider(
        csvExportService: csvService,
        fileWriterService: fileWriterService,
        reportsLoader: () async => const Right(<Report>[]),
        healthLogsLoader: () async => const Right(<HealthLog>[]),
      );

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            exportNotifierProvider.overrideWith((ref) => exportProvider),
          ],
        ),
      );

      await tester.pump();
      router.go(RouteNames.export);
      await tester.pump();
      await pumpAndSettleWithTimers(tester);
      expect(find.byType(ExportPage), findsOneWidget);

      router.go(RouteNames.doctorPdfConfig);
      await tester.pump();
      await pumpAndSettleWithTimers(tester);
      expect(find.byType(DoctorPdfConfigPage), findsOneWidget);
    });
  });
}
