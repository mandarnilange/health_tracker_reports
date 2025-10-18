import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:hive/hive.dart';

part 'app_config_model.g.dart';

@HiveType(typeId: 0)
class AppConfigModel extends AppConfig {
  @override
  @HiveField(0)
  final Map<LlmProvider, String> llmApiKeys;

  @override
  @HiveField(1)
  final LlmProvider llmProvider;

  @override
  @HiveField(2)
  final bool darkModeEnabled;

  /// Creates an [AppConfigModel] with the given properties
  const AppConfigModel({
    this.llmApiKeys = const {},
    this.llmProvider = LlmProvider.claude,
    this.darkModeEnabled = false,
  }) : super(
          llmApiKeys: llmApiKeys,
          llmProvider: llmProvider,
          darkModeEnabled: darkModeEnabled,
        );

  /// Creates an [AppConfigModel] from an [AppConfig] entity
  factory AppConfigModel.fromEntity(AppConfig entity) {
    return AppConfigModel(
      llmApiKeys: entity.llmApiKeys,
      llmProvider: entity.llmProvider,
      darkModeEnabled: entity.darkModeEnabled,
    );
  }

  /// Creates an [AppConfigModel] from a JSON map
  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    // Parse llmApiKeys map
    final apiKeysMap = json['llmApiKeys'] as Map<String, dynamic>? ?? {};
    final llmApiKeys = <LlmProvider, String>{};
    apiKeysMap.forEach((key, value) {
      final provider = LlmProvider.values.firstWhere(
        (p) => p.name == key,
        orElse: () => LlmProvider.claude,
      );
      llmApiKeys[provider] = value as String;
    });

    // Parse llmProvider
    final providerString = json['llmProvider'] as String? ?? 'claude';
    final llmProvider = LlmProvider.values.firstWhere(
      (p) => p.name == providerString,
      orElse: () => LlmProvider.claude,
    );

    return AppConfigModel(
      llmApiKeys: llmApiKeys,
      llmProvider: llmProvider,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    final apiKeysMap = <String, String>{};
    llmApiKeys.forEach((key, value) {
      apiKeysMap[key.name] = value;
    });

    return {
      'llmApiKeys': apiKeysMap,
      'llmProvider': llmProvider.name,
      'darkModeEnabled': darkModeEnabled,
    };
  }

  AppConfig toEntity() {
    return AppConfig(
      llmApiKeys: llmApiKeys,
      llmProvider: llmProvider,
      darkModeEnabled: darkModeEnabled,
    );
  }
}
