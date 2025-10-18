import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/services/report_scan_service.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file.dart';
import 'package:health_tracker_reports/domain/usecases/normalize_biomarker_name.dart';
import 'package:mocktail/mocktail.dart';

class MockReportScanService extends Mock implements ReportScanService {}

class MockNormalizeBiomarkerName extends Mock
    implements NormalizeBiomarkerName {}

void main() {
  late ExtractReportFromFile usecase;
  late MockReportScanService mockReportScanService;
  late MockNormalizeBiomarkerName mockNormalizeBiomarkerName;
  late DateTime fixedNow;
  late Iterator<String> idIterator;

  setUp(() {
    mockReportScanService = MockReportScanService();
    mockNormalizeBiomarkerName = MockNormalizeBiomarkerName();
    fixedNow = DateTime(2025, 1, 1, 12);
    final ids = ['bio-1', 'bio-2'].iterator;
    idIterator = ids;
    registerFallbackValue(const ReportScanRequest(
      source: ScanSource.pdf,
      uri: '',
      imageUris: [],
    ));
    usecase = ExtractReportFromFile.test(
      reportScanService: mockReportScanService,
      normalizeBiomarker: mockNormalizeBiomarkerName,
      idGenerator: () {
        if (!idIterator.moveNext()) {
          throw StateError('No more ids');
        }
        return idIterator.current;
      },
      now: () => fixedNow,
    );
  });

  ReportScanEventStructured createStructuredEvent() {
    return ReportScanEventStructured(
      page: 1,
      totalPages: 1,
      payload: ReportScanPayload(
        rawText: 'Patient Name : Alice Example\nHemoglobin 13.5 g/dL',
        lines: const [
          RecognizedLine(
            text: 'Patient Name : Alice Example',
            boundingBox: BoundingBox(x: 0.1, y: 0.9, width: 0.8, height: 0.05),
          ),
          RecognizedLine(
            text: 'Hemoglobin 13.5 g/dL 12-17',
            boundingBox: BoundingBox(x: 0.2, y: 0.6, width: 0.7, height: 0.05),
          ),
        ],
      ),
    );
  }

  test('returns Report when structured data emitted for PDF', () async {
    final controller = StreamController<ReportScanEvent>();
    late ReportScanRequest capturedRequest;

    when(() => mockNormalizeBiomarkerName(any())).thenReturn('Hemoglobin');
    when(() => mockReportScanService.scanReport(any()))
        .thenAnswer((invocation) {
      capturedRequest =
          invocation.positionalArguments.first as ReportScanRequest;
      return controller.stream;
    });

    final resultFuture = usecase('/path/to/report.pdf');

    controller.add(const ReportScanEventProgress(page: 1, totalPages: 1));
    controller.add(createStructuredEvent());
    controller.add(const ReportScanEventComplete());
    await controller.close();

    final result = await resultFuture;

    expect(result, isA<Right<Failure, Report>>());
    final report = result.getOrElse(() => throw StateError('Expected report'));
    expect(report.date, fixedNow);
    expect(report.originalFilePath, '/path/to/report.pdf');
    expect(report.biomarkers, hasLength(1));
    final biomarker = report.biomarkers.first;
    expect(biomarker.name, 'Hemoglobin');
    expect(biomarker.value, 13.5);
    expect(biomarker.unit, 'g/dL');
    expect(biomarker.referenceRange.min, 12.0);
    expect(biomarker.referenceRange.max, 17.0);
    expect(
      report.notes,
      'Patient Name: Alice Example\n\nHemoglobin 13.5 g/dL',
    );
    expect(capturedRequest.source, ScanSource.pdf);
    expect(capturedRequest.uri, Uri.file('/path/to/report.pdf').toString());
    verify(() => mockNormalizeBiomarkerName('Hemoglobin')).called(1);
  });

  test('uses image scan when non-pdf file provided', () async {
    late ReportScanRequest capturedRequest;

    when(() => mockNormalizeBiomarkerName(any())).thenReturn('Hemoglobin');
    when(() => mockReportScanService.scanReport(any()))
        .thenAnswer((invocation) {
      capturedRequest =
          invocation.positionalArguments.first as ReportScanRequest;
      return Stream.fromIterable([
        createStructuredEvent(),
        const ReportScanEventComplete(),
      ]);
    });

    final result = await usecase('/path/to/photo.png');

    expect(result, isA<Right<Failure, Report>>());
    expect(capturedRequest.source, ScanSource.images);
    expect(capturedRequest.imageUris, [
      Uri.file('/path/to/photo.png').toString(),
    ]);
  });

  test('returns OcrFailure when scan emits error', () async {
    when(() => mockReportScanService.scanReport(any())).thenAnswer(
      (_) => Stream.fromIterable([
        const ReportScanEventError(
            code: 'scan_failed', message: 'Unable to scan'),
      ]),
    );

    final result = await usecase('/path/to/report.pdf');

    expect(result, isA<Left<Failure, Report>>());
    result.fold(
      (failure) => expect(failure, const OcrFailure(message: 'Unable to scan')),
      (_) => fail('Expected failure'),
    );
  });

  test('returns ValidationFailure when no biomarkers extracted', () async {
    when(() => mockReportScanService.scanReport(any())).thenAnswer(
      (_) => Stream.fromIterable([
        const ReportScanEventProgress(page: 1, totalPages: 1),
        const ReportScanEventComplete(),
      ]),
    );

    final result = await usecase('/empty.pdf');

    expect(result, isA<Left<Failure, Report>>());
    result.fold(
      (failure) => expect(
        failure,
        const ValidationFailure(message: 'No biomarkers detected'),
      ),
      (_) => fail('Expected failure'),
    );
  });

  test('sorts multi-column lines by X-coordinate before parsing', () async {
    // This tests the critical bug fix: lines in the same row should be sorted
    // left-to-right by X-coordinate, not in OCR scan order
    when(() => mockNormalizeBiomarkerName(any())).thenReturn('Glucose');
    when(() => mockReportScanService.scanReport(any())).thenAnswer(
      (_) => Stream.fromIterable([
        ReportScanEventStructured(
          page: 1,
          totalPages: 1,
          payload: const ReportScanPayload(
            rawText: '',
            lines: [
              // These lines are intentionally in wrong order (right-to-left)
              // to simulate OCR returning columns out of sequence.
              // Same Y-coordinate (0.5) means they're in the same row.
              RecognizedLine(
                text: '70-110', // Reference range (rightmost column)
                boundingBox: BoundingBox(x: 0.7, y: 0.5, width: 0.2, height: 0.05),
              ),
              RecognizedLine(
                text: 'mg/dL', // Unit (middle-right column)
                boundingBox: BoundingBox(x: 0.5, y: 0.5, width: 0.15, height: 0.05),
              ),
              RecognizedLine(
                text: '95', // Value (middle column)
                boundingBox: BoundingBox(x: 0.35, y: 0.5, width: 0.1, height: 0.05),
              ),
              RecognizedLine(
                text: 'Glucose', // Biomarker name (leftmost column)
                boundingBox: BoundingBox(x: 0.1, y: 0.5, width: 0.2, height: 0.05),
              ),
            ],
          ),
        ),
        const ReportScanEventComplete(),
      ]),
    );

    final result = await usecase('/path/to/report.pdf');

    expect(result, isA<Right<Failure, Report>>());
    final report = result.getOrElse(() => throw StateError('Expected report'));

    // Verify the biomarker was parsed correctly after X-coordinate sorting
    expect(report.biomarkers, hasLength(1));
    final biomarker = report.biomarkers.first;
    expect(biomarker.name, 'Glucose');
    expect(biomarker.value, 95.0);
    expect(biomarker.unit, 'mg/dL');
    expect(biomarker.referenceRange.min, 70.0);
    expect(biomarker.referenceRange.max, 110.0);
  });
}
