import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/data/datasources/external/chart_rendering_service.dart';
import 'package:health_tracker_reports/data/datasources/local/hive_database.dart';
import 'package:health_tracker_reports/data/datasources/external/claude_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/gemini_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/openai_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_generator_service.dart';
import 'package:health_tracker_reports/data/datasources/external/share_service.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/data/models/health_log_model.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:hive/hive.dart';
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

    test('dio provider yields Dio instance', () {
      final dio = module.dio;
      expect(dio, isA<Dio>());
    });

    test('secureStorage provider yields FlutterSecureStorage', () {
      final storage = module.secureStorage;
      expect(storage, isA<FlutterSecureStorage>());
    });

    test('hive getter returns Hive interface', () {
      final hive = module.hive;
      expect(hive, Hive);
    });

    group('Hive database bindings', () {
      late Directory tempDir;

      setUpAll(() async {
        tempDir = await Directory.systemTemp.createTemp('hive_test');
        Hive.init(tempDir.path);
        final db = HiveDatabase(hive: Hive);
        await db.init();
        await db.openBoxes();
      });

      tearDownAll(() async {
        await Hive.deleteBoxFromDisk(HiveDatabase.reportBoxName);
        await Hive.deleteBoxFromDisk(HiveDatabase.configBoxName);
        await Hive.deleteBoxFromDisk(HiveDatabase.healthLogBoxName);
        await Hive.close();
        await tempDir.delete(recursive: true);
      });

      test('reportBox returns opened Hive box', () {
        final box = module.reportBox;
        expect(box.name, HiveDatabase.reportBoxName);
        expect(box, isA<Box<ReportModel>>());
      });

      test('configBox returns opened Hive box', () {
        final box = module.configBox;
        expect(box.name, HiveDatabase.configBoxName);
        expect(box, isA<Box<AppConfigModel>>());
      });

      test('healthLogBox returns opened Hive box', () {
        final box = module.healthLogBox;
        expect(box.name, HiveDatabase.healthLogBoxName);
        expect(box, isA<Box<HealthLogModel>>());
      });
    });
  });
}
