import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/claude_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/gemini_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_provider_service.dart';
import 'package:health_tracker_reports/data/datasources/external/openai_llm_service.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:health_tracker_reports/domain/repositories/llm_extraction_repository.dart';

@LazySingleton(as: LlmExtractionRepository)
class LlmExtractionRepositoryImpl implements LlmExtractionRepository {
  final Map<LlmProvider, LlmProviderService> _providerServices;
  final ConfigRepository _configRepository;

  LlmExtractionRepositoryImpl({
    required ClaudeLlmService claudeService,
    required OpenAiLlmService openAiService,
    required GeminiLlmService geminiService,
    required ConfigRepository configRepository,
  })  : _providerServices = {
          LlmProvider.claude: claudeService,
          LlmProvider.openai: openAiService,
          LlmProvider.gemini: geminiService,
        },
        _configRepository = configRepository;

  @override
  Future<Either<Failure, LlmExtractionResult>> extractFromImage({
    required String base64Image,
    LlmProvider? provider,
  }) async {
    try {
      // Get provider and API key from config
      final configResult = await _configRepository.getConfig();
      final config = configResult.fold(
        (failure) => null,
        (config) => config,
      );

      final activeProvider = provider ?? config?.llmProvider ?? LlmProvider.claude;
      final apiKey = config?.getApiKey(activeProvider);

      if (apiKey == null || apiKey.isEmpty) {
        return Left(ApiKeyMissingFailure(activeProvider.name));
      }

      final service = _providerServices[activeProvider]!;
      final result = await service.extractFromImage(
        base64Image: base64Image,
        apiKey: apiKey,
      );

      return Right(result);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return Left(RateLimitFailure(DateTime.now().add(Duration(seconds: 60))));
      } else if (e.response?.statusCode == 401) {
        return Left(const NetworkFailure('Invalid API key'));
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(const NetworkFailure('Request timeout'));
      }
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      if (e.toString().contains('Failed to parse')) {
        return Left(InvalidResponseFailure(message: e.toString()));
      }
      return Left(OcrFailure(message: 'Extraction failed: $e'));
    }
  }

  @override
  LlmProvider getCurrentProvider() {
    final configResult = _configRepository.getConfig();
    return configResult.fold(
      (failure) => LlmProvider.claude,
      (config) => config.llmProvider,
    );
  }

  @override
  void cancel() {
    _providerServices.values.forEach((service) => service.cancel());
  }
}
