import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/local/secure_config_storage.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockFlutterSecureStorage storage;
  late SecureConfigStorageImpl secureStorage;

  setUp(() {
    storage = _MockFlutterSecureStorage();
    secureStorage = SecureConfigStorageImpl(storage);
  });

  group('SecureConfigStorageImpl', () {
    test('writeApiKeys writes values and deletes empty entries', () async {
      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

      await secureStorage.writeApiKeys({
        LlmProvider.gemini: 'gem-key',
        LlmProvider.openai: '',
      });

      verify(
        () => storage.write(
          key: 'llm_api_key_gemini',
          value: 'gem-key',
        ),
      ).called(1);
      verify(() => storage.delete(key: 'llm_api_key_openai')).called(1);
      verify(() => storage.delete(key: 'llm_api_key_claude')).called(1);
    });

    test('readApiKey delegates to secure storage', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'claude-key');

      final result = await secureStorage.readApiKey(LlmProvider.claude);

      expect(result, 'claude-key');
      verify(() => storage.read(key: 'llm_api_key_claude')).called(1);
    });

    test('readAllApiKeys aggregates only non-empty values', () async {
      when(() => storage.read(key: 'llm_api_key_gemini')).thenAnswer((_) async => 'g');
      when(() => storage.read(key: 'llm_api_key_openai')).thenAnswer((_) async => null);
      when(() => storage.read(key: 'llm_api_key_claude')).thenAnswer((_) async => '');

      final result = await secureStorage.readAllApiKeys();

      expect(result, {LlmProvider.gemini: 'g'});
      verify(() => storage.read(key: any(named: 'key'))).called(3);
    });
  });
}
