import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';

void main() {
  group('AppConfigModel', () {
    const tLlmApiKey = 'test-api-key-123';
    const tLlmProvider = 'openai';
    const tUseLlmExtraction = true;
    const tDarkModeEnabled = true;

    const tAppConfig = AppConfig(
      llmApiKey: tLlmApiKey,
      llmProvider: tLlmProvider,
      useLlmExtraction: tUseLlmExtraction,
      darkModeEnabled: tDarkModeEnabled,
    );

    const tAppConfigModel = AppConfigModel(
      llmApiKey: tLlmApiKey,
      llmProvider: tLlmProvider,
      useLlmExtraction: tUseLlmExtraction,
      darkModeEnabled: tDarkModeEnabled,
    );

    final tJson = {
      'llmApiKey': tLlmApiKey,
      'llmProvider': tLlmProvider,
      'useLlmExtraction': tUseLlmExtraction,
      'darkModeEnabled': tDarkModeEnabled,
    };

    group('fromEntity', () {
      test('should create AppConfigModel from AppConfig entity', () {
        // Act
        final result = AppConfigModel.fromEntity(tAppConfig);

        // Assert
        expect(result, isA<AppConfigModel>());
        expect(result.llmApiKey, tAppConfig.llmApiKey);
        expect(result.llmProvider, tAppConfig.llmProvider);
        expect(result.useLlmExtraction, tAppConfig.useLlmExtraction);
        expect(result.darkModeEnabled, tAppConfig.darkModeEnabled);
      });

      test('should create model that equals another model with same values', () {
        // Act
        final result = AppConfigModel.fromEntity(tAppConfig);

        // Assert
        expect(result, tAppConfigModel);
      });

      test('should handle config with null llmApiKey', () {
        // Arrange
        const configWithNullKey = AppConfig(
          llmApiKey: null,
          llmProvider: tLlmProvider,
          useLlmExtraction: false,
          darkModeEnabled: false,
        );

        // Act
        final result = AppConfigModel.fromEntity(configWithNullKey);

        // Assert
        expect(result.llmApiKey, isNull);
        expect(result.llmProvider, tLlmProvider);
      });

      test('should handle config with null llmProvider', () {
        // Arrange
        const configWithNullProvider = AppConfig(
          llmApiKey: tLlmApiKey,
          llmProvider: null,
          useLlmExtraction: true,
          darkModeEnabled: true,
        );

        // Act
        final result = AppConfigModel.fromEntity(configWithNullProvider);

        // Assert
        expect(result.llmApiKey, tLlmApiKey);
        expect(result.llmProvider, isNull);
      });

      test('should handle config with default values', () {
        // Arrange
        const configWithDefaults = AppConfig();

        // Act
        final result = AppConfigModel.fromEntity(configWithDefaults);

        // Assert
        expect(result.llmApiKey, isNull);
        expect(result.llmProvider, isNull);
        expect(result.useLlmExtraction, false);
        expect(result.darkModeEnabled, false);
      });

      test('should inherit hasLlmConfigured getter from AppConfig', () {
        // Act
        final result = AppConfigModel.fromEntity(tAppConfig);

        // Assert
        expect(result.hasLlmConfigured, true);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Act
        final result = tAppConfigModel.toJson();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result, tJson);
      });

      test('should return JSON with correct keys', () {
        // Act
        final result = tAppConfigModel.toJson();

        // Assert
        expect(result.containsKey('llmApiKey'), true);
        expect(result.containsKey('llmProvider'), true);
        expect(result.containsKey('useLlmExtraction'), true);
        expect(result.containsKey('darkModeEnabled'), true);
        expect(result.keys.length, 4);
      });

      test('should handle null llmApiKey', () {
        // Arrange
        const modelWithNullKey = AppConfigModel(
          llmApiKey: null,
          llmProvider: tLlmProvider,
          useLlmExtraction: false,
          darkModeEnabled: false,
        );

        // Act
        final result = modelWithNullKey.toJson();

        // Assert
        expect(result['llmApiKey'], isNull);
        expect(result['llmProvider'], tLlmProvider);
      });

      test('should handle null llmProvider', () {
        // Arrange
        const modelWithNullProvider = AppConfigModel(
          llmApiKey: tLlmApiKey,
          llmProvider: null,
          useLlmExtraction: true,
          darkModeEnabled: true,
        );

        // Act
        final result = modelWithNullProvider.toJson();

        // Assert
        expect(result['llmApiKey'], tLlmApiKey);
        expect(result['llmProvider'], isNull);
      });

      test('should handle both nullable fields as null', () {
        // Arrange
        const modelWithAllNull = AppConfigModel(
          llmApiKey: null,
          llmProvider: null,
          useLlmExtraction: false,
          darkModeEnabled: false,
        );

        // Act
        final result = modelWithAllNull.toJson();

        // Assert
        expect(result['llmApiKey'], isNull);
        expect(result['llmProvider'], isNull);
        expect(result['useLlmExtraction'], false);
        expect(result['darkModeEnabled'], false);
      });

      test('should preserve boolean values', () {
        // Arrange
        const modelWithFalseValues = AppConfigModel(
          llmApiKey: tLlmApiKey,
          llmProvider: tLlmProvider,
          useLlmExtraction: false,
          darkModeEnabled: false,
        );

        // Act
        final result = modelWithFalseValues.toJson();

        // Assert
        expect(result['useLlmExtraction'], false);
        expect(result['darkModeEnabled'], false);
      });
    });

    group('fromJson', () {
      test('should return a valid AppConfigModel from JSON', () {
        // Act
        final result = AppConfigModel.fromJson(tJson);

        // Assert
        expect(result, isA<AppConfigModel>());
        expect(result, tAppConfigModel);
      });

      test('should correctly parse all fields from JSON', () {
        // Act
        final result = AppConfigModel.fromJson(tJson);

        // Assert
        expect(result.llmApiKey, tLlmApiKey);
        expect(result.llmProvider, tLlmProvider);
        expect(result.useLlmExtraction, tUseLlmExtraction);
        expect(result.darkModeEnabled, tDarkModeEnabled);
      });

      test('should handle null llmApiKey from JSON', () {
        // Arrange
        final jsonWithNullKey = {
          ...tJson,
          'llmApiKey': null,
        };

        // Act
        final result = AppConfigModel.fromJson(jsonWithNullKey);

        // Assert
        expect(result.llmApiKey, isNull);
        expect(result.llmProvider, tLlmProvider);
      });

      test('should handle null llmProvider from JSON', () {
        // Arrange
        final jsonWithNullProvider = {
          ...tJson,
          'llmProvider': null,
        };

        // Act
        final result = AppConfigModel.fromJson(jsonWithNullProvider);

        // Assert
        expect(result.llmApiKey, tLlmApiKey);
        expect(result.llmProvider, isNull);
      });

      test('should handle both nullable fields as null from JSON', () {
        // Arrange
        final jsonWithAllNull = {
          'llmApiKey': null,
          'llmProvider': null,
          'useLlmExtraction': false,
          'darkModeEnabled': false,
        };

        // Act
        final result = AppConfigModel.fromJson(jsonWithAllNull);

        // Assert
        expect(result.llmApiKey, isNull);
        expect(result.llmProvider, isNull);
        expect(result.useLlmExtraction, false);
        expect(result.darkModeEnabled, false);
      });

      test('should parse boolean values from JSON', () {
        // Arrange
        final jsonWithFalseValues = {
          'llmApiKey': tLlmApiKey,
          'llmProvider': tLlmProvider,
          'useLlmExtraction': false,
          'darkModeEnabled': false,
        };

        // Act
        final result = AppConfigModel.fromJson(jsonWithFalseValues);

        // Assert
        expect(result.useLlmExtraction, false);
        expect(result.darkModeEnabled, false);
      });

      test('should handle default values from JSON', () {
        // Arrange - minimal JSON with defaults
        final jsonWithDefaults = {
          'llmApiKey': null,
          'llmProvider': null,
          'useLlmExtraction': false,
          'darkModeEnabled': false,
        };

        // Act
        final result = AppConfigModel.fromJson(jsonWithDefaults);

        // Assert
        expect(result.llmApiKey, isNull);
        expect(result.llmProvider, isNull);
        expect(result.useLlmExtraction, false);
        expect(result.darkModeEnabled, false);
      });
    });

    group('JSON serialization round-trip', () {
      test('should preserve all data through toJson and fromJson', () {
        // Act
        final json = tAppConfigModel.toJson();
        final result = AppConfigModel.fromJson(json);

        // Assert
        expect(result, tAppConfigModel);
      });

      test('should preserve null values through round-trip', () {
        // Arrange
        const modelWithNulls = AppConfigModel(
          llmApiKey: null,
          llmProvider: null,
          useLlmExtraction: false,
          darkModeEnabled: false,
        );

        // Act
        final json = modelWithNulls.toJson();
        final result = AppConfigModel.fromJson(json);

        // Assert
        expect(result, modelWithNulls);
        expect(result.llmApiKey, isNull);
        expect(result.llmProvider, isNull);
      });

      test('should preserve boolean values through round-trip', () {
        // Arrange
        const modelWithFalseValues = AppConfigModel(
          llmApiKey: tLlmApiKey,
          llmProvider: tLlmProvider,
          useLlmExtraction: false,
          darkModeEnabled: false,
        );

        // Act
        final json = modelWithFalseValues.toJson();
        final result = AppConfigModel.fromJson(json);

        // Assert
        expect(result, modelWithFalseValues);
        expect(result.useLlmExtraction, false);
        expect(result.darkModeEnabled, false);
      });

      test('should preserve mixed null and non-null values through round-trip', () {
        // Arrange
        const modelWithMixed = AppConfigModel(
          llmApiKey: tLlmApiKey,
          llmProvider: null,
          useLlmExtraction: true,
          darkModeEnabled: false,
        );

        // Act
        final json = modelWithMixed.toJson();
        final result = AppConfigModel.fromJson(json);

        // Assert
        expect(result, modelWithMixed);
        expect(result.llmApiKey, tLlmApiKey);
        expect(result.llmProvider, isNull);
        expect(result.useLlmExtraction, true);
        expect(result.darkModeEnabled, false);
      });
    });

    group('inheritance from AppConfig', () {
      test('should be a subtype of AppConfig', () {
        // Assert
        expect(tAppConfigModel, isA<AppConfig>());
      });

      test('should have access to hasLlmConfigured getter', () {
        // Arrange
        const modelWithKey = AppConfigModel(
          llmApiKey: tLlmApiKey,
          llmProvider: tLlmProvider,
          useLlmExtraction: true,
          darkModeEnabled: true,
        );

        const modelWithoutKey = AppConfigModel(
          llmApiKey: null,
          llmProvider: tLlmProvider,
          useLlmExtraction: false,
          darkModeEnabled: false,
        );

        const modelWithEmptyKey = AppConfigModel(
          llmApiKey: '',
          llmProvider: tLlmProvider,
          useLlmExtraction: false,
          darkModeEnabled: false,
        );

        // Assert
        expect(modelWithKey.hasLlmConfigured, true);
        expect(modelWithoutKey.hasLlmConfigured, false);
        expect(modelWithEmptyKey.hasLlmConfigured, false);
      });

      test('should maintain Equatable equality', () {
        // Arrange
        const model1 = AppConfigModel(
          llmApiKey: tLlmApiKey,
          llmProvider: tLlmProvider,
          useLlmExtraction: true,
          darkModeEnabled: true,
        );

        const model2 = AppConfigModel(
          llmApiKey: tLlmApiKey,
          llmProvider: tLlmProvider,
          useLlmExtraction: true,
          darkModeEnabled: true,
        );

        const model3 = AppConfigModel(
          llmApiKey: 'different-key',
          llmProvider: tLlmProvider,
          useLlmExtraction: true,
          darkModeEnabled: true,
        );

        // Assert
        expect(model1, model2);
        expect(model1, isNot(model3));
      });

      test('should have access to copyWith method', () {
        // Act
        final result = tAppConfigModel.copyWith(llmProvider: 'gemini');

        // Assert
        expect(result.llmProvider, 'gemini');
        expect(result.llmApiKey, tLlmApiKey);
        expect(result.useLlmExtraction, tUseLlmExtraction);
        expect(result.darkModeEnabled, tDarkModeEnabled);
      });
    });
  });
}
