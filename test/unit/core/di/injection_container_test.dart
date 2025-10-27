import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/data/datasources/external/chart_rendering_service.dart';
import 'package:health_tracker_reports/data/datasources/external/claude_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/gemini_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/openai_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_generator_service.dart';
import 'package:health_tracker_reports/data/datasources/external/share_service.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _TestAppModule extends AppModule {}

class _MockGeminiService extends Mock implements GeminiLlmService {}

class _MockOpenAiService extends Mock implements OpenAiLlmService {}

class _MockClaudeService extends Mock implements ClaudeLlmService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppModule', () {
    late _TestAppModule module;
    late _MockGeminiService geminiService;
    late _MockOpenAiService openAiService;
    late _MockClaudeService claudeService;

    setUp(() {
      module = _TestAppModule();
      geminiService = _MockGeminiService();
      openAiService = _MockOpenAiService();
      claudeService = _MockClaudeService();

      when(() => geminiService.provider).thenReturn(LlmProvider.gemini);
      when(() => openAiService.provider).thenReturn(LlmProvider.openai);
      when(() => claudeService.provider).thenReturn(LlmProvider.claude);
    });

    test('llmProviderServices maps providers to concrete services', () {
      final map = module.llmProviderServices(
        geminiService,
        openAiService,
        claudeService,
      );

      expect(map.length, 3);
      expect(map[LlmProvider.gemini], same(geminiService));
      expect(map[LlmProvider.openai], same(openAiService));
      expect(map[LlmProvider.claude], same(claudeService));
    });

    test('chartRenderingService provides ChartRenderingServiceImpl', () {
      final service = module.chartRenderingService;
      expect(service, isA<ChartRenderingServiceImpl>());
    });

    test('pdfDocumentWrapper provides PdfDocumentWrapperImpl', () {
      final wrapper = module.pdfDocumentWrapper;
      expect(wrapper, isA<PdfDocumentWrapperImpl>());
    });

    test('shareWrapper provides ShareWrapperImpl', () {
      final wrapper = module.shareWrapper;
      expect(wrapper, isA<ShareWrapperImpl>());
    });

    test('uuid provider returns const Uuid instance', () {
      final uuid = module.uuid;
      expect(uuid, isA<Uuid>());
      expect(uuid.v4().length, 36);
    });
  });
}
