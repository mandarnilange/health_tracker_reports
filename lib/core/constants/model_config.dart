/// Configuration constants for ML models used in the application.
///
/// This class contains static configuration for downloadable ML models
/// including model IDs, expected file sizes, checksums, and download URLs.
class ModelConfig {
  /// Medical NER (Named Entity Recognition) model identifier
  static const String medicalNerModelId = 'medical_ner_v1';

  /// Expected size of the medical NER model in bytes (66MB)
  static const int medicalNerModelSize = 66 * 1024 * 1024; // 66MB

  /// SHA256 checksum for medical NER model integrity verification
  /// Note: In production, this should be the actual SHA256 hash of the model file
  /// Currently set to empty file hash for testing purposes
  static const String medicalNerChecksum =
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

  /// CDN base URL for model downloads
  /// Note: Replace with actual CDN URL in production
  static const String modelCdnBaseUrl = 'https://cdn.example.com/models';

  /// Get the download URL for a specific model
  static String getModelUrl(String modelId) {
    return '$modelCdnBaseUrl/$modelId.tflite';
  }

  /// Map of model IDs to their expected file sizes
  static const Map<String, int> modelSizes = {
    medicalNerModelId: medicalNerModelSize,
  };

  /// Map of model IDs to their SHA256 checksums
  static const Map<String, String> modelChecksums = {
    medicalNerModelId: medicalNerChecksum,
  };

  /// Map of model IDs to their download URLs
  static Map<String, String> get modelUrls => {
        medicalNerModelId: getModelUrl(medicalNerModelId),
      };
}
