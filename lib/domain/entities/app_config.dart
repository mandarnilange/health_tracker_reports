import 'package:equatable/equatable.dart';

/// Represents the application configuration settings.
///
/// This entity stores user preferences and API configuration for
/// features like LLM extraction and UI theming.
class AppConfig extends Equatable {
  /// API key for LLM service (OpenAI, Gemini, etc.)
  final String? llmApiKey;

  /// LLM provider identifier (e.g., 'openai', 'gemini')
  final String? llmProvider;

  /// Whether to use LLM for enhanced biomarker extraction
  final bool useLlmExtraction;

  /// Whether dark mode is enabled
  final bool darkModeEnabled;

  /// Creates an [AppConfig] with the given properties.
  ///
  /// All fields are optional with sensible defaults:
  /// - [llmApiKey] and [llmProvider] default to null
  /// - [useLlmExtraction] defaults to false
  /// - [darkModeEnabled] defaults to false
  const AppConfig({
    this.llmApiKey,
    this.llmProvider,
    this.useLlmExtraction = false,
    this.darkModeEnabled = false,
  });

  /// Checks if LLM extraction is properly configured.
  ///
  /// Returns `true` if an API key is provided and not empty.
  bool get hasLlmConfigured {
    return llmApiKey != null && llmApiKey!.isNotEmpty;
  }

  /// Creates a copy of this config with the given fields replaced with new values.
  AppConfig copyWith({
    String? llmApiKey,
    String? llmProvider,
    bool? useLlmExtraction,
    bool? darkModeEnabled,
  }) {
    return AppConfig(
      llmApiKey: llmApiKey ?? this.llmApiKey,
      llmProvider: llmProvider ?? this.llmProvider,
      useLlmExtraction: useLlmExtraction ?? this.useLlmExtraction,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }

  @override
  List<Object?> get props => [
        llmApiKey,
        llmProvider,
        useLlmExtraction,
        darkModeEnabled,
      ];
}
