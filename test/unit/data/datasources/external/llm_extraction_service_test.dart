import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/entities/structured_data.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_extraction_service.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_extraction_service_impl.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_provider_service.dart';

class MockConfigRepository extends Mock implements ConfigRepository {}
class MockLlmProviderService extends Mock implements LlmProviderService {}

void main() {
  late LlmExtractionServiceImpl service;
  late MockConfigRepository mockConfigRepository;
  late MockLlmProviderService mockGeminiService;
  late MockLlmProviderService mockOpenAiService;
  late MockLlmProviderService mockClaudeService;

  setUp(() {
    mockConfigRepository = MockConfigRepository();
    mockGeminiService = MockLlmProviderService();
    mockOpenAiService = MockLlmProviderService();
    mockClaudeService = MockLlmProviderService();

    when(() => mockGeminiService.provider).thenReturn(LlmProvider.gemini);
    when(() => mockOpenAiService.provider).thenReturn(LlmProvider.openai);
    when(() => mockClaudeService.provider).thenReturn(LlmProvider.claude);

    service = LlmExtractionServiceImpl(
      configRepository: mockConfigRepository,
      providerServices: {
        LlmProvider.gemini: mockGeminiService,
        LlmProvider.openai: mockOpenAiService,
        LlmProvider.claude: mockClaudeService,
      },
    );
  });

  final tExtractedText = 'Some extracted text';
  final tStructuredData = StructuredData(
    reportDate: DateTime(2023, 1, 1),
    labName: 'Test Lab',
    biomarkers: [],
  );

  group('LlmExtractionServiceImpl', () {
    test('should extract biomarkers using the configured Gemini provider', () async {
      // Arrange
      final appConfig = AppConfig(
        llmApiKeys: {LlmProvider.gemini: 'gemini_key'},
        llmProvider: LlmProvider.gemini,
      );
      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => Right(appConfig));
      when(() => mockGeminiService.extractBiomarkers(any(), any()))
          .thenAnswer((_) async => Right(tStructuredData));

      // Act
      final result = await service.extractBiomarkers(tExtractedText);

      // Assert
      expect(result, Right(tStructuredData));
      verify(() => mockGeminiService.extractBiomarkers(tExtractedText, 'gemini_key')).called(1);
    });

    test('should return LlmFailure if API key is missing', () async {
      // Arrange
      final appConfig = AppConfig(
        llmApiKeys: {},
        llmProvider: LlmProvider.gemini,
      );
      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => Right(appConfig));

      // Act
      final result = await service.extractBiomarkers(tExtractedText);

      // Assert
      expect(result, Left(LlmFailure(message: 'API key not configured for LlmProvider.gemini')));
      verifyNever(() => mockGeminiService.extractBiomarkers(any(), any()));
    });

    test('should return LlmFailure if LLM service fails', () async {
      // Arrange
      final appConfig = AppConfig(
        llmApiKeys: {LlmProvider.gemini: 'gemini_key'},
        llmProvider: LlmProvider.gemini,
      );
      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => Right(appConfig));
      when(() => mockGeminiService.extractBiomarkers(any(), any()))
          .thenAnswer((_) async => Left(LlmFailure(message: 'Gemini error')));

      // Act
      final result = await service.extractBiomarkers(tExtractedText);

      // Assert
      expect(result, Left(LlmFailure(message: 'Gemini error')));
      verify(() => mockGeminiService.extractBiomarkers(tExtractedText, 'gemini_key')).called(1);
    });
  });
}
