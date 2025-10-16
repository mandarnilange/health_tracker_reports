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
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file.dart';
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

class _MockExtractReportFromFile extends Mock implements ExtractReportFromFile {}

class _DummyReportRepository implements ReportRepository {
  @override
  Future<Either<Failure, Report>> saveReport(Report report) async => Right(report);

  @override
  Future<Either<Failure, List<Report>>> getAllReports() async => Right(<Report>[]);

  @override
  Future<Either<Failure, Report>> getReportById(String id) async => Left(const CacheFailure());

  @override
  Future<Either<Failure, void>> deleteReport(String id) async => Right(null);

  @override
  Future<Either<Failure, void>> updateReport(Report report) async => Right(null);

  @override
  Future<Either<Failure, List<TrendDataPoint>>> getBiomarkerTrend(
          String biomarkerName,
          {DateTime? startDate,
          DateTime? endDate}) async =>
      Right(<TrendDataPoint>[]);
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
  Future<Either<Failure, Report>> saveReport(Report report) async => Right(report);
}

class _FakeReportFilePicker extends ReportFilePicker {
  const _FakeReportFilePicker();

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

  Widget buildRouterApp(GoRouter router, {List<Override> overrides = const []}) {
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

      final mockUsecase = _MockExtractReportFromFile();
      when(() => mockUsecase(any())).thenAnswer((_) async => const Left(CacheFailure()));

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            reportsProvider.overrideWith((ref) => _FakeReportsNotifier()),
            extractionProvider.overrideWith((ref) => ExtractionNotifier(mockUsecase)),
            reportFilePickerProvider.overrideWithValue(const _FakeReportFilePicker()),
          ],
        ),
      );

      router.go(RouteNames.upload);
      await pumpAndSettleWithTimers(tester);

      expect(find.byType(UploadPage), findsOneWidget);
    });

    testWidgets('review route without report extra shows ErrorPage', (tester) async {
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

    testWidgets('review route with report extra shows ReviewPage', (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            reportsProvider.overrideWith((ref) => _FakeReportsNotifier(initialReports: [sampleReport])),
          ],
        ),
      );

      router.go(RouteNames.review, extra: sampleReport);
      await pumpAndSettleWithTimers(tester);

      expect(find.byType(ReviewPage), findsOneWidget);
    });

    testWidgets('report detail route with id shows ReportDetailPage', (tester) async {
      final router = AppRouter.createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        buildRouterApp(
          router,
          overrides: [
            reportsProvider.overrideWith((ref) => _FakeReportsNotifier(initialReports: [sampleReport])),
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
