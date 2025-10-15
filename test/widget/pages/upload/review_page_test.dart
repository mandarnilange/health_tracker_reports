import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/presentation/pages/upload/review_page.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockReportsNotifier extends Mock implements ReportsNotifier {}

class FakeAsyncError extends Fake implements AsyncError<List<Report>> {}

void main() {
  late MockReportsNotifier mockReportsNotifier;
  late Report testReport;

  setUpAll(() {
    registerFallbackValue(
      Report(
        id: 'fallback',
        date: DateTime(2025, 1, 1),
        labName: 'Fallback',
        biomarkers: const [],
        originalFilePath: '/tmp/report.pdf',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ),
    );
  });

  setUp(() {
    mockReportsNotifier = MockReportsNotifier();

    testReport = Report(
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
        Biomarker(
          id: 'bio-2',
          name: 'Glucose',
          value: 150.0,
          unit: 'mg/dL',
          referenceRange: const ReferenceRange(min: 70.0, max: 100.0),
          measuredAt: DateTime(2025, 10, 15),
        ),
      ],
      originalFilePath: '/tmp/report.pdf',
      createdAt: DateTime(2025, 10, 15),
      updatedAt: DateTime(2025, 10, 15),
    );
  });

  Widget createWidgetUnderTest({Report? initialReport}) {
    return ProviderScope(
      overrides: [
        reportsProvider.overrideWith((ref) => mockReportsNotifier),
      ],
      child: MaterialApp(
        home: ReviewPage(
          initialReport: initialReport ?? testReport,
        ),
      ),
    );
  }

  group('ReviewPage', () {
    testWidgets('displays report details and biomarkers', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Lab'), findsOneWidget);
      expect(find.text('October 15, 2025'), findsOneWidget);
      expect(find.text('Hemoglobin'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('valueField-0')))
            .controller
            ?.text,
        '14.5',
      );
      expect(find.text('Glucose'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('valueField-1')))
            .controller
            ?.text,
        '150.0',
      );
    });

    testWidgets('allows editing biomarker value and saves updated report',
        (tester) async {
      when(() => mockReportsNotifier.saveReport(any()))
          .thenAnswer((invocation) async {
        final updatedReport = invocation.positionalArguments.first as Report;
        expect(updatedReport.biomarkers.first.value, equals(16.0));
        return Right(updatedReport);
      });

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byKey(const Key('valueField-0')), '16.0');
      await tester.pump();

      await tester.ensureVisible(find.text('Save Report'));
      await tester.tap(find.text('Save Report'));
      await tester.pumpAndSettle();

      verify(() => mockReportsNotifier.saveReport(any())).called(1);
    });

    testWidgets('shows validation error when lab name is empty',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byKey(const Key('labNameField')), '');
      await tester.ensureVisible(find.text('Save Report'));
      await tester.tap(find.text('Save Report'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Please enter the lab name'), findsOneWidget);
      verifyNever(() => mockReportsNotifier.saveReport(any()));
    });

    testWidgets('shows error snackbar when save fails', (tester) async {
      when(() => mockReportsNotifier.saveReport(any())).thenAnswer(
        (_) async => const Left(CacheFailure('Save failed')),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.ensureVisible(find.text('Save Report'));
      await tester.tap(find.text('Save Report'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Failed to save report: Save failed'), findsOneWidget);
    });
  });
}
