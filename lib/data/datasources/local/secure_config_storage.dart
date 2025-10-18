import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:injectable/injectable.dart';

/// Abstraction over secure storage for persisting LLM API keys.
abstract class SecureConfigStorage {
  /// Persists all provided API keys, removing any that are empty or omitted.
  Future<void> writeApiKeys(Map<LlmProvider, String> apiKeys);

  /// Reads a single API key for the given provider.
  Future<String?> readApiKey(LlmProvider provider);

  /// Reads all API keys present in secure storage.
  Future<Map<LlmProvider, String>> readAllApiKeys();
}

@LazySingleton(as: SecureConfigStorage)
class SecureConfigStorageImpl implements SecureConfigStorage {
  SecureConfigStorageImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _keyPrefix = 'llm_api_key_';

  @override
  Future<Map<LlmProvider, String>> readAllApiKeys() async {
    final result = <LlmProvider, String>{};

    for (final provider in LlmProvider.values) {
      final value = await readApiKey(provider);
      if (value != null && value.isNotEmpty) {
        result[provider] = value;
      }
    }

    return result;
  }

  @override
  Future<String?> readApiKey(LlmProvider provider) async {
    return _storage.read(key: _storageKey(provider));
  }

  @override
  Future<void> writeApiKeys(Map<LlmProvider, String> apiKeys) async {
    for (final provider in LlmProvider.values) {
      final value = apiKeys[provider];
      final storageKey = _storageKey(provider);

      if (value != null && value.isNotEmpty) {
        await _storage.write(key: storageKey, value: value);
      } else {
        await _storage.delete(key: storageKey);
      }
    }
  }

  String _storageKey(LlmProvider provider) => '$_keyPrefix${provider.name}';
}

