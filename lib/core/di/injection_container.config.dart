// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:health_tracker_reports/core/di/injection_container.dart'
    as _i838;
import 'package:health_tracker_reports/core/utils/clock.dart' as _i31;
import 'package:health_tracker_reports/data/datasources/external/chart_rendering_service.dart'
    as _i560;
import 'package:health_tracker_reports/data/datasources/external/claude_llm_service.dart'
    as _i26;
import 'package:health_tracker_reports/data/datasources/external/csv_export_service.dart'
    as _i611;
import 'package:health_tracker_reports/data/datasources/external/file_writer_service.dart'
    as _i446;
import 'package:health_tracker_reports/data/datasources/external/gemini_llm_service.dart'
    as _i48;
import 'package:health_tracker_reports/data/datasources/external/image_processing_service.dart'
    as _i46;
import 'package:health_tracker_reports/data/datasources/external/llm_provider_service.dart'
    as _i693;
import 'package:health_tracker_reports/data/datasources/external/openai_llm_service.dart'
    as _i549;
import 'package:health_tracker_reports/data/datasources/external/pdf_generator_service.dart'
    as _i917;
import 'package:health_tracker_reports/data/datasources/external/share_service.dart'
    as _i60;
import 'package:health_tracker_reports/data/datasources/local/config_local_datasource.dart'
    as _i537;
import 'package:health_tracker_reports/data/datasources/local/health_log_local_datasource.dart'
    as _i154;
import 'package:health_tracker_reports/data/datasources/local/hive_database.dart'
    as _i648;
import 'package:health_tracker_reports/data/datasources/local/report_local_datasource.dart'
    as _i273;
import 'package:health_tracker_reports/data/datasources/local/secure_config_storage.dart'
    as _i848;
import 'package:health_tracker_reports/data/models/app_config_model.dart'
    as _i386;
import 'package:health_tracker_reports/data/models/health_log_model.dart'
    as _i510;
import 'package:health_tracker_reports/data/models/report_model.dart' as _i936;
import 'package:health_tracker_reports/data/repositories/config_repository_impl.dart'
    as _i616;
import 'package:health_tracker_reports/data/repositories/health_log_repository_impl.dart'
    as _i250;
import 'package:health_tracker_reports/data/repositories/llm_extraction_repository_impl.dart'
    as _i836;
import 'package:health_tracker_reports/data/repositories/report_repository_impl.dart'
    as _i508;
import 'package:health_tracker_reports/data/repositories/timeline_repository_impl.dart'
    as _i875;
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart'
    as _i229;
import 'package:health_tracker_reports/domain/repositories/config_repository.dart'
    as _i649;
import 'package:health_tracker_reports/domain/repositories/health_log_repository.dart'
    as _i49;
import 'package:health_tracker_reports/domain/repositories/llm_extraction_repository.dart'
    as _i111;
import 'package:health_tracker_reports/domain/repositories/report_repository.dart'
    as _i767;
import 'package:health_tracker_reports/domain/repositories/timeline_repository.dart'
    as _i880;
import 'package:health_tracker_reports/domain/usecases/calculate_summary_statistics.dart'
    as _i549;
import 'package:health_tracker_reports/domain/usecases/calculate_trend.dart'
    as _i680;
import 'package:health_tracker_reports/domain/usecases/calculate_vital_statistics.dart'
    as _i116;
import 'package:health_tracker_reports/domain/usecases/compare_biomarker_across_reports.dart'
    as _i889;
import 'package:health_tracker_reports/domain/usecases/create_health_log.dart'
    as _i466;
import 'package:health_tracker_reports/domain/usecases/delete_health_log.dart'
    as _i508;
import 'package:health_tracker_reports/domain/usecases/delete_report.dart'
    as _i248;
import 'package:health_tracker_reports/domain/usecases/export_reports_to_csv.dart'
    as _i249;
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart'
    as _i733;
import 'package:health_tracker_reports/domain/usecases/export_vitals_to_csv.dart'
    as _i361;
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file.dart'
    as _i839;
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file_llm.dart'
    as _i990;
import 'package:health_tracker_reports/domain/usecases/generate_doctor_pdf.dart'
    as _i789;
import 'package:health_tracker_reports/domain/usecases/get_all_health_logs.dart'
    as _i989;
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart'
    as _i657;
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart'
    as _i926;
import 'package:health_tracker_reports/domain/usecases/get_health_log_by_id.dart'
    as _i673;
import 'package:health_tracker_reports/domain/usecases/get_unified_timeline.dart'
    as _i312;
