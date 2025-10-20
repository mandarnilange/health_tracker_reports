import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

/// Abstract service for specific LLM provider API
abstract class LlmProviderService {
  /// Extracts biomarkers from a base64-encoded image using the provider API.
  ///
  /// [existingBiomarkerNames] contains previously seen biomarker names so the
  /// LLM can normalize aliases to match historical data.
  Future<LlmExtractionResult> extractFromImage({
    required String base64Image,
    required String apiKey,
    List<String> existingBiomarkerNames = const [],
    int timeoutSeconds = 30,
  });

  /// Cancels the in-flight extraction request if supported.
  void cancel();

  /// Provider identifier (Claude/OpenAI/Gemini).
  LlmProvider get provider;
}
