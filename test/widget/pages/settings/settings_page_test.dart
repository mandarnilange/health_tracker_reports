import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/app_config.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/repositories/config_repository.dart';
import 'package:health_tracker_reports/presentation/pages/settings/settings_page.dart';
import 'package:health_tracker_reports/presentation/providers/config_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockConfigRepository extends Mock implements ConfigRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockConfigRepository mockRepository;
  late AppConfig initialConfig;

  setUpAll(() {
    registerFallbackValue(const AppConfig());
  });

  setUp(() {
    mockRepository = _MockConfigRepository();
    initialConfig = AppConfig(
      llmApiKeys: {
        LlmProvider.claude: 'claude-key',
        LlmProvider.openai: 'openai-key',
      },
      llmProvider: LlmProvider.claude,
    );

    when(() => mockRepository.getConfig())
        .thenAnswer((_) async => Right(initialConfig));
    when(() => mockRepository.saveConfig(any()))
        .thenAnswer((_) async => const Right(null));
  });

  Future<ProviderContainer> _pumpPage(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        configProvider.overrideWith(
          (ref) => ConfigNotifier(mockRepository),
        ),
      ],
    );

    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );

    await tester.pump(); // allow async load
    return container;
  }

  testWidgets('loads existing config and toggles provider visibility',
      (tester) async {
    await _pumpPage(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Claude (Anthropic)'), findsOneWidget);
    expect(find.text('GPT-4 Vision (OpenAI)'), findsOneWidget);

    // Toggle visibility icon should reveal keys
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('validates required API key for selected provider',
      (tester) async {
    await _pumpPage(tester);

    // Select OpenAI provider
    await tester.tap(find.text('GPT-4 Vision (OpenAI)'));
    await tester.pumpAndSettle();

    // Clear OpenAI key field
    final openAiField = find.widgetWithText(TextFormField, 'OpenAI API Key *');
    await tester.enterText(openAiField, '');

    // Tap save
    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();

    expect(
      find.text('API key required for selected provider'),
      findsOneWidget,
    );
    verifyNever(() => mockRepository.saveConfig(any()));
  });

  testWidgets('saves configuration and shows confirmation snackbar',
      (tester) async {
    await _pumpPage(tester);

    // Select Gemini provider and provide key
    await tester.tap(find.text('Gemini (Google)'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Gemini API Key *'),
      'gemini-key',
    );

    await tester.tap(find.byIcon(Icons.save));
    await tester.pump(); // process validation
    await tester.pump(const Duration(milliseconds: 100)); // show snackbar

    verify(
      () => mockRepository.saveConfig(
        any(
          that: predicate<AppConfig>((config) {
            return config.llmProvider == LlmProvider.gemini &&
                config.llmApiKeys[LlmProvider.gemini] == 'gemini-key';
          }),
        ),
      ),
    ).called(1);

    expect(find.text('Settings saved successfully'), findsOneWidget);
  });
}
