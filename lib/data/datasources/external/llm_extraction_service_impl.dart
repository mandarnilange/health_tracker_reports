import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/entities/structured_data.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_provider_service.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_extraction_service.dart';

@LazySingleton(as: LlmExtractionService)
class LlmExtractionServiceImpl implements LlmExtractionService {
  final ConfigRepository configRepository;
  final Map<LlmProvider, LlmProviderService> _providerServices;

  LlmExtractionServiceImpl({
    required this.configRepository,
    @Named('llmProviderServices') required Map<LlmProvider, LlmProviderService> providerServices,
  }) : _providerServices = providerServices;

  @override
  Future<Either<Failure, StructuredData>> extractBiomarkers(String extractedText) async {
    final configEither = await configRepository.getConfig();

    return configEither.fold(
      (failure) => Left(failure),
      (appConfig) async {
        final activeProvider = appConfig.llmProvider;
        final apiKey = appConfig.getApiKey(activeProvider);

        if (apiKey == null || apiKey.isEmpty) {
          return Left(LlmFailure(message: 'API key not configured for $activeProvider'));
        }

        final service = _providerServices[activeProvider];
        if (service == null) {
          return Left(LlmFailure(message: 'No LLM service found for $activeProvider'));
        }

        return await service.extractBiomarkers(extractedText, apiKey);
      },
    );
  }
}
