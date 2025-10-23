import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file_llm.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/presentation/pages/upload/review_page.dart';
import 'package:health_tracker_reports/presentation/pages/upload/upload_page.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/presentation/providers/extraction_provider.dart';
import 'package:health_tracker_reports/presentation/providers/file_picker_provider.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockExtractReportFromFileLlm extends Mock implements ExtractReportFromFileLlm {}

class MockReportFilePicker extends Mock implements ReportFilePicker {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute<T> extends Fake implements Route<T> {}

class _DummyReportRepository implements ReportRepository {
  @override
  Future<Either<Failure, Report>> saveReport(Report report) async =>
      Right(report);

  @override
  Future<Either<Failure, List<Report>>> getAllReports() async =>
      const Right([]);

  @override
  Future<Either<Failure, Report>> getReportById(String id) async =>
      Left(CacheFailure());

  @override
  Future<Either<Failure, void>> deleteReport(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateReport(Report report) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<TrendDataPoint>>> getBiomarkerTrend(
          String biomarkerName,
          {DateTime? startDate,
          DateTime? endDate}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<String>>> getDistinctBiomarkerNames() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Report>>> getReportsByDateRange(
          DateTime startDate, DateTime endDate) async =>
      const Right([]);
}

class _DummyGetAllReports extends GetAllReports {
  _DummyGetAllReports() : super(repository: _DummyReportRepository());

  @override
  Future<Either<Failure, List<Report>>> call() async => const Right([]);
}

class _DummySaveReport extends SaveReport {
  _DummySaveReport()
      : super(
          repository: _DummyReportRepository(),
        );

  @override
  Future<Either<Failure, Report>> call(Report report) async => Right(report);
}

class _FakeReportsNotifier extends ReportsNotifier {
  _FakeReportsNotifier()
      : super(
          getAllReports: _DummyGetAllReports(),
          saveReportProvider: () => _DummySaveReport(),
        ) {
    state = const AsyncValue.data([]);
  }

  @override
  Future<void> loadReports() async {
    state = const AsyncValue.data([]);
  }

  @override
  Future<Either<Failure, Report>> saveReport(Report report) async {
    return Right(report);
  }
}

void main() {
  Future<void> pumpUntilFound(WidgetTester tester, Finder finder,
      {int maxPumps = 10}) async {
    var pumps = 0;
    while (!tester.any(finder) && pumps < maxPumps) {
      await tester.pump(const Duration(milliseconds: 20));
      pumps += 1;
    }
  }

  late MockReportFilePicker mockFilePicker;
  late NavigatorObserver mockNavigatorObserver;

  final testReport = Report(
    id: 'report-1',
    date: DateTime(2025, 10, 15),
    labName: 'Test Lab',
    biomarkers: [
      Biomarker(
        id: 'bio-1',
        name: 'Hemoglobin',
        value: 14.5,
        unit: 'g/dL',
        referenceRange: const ReferenceRange(min: 13.0, max: 17.0),
        measuredAt: DateTime(2025, 10, 15),
      ),
    ],
    originalFilePath: '/tmp/report.pdf',
    createdAt: DateTime(2025, 10, 15),
    updatedAt: DateTime(2025, 10, 15),
  );

  setUpAll(() {
    registerFallbackValue(const RouteSettings());
    registerFallbackValue(FakeRoute<dynamic>());
    registerFallbackValue(testReport);
  });

  setUp(() {
    mockFilePicker = MockReportFilePicker();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  ProviderScope createWidgetUnderTest({
    MockExtractReportFromFileLlm? extractReportUsecase,
    AsyncValue<Report?>? initialExtractionState,
    void Function(ExtractionNotifier notifier)? onNotifierReady,
    bool withRouter = false,
  }) {
    final usecase = extractReportUsecase ?? MockExtractReportFromFileLlm();
    final dummyGetAllReports = _DummyGetAllReports();
    final dummySaveReport = _DummySaveReport();
    GoRouter? router;
    if (withRouter) {
      router = GoRouter(
        observers: [mockNavigatorObserver],
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const UploadPage(),
          ),
          GoRoute(
            path: '/review',
            builder: (context, state) =>
                ReviewPage(initialReport: state.extra! as Report),
          ),
        ],
      );
    }

    return ProviderScope(
      overrides: [
        extractionProvider.overrideWith((ref) {
          final notifier = ExtractionNotifier(usecase);
          if (initialExtractionState != null) {
            notifier.state = initialExtractionState;
          }
          onNotifierReady?.call(notifier);
          return notifier;
        }),
        reportsProvider.overrideWith((ref) => _FakeReportsNotifier()),
        reportFilePickerProvider.overrideWithValue(mockFilePicker),
      ],
      child: withRouter && router != null
          ? MaterialApp.router(routerConfig: router)
          : const MaterialApp(home: UploadPage()),
    );
  }

  group('UploadPage', () {
    testWidgets('shows instructions when no report selected', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          initialExtractionState: const AsyncValue.data(null),
          withRouter: false,
        ),
      );
      await tester.pump();
      await pumpUntilFound(tester, find.text('Select Blood Report'));

      expect(find.text('Select Blood Report'), findsOneWidget);
      expect(find.byIcon(Icons.upload_file), findsOneWidget);
    });

    testWidgets('shows loading indicator while extraction running',
        (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          initialExtractionState: const AsyncValue.loading(),
          withRouter: false,
        ),
      );
      await tester.pump();
      await pumpUntilFound(tester, find.byType(CircularProgressIndicator));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Extracting biomarkers...'), findsOneWidget);
    });