import 'package:health_tracker_reports/domain/usecases/get_vital_trend.dart'
    as _i681;
import 'package:health_tracker_reports/domain/usecases/save_report.dart'
    as _i567;
import 'package:health_tracker_reports/domain/usecases/update_config.dart'
    as _i1005;
import 'package:health_tracker_reports/domain/usecases/update_health_log.dart'
    as _i374;
import 'package:health_tracker_reports/domain/usecases/validate_vital_measurement.dart'
    as _i542;
import 'package:hive/hive.dart' as _i979;
import 'package:injectable/injectable.dart' as _i526;
import 'package:uuid/uuid.dart' as _i706;

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
    gh.lazySingleton<_i979.Box<_i510.HealthLogModel>>(
        () => appModule.healthLogBox);
    gh.lazySingleton<_i361.Dio>(() => appModule.dio);
    gh.lazySingleton<_i558.FlutterSecureStorage>(() => appModule.secureStorage);
    gh.lazySingleton<_i706.Uuid>(() => appModule.uuid);
    gh.lazySingleton<_i560.ChartRenderingService>(
        () => appModule.chartRenderingService);
    gh.lazySingleton<_i917.PdfDocumentWrapper>(
        () => appModule.pdfDocumentWrapper);
    gh.lazySingleton<_i60.ShareWrapper>(() => appModule.shareWrapper);
    gh.lazySingleton<_i46.ImageProcessingService>(
        () => _i46.ImageProcessingService());
    gh.lazySingleton<_i361.ExportVitalsToCsv>(() => _i361.ExportVitalsToCsv());
    gh.lazySingleton<_i680.CalculateTrend>(() => _i680.CalculateTrend());
    gh.lazySingleton<_i733.ExportTrendsToCsv>(() => _i733.ExportTrendsToCsv());
    gh.lazySingleton<_i249.ExportReportsToCsv>(
        () => _i249.ExportReportsToCsv());
    gh.lazySingleton<_i542.ValidateVitalMeasurement>(
        () => _i542.ValidateVitalMeasurement());
    gh.lazySingleton<_i154.HealthLogLocalDataSource>(() =>
        _i154.HealthLogLocalDataSourceImpl(
            box: gh<_i979.Box<_i510.HealthLogModel>>()));
    gh.lazySingleton<_i31.Clock>(() => _i31.SystemClock());
    gh.lazySingleton<_i446.DownloadsPathProvider>(
        () => const _i446.PathProviderDownloadsPath());
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
    gh.lazySingleton<_i60.ShareService>(
        () => _i60.ShareServiceImpl(shareWrapper: gh<_i60.ShareWrapper>()));
    gh.lazySingleton<_i889.CompareBiomarkerAcrossReports>(() =>
        _i889.CompareBiomarkerAcrossReports(
            repository: gh<_i767.ReportRepository>()));
    gh.lazySingleton<_i567.SaveReport>(
        () => _i567.SaveReport(repository: gh<_i767.ReportRepository>()));
    gh.lazySingleton<_i657.GetAllReports>(
        () => _i657.GetAllReports(repository: gh<_i767.ReportRepository>()));
    gh.lazySingleton<_i926.GetBiomarkerTrend>(() =>
        _i926.GetBiomarkerTrend(repository: gh<_i767.ReportRepository>()));
    gh.lazySingleton<_i248.DeleteReport>(
        () => _i248.DeleteReport(repository: gh<_i767.ReportRepository>()));
    gh.lazySingleton<_i49.HealthLogRepository>(() =>
        _i250.HealthLogRepositoryImpl(
            localDataSource: gh<_i154.HealthLogLocalDataSource>()));
    gh.lazySingleton<_i848.SecureConfigStorage>(
        () => _i848.SecureConfigStorageImpl(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i611.CsvExportService>(() => _i611.CsvExportService(
          exportReportsToCsv: gh<_i249.ExportReportsToCsv>(),
          exportVitalsToCsv: gh<_i361.ExportVitalsToCsv>(),
          exportTrendsToCsv: gh<_i733.ExportTrendsToCsv>(),
        ));
    gh.lazySingleton<_i446.FileWriterService>(() => _i446.FileWriterService(
        downloadsPathProvider: gh<_i446.DownloadsPathProvider>()));
    gh.factory<Map<_i229.LlmProvider, _i693.LlmProviderService>>(
      () => appModule.llmProviderServices(
        gh<_i48.GeminiLlmService>(),
        gh<_i549.OpenAiLlmService>(),
        gh<_i26.ClaudeLlmService>(),
      ),
      instanceName: 'llmProviderServices',
    );
    gh.lazySingleton<_i880.TimelineRepository>(
        () => _i875.TimelineRepositoryImpl(
              reportLocalDataSource: gh<_i273.ReportLocalDataSource>(),
              healthLogLocalDataSource: gh<_i154.HealthLogLocalDataSource>(),
            ));
    gh.lazySingleton<_i989.GetAllHealthLogs>(() =>
        _i989.GetAllHealthLogs(repository: gh<_i49.HealthLogRepository>()));
    gh.lazySingleton<_i681.GetVitalTrend>(
        () => _i681.GetVitalTrend(repository: gh<_i49.HealthLogRepository>()));
    gh.lazySingleton<_i673.GetHealthLogById>(() =>
        _i673.GetHealthLogById(repository: gh<_i49.HealthLogRepository>()));
    gh.lazySingleton<_i508.DeleteHealthLog>(() =>
        _i508.DeleteHealthLog(repository: gh<_i49.HealthLogRepository>()));
    gh.lazySingleton<_i649.ConfigRepository>(() => _i616.ConfigRepositoryImpl(
          localDataSource: gh<_i537.ConfigLocalDataSource>(),
          secureStorage: gh<_i848.SecureConfigStorage>(),
        ));
    gh.lazySingleton<_i116.CalculateVitalStatistics>(() =>
        _i116.CalculateVitalStatistics(
            getVitalTrend: gh<_i681.GetVitalTrend>()));
    gh.lazySingleton<_i466.CreateHealthLog>(() => _i466.CreateHealthLog(
          repository: gh<_i49.HealthLogRepository>(),
          validateVitalMeasurement: gh<_i542.ValidateVitalMeasurement>(),
          clock: gh<_i31.Clock>(),
          uuid: gh<_i706.Uuid>(),
        ));
    gh.lazySingleton<_i374.UpdateHealthLog>(() => _i374.UpdateHealthLog(
          repository: gh<_i49.HealthLogRepository>(),
          validateVitalMeasurement: gh<_i542.ValidateVitalMeasurement>(),
          clock: gh<_i31.Clock>(),
          uuid: gh<_i706.Uuid>(),
        ));
    gh.lazySingleton<_i312.GetUnifiedTimeline>(() =>
        _i312.GetUnifiedTimeline(repository: gh<_i880.TimelineRepository>()));
    gh.lazySingleton<_i917.PdfGeneratorService>(
        () => _i917.PdfGeneratorServiceImpl(
              pdfDocumentWrapper: gh<_i917.PdfDocumentWrapper>(),
              chartRenderingService: gh<_i560.ChartRenderingService>(),
              fileWriterService: gh<_i446.FileWriterService>(),
            ));
    gh.lazySingleton<_i111.LlmExtractionRepository>(
        () => _i836.LlmExtractionRepositoryImpl(
              claudeService: gh<_i26.ClaudeLlmService>(),
              openAiService: gh<_i549.OpenAiLlmService>(),
              geminiService: gh<_i48.GeminiLlmService>(),
              configRepository: gh<_i649.ConfigRepository>(),
            ));
    gh.lazySingleton<_i549.CalculateSummaryStatistics>(
        () => _i549.CalculateSummaryStatistics(
              reportRepository: gh<_i767.ReportRepository>(),
              healthLogRepository: gh<_i49.HealthLogRepository>(),
              getBiomarkerTrend: gh<_i926.GetBiomarkerTrend>(),
              getVitalTrend: gh<_i681.GetVitalTrend>(),
              calculateTrend: gh<_i680.CalculateTrend>(),
            ));
    gh.factory<_i1005.UpdateConfig>(
        () => _i1005.UpdateConfig(gh<_i649.ConfigRepository>()));
    gh.factory<_i990.ExtractReportFromFileLlm>(
        () => _i990.ExtractReportFromFileLlm(
              llmRepository: gh<_i111.LlmExtractionRepository>(),
              imageService: gh<_i46.ImageProcessingService>(),
              reportRepository: gh<_i767.ReportRepository>(),
            ));
    gh.lazySingleton<_i789.GenerateDoctorPdf>(() => _i789.GenerateDoctorPdf(
          calculateSummaryStatistics: gh<_i549.CalculateSummaryStatistics>(),
          pdfGeneratorService: gh<_i917.PdfGeneratorService>(),
        ));
    gh.lazySingleton<_i839.ExtractReportFromFile>(() =>
        _i839.ExtractReportFromFile(
            delegate: gh<_i990.ExtractReportFromFileLlm>()));
    return this;
  }
}

class _$AppModule extends _i838.AppModule {}
