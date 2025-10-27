import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/share_service.dart';
import 'package:health_tracker_reports/domain/entities/doctor_summary_config.dart';
import 'package:health_tracker_reports/domain/usecases/generate_doctor_pdf.dart';
import 'package:intl/intl.dart';
import 'package:health_tracker_reports/presentation/pages/export/doctor_pdf_config_page.dart';
import 'package:health_tracker_reports/presentation/providers/generate_doctor_pdf_provider.dart';
import 'package:health_tracker_reports/presentation/providers/share_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';

class _MockGenerateDoctorPdf extends Mock implements GenerateDoctorPdf {}

class _MockShareService extends Mock implements ShareService {}

Future<void> _pumpPage(
  WidgetTester tester, {
  required _MockGenerateDoctorPdf mockGenerate,
  required _MockShareService mockShare,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        generateDoctorPdfProvider.overrideWithValue(mockGenerate),
        shareServiceProvider.overrideWithValue(mockShare),
      ],
      child: const MaterialApp(
        home: DoctorPdfConfigPage(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      DoctorSummaryConfig(
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 2),
      ),
    );
    registerFallbackValue(XFile('path/to/file.pdf'));
  });

  testWidgets('DoctorPdfConfigPage renders controls and actions',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DoctorPdfConfigPage(),
        ),
      ),
    );

    expect(find.text('Doctor PDF Config'), findsOneWidget);
    expect(find.text('Select Date Range'), findsOneWidget);
    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('End Date'), findsOneWidget);

    // Date pickers show initial formatted values
    final formatter = DateFormat('yyyy-MM-dd');
    expect(
      find.text(
          formatter.format(DateTime.now().subtract(const Duration(days: 30)))),
      findsOneWidget,
    );
    expect(find.text(formatter.format(DateTime.now())), findsOneWidget);

    // Toggles for PDF options
    expect(find.text('Include Vitals'), findsOneWidget);
    expect(find.text('Include Full Data Table'), findsOneWidget);

    // Action buttons
    expect(find.text('Generate PDF'), findsOneWidget);
    expect(find.text('Generate & Share'), findsOneWidget);
  });

  testWidgets('toggling switches updates configuration state', (tester) async {
    final mockGenerate = _MockGenerateDoctorPdf();
    final mockShare = _MockShareService();

    when(() => mockGenerate(any())).thenAnswer(
      (_) async => const Right('/tmp/doctor.pdf'),
    );
    when(() => mockShare.shareFile(any()))
        .thenAnswer((_) async => const Right(null));

    await _pumpPage(
      tester,
      mockGenerate: mockGenerate,
      mockShare: mockShare,
    );
    await tester.pumpAndSettle();

    final includeVitalsFinder =
        find.widgetWithText(SwitchListTile, 'Include Vitals');
    final includeTableFinder =
        find.widgetWithText(SwitchListTile, 'Include Full Data Table');

    expect(
      tester.widget<SwitchListTile>(includeVitalsFinder).value,
      isTrue,
    );
    expect(
      tester.widget<SwitchListTile>(includeTableFinder).value,
      isFalse,
    );

    await tester.tap(includeVitalsFinder);
    await tester.pumpAndSettle();
    await tester.tap(includeTableFinder);
    await tester.pumpAndSettle();

    expect(
      tester.widget<SwitchListTile>(includeVitalsFinder).value,
      isFalse,
    );
    expect(
      tester.widget<SwitchListTile>(includeTableFinder).value,
      isTrue,
    );
  });

  testWidgets('generate button invokes use case and shows success snackbar',
      (tester) async {
    final mockGenerate = _MockGenerateDoctorPdf();
    final mockShare = _MockShareService();

    when(() => mockGenerate(any())).thenAnswer(
      (_) async => const Right('/tmp/doctor.pdf'),
    );
    when(() => mockShare.shareFile(any()))
        .thenAnswer((_) async => const Right(null));

    await _pumpPage(
      tester,
      mockGenerate: mockGenerate,
      mockShare: mockShare,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate PDF'));
    await tester.pump();
    await tester.pumpAndSettle();

    final captured = verify(
      () => mockGenerate(captureAny<DoctorSummaryConfig>()),
    ).captured;
    expect(captured, hasLength(1));
    final config = captured.first as DoctorSummaryConfig;
    expect(config.includeVitals, isTrue);
    expect(config.includeFullDataTable, isFalse);

    expect(
      find.textContaining('PDF saved to: /tmp/doctor.pdf'),
      findsOneWidget,
    );
  });

  testWidgets('generate & share triggers share service on success',
      (tester) async {
    final mockGenerate = _MockGenerateDoctorPdf();
    final mockShare = _MockShareService();

    when(() => mockGenerate(any())).thenAnswer(
      (_) async => const Right('/tmp/shared.pdf'),
    );
    when(() => mockShare.shareFile(any()))
        .thenAnswer((_) async => const Right(null));

    await _pumpPage(
      tester,
      mockGenerate: mockGenerate,
      mockShare: mockShare,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate & Share'));
    await tester.pump();
    await tester.pumpAndSettle();

    verify(() => mockGenerate(any())).called(1);
    final sharedFiles = verify(
      () => mockShare.shareFile(captureAny<XFile>()),
    ).captured;
    expect(sharedFiles, hasLength(1));
    final sharedFile = sharedFiles.first as XFile;
    expect(sharedFile.path, '/tmp/shared.pdf');
    expect(find.textContaining('PDF saved to: /tmp/shared.pdf'), findsOneWidget);
  });

  testWidgets('shows error snackbar when generation fails', (tester) async {
    final mockGenerate = _MockGenerateDoctorPdf();
    final mockShare = _MockShareService();

    when(() => mockGenerate(any())).thenAnswer(
      (_) async => const Left(
        ValidationFailure(message: 'No reports found'),
      ),
    );

    await _pumpPage(
      tester,
      mockGenerate: mockGenerate,
      mockShare: mockShare,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate PDF'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('No reports found'), findsOneWidget);
    verifyNever(() => mockShare.shareFile(any()));
  });
}
