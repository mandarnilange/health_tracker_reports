import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

/// Abstract service for specific LLM provider API
abstract class LlmProviderService {
  /// Extracts biomarkers from image using provider's API
  ///
  /// [existingBiomarkerNames] List of biomarker names from historical reports
  /// Used by the LLM to normalize extracted biomarker names to match existing ones
  Future<LlmExtractionResult> extractFromImage({
    required String base64Image,
    required String apiKey,
    List<String> existingBiomarkerNames = const [],
    int timeoutSeconds = 30,
  });

  /// Cancels ongoing request
  void cancel();

  /// Returns the provider type
  LlmProvider get provider;
}
