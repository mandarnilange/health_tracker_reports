import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/presentation/pages/upload/review_page.dart';
import 'package:health_tracker_reports/presentation/pages/upload/upload_page.dart';
import 'package:health_tracker_reports/presentation/providers/extraction_provider.dart';
import 'package:health_tracker_reports/presentation/providers/file_picker_provider.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockExtractionNotifier extends Mock implements ExtractionNotifier {}

class MockReportsNotifier extends Mock implements ReportsNotifier {}

class MockReportFilePicker extends Mock implements ReportFilePicker {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute<T> extends Fake implements Route<T> {}

void main() {
  late MockExtractionNotifier mockExtractionNotifier;
  late MockReportsNotifier mockReportsNotifier;
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
  });

  setUp(() {
    mockExtractionNotifier = MockExtractionNotifier();
    mockReportsNotifier = MockReportsNotifier();
    mockFilePicker = MockReportFilePicker();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  ProviderScope createWidgetUnderTest() {
    final router = GoRouter(
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

    return ProviderScope(
      overrides: [
        extractionProvider.overrideWith((ref) => mockExtractionNotifier),
        reportsProvider.overrideWith((ref) => mockReportsNotifier),
        reportFilePickerProvider.overrideWithValue(mockFilePicker),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('UploadPage', () {
    testWidgets('shows instructions when no report selected', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Select Blood Report'), findsOneWidget);
      expect(find.byIcon(Icons.upload_file), findsOneWidget);
    });

    testWidgets('shows loading indicator while extraction running',
        (tester) async {
      when(() => mockFilePicker.pickReportPath())
          .thenAnswer((_) async => '/tmp/report.pdf');
      when(() => mockExtractionNotifier.extractFromFile(any()))
          .thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return const Left(OcrFailure(message: ''));
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Extracting biomarkers...'), findsOneWidget);
    });

    testWidgets('shows error card when extraction fails', (tester) async {
      when(() => mockExtractionNotifier.extractFromFile(any())).thenAnswer(
        (_) async => const Left(OcrFailure(message: 'Extraction failed')),
      );
      when(() => mockFilePicker.pickReportPath())
          .thenAnswer((_) async => '/tmp/report.pdf');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Select Blood Report'));
      await tester.pump();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Extraction failed'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('invokes file picker when upload card tapped', (tester) async {
      when(() => mockFilePicker.pickReportPath())
          .thenAnswer((_) async => '/tmp/report.pdf');
      when(() => mockExtractionNotifier.extractFromFile(any()))
          .thenAnswer((_) async => Right(testReport));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Select Blood Report'));
      await tester.pump();

      verify(() => mockFilePicker.pickReportPath()).called(1);
      verify(() => mockExtractionNotifier.extractFromFile('/tmp/report.pdf'))
          .called(1);
    });

    testWidgets('navigates to ReviewPage when extraction succeeds',
        (tester) async {
      when(() => mockFilePicker.pickReportPath())
          .thenAnswer((_) async => '/tmp/report.pdf');
      when(() => mockExtractionNotifier.extractFromFile(any()))
          .thenAnswer((_) async => Right(testReport));
      when(() => mockExtractionNotifier.reset()).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Select Blood Report'));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any())).called(2);
      expect(find.byType(ReviewPage), findsOneWidget);
    });
  });
}
