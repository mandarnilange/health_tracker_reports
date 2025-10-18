// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:health_tracker_reports/core/di/injection_container.dart'
    as _i838;
import 'package:health_tracker_reports/data/datasources/external/claude_llm_service.dart'
    as _i26;
import 'package:health_tracker_reports/data/datasources/external/gemini_llm_service.dart'
    as _i48;
import 'package:health_tracker_reports/data/datasources/external/image_processing_service.dart'
    as _i46;
import 'package:health_tracker_reports/data/datasources/external/openai_llm_service.dart'
    as _i549;
import 'package:health_tracker_reports/data/datasources/local/config_local_datasource.dart'
    as _i537;
import 'package:health_tracker_reports/data/datasources/local/hive_database.dart'
    as _i648;
import 'package:health_tracker_reports/data/datasources/local/report_local_datasource.dart'
    as _i273;
import 'package:health_tracker_reports/data/models/app_config_model.dart'
    as _i386;
import 'package:health_tracker_reports/data/models/report_model.dart' as _i936;
import 'package:health_tracker_reports/data/repositories/config_repository_impl.dart'
    as _i616;
import 'package:health_tracker_reports/data/repositories/llm_extraction_repository_impl.dart'
    as _i836;
import 'package:health_tracker_reports/data/repositories/report_repository_impl.dart'
    as _i508;
import 'package:health_tracker_reports/domain/repositories/config_repository.dart'
    as _i649;
import 'package:health_tracker_reports/domain/repositories/llm_extraction_repository.dart'
    as _i111;
import 'package:health_tracker_reports/domain/repositories/report_repository.dart'
    as _i767;
import 'package:health_tracker_reports/domain/usecases/calculate_trend.dart'
    as _i680;
import 'package:health_tracker_reports/domain/usecases/compare_biomarker_across_reports.dart'
    as _i889;
import 'package:health_tracker_reports/domain/usecases/delete_report.dart'
    as _i248;
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file_llm.dart'
    as _i990;
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart'
    as _i657;
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart'
    as _i926;
import 'package:health_tracker_reports/domain/usecases/normalize_biomarker_name.dart'
    as _i197;
import 'package:health_tracker_reports/domain/usecases/save_report.dart'
    as _i567;
import 'package:health_tracker_reports/domain/usecases/update_config.dart'
    as _i1005;
import 'package:hive/hive.dart' as _i979;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    await gh.factoryAsync<_i648.HiveDatabase>(
      () => appModule.hiveDatabase,
      preResolve: true,
    );
    gh.lazySingleton<_i979.HiveInterface>(() => appModule.hive);
    gh.lazySingleton<_i979.Box<_i936.ReportModel>>(() => appModule.reportBox);
    gh.lazySingleton<_i979.Box<_i386.AppConfigModel>>(
        () => appModule.configBox);
    gh.lazySingleton<_i361.Dio>(() => appModule.dio);
    gh.lazySingleton<_i46.ImageProcessingService>(
        () => _i46.ImageProcessingService());
    gh.lazySingleton<_i680.CalculateTrend>(() => _i680.CalculateTrend());
    gh.lazySingleton<_i197.NormalizeBiomarkerName>(
        () => _i197.NormalizeBiomarkerName());
    gh.lazySingleton<_i273.ReportLocalDataSource>(() =>
        _i273.ReportLocalDataSourceImpl(
            box: gh<_i979.Box<_i936.ReportModel>>()));
    gh.lazySingleton<_i26.ClaudeLlmService>(
        () => _i26.ClaudeLlmService(gh<_i361.Dio>()));
    gh.lazySingleton<_i549.OpenAiLlmService>(
        () => _i549.OpenAiLlmService(gh<_i361.Dio>()));
    gh.lazySingleton<_i48.GeminiLlmService>(
        () => _i48.GeminiLlmService(gh<_i361.Dio>()));
    gh.lazySingleton<_i537.ConfigLocalDataSource>(() =>
        _i537.ConfigLocalDataSourceImpl(
            box: gh<_i979.Box<_i386.AppConfigModel>>()));
    gh.lazySingleton<_i767.ReportRepository>(() => _i508.ReportRepositoryImpl(
        localDataSource: gh<_i273.ReportLocalDataSource>()));
    gh.lazySingleton<_i567.SaveReport>(
        () => _i567.SaveReport(repository: gh<_i767.ReportRepository>()));
    gh.lazySingleton<_i657.GetAllReports>(
        () => _i657.GetAllReports(repository: gh<_i767.ReportRepository>()));
    gh.lazySingleton<_i248.DeleteReport>(
        () => _i248.DeleteReport(repository: gh<_i767.ReportRepository>()));
    gh.lazySingleton<_i649.ConfigRepository>(() => _i616.ConfigRepositoryImpl(
        localDataSource: gh<_i537.ConfigLocalDataSource>()));
    gh.factory<_i1005.UpdateConfig>(
        () => _i1005.UpdateConfig(gh<_i649.ConfigRepository>()));
    gh.lazySingleton<_i889.CompareBiomarkerAcrossReports>(
        () => _i889.CompareBiomarkerAcrossReports(
              repository: gh<_i767.ReportRepository>(),
              normalizeBiomarkerName: gh<_i197.NormalizeBiomarkerName>(),
            ));
    gh.lazySingleton<_i926.GetBiomarkerTrend>(() => _i926.GetBiomarkerTrend(
          repository: gh<_i767.ReportRepository>(),
          normalizeBiomarkerName: gh<_i197.NormalizeBiomarkerName>(),
        ));
    gh.lazySingleton<_i111.LlmExtractionRepository>(
        () => _i836.LlmExtractionRepositoryImpl(
              claudeService: gh<_i26.ClaudeLlmService>(),
              openAiService: gh<_i549.OpenAiLlmService>(),
              geminiService: gh<_i48.GeminiLlmService>(),
              configRepository: gh<_i649.ConfigRepository>(),
            ));
    gh.factory<_i990.ExtractReportFromFileLlm>(
        () => _i990.ExtractReportFromFileLlm(
              llmRepository: gh<_i111.LlmExtractionRepository>(),
              imageService: gh<_i46.ImageProcessingService>(),
              reportRepository: gh<_i767.ReportRepository>(),
            ));
    return this;
  }
}

class _$AppModule extends _i838.AppModule {}