    testWidgets('shows error card when extraction fails', (tester) async {
      const failure = OcrFailure(message: 'Extraction failed');
      await tester.pumpWidget(
        createWidgetUnderTest(
          initialExtractionState: AsyncValue.error(failure, StackTrace.current),
          withRouter: false,
        ),
      );
      await tester.pump();
      await pumpUntilFound(tester, find.text('Error'));

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Extraction failed'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('invokes file picker when upload card tapped', (tester) async {
      final mockUsecase = MockExtractReportFromFileLlm();
      when(() => mockUsecase(any()))
          .thenAnswer((_) async => const Left(CacheFailure()));

      when(() => mockFilePicker.pickReportPath())
          .thenAnswer((_) async => '/tmp/report.pdf');

      await tester.pumpWidget(
        createWidgetUnderTest(
          extractReportUsecase: mockUsecase,
          initialExtractionState: const AsyncValue.data(null),
          withRouter: false,
        ),
      );
      await tester.pump();
      await pumpUntilFound(tester, find.text('Select Blood Report'));

      await tester.tap(find.text('Select Blood Report'));
      await tester.pump();

      verify(() => mockFilePicker.pickReportPath()).called(1);
      verify(() => mockUsecase('/tmp/report.pdf')).called(1);
    });

    testWidgets('navigates to ReviewPage when extraction succeeds',
        (tester) async {
      final mockUsecase = MockExtractReportFromFileLlm();
      when(() => mockUsecase(any())).thenAnswer((_) async => Right(testReport));
      when(() => mockFilePicker.pickReportPath())
          .thenAnswer((_) async => '/tmp/report.pdf');

      await tester.pumpWidget(
        createWidgetUnderTest(
          extractReportUsecase: mockUsecase,
          initialExtractionState: const AsyncValue.data(null),
          withRouter: true,
        ),
      );
      await tester.pump();
      await pumpUntilFound(tester, find.text('Select Blood Report'));

      expect(find.text('Select Blood Report'), findsOneWidget);

      await tester.tap(find.text('Select Blood Report'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockNavigatorObserver.didPush(any(), any())).called(2);
      expect(find.byType(ReviewPage), findsOneWidget);
    });

    testWidgets('does not show error when user cancels file picker',
        (tester) async {
      final mockUsecase = MockExtractReportFromFileLlm();
      when(() => mockFilePicker.pickReportPath()).thenThrow(
        PlatformException(code: 'aborted', message: 'User cancelled'),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          extractReportUsecase: mockUsecase,
          initialExtractionState: const AsyncValue.data(null),
          withRouter: false,
        ),
      );
      await tester.pump();
      await pumpUntilFound(tester, find.text('Select Blood Report'));

      await tester.tap(find.text('Select Blood Report'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verifyNever(() => mockUsecase(any()));
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
