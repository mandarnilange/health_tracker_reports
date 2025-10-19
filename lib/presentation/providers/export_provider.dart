import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/csv_export_service.dart';
import 'package:health_tracker_reports/data/datasources/external/file_writer_service.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_health_logs.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/presentation/providers/health_log_provider.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';

/// Enum describing the current export lifecycle status.
enum ExportStatus { idle, inProgress, success, error }

/// Enum describing which CSV export target is being processed.
enum ExportTarget { reports, vitals, trends }

/// High-level export actions initiated from the UI.
enum ExportAction { reports, vitals, trends, all }

/// Result of an export operation containing the saved file path.
class ExportResult extends Equatable {
  const ExportResult({
    required this.target,
    required this.path,
  });

  final ExportTarget target;
  final String path;

  @override
  List<Object?> get props => [target, path];
}

/// Provider exposing [CsvExportService].
final csvExportServiceProvider = Provider<CsvExportService>(
  (ref) => getIt<CsvExportService>(),
);

/// Provider exposing [FileWriterService].
final fileWriterServiceProvider = Provider<FileWriterService>(
  (ref) => getIt<FileWriterService>(),
);

/// Provider exposing the export [StateNotifier].
final exportNotifierProvider =
    StateNotifierProvider<ExportProvider, ExportState>(
  (ref) => ExportProvider(
    csvExportService: ref.watch(csvExportServiceProvider),
    fileWriterService: ref.watch(fileWriterServiceProvider),
    getAllReports: ref.watch(getAllReportsProvider),
    getAllHealthLogs: ref.watch(getAllHealthLogsUseCaseProvider),
  ),
);

/// State model exposed by [ExportProvider].
class ExportState extends Equatable {
  const ExportState({
    required this.status,
    required this.results,
    required this.completed,
    required this.total,
    this.failure,
    this.activeAction,
  });

  factory ExportState.initial() => const ExportState(
        status: ExportStatus.idle,
        results: [],
        completed: 0,
        total: 0,
      );

  final ExportStatus status;
  final List<ExportResult> results;
  final int completed;
  final int total;
  final Failure? failure;
  final ExportAction? activeAction;

  double get progress =>
      total == 0 ? 0 : (completed.clamp(0, total) / total.toDouble());

  ExportState copyWith({
    ExportStatus? status,
    List<ExportResult>? results,
    int? completed,
    int? total,
    Failure? failure,
    ExportAction? activeAction,
  }) {
    return ExportState(
      status: status ?? this.status,
      results: results ?? this.results,
      completed: completed ?? this.completed,
      total: total ?? this.total,
      failure: failure,
      activeAction: activeAction,
    );
  }

  ExportState asProgress({
    required ExportAction action,
    required int completed,
    required int total,
    List<ExportResult> results = const [],
  }) {
    return ExportState(
      status: ExportStatus.inProgress,
      results: results,
      completed: completed,
      total: total,
      failure: null,
      activeAction: action,
    );
  }

  ExportState asSuccess(List<ExportResult> results, {
    required int total,
  }) {
    return ExportState(
      status: ExportStatus.success,
      results: results,
      completed: results.length,
      total: total,
      failure: null,
      activeAction: null,
    );
  }

  ExportState asError(
    Failure failure,
    List<ExportResult> results, {
    required int total,
    required int completed,
  }) {
    return ExportState(
      status: ExportStatus.error,
      results: results,
      completed: completed,
      total: total,
      failure: failure,
      activeAction: null,
    );
  }

  @override
  List<Object?> get props => [
        status,
        results,
        completed,
        total,
        failure,
        activeAction,
      ];
}

typedef _CsvGenerator<T> = Either<Failure, String> Function(T input);

/// StateNotifier that coordinates CSV generation and file writing.
class ExportProvider extends StateNotifier<ExportState> {
  ExportProvider({
    required this.csvExportService,
    required this.fileWriterService,
    GetAllReports? getAllReports,
    GetAllHealthLogs? getAllHealthLogs,
    Future<Either<Failure, List<Report>>> Function()? reportsLoader,
    Future<Either<Failure, List<HealthLog>>> Function()? healthLogsLoader,
  })  : _getAllReports = getAllReports,
        _getAllHealthLogs = getAllHealthLogs,
        super(ExportState.initial()) {
    _fetchReports = reportsLoader ?? () => (_getAllReports ?? getIt<GetAllReports>())();
    _fetchHealthLogs =
        healthLogsLoader ?? () => (_getAllHealthLogs ?? getIt<GetAllHealthLogs>())();
  }

