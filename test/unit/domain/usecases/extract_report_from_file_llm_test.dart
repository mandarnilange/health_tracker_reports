import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/services/image_processing_service.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/repositories/llm_extraction_repository.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file_llm.dart';
import 'package:mocktail/mocktail.dart';

class _MockLlmRepository extends Mock implements LlmExtractionRepository {}

class _MockImageProcessingService extends Mock
    implements ImageProcessingService {}

class _MockReportRepository extends Mock implements ReportRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(LlmProvider.claude);
    registerFallbackValue(<String>[]);
  });
  late _MockLlmRepository llmRepository;
  late _MockImageProcessingService imageService;
  late _MockReportRepository reportRepository;
  late ExtractReportFromFileLlm usecase;

  const pdfPath = '/tmp/report.pdf';
  const imagePath = '/tmp/report.png';
  const base64Page = 'base64-page';
  const compressedPage = 'compressed-page';

  LlmExtractionResult buildExtraction({
    List<ExtractedBiomarker>? biomarkers,
    ExtractedMetadata? metadata,
  }) {
    final defaultMetadata = ExtractedMetadata(
      patientName: 'John Doe',
      reportDate: DateTime(2025, 1, 15),
      labName: 'Quest Diagnostics',
    );
    final defaultBiomarkers = biomarkers ??
        const [
          ExtractedBiomarker(
            name: 'Hemoglobin',
            value: '13.5',
            unit: 'g/dL',
            referenceRange: '12-16',
          ),
        ];

    return LlmExtractionResult(
      biomarkers: defaultBiomarkers,
      metadata: metadata ?? defaultMetadata,
      confidence: 0.9,
      rawResponse: '{}',
      provider: LlmProvider.claude,
    );
  }

  setUp(() {
    llmRepository = _MockLlmRepository();
    imageService = _MockImageProcessingService();
    reportRepository = _MockReportRepository();
    usecase = ExtractReportFromFileLlm(
      llmRepository: llmRepository,
      imageService: imageService,
      reportRepository: reportRepository,
    );

    when(() => reportRepository.getDistinctBiomarkerNames())
        .thenAnswer((_) async => const Right(<String>[]));
    when(() => imageService.compressImageBase64(any()))
        .thenAnswer((invocation) async => invocation.positionalArguments.first);
  });

  group('call', () {
    test('converts PDF to images before extraction', () async {
      when(() => imageService.pdfToBase64Images(pdfPath))
          .thenAnswer((_) async => [base64Page]);
      when(
        () => llmRepository.extractFromImage(
          base64Image: any(named: 'base64Image'),
          existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
          provider: any(named: 'provider'),
        ),
      ).thenAnswer((_) async => Right(buildExtraction()));

      final result = await usecase(pdfPath);

      expect(result.isRight(), isTrue);
      verify(() => imageService.pdfToBase64Images(pdfPath)).called(1);
      verifyNever(() => imageService.imageToBase64(any()));
    });

    test('uses imageToBase64 for non-PDF files', () async {
      when(() => imageService.imageToBase64(imagePath))
          .thenAnswer((_) async => base64Page);
      when(
        () => llmRepository.extractFromImage(
          base64Image: any(named: 'base64Image'),
          existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
          provider: any(named: 'provider'),
        ),
      ).thenAnswer((_) async => Right(buildExtraction()));

      await usecase(imagePath);

      verify(() => imageService.imageToBase64(imagePath)).called(1);
    });

    test('returns validation failure when no images extracted', () async {
      when(() => imageService.pdfToBase64Images(pdfPath))
          .thenAnswer((_) async => <String>[]);

      final result = await usecase(pdfPath);

      expect(result.isLeft(), isTrue);
      final failure = (result as Left<Failure, Report>).value;
      expect(failure, isA<ValidationFailure>());
    });

    test('returns last LLM failure when extraction fails for all pages',
        () async {
      when(() => imageService.pdfToBase64Images(pdfPath))
          .thenAnswer((_) async => [base64Page]);
      when(() => imageService.compressImageBase64(base64Page))
          .thenAnswer((_) async => compressedPage);
      final failure = LlmFailure(message: 'LLM down');
      when(
        () => llmRepository.extractFromImage(
          base64Image: compressedPage,
          existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
          provider: any(named: 'provider'),
        ),
      ).thenAnswer((_) async => Left(failure));

      final result = await usecase(pdfPath);

      expect(result, Left(failure));
    });

    test('skips non-numeric biomarker values and returns validation failure',
        () async {
      when(() => imageService.imageToBase64(imagePath))
          .thenAnswer((_) async => base64Page);
      when(
        () => llmRepository.extractFromImage(
          base64Image: base64Page,
          existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
          provider: any(named: 'provider'),
        ),
      ).thenAnswer(
        (_) async => Right(
          buildExtraction(
            biomarkers: const [
              ExtractedBiomarker(
                name: 'Hemoglobin',
                value: 'not-a-number',
                unit: 'g/dL',
              ),
            ],
          ),
        ),
      );

      final result = await usecase(imagePath);

      expect(result.isLeft(), isTrue);
      final failure = (result as Left<Failure, Report>).value;
      expect(failure, isA<ValidationFailure>());
    });

    test('parses reference ranges and metadata into report', () async {
      when(() => imageService.imageToBase64(imagePath))
          .thenAnswer((_) async => base64Page);
      when(() => imageService.compressImageBase64(base64Page))
          .thenAnswer((_) async => compressedPage);
      final extraction = buildExtraction();
      when(
        () => llmRepository.extractFromImage(
          base64Image: compressedPage,
          existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
          provider: any(named: 'provider'),
        ),
      ).thenAnswer((_) async => Right(extraction));

      final result = await usecase(imagePath);

      expect(result.isRight(), isTrue);
      final report = (result as Right<Failure, Report>).value;
      expect(report.labName, extraction.metadata?.labName);
      expect(report.notes, 'Patient: ${extraction.metadata?.patientName}');
      expect(report.biomarkers.first.referenceRange.min, 12);
      expect(report.biomarkers.first.referenceRange.max, 16);
    });

    test('handles "<" reference range gracefully', () async {
      when(() => imageService.imageToBase64(imagePath))
          .thenAnswer((_) async => base64Page);
      final extraction = buildExtraction(
        biomarkers: const [
          ExtractedBiomarker(
            name: 'Triglycerides',
            value: '150',
            unit: 'mg/dL',
            referenceRange: '<200',
          ),
        ],
      );
      when(
        () => llmRepository.extractFromImage(
          base64Image: any(named: 'base64Image'),
          existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
          provider: any(named: 'provider'),
        ),
      ).thenAnswer((_) async => Right(extraction));

      final result = await usecase(imagePath);

      expect(result.isRight(), isTrue);
      final biomarker = (result as Right<Failure, Report>)
          .value
          .biomarkers
          .firstWhere((b) => b.name == 'Triglycerides');
      expect(biomarker.referenceRange.max, 200);
    });
  });
}
