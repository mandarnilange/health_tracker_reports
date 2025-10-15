import 'package:health_tracker_reports/domain/entities/app_config.dart';

/// Data model for [AppConfig] entity with JSON serialization support.
///
/// Extends [AppConfig] to inherit domain logic while adding
/// serialization capabilities for data layer operations.
class AppConfigModel extends AppConfig {
  /// Creates an [AppConfigModel] with the given properties
  const AppConfigModel({
    super.llmApiKey,
    super.llmProvider,
    super.useLlmExtraction = false,
    super.darkModeEnabled = false,
  });

  /// Creates an [AppConfigModel] from an [AppConfig] entity
  factory AppConfigModel.fromEntity(AppConfig entity) {
    return AppConfigModel(
      llmApiKey: entity.llmApiKey,
      llmProvider: entity.llmProvider,
      useLlmExtraction: entity.useLlmExtraction,
      darkModeEnabled: entity.darkModeEnabled,
    );
  }

  /// Creates an [AppConfigModel] from a JSON map
  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    return AppConfigModel(
      llmApiKey: json['llmApiKey'] as String?,
      llmProvider: json['llmProvider'] as String?,
      useLlmExtraction: json['useLlmExtraction'] as bool? ?? false,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'llmApiKey': llmApiKey,
      'llmProvider': llmProvider,
      'useLlmExtraction': useLlmExtraction,
      'darkModeEnabled': darkModeEnabled,
    };
  }
}
