import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/claude_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/gemini_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/openai_llm_service.dart';
import 'package:health_tracker_reports/data/repositories/llm_extraction_repository_impl.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockConfigRepository extends Mock implements ConfigRepository {}

class _MockClaudeService extends Mock implements ClaudeLlmService {}

class _MockOpenAiService extends Mock implements OpenAiLlmService {}

class _MockGeminiService extends Mock implements GeminiLlmService {}

void main() {
  late _MockConfigRepository configRepository;
  late _MockClaudeService claudeService;
  late _MockOpenAiService openAiService;
  late _MockGeminiService geminiService;
  late LlmExtractionRepositoryImpl repository;

  const config = AppConfig(
    llmProvider: LlmProvider.claude,
    llmApiKeys: {LlmProvider.claude: 'key-claude'},
  );

  const extractionResult = LlmExtractionResult(
    biomarkers: [],
    metadata: ExtractedMetadata(),
    confidence: 0.9,
    provider: LlmProvider.claude,
  );

  setUp(() {
    registerFallbackValue(const ExtractedMetadata());
    configRepository = _MockConfigRepository();
    claudeService = _MockClaudeService();
    openAiService = _MockOpenAiService();
    geminiService = _MockGeminiService();

    repository = LlmExtractionRepositoryImpl(
      claudeService: claudeService,
      openAiService: openAiService,
      geminiService: geminiService,
      configRepository: configRepository,
    );
  });

  test('returns ApiKeyMissingFailure when API key absent', () async {
    when(() => configRepository.getConfig()).thenAnswer(
      (_) async => const Right(AppConfig(llmApiKeys: {})),
    );

    final result = await repository.extractFromImage(base64Image: 'image');

    expect(result.isLeft(), isTrue);
    final failure = result.fold((f) => f, (_) => null);
    expect(failure, isA<ApiKeyMissingFailure>());
  });

  test('delegates to provider service on success', () async {
    when(() => configRepository.getConfig()).thenAnswer(
      (_) async => const Right(config),
    );
    when(
      () => claudeService.extractFromImage(
        base64Image: any(named: 'base64Image'),
        apiKey: any(named: 'apiKey'),
        existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
      ),
    ).thenAnswer((_) async => extractionResult);

    final result = await repository.extractFromImage(
      base64Image: 'img',
      existingBiomarkerNames: const ['Hb'],
    );

    expect(result, const Right<Failure, LlmExtractionResult>(extractionResult));
    verify(() => claudeService.extractFromImage(
          base64Image: 'img',
          apiKey: 'key-claude',
          existingBiomarkerNames: const ['Hb'],
        )).called(1);
  });

  test('maps 429 DioException to RateLimitFailure', () async {
    when(() => configRepository.getConfig()).thenAnswer(
      (_) async => const Right(config),
    );
    when(
      () => claudeService.extractFromImage(
        base64Image: any(named: 'base64Image'),
        apiKey: any(named: 'apiKey'),
        existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/extract'),
        response: Response(statusCode: 429, requestOptions: RequestOptions(path: '/extract')),
      ),
    );

    final result = await repository.extractFromImage(base64Image: 'img');

    expect(result.isLeft(), isTrue);
    expect(result.fold((f) => f, (_) => null), isA<RateLimitFailure>());
  });

  test('maps 401 DioException to NetworkFailure', () async {
    when(() => configRepository.getConfig()).thenAnswer(
      (_) async => const Right(config),
    );
    when(
      () => claudeService.extractFromImage(
        base64Image: any(named: 'base64Image'),
        apiKey: any(named: 'apiKey'),
        existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/extract'),
        response: Response(statusCode: 401, requestOptions: RequestOptions(path: '/extract')),
      ),
    );

    final result = await repository.extractFromImage(base64Image: 'img');

    expect(result.isLeft(), isTrue);
    expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
  });

  test('maps timeout DioException to NetworkFailure with timeout message', () async {
    when(() => configRepository.getConfig()).thenAnswer(
      (_) async => const Right(config),
    );
    when(
      () => claudeService.extractFromImage(
        base64Image: any(named: 'base64Image'),
        apiKey: any(named: 'apiKey'),
        existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/extract'),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    final result = await repository.extractFromImage(base64Image: 'img');

    expect(result.isLeft(), isTrue);
    final failure = result.fold((f) => f, (_) => null) as NetworkFailure;
    expect(failure.message, contains('timeout'));
  });

  test('maps parse errors to InvalidResponseFailure', () async {
    when(() => configRepository.getConfig()).thenAnswer(
      (_) async => const Right(config),
    );
    when(
      () => claudeService.extractFromImage(
        base64Image: any(named: 'base64Image'),
        apiKey: any(named: 'apiKey'),
        existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
      ),
    ).thenThrow(Exception('Failed to parse response'));

    final result = await repository.extractFromImage(base64Image: 'img');

    expect(result.isLeft(), isTrue);
    expect(result.fold((f) => f, (_) => null), isA<InvalidResponseFailure>());
  });

  test('maps unexpected errors to OcrFailure', () async {
    when(() => configRepository.getConfig()).thenAnswer(
      (_) async => const Right(config),
    );
    when(
      () => claudeService.extractFromImage(
        base64Image: any(named: 'base64Image'),
        apiKey: any(named: 'apiKey'),
        existingBiomarkerNames: any(named: 'existingBiomarkerNames'),
      ),
    ).thenThrow(Exception('something else'));

    final result = await repository.extractFromImage(base64Image: 'img');

    expect(result.isLeft(), isTrue);
    expect(result.fold((f) => f, (_) => null), isA<OcrFailure>());
  });

  test('cancel forwards to all provider services', () {
    repository.cancel();

    verify(() => claudeService.cancel()).called(1);
    verify(() => openAiService.cancel()).called(1);
    verify(() => geminiService.cancel()).called(1);
  });
}
