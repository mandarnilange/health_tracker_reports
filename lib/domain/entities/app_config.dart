import 'package:equatable/equatable.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

/// Represents the application configuration settings.
///
/// This entity stores user preferences and API configuration for
/// features like LLM extraction and UI theming.
class AppConfig extends Equatable {
  /// API keys for each LLM provider
  final Map<LlmProvider, String> llmApiKeys;

  /// Currently selected LLM provider
  final LlmProvider llmProvider;

  /// Whether dark mode is enabled
  final bool darkModeEnabled;

  /// Creates an [AppConfig] with the given properties.
  ///
  /// All fields have sensible defaults:
  /// - [llmApiKeys] defaults to empty map
  /// - [llmProvider] defaults to Claude
  /// - [darkModeEnabled] defaults to false
  const AppConfig({
    this.llmApiKeys = const {},
    this.llmProvider = LlmProvider.claude,
    this.darkModeEnabled = false,
  });

  /// Checks if LLM extraction is properly configured for the current provider.
  ///
  /// Returns `true` if an API key is provided for the selected provider.
  bool get hasLlmConfigured {
    final apiKey = llmApiKeys[llmProvider];
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Gets the API key for a specific provider
  String? getApiKey(LlmProvider provider) => llmApiKeys[provider];

  /// Creates a copy of this config with the given fields replaced with new values.
  AppConfig copyWith({
    Map<LlmProvider, String>? llmApiKeys,
    LlmProvider? llmProvider,
    bool? darkModeEnabled,
  }) {
    return AppConfig(
      llmApiKeys: llmApiKeys ?? this.llmApiKeys,
      llmProvider: llmProvider ?? this.llmProvider,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }

  @override
  List<Object?> get props => [
        llmApiKeys,
        llmProvider,
        darkModeEnabled,
      ];
}

