import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/claude_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/gemini_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_provider_service.dart';
import 'package:health_tracker_reports/data/datasources/external/openai_llm_service.dart';
import 'package:health_tracker_reports/data/repositories/llm_extraction_repository_impl.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockConfigRepository extends Mock implements ConfigRepository {}

class _MockClaudeLlmService extends Mock implements ClaudeLlmService {}

class _MockOpenAiLlmService extends Mock implements OpenAiLlmService {}

class _MockGeminiLlmService extends Mock implements GeminiLlmService {}

void main() {
  late _MockConfigRepository configRepository;
  late _MockClaudeLlmService claudeService;
  late _MockOpenAiLlmService openAiService;
  late _MockGeminiLlmService geminiService;
  late LlmExtractionRepositoryImpl repository;
  const base64Image = 'base64-data';

  setUpAll(() {
    registerFallbackValue(LlmProvider.claude);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    configRepository = _MockConfigRepository();
    claudeService = _MockClaudeLlmService();
    openAiService = _MockOpenAiLlmService();
    geminiService = _MockGeminiLlmService();

    when(() => claudeService.provider).thenReturn(LlmProvider.claude);
    when(() => openAiService.provider).thenReturn(LlmProvider.openai);
    when(() => geminiService.provider).thenReturn(LlmProvider.gemini);

    repository = LlmExtractionRepositoryImpl(
      claudeService: claudeService,
      openAiService: openAiService,
      geminiService: geminiService,
      configRepository: configRepository,
    );
  });

  group('extractFromImage', () {
    final extraction = LlmExtractionResult(
      biomarkers: const [],
      metadata: null,
      confidence: 0.9,
      rawResponse: '{}',
      provider: LlmProvider.claude,
    );

    test('returns ApiKeyMissingFailure when API key missing', () async {
      when(() => configRepository.getConfig())
          .thenAnswer((_) async => const Right(AppConfig()));

      final result =
          await repository.extractFromImage(base64Image: base64Image);

      final left = result as Left<Failure, LlmExtractionResult>;
      expect(left.value, isA<ApiKeyMissingFailure>());
      final failure = left.value as ApiKeyMissingFailure;
      expect(failure.provider, equals('claude'));
      verifyNever(() => claudeService.extractFromImage(
            base64Image: any(named: 'base64Image'),
            apiKey: any(named: 'apiKey'),
            existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
            timeoutSeconds: any(named: 'timeoutSeconds'),
          ));
    });

    test('uses configured provider and forwards parameters on success',
        () async {
      const apiKey = 'claude-key';
      final config = AppConfig(
        llmApiKeys: {LlmProvider.claude: apiKey},
        llmProvider: LlmProvider.claude,
      );
      when(() => configRepository.getConfig())
          .thenAnswer((_) async => Right(config));
      when(
        () => claudeService.extractFromImage(
          base64Image: any(named: 'base64Image'),
          apiKey: any(named: 'apiKey'),
          existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
          timeoutSeconds: any(named: 'timeoutSeconds'),
        ),
      ).thenAnswer((_) async => extraction);

      final result = await repository.extractFromImage(
        base64Image: base64Image,
        existingBiomarkerNames: const ['Hemoglobin'],
      );

      expect(result, Right(extraction));
      verify(
        () => claudeService.extractFromImage(
          base64Image: base64Image,
          apiKey: apiKey,
          existingBiomarkerNames: const ['Hemoglobin'],
          timeoutSeconds: any(named: 'timeoutSeconds'),
        ),
      ).called(1);
    });

    test('overrides provider when explicitly supplied', () async {
      const apiKey = 'openai-key';
      final config = AppConfig(
        llmApiKeys: {LlmProvider.openai: apiKey},
        llmProvider: LlmProvider.claude,
      );
      when(() => configRepository.getConfig())
          .thenAnswer((_) async => Right(config));
      final openAiExtraction = LlmExtractionResult(
        biomarkers: const [],
        metadata: null,
        confidence: 0.9,
        rawResponse: '{}',
        provider: LlmProvider.openai,
      );

      when(
        () => openAiService.extractFromImage(
          base64Image: any(named: 'base64Image'),
          apiKey: any(named: 'apiKey'),
          existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
          timeoutSeconds: any(named: 'timeoutSeconds'),
        ),
      ).thenAnswer((_) async => openAiExtraction);

      final result = await repository.extractFromImage(
        base64Image: base64Image,
        provider: LlmProvider.openai,
      );

      expect(result, Right(openAiExtraction));
      verify(
        () => openAiService.extractFromImage(
          base64Image: base64Image,
          apiKey: apiKey,
          existingBiomarkerNames: const [],
          timeoutSeconds: any(named: 'timeoutSeconds'),
        ),
      ).called(1);
    });

    test('maps DioException with 429 to RateLimitFailure', () async {
      const apiKey = 'claude-key';
      final config = AppConfig(
        llmApiKeys: {LlmProvider.claude: apiKey},
        llmProvider: LlmProvider.claude,
      );
      when(() => configRepository.getConfig())
          .thenAnswer((_) async => Right(config));

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          statusCode: 429,
          requestOptions: RequestOptions(path: '/'),
        ),
        type: DioExceptionType.badResponse,
      );

      when(
        () => claudeService.extractFromImage(
          base64Image: any(named: 'base64Image'),
          apiKey: any(named: 'apiKey'),
          existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
          timeoutSeconds: any(named: 'timeoutSeconds'),
        ),
      ).thenThrow(dioError);

      final result =
          await repository.extractFromImage(base64Image: base64Image);

      expect(result.isLeft(), isTrue);
      final failure = (result as Left<Failure, LlmExtractionResult>).value;
      expect(failure, isA<RateLimitFailure>());
    });

    test('maps parsing errors to InvalidResponseFailure', () async {
      const apiKey = 'claude-key';
      final config = AppConfig(
        llmApiKeys: {LlmProvider.claude: apiKey},
        llmProvider: LlmProvider.claude,
      );
      when(() => configRepository.getConfig())
          .thenAnswer((_) async => Right(config));

      when(
        () => claudeService.extractFromImage(
          base64Image: any(named: 'base64Image'),
          apiKey: any(named: 'apiKey'),
          existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
          timeoutSeconds: any(named: 'timeoutSeconds'),
        ),
      ).thenThrow(Exception('Failed to parse response'));

      final result =
          await repository.extractFromImage(base64Image: base64Image);

      expect(result.isLeft(), isTrue);
      final failure = (result as Left<Failure, LlmExtractionResult>).value;
      expect(failure, isA<InvalidResponseFailure>());
    });

    test('maps unexpected errors to OcrFailure', () async {
      const apiKey = 'claude-key';
      final config = AppConfig(
        llmApiKeys: {LlmProvider.claude: apiKey},
        llmProvider: LlmProvider.claude,
      );
      when(() => configRepository.getConfig())
          .thenAnswer((_) async => Right(config));

      when(
        () => claudeService.extractFromImage(
          base64Image: any(named: 'base64Image'),
          apiKey: any(named: 'apiKey'),
          existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
          timeoutSeconds: any(named: 'timeoutSeconds'),
        ),
      ).thenThrow(StateError('boom'));

      final result =
          await repository.extractFromImage(base64Image: base64Image);

      expect(result.isLeft(), isTrue);
      final failure = (result as Left<Failure, LlmExtractionResult>).value;
      expect(failure, isA<OcrFailure>());
    });
  });
}