  final CsvExportService csvExportService;
  final FileWriterService fileWriterService;
  final GetAllReports? _getAllReports;
  final GetAllHealthLogs? _getAllHealthLogs;
  late final Future<Either<Failure, List<Report>>> Function() _fetchReports;
  late final Future<Either<Failure, List<HealthLog>>> Function() _fetchHealthLogs;

  static const _reportsPrefix = 'reports_biomarkers';
  static const _vitalsPrefix = 'health_logs_vitals';
  static const _trendsPrefix = 'trends_statistics';

  /// Exports only the reports CSV.
  Future<void> exportReports() async {
    await _exportSingle<List<Report>>(
      action: ExportAction.reports,
      target: ExportTarget.reports,
      filenamePrefix: _reportsPrefix,
      loader: _loadReports,
      generator: csvExportService.generateReportsCsv,
    );
  }

  /// Exports only the vitals CSV.
  Future<void> exportVitals() async {
    await _exportSingle<List<HealthLog>>(
      action: ExportAction.vitals,
      target: ExportTarget.vitals,
      filenamePrefix: _vitalsPrefix,
      loader: _loadHealthLogs,
      generator: csvExportService.generateVitalsCsv,
    );
  }

  /// Exports only the trends CSV.
  Future<void> exportTrends() async {
    await _exportSingle<List<TrendMetricSeries>>(
      action: ExportAction.trends,
      target: ExportTarget.trends,
      filenamePrefix: _trendsPrefix,
      loader: _loadTrendSeries,
      generator: csvExportService.generateTrendsCsv,
    );
  }

  /// Exports all CSV files sequentially, updating progress after each step.
  Future<void> exportAll() async {
    const total = 3;
    final results = <ExportResult>[];

    state = state.asProgress(
      action: ExportAction.all,
      completed: 0,
      total: total,
    );

    final reportsResult = await _loadReports();
    final reports = await _handleLoadResult<List<Report>>(
      reportsResult,
      results,
      total,
      completed: 0,
    );
    if (reports == null) return;

    final reportFailure = await _processStep<List<Report>>(
      data: reports,
      target: ExportTarget.reports,
      filenamePrefix: _reportsPrefix,
      generator: csvExportService.generateReportsCsv,
      results: results,
      total: total,
      action: ExportAction.all,
    );
    if (reportFailure != null) {
      state = state.asError(
        reportFailure,
        results,
        total: total,
        completed: results.length,
      );
      return;
    }

    final logsResult = await _loadHealthLogs();
    final logs = await _handleLoadResult<List<HealthLog>>(
      logsResult,
      results,
      total,
      completed: results.length,
    );
    if (logs == null) return;

    final vitalsFailure = await _processStep<List<HealthLog>>(
      data: logs,
      target: ExportTarget.vitals,
      filenamePrefix: _vitalsPrefix,
      generator: csvExportService.generateVitalsCsv,
      results: results,
      total: total,
      action: ExportAction.all,
    );
    if (vitalsFailure != null) {
      state = state.asError(
        vitalsFailure,
        results,
        total: total,
        completed: results.length,
      );
      return;
    }

    final trendSeriesResult = await _buildTrendSeriesFromData(reports, logs);
    final trendSeries = await _handleLoadResult<List<TrendMetricSeries>>(
      trendSeriesResult,
      results,
      total,
      completed: results.length,
    );
    if (trendSeries == null) return;

    final trendsFailure = await _processStep<List<TrendMetricSeries>>(
      data: trendSeries,
      target: ExportTarget.trends,
      filenamePrefix: _trendsPrefix,
      generator: csvExportService.generateTrendsCsv,
      results: results,
      total: total,
      action: ExportAction.all,
    );
    if (trendsFailure != null) {
      state = state.asError(
        trendsFailure,
        results,
        total: total,
        completed: results.length,
      );
      return;
    }

    state = state.asSuccess(results, total: total);
  }

  Future<void> _exportSingle<T>({
    required ExportAction action,
    required ExportTarget target,
    required String filenamePrefix,
    required Future<Either<Failure, T>> Function() loader,
    required _CsvGenerator<T> generator,
  }) async {
    state = state.asProgress(action: action, completed: 0, total: 1);

    final dataResult = await loader();
    if (dataResult.isLeft()) {
      final failure = (dataResult as Left<Failure, T>).value;
      state = state.asError(
        failure,
        const [],
        total: 1,
        completed: 0,
      );
      return;
    }

    final data = (dataResult as Right<Failure, T>).value;
    final csvResult = generator(data);
    if (csvResult.isLeft()) {
      final failure = (csvResult as Left<Failure, String>).value;
      state = state.asError(
        failure,
        const [],
        total: 1,
        completed: 0,
      );
      return;
    }

    final csvContent = (csvResult as Right<Failure, String>).value;
    final writeResult = await fileWriterService.writeCsv(
      filenamePrefix: filenamePrefix,
      contents: csvContent,
    );

    writeResult.fold(
      (failure) {
        state = state.asError(
          failure,
          const [],
          total: 1,
          completed: 0,
        );
      },
      (path) {
        state = state.asSuccess(
          [ExportResult(target: target, path: path)],
          total: 1,
        );
      },
    );
  }

