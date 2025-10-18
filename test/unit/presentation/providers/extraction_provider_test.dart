import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file_llm.dart';
import 'package:health_tracker_reports/presentation/providers/extraction_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockExtractReportFromFileLlm extends Mock implements ExtractReportFromFileLlm {}

void main() {
  late MockExtractReportFromFileLlm mockExtractReportFromFileLlm;
  late ExtractionNotifier notifier;

  const filePath = '/tmp/report.pdf';

  final report = Report(
    id: 'report-1',
    date: DateTime(2025, 10, 15),
    labName: 'Test Lab',
    biomarkers: [
      Biomarker(
        id: 'bio-1',
        name: 'Hemoglobin',
        value: 13.5,
        unit: 'g/dL',
        referenceRange: const ReferenceRange(min: 12.0, max: 17.0),
        measuredAt: DateTime(2025, 10, 15),
      ),
    ],
    originalFilePath: filePath,
    createdAt: DateTime(2025, 10, 15),
    updatedAt: DateTime(2025, 10, 15),
  );

  setUp(() {
    mockExtractReportFromFileLlm = MockExtractReportFromFileLlm();
    notifier = ExtractionNotifier(mockExtractReportFromFileLlm);
  });

  test('initial state should be null data', () {
    expect(notifier.state, const AsyncData<Report?>(null));
  });

  test('extractFromFile should set loading before processing', () async {
    when(() => mockExtractReportFromFileLlm(filePath))
        .thenAnswer((_) async => Right(report));

    final future = notifier.extractFromFile(filePath);

    expect(notifier.state, isA<AsyncLoading<Report?>>());

    await future;
  });

  test('extractFromFile should emit data on success', () async {
    when(() => mockExtractReportFromFileLlm(filePath))
        .thenAnswer((_) async => Right(report));

    final result = await notifier.extractFromFile(filePath);

    expect(result, equals(Right(report)));
    expect(notifier.state, AsyncData<Report?>(report));
  });

  test('extractFromFile should emit error on failure', () async {
    const failure = OcrFailure(message: 'Failed');
    when(() => mockExtractReportFromFileLlm(filePath))
        .thenAnswer((_) async => const Left(failure));

    final result = await notifier.extractFromFile(filePath);

    expect(result, equals(const Left(failure)));
    expect(notifier.state, isA<AsyncError<Report?>>());
  });

  test('reset should clear state to null data', () {
    notifier.reset();

    expect(notifier.state, const AsyncData<Report?>(null));
  });
}
