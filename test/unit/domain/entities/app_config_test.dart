import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';

void main() {
  group('AppConfig', () {
    const tLlmApiKey = 'test-api-key-12345';
    const tLlmProvider = 'openai';

    test('should create AppConfig with all fields', () {
      // Act
      const config = AppConfig(
        llmApiKey: tLlmApiKey,
        llmProvider: tLlmProvider,
        useLlmExtraction: true,
        darkModeEnabled: true,
      );

      // Assert
      expect(config.llmApiKey, tLlmApiKey);
      expect(config.llmProvider, tLlmProvider);
      expect(config.useLlmExtraction, true);
      expect(config.darkModeEnabled, true);
    });

    test('should create AppConfig with minimal fields (nulls)', () {
      // Act
      const config = AppConfig(
        llmApiKey: null,
        llmProvider: null,
        useLlmExtraction: false,
        darkModeEnabled: false,
      );

      // Assert
      expect(config.llmApiKey, isNull);
      expect(config.llmProvider, isNull);
      expect(config.useLlmExtraction, false);
      expect(config.darkModeEnabled, false);
    });

    test('should create AppConfig with default values', () {
      // Act
      const config = AppConfig();

      // Assert
      expect(config.llmApiKey, isNull);
      expect(config.llmProvider, isNull);
      expect(config.useLlmExtraction, false);
      expect(config.darkModeEnabled, false);
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      const config1 = AppConfig(
        llmApiKey: tLlmApiKey,
        llmProvider: tLlmProvider,
        useLlmExtraction: true,
        darkModeEnabled: true,
      );
      const config2 = AppConfig(
        llmApiKey: tLlmApiKey,
        llmProvider: tLlmProvider,
        useLlmExtraction: true,
        darkModeEnabled: true,
      );

      // Assert
      expect(config1, config2);
    });

    test('should not be equal when properties are different', () {
      // Arrange
      const config1 = AppConfig(
        llmApiKey: tLlmApiKey,
        llmProvider: tLlmProvider,
        useLlmExtraction: true,
        darkModeEnabled: true,
      );
      const config2 = AppConfig(
        llmApiKey: 'different-key',
        llmProvider: tLlmProvider,
        useLlmExtraction: true,
        darkModeEnabled: true,
      );

      // Assert
      expect(config1, isNot(config2));
    });

    test('should be equal when both have null values', () {
      // Arrange
      const config1 = AppConfig();
      const config2 = AppConfig();

      // Assert
      expect(config1, config2);
    });

    group('copyWith', () {
      const originalConfig = AppConfig(
        llmApiKey: tLlmApiKey,
        llmProvider: tLlmProvider,
        useLlmExtraction: true,
        darkModeEnabled: true,
      );

      test('should return a copy with updated llmApiKey', () {
        // Act
        final updated = originalConfig.copyWith(llmApiKey: 'new-key');

        // Assert
        expect(updated.llmApiKey, 'new-key');
        expect(updated.llmProvider, tLlmProvider);
        expect(updated.useLlmExtraction, true);
        expect(updated.darkModeEnabled, true);
      });

      test('should return a copy with updated llmProvider', () {
        // Act
        final updated = originalConfig.copyWith(llmProvider: 'gemini');

        // Assert
        expect(updated.llmApiKey, tLlmApiKey);
        expect(updated.llmProvider, 'gemini');
        expect(updated.useLlmExtraction, true);
        expect(updated.darkModeEnabled, true);
      });

      test('should return a copy with updated useLlmExtraction', () {
        // Act
        final updated = originalConfig.copyWith(useLlmExtraction: false);

        // Assert
        expect(updated.llmApiKey, tLlmApiKey);
        expect(updated.llmProvider, tLlmProvider);
        expect(updated.useLlmExtraction, false);
        expect(updated.darkModeEnabled, true);
      });

      test('should return a copy with updated darkModeEnabled', () {
        // Act
        final updated = originalConfig.copyWith(darkModeEnabled: false);

        // Assert
        expect(updated.llmApiKey, tLlmApiKey);
        expect(updated.llmProvider, tLlmProvider);
        expect(updated.useLlmExtraction, true);
        expect(updated.darkModeEnabled, false);
      });

      test('should return exact copy when no parameters provided', () {
        // Act
        final copy = originalConfig.copyWith();

        // Assert
        expect(copy, originalConfig);
      });

      test('should return a copy with multiple fields updated', () {
        // Act
        final updated = originalConfig.copyWith(
          llmApiKey: 'updated-key',
          useLlmExtraction: false,
          darkModeEnabled: false,
        );

        // Assert
        expect(updated.llmApiKey, 'updated-key');
        expect(updated.llmProvider, tLlmProvider);
        expect(updated.useLlmExtraction, false);
        expect(updated.darkModeEnabled, false);
      });
    });

    group('hasLlmConfigured getter', () {
      test('should return true when llmApiKey is set', () {
        // Arrange
        const config = AppConfig(
          llmApiKey: tLlmApiKey,
          llmProvider: tLlmProvider,
        );

        // Assert
        expect(config.hasLlmConfigured, true);
      });

      test('should return false when llmApiKey is null', () {
        // Arrange
        const config = AppConfig(
          llmApiKey: null,
          llmProvider: tLlmProvider,
        );

        // Assert
        expect(config.hasLlmConfigured, false);
      });

      test('should return false when llmApiKey is empty string', () {
        // Arrange
        const config = AppConfig(
          llmApiKey: '',
          llmProvider: tLlmProvider,
        );

        // Assert
        expect(config.hasLlmConfigured, false);
      });

      test('should return false when both llmApiKey and llmProvider are null',
          () {
        // Arrange
        const config = AppConfig();

        // Assert
        expect(config.hasLlmConfigured, false);
      });
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const config = AppConfig(
        llmApiKey: tLlmApiKey,
        llmProvider: tLlmProvider,
        useLlmExtraction: true,
        darkModeEnabled: true,
      );

      // Assert
      expect(
        config.props,
        [tLlmApiKey, tLlmProvider, true, true],
      );
    });
  });
}