  Future<Failure?> _processStep<T>({
    required T data,
    required ExportTarget target,
    required String filenamePrefix,
    required _CsvGenerator<T> generator,
    required List<ExportResult> results,
    required int total,
    required ExportAction action,
  }) async {
    final csvResult = generator(data);
    if (csvResult.isLeft()) {
      return (csvResult as Left<Failure, String>).value;
    }

    final csvContent = (csvResult as Right<Failure, String>).value;
    final writeResult = await fileWriterService.writeCsv(
      filenamePrefix: filenamePrefix,
      contents: csvContent,
    );

    return writeResult.fold(
      (failure) => failure,
      (path) {
        results.add(ExportResult(target: target, path: path));
        state = state.asProgress(
          action: action,
          completed: results.length,
          total: total,
          results: results,
        );
        return null;
      },
    );
  }

  Future<Either<Failure, List<Report>>> _loadReports() async {
    return await _fetchReports();
  }

  Future<Either<Failure, List<HealthLog>>> _loadHealthLogs() async {
    return await _fetchHealthLogs();
  }

  Future<Either<Failure, List<TrendMetricSeries>>> _loadTrendSeries() async {
    final reportsResult = await _loadReports();
    if (reportsResult.isLeft()) {
      return Left((reportsResult as Left<Failure, List<Report>>).value);
    }

    final logsResult = await _loadHealthLogs();
    if (logsResult.isLeft()) {
      return Left((logsResult as Left<Failure, List<HealthLog>>).value);
    }

    final reports = (reportsResult as Right<Failure, List<Report>>).value;
    final logs = (logsResult as Right<Failure, List<HealthLog>>).value;
    return _buildTrendSeriesFromData(reports, logs);
  }

  Future<Either<Failure, List<TrendMetricSeries>>> _buildTrendSeriesFromData(
    List<Report> reports,
    List<HealthLog> healthLogs,
  ) async {
    final biomarkerSeries = <String, List<TrendMetricPoint>>{};
    for (final report in reports) {
      for (final biomarker in report.biomarkers) {
        final series = biomarkerSeries.putIfAbsent(biomarker.name, () => []);
        series.add(
          TrendMetricPoint(
            timestamp: biomarker.measuredAt,
            value: biomarker.value,
            unit: biomarker.unit,
            isOutOfRange: biomarker.isOutOfRange,
          ),
        );
      }
    }

    final vitalSeries = <VitalType, List<TrendMetricPoint>>{};
    for (final log in healthLogs) {
      for (final vital in log.vitals) {
        final series = vitalSeries.putIfAbsent(vital.type, () => []);
        series.add(
          TrendMetricPoint(
            timestamp: log.timestamp,
            value: vital.value,
            unit: vital.unit,
            isOutOfRange: vital.isOutOfRange,
          ),
        );
      }
    }

    List<TrendMetricSeries> buildSeriesFromMap<K>(
      Map<K, List<TrendMetricPoint>> map,
      TrendMetricType type,
      String Function(K key) nameBuilder,
    ) {
      return map.entries.map((entry) {
        entry.value.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return TrendMetricSeries(
          type: type,
          name: nameBuilder(entry.key),
          points: List.unmodifiable(entry.value),
        );
      }).toList(growable: false);
    }

    final series = <TrendMetricSeries>[
      ...buildSeriesFromMap(
        biomarkerSeries,
        TrendMetricType.biomarker,
        (name) => name,
      ),
      ...buildSeriesFromMap(
        vitalSeries,
        TrendMetricType.vital,
        (type) => type.displayName,
      ),
    ];

    return Right(series);
  }

  Future<T?> _handleLoadResult<T>(
    Either<Failure, T> result,
    List<ExportResult> results,
    int total, {
    required int completed,
  }) async {
    if (result.isLeft()) {
      final failure = (result as Left<Failure, T>).value;
      state = state.asError(
        failure,
        results,
        total: total,
        completed: completed,
      );
      return null;
    }

    return (result as Right<Failure, T>).value;
  }
}
