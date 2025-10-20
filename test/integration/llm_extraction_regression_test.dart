import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/structured_data.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file.dart';
import 'package:health_tracker_reports/domain/usecases/normalize_biomarker_name.dart';
import 'package:health_tracker_reports/data/datasources/external/ocr_service.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_extraction_service.dart';
import 'package:uuid/uuid.dart';

class MockOcrService extends Mock implements OcrService {}
class MockLlmExtractionService extends Mock implements LlmExtractionService {}
class MockNormalizeBiomarkerName extends Mock implements NormalizeBiomarkerName {}
class MockUuid extends Mock implements Uuid {}

void main() {
  late ExtractReportFromFile usecase;
  late MockOcrService mockOcrService;
  late MockLlmExtractionService mockLlmExtractionService;
  late MockNormalizeBiomarkerName mockNormalizeBiomarkerName;
  late MockUuid mockUuid;

  setUp(() {
    mockOcrService = MockOcrService();
    mockLlmExtractionService = MockLlmExtractionService();
    mockNormalizeBiomarkerName = MockNormalizeBiomarkerName();
    mockUuid = MockUuid();

    usecase = ExtractReportFromFile(
      ocrService: mockOcrService,
      llmService: mockLlmExtractionService,
      normalizeBiomarker: mockNormalizeBiomarkerName,
      uuid: mockUuid,
    );

    when(() => mockUuid.v4()).thenReturn('test-uuid');
    when(() => mockNormalizeBiomarkerName(any())).thenAnswer((invocation) => invocation.positionalArguments[0]);
  });

  group('LLM Extraction Regression Tests', () {
    final tFilePath = 'assets/test_fixtures/sample_report.pdf';
    final tExtractedText = 'Extracted text from sample report';
    final tStructuredData = StructuredData(
      reportDate: DateTime(2023, 1, 1),
      labName: 'Test Lab',
      biomarkers: [
        Biomarker(
          id: 'b1',
          name: 'Glucose',
          value: 95.0,
          unit: 'mg/dL',
          referenceRange: ReferenceRange(min: 70, max: 100),
          measuredAt: DateTime(2023, 1, 1),
        ),
      ],
    );

    test('should correctly extract data from a sample PDF', () async {
      // Arrange
      when(() => mockOcrService.extractText(any()))
          .thenAnswer((_) async => tExtractedText);
      when(() => mockLlmExtractionService.extractBiomarkers(any()))
          .thenAnswer((_) async => Right(tStructuredData));

      // Act
      final result = await usecase(tFilePath);

      // Assert
      expect(result, isA<Right<Failure, Report>>());
      result.fold(
        (failure) => fail('Expected success, got $failure'),
        (report) {
          expect(report.date, tStructuredData.reportDate);
          expect(report.labName, tStructuredData.labName);
          expect(report.biomarkers, hasLength(1));
          expect(report.biomarkers.first.name, 'Glucose');
          expect(report.biomarkers.first.value, 95.0);
        },
      );
    });
  });
}
