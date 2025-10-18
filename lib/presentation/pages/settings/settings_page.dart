import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/presentation/providers/config_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _claudeKeyController = TextEditingController();
  final _openaiKeyController = TextEditingController();
  final _geminiKeyController = TextEditingController();

  LlmProvider _selectedProvider = LlmProvider.claude;
  bool _obscureKeys = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    final config = ref.read(configProvider).maybeWhen(
          data: (config) => config,
          orElse: () => null,
        );

    if (config != null) {
      _selectedProvider = config.llmProvider;
      _claudeKeyController.text = config.getApiKey(LlmProvider.claude) ?? '';
      _openaiKeyController.text = config.getApiKey(LlmProvider.openai) ?? '';
      _geminiKeyController.text = config.getApiKey(LlmProvider.gemini) ?? '';
    }
  }

  @override
  void dispose() {
    _claudeKeyController.dispose();
    _openaiKeyController.dispose();
    _geminiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final currentConfig = ref.read(configProvider).maybeWhen(
          data: (config) => config,
          orElse: () => const AppConfig(),
        );

    final apiKeys = <LlmProvider, String>{};
    if (_claudeKeyController.text.isNotEmpty) {
      apiKeys[LlmProvider.claude] = _claudeKeyController.text;
    }
    if (_openaiKeyController.text.isNotEmpty) {
      apiKeys[LlmProvider.openai] = _openaiKeyController.text;
    }
    if (_geminiKeyController.text.isNotEmpty) {
      apiKeys[LlmProvider.gemini] = _geminiKeyController.text;
    }

    final newConfig = currentConfig.copyWith(
      llmApiKeys: apiKeys,
      llmProvider: _selectedProvider,
    );

    await ref.read(configProvider.notifier).saveConfig(newConfig);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final configState = ref.watch(configProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: configState.when(
        data: (config) => _buildSettingsForm(config),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading settings: $error'),
        ),
      ),
    );
  }

  Widget _buildSettingsForm(AppConfig config) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProviderSection(),
          const SizedBox(height: 24),
          _buildApiKeysSection(),
          const SizedBox(height: 24),
          _buildPrivacyNotice(),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildProviderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LLM Provider',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the AI provider for biomarker extraction',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...LlmProvider.values.map((provider) {
              return RadioListTile<LlmProvider>(
                title: Text(_getProviderName(provider)),
                subtitle: Text(_getProviderDescription(provider)),
                value: provider,
                groupValue: _selectedProvider,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedProvider = value);
                  }
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeysSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'API Keys',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: Icon(
                    _obscureKeys ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscureKeys = !_obscureKeys);
                  },
                  tooltip: _obscureKeys ? 'Show keys' : 'Hide keys',
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your API keys for each provider. Only the selected provider\'s key is required.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildApiKeyField(
              controller: _claudeKeyController,
              label: 'Claude API Key',
              hint: 'sk-ant-...',
              isRequired: _selectedProvider == LlmProvider.claude,
            ),
            const SizedBox(height: 16),
            _buildApiKeyField(
              controller: _openaiKeyController,
              label: 'OpenAI API Key',
              hint: 'sk-...',
              isRequired: _selectedProvider == LlmProvider.openai,
            ),
            const SizedBox(height: 16),
            _buildApiKeyField(
              controller: _geminiKeyController,
              label: 'Gemini API Key',
              hint: 'AIza...',
              isRequired: _selectedProvider == LlmProvider.gemini,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isRequired,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscureKeys,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => controller.clear(),
              )
            : null,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'API key required for selected provider';
        }
        return null;
      },
    );
  }

  Widget _buildPrivacyNotice() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Notice',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your lab reports will be sent to the selected AI provider for analysis. '
                    'API keys are stored securely on your device.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return FilledButton.icon(
      onPressed: _saveSettings,
      icon: const Icon(Icons.save),
      label: const Text('Save Settings'),
    );
  }

  String _getProviderName(LlmProvider provider) {
    switch (provider) {
      case LlmProvider.claude:
        return 'Claude (Anthropic)';
      case LlmProvider.openai:
        return 'GPT-4 Vision (OpenAI)';
      case LlmProvider.gemini:
        return 'Gemini (Google)';
    }
  }

  String _getProviderDescription(LlmProvider provider) {
    switch (provider) {
      case LlmProvider.claude:
        return 'Claude 3.5 Sonnet - High accuracy, good cost';
      case LlmProvider.openai:
        return 'GPT-4 Vision - Excellent accuracy, higher cost';
      case LlmProvider.gemini:
        return 'Gemini Pro Vision - Good accuracy, lowest cost';
    }
  }
}
