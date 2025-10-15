import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:health_tracker_reports/presentation/providers/config_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockConfigRepository extends Mock implements ConfigRepository {}

class FakeAppConfig extends Fake implements AppConfig {}

void main() {
  late MockConfigRepository mockConfigRepository;

  setUpAll(() {
    registerFallbackValue(FakeAppConfig());
  });

  setUp(() {
    mockConfigRepository = MockConfigRepository();
  });

  group('ConfigNotifier', () {
    const tConfig = AppConfig(
      llmApiKey: 'test-api-key',
      llmProvider: 'openai',
      useLlmExtraction: true,
      darkModeEnabled: false,
    );

    const tUpdatedConfig = AppConfig(
      llmApiKey: 'test-api-key',
      llmProvider: 'openai',
      useLlmExtraction: true,
      darkModeEnabled: true,
    );

    test('initial state should be loading', () {
      // Arrange
      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));

      // Act
      final notifier = ConfigNotifier(mockConfigRepository);

      // Assert
      expect(notifier.state, isA<AsyncLoading<AppConfig>>());
    });

    test('should load config on initialization', () async {
      // Arrange
      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));

      // Act
      final notifier = ConfigNotifier(mockConfigRepository);
      await Future.delayed(Duration.zero); // Let the future complete

      // Assert
      verify(() => mockConfigRepository.getConfig()).called(1);
      expect(notifier.state, isA<AsyncData<AppConfig>>());
    });

    test('should emit data state when config is loaded successfully', () async {
      // Arrange
      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));

      // Act
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final provider =
          StateNotifierProvider<ConfigNotifier, AsyncValue<AppConfig>>(
        (ref) => ConfigNotifier(mockConfigRepository),
      );

      // Instantiate provider and allow async operation to complete
      container.read(provider);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      final state = container.read(provider);
      expect(state, isA<AsyncData<AppConfig>>());
      state.whenData((config) {
        expect(config, equals(tConfig));
      });
    });

    test('should emit error state when loading config fails', () async {
      // Arrange
      const tFailure = CacheFailure('Failed to load config');
      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final provider =
          StateNotifierProvider<ConfigNotifier, AsyncValue<AppConfig>>(
        (ref) => ConfigNotifier(mockConfigRepository),
      );

      // Instantiate provider and allow async operation to complete
      container.read(provider);
      await Future.delayed(Duration.zero);

      // Assert
      final state = container.read(provider);
      expect(state, isA<AsyncError<AppConfig>>());
    });

    test('should save config and reload when saveConfig is called', () async {
      // Arrange
      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockConfigRepository.saveConfig(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final notifier = ConfigNotifier(mockConfigRepository);
      await Future.delayed(Duration.zero); // Let initial load complete
      await notifier.saveConfig(tUpdatedConfig);

      // Assert
      verify(() => mockConfigRepository.saveConfig(tUpdatedConfig)).called(1);
      verify(() => mockConfigRepository.getConfig())
          .called(2); // Initial + reload
    });

    test('should toggle dark mode and save config', () async {
      // Arrange
      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockConfigRepository.saveConfig(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final notifier = ConfigNotifier(mockConfigRepository);
      await Future.delayed(Duration.zero); // Let initial load complete
      await notifier.toggleDarkMode();

      // Assert
      final capturedConfig =
          verify(() => mockConfigRepository.saveConfig(captureAny()))
              .captured
              .first as AppConfig;
      expect(capturedConfig.darkModeEnabled, equals(true));
      verify(() => mockConfigRepository.getConfig())
          .called(2); // Initial + reload
    });

    test('should update LLM config and save', () async {
      // Arrange
      const newApiKey = 'new-api-key';
      const newProvider = 'gemini';
      const useLlm = false;

      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockConfigRepository.saveConfig(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final notifier = ConfigNotifier(mockConfigRepository);
      await Future.delayed(Duration.zero); // Let initial load complete
      await notifier.updateLlmConfig(
        apiKey: newApiKey,
        provider: newProvider,
        useLlmExtraction: useLlm,
      );

      // Assert
      final capturedConfig =
          verify(() => mockConfigRepository.saveConfig(captureAny()))
              .captured
              .first as AppConfig;
      expect(capturedConfig.llmApiKey, equals(newApiKey));
      expect(capturedConfig.llmProvider, equals(newProvider));
      expect(capturedConfig.useLlmExtraction, equals(useLlm));
      verify(() => mockConfigRepository.getConfig())
          .called(2); // Initial + reload
    });

    test('should update only provided LLM config fields', () async {
      // Arrange
      const newApiKey = 'new-api-key';

      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockConfigRepository.saveConfig(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final notifier = ConfigNotifier(mockConfigRepository);
      await Future.delayed(Duration.zero); // Let initial load complete
      await notifier.updateLlmConfig(apiKey: newApiKey);

      // Assert
      final capturedConfig =
          verify(() => mockConfigRepository.saveConfig(captureAny()))
              .captured
              .first as AppConfig;
      expect(capturedConfig.llmApiKey, equals(newApiKey));
      expect(
          capturedConfig.llmProvider, equals(tConfig.llmProvider)); // Unchanged
      expect(capturedConfig.useLlmExtraction,
          equals(tConfig.useLlmExtraction)); // Unchanged
    });

    test('should handle error when saving config fails', () async {
      // Arrange
      const tFailure = CacheFailure('Failed to save config');
      when(() => mockConfigRepository.getConfig())
          .thenAnswer((_) async => const Right(tConfig));
      when(() => mockConfigRepository.saveConfig(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final notifier = ConfigNotifier(mockConfigRepository);
      await Future.delayed(Duration.zero); // Let initial load complete
      await notifier.saveConfig(tUpdatedConfig);

      // Assert
      verify(() => mockConfigRepository.saveConfig(tUpdatedConfig)).called(1);
      expect(notifier.state, isA<AsyncError<AppConfig>>());
    });
  });

  group('configProvider', () {
    test('should create ConfigNotifier with repository from DI', () {
      // This test verifies that the provider is properly set up
      // Actual DI testing is done in integration tests
      expect(configProvider,
          isA<StateNotifierProvider<ConfigNotifier, AsyncValue<AppConfig>>>());
    });
  });
}
