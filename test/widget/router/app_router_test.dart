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
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file_llm.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/presentation/pages/error/error_page.dart';
import 'package:health_tracker_reports/presentation/pages/home/reports_list_page.dart';
import 'package:health_tracker_reports/presentation/pages/report_detail/report_detail_page.dart';
import 'package:health_tracker_reports/presentation/pages/upload/review_page.dart';
import 'package:health_tracker_reports/presentation/pages/upload/upload_page.dart';
import 'package:health_tracker_reports/presentation/providers/extraction_provider.dart';
import 'package:health_tracker_reports/presentation/providers/file_picker_provider.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:health_tracker_reports/presentation/router/app_router.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:mocktail/mocktail.dart';

class _MockExtractReportFromFileLlm extends Mock
    implements ExtractReportFromFileLlm {}

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

void main() {
  setUpAll(() {
    registerFallbackValue(const RouteSettings());
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
      overrides: overrides,
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
  });
}
