import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:health_tracker_reports/data/datasources/local/hive_database.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/data/models/health_log_model.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_provider_service.dart';
import 'package:health_tracker_reports/data/datasources/external/gemini_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/openai_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/claude_llm_service.dart';
import 'package:health_tracker_reports/data/datasources/external/share_service.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_generator_service.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:health_tracker_reports/data/datasources/external/chart_rendering_service.dart';

import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

@module
abstract class AppModule {
  @preResolve
  Future<HiveDatabase> get hiveDatabase async {
    final db = HiveDatabase(hive: Hive);
    await db.init();
    await db.openBoxes();
    return db;
  }

  @lazySingleton
  HiveInterface get hive => Hive;

  @lazySingleton
  Box<ReportModel> get reportBox =>
      Hive.box<ReportModel>(HiveDatabase.reportBoxName);

  @lazySingleton
  Box<AppConfigModel> get configBox =>
      Hive.box<AppConfigModel>(HiveDatabase.configBoxName);

  @lazySingleton
  Box<HealthLogModel> get healthLogBox =>
      Hive.box<HealthLogModel>(HiveDatabase.healthLogBoxName);

  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Uuid get uuid => const Uuid();

  @lazySingleton
  ChartRenderingService get chartRenderingService =>
      ChartRenderingServiceImpl();

  @lazySingleton
  PdfDocumentWrapper get pdfDocumentWrapper => PdfDocumentWrapperImpl();

  @lazySingleton
  ShareWrapper get shareWrapper => ShareWrapperImpl();

  @Named('llmProviderServices')
  Map<LlmProvider, LlmProviderService> llmProviderServices(
    GeminiLlmService geminiLlmService,
    OpenAiLlmService openAiLlmService,
    ClaudeLlmService claudeLlmService,
  ) =>
      {
        LlmProvider.gemini: geminiLlmService,
        LlmProvider.openai: openAiLlmService,
        LlmProvider.claude: claudeLlmService,
      };
}
