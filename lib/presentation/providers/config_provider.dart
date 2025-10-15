import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';

/// StateNotifier for managing application configuration state.
///
/// Provides methods to load, save, and update app configuration including
/// dark mode settings and LLM configuration.
class ConfigNotifier extends StateNotifier<AsyncValue<AppConfig>> {
  final ConfigRepository _repository;

  /// Creates a [ConfigNotifier] and immediately loads the config.
  ConfigNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadConfig();
  }

  /// Loads the configuration from the repository.
  Future<void> loadConfig() async {
    state = const AsyncValue.loading();
    final result = await _repository.getConfig();
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (config) => AsyncValue.data(config),
    );
  }

  /// Saves the provided configuration to the repository.
  ///
  /// After saving, automatically reloads the config to ensure state is in sync.
  Future<void> saveConfig(AppConfig config) async {
    final result = await _repository.saveConfig(config);
    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) {
        loadConfig(); // Reload after save
      },
    );
  }

  /// Toggles the dark mode setting.
  ///
  /// Takes the current config and flips the darkModeEnabled flag,
  /// then saves the updated config.
  Future<void> toggleDarkMode() async {
    final current = state;
    if (current is AsyncData<AppConfig>) {
      final updatedConfig = current.value.copyWith(
        darkModeEnabled: !current.value.darkModeEnabled,
      );
      await saveConfig(updatedConfig);
    }
  }

  /// Updates LLM configuration settings.
  ///
  /// All parameters are optional - only provided values will be updated.
  /// After updating, saves the new config to the repository.
  Future<void> updateLlmConfig({
    String? apiKey,
    String? provider,
    bool? useLlmExtraction,
  }) async {
    final current = state;
    if (current is AsyncData<AppConfig>) {
      final updatedConfig = current.value.copyWith(
        llmApiKey: apiKey ?? current.value.llmApiKey,
        llmProvider: provider ?? current.value.llmProvider,
        useLlmExtraction: useLlmExtraction ?? current.value.useLlmExtraction,
      );
      await saveConfig(updatedConfig);
    }
  }
}

/// Provider for application configuration state.
///
/// Uses [ConfigRepository] from dependency injection to manage config state.
final configProvider =
    StateNotifierProvider<ConfigNotifier, AsyncValue<AppConfig>>(
  (ref) => ConfigNotifier(getIt<ConfigRepository>()),
);
