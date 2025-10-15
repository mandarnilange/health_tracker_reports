import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:hive/hive.dart';

part 'app_config_model.g.dart';

@HiveType(typeId: 0)
class AppConfigModel extends AppConfig {
  @override
  @HiveField(0)
  final String? llmApiKey;

  @override
  @HiveField(1)
  final String? llmProvider;

  @override
  @HiveField(2)
  final bool useLlmExtraction;

  @override
  @HiveField(3)
  final bool darkModeEnabled;
  /// Creates an [AppConfigModel] with the given properties
  const AppConfigModel({
    this.llmApiKey,
    this.llmProvider,
    this.useLlmExtraction = false,
    this.darkModeEnabled = false,
  }) : super(
          llmApiKey: llmApiKey,
          llmProvider: llmProvider,
          useLlmExtraction: useLlmExtraction,
          darkModeEnabled: darkModeEnabled,
        );

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

  AppConfig toEntity() {
    return AppConfig(
      llmApiKey: llmApiKey,
      llmProvider: llmProvider,
      useLlmExtraction: useLlmExtraction,
      darkModeEnabled: darkModeEnabled,
    );
  }
}
