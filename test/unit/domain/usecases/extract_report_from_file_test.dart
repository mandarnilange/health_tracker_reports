import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_extraction_service.dart';
import 'package:health_tracker_reports/data/datasources/external/ocr_service.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_service.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file.dart';
import 'package:health_tracker_reports/domain/usecases/normalize_biomarker_name.dart';
import 'package:mocktail/mocktail.dart';

class MockPdfService extends Mock implements PdfService {}
class MockOcrService extends Mock implements OcrService {}
class MockLlmExtractionService extends Mock implements LlmExtractionService {}
class MockNormalizeBiomarkerName extends Mock implements NormalizeBiomarkerName {}

void main() {
  late ExtractReportFromFile usecase;
  late MockPdfService mockPdfService;
  late MockOcrService mockOcrService;
  late MockLlmExtractionService mockLlmExtractionService;
  late MockNormalizeBiomarkerName mockNormalizeBiomarkerName;

  setUp(() {
    mockPdfService = MockPdfService();
    mockOcrService = MockOcrService();
    mockLlmExtractionService = MockLlmExtractionService();
    mockNormalizeBiomarkerName = MockNormalizeBiomarkerName();
    usecase = ExtractReportFromFile(
      pdfService: mockPdfService,
      ocrService: mockOcrService,
      llmService: mockLlmExtractionService,
      normalizeBiomarker: mockNormalizeBiomarkerName,
    );
    registerFallbackValue(ReportModel.fromEntity(Report(
      id: '1',
      date: DateTime.now(),
      labName: 'Test Lab',
      biomarkers: [],
      originalFilePath: '/path/to/file',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )));
  });

  final tPdfPath = 'test.pdf';
  final tImagePath = 'test.png';
  final tImageBytes = Uint8List(0);
  final tOcrText = 'Sample OCR text';
  final tReportModel = ReportModel(
    id: '1',
    date: DateTime.now(),
    labName: 'Test Lab',
    biomarkers: [],
    originalFilePath: tPdfPath,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  final tReport = tReportModel.toEntity();

  test('should extract text from PDF and return a report', () async {
    // Arrange
    when(() => mockPdfService.convertToImages(any())).thenAnswer((_) async => [tImageBytes]);
    when(() => mockOcrService.extractText(any())).thenAnswer((_) async => tOcrText);
    when(() => mockLlmExtractionService.extractBiomarkers(any())).thenAnswer((_) async => tReportModel);
    when(() => mockNormalizeBiomarkerName(any())).thenReturn('Normalized Name');

    // Act
    final result = await usecase(tPdfPath);

    // Assert
    expect(result, Right(tReport));
    verify(() => mockPdfService.convertToImages(tPdfPath)).called(1);
    verify(() => mockOcrService.extractText([tImageBytes])).called(1);
    verify(() => mockLlmExtractionService.extractBiomarkers(tOcrText)).called(1);
  });

  test('should extract text from image and return a report', () async {
    // Arrange
    final file = File(tImagePath);
    await file.writeAsBytes(tImageBytes);
    when(() => mockOcrService.extractText(any())).thenAnswer((_) async => tOcrText);
    when(() => mockLlmExtractionService.extractBiomarkers(any())).thenAnswer((_) async => tReportModel);
    when(() => mockNormalizeBiomarkerName(any())).thenReturn('Normalized Name');

    // Act
    final result = await usecase(tImagePath);

    // Assert
    expect(result, Right(tReport));
    verifyNever(() => mockPdfService.convertToImages(any()));
    verify(() => mockOcrService.extractText(any())).called(1);
    verify(() => mockLlmExtractionService.extractBiomarkers(tOcrText)).called(1);

    // Clean up
    await file.delete();
  });

  test('should return OcrFailure when OCR fails', () async {
    // Arrange
    when(() => mockPdfService.convertToImages(any())).thenAnswer((_) async => [tImageBytes]);
    when(() => mockOcrService.extractText(any())).thenThrow(OcrException('OCR failed'));

    // Act
    final result = await usecase(tPdfPath);

    // Assert
    expect(result, Left(OcrFailure(message: 'OCR failed')));
  });

  test('should return LlmFailure when LLM extraction fails', () async {
    // Arrange
    when(() => mockPdfService.convertToImages(any())).thenAnswer((_) async => [tImageBytes]);
    when(() => mockOcrService.extractText(any())).thenAnswer((_) async => tOcrText);
    when(() => mockLlmExtractionService.extractBiomarkers(any()))
        .thenThrow(LlmException('LLM failed'));

    // Act
    final result = await usecase(tPdfPath);

    // Assert
    expect(result, Left(LlmFailure(message: 'LLM failed')));
  });
}