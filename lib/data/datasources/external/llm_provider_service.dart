import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

/// Abstract service for specific LLM provider API
abstract class LlmProviderService {
  /// Extracts biomarkers from image using provider's API
  Future<LlmExtractionResult> extractFromImage({
    required String base64Image,
    required String apiKey,
    int timeoutSeconds = 30,
  });

  /// Cancels ongoing request
  void cancel();

  /// Returns the provider type
  LlmProvider get provider;
}
