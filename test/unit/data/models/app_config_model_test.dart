import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

void main() {
  group('AppConfigModel', () {
    const apiKeys = {
      LlmProvider.claude: 'claude-key',
      LlmProvider.openai: 'openai-key',
    };

    test('fromEntity copies all properties', () {
      const entity = AppConfig(
        llmApiKeys: apiKeys,
        llmProvider: LlmProvider.openai,
        darkModeEnabled: true,
      );

      final model = AppConfigModel.fromEntity(entity);

      expect(model.llmApiKeys, equals(apiKeys));
      expect(model.llmProvider, equals(LlmProvider.openai));
      expect(model.darkModeEnabled, isTrue);
    });

    test('toJson serialises provider keys as strings', () {
      const model = AppConfigModel(
        llmApiKeys: apiKeys,
        llmProvider: LlmProvider.claude,
        darkModeEnabled: true,
      );

      final json = model.toJson();

      expect(
        json['llmApiKeys'],
        equals({'claude': 'claude-key', 'openai': 'openai-key'}),
      );
      expect(json['llmProvider'], equals('claude'));
      expect(json['darkModeEnabled'], isTrue);
    });

    test('fromJson falls back to defaults for unknown provider', () {
      final json = {
        'llmApiKeys': {'claude': 'claude-key', 'unknown': 'mystery'},
        'llmProvider': 'unknown',
        'darkModeEnabled': true,
      };

      final model = AppConfigModel.fromJson(json);

      expect(model.llmApiKeys[LlmProvider.claude], equals('claude-key'));
      expect(model.llmApiKeys.containsKey(LlmProvider.openai), isFalse);
      expect(model.llmProvider, equals(LlmProvider.claude));
      expect(model.darkModeEnabled, isTrue);
    });

    test('toEntity creates equivalent AppConfig', () {
      const model = AppConfigModel(
        llmApiKeys: apiKeys,
        llmProvider: LlmProvider.openai,
        darkModeEnabled: true,
      );

      final entity = model.toEntity();

      expect(entity.llmApiKeys, equals(apiKeys));
      expect(entity.llmProvider, equals(LlmProvider.openai));
      expect(entity.darkModeEnabled, isTrue);
    });
  });
}
