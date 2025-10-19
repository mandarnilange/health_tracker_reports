import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/csv_export_service.dart';
import 'package:health_tracker_reports/data/datasources/external/file_writer_service.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/export_trends_to_csv.dart';

/// Enum describing the current export lifecycle status.
enum ExportStatus { idle, inProgress, success, error }

/// Enum describing which CSV export target is being processed.
enum ExportTarget { reports, vitals, trends }

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

  double get progress =>
      total == 0 ? 0 : (completed.clamp(0, total) / total.toDouble());

  ExportState copyWith({
    ExportStatus? status,
    List<ExportResult>? results,
    int? completed,
    int? total,
    Failure? failure,
  }) {
    return ExportState(
      status: status ?? this.status,
      results: results ?? this.results,
      completed: completed ?? this.completed,
      total: total ?? this.total,
      failure: failure,
    );
  }

  ExportState asProgress({
    required int completed,
    required int total,
    List<ExportResult> results = const [],
  }) {
    return copyWith(
      status: ExportStatus.inProgress,
      completed: completed,
      total: total,
      failure: null,
      results: results,
    );
  }

  ExportState asSuccess(List<ExportResult> results, {required int total}) {
    return ExportState(
      status: ExportStatus.success,
      results: results,
      completed: results.length,
      total: total,
      failure: null,
    );
  }

  ExportState asError(Failure failure, List<ExportResult> results,
      {required int total, required int completed}) {
    return ExportState(
      status: ExportStatus.error,
      results: results,
      completed: completed,
      total: total,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, results, completed, total, failure];
}

typedef _CsvGenerator<T> = Either<Failure, String> Function(T input);

/// StateNotifier that coordinates CSV generation and file writing.
class ExportProvider extends StateNotifier<ExportState> {
  ExportProvider({
    required this.csvExportService,
    required this.fileWriterService,
  }) : super(ExportState.initial());

  final CsvExportService csvExportService;
  final FileWriterService fileWriterService;

  static const _reportsPrefix = 'reports_biomarkers';
  static const _vitalsPrefix = 'health_logs_vitals';
  static const _trendsPrefix = 'trends_statistics';

  /// Exports only the reports CSV.
  Future<void> exportReports(List<Report> reports) async {
    await _exportSingle< List<Report> >(
      target: ExportTarget.reports,
      data: reports,
      filenamePrefix: _reportsPrefix,
      generator: csvExportService.generateReportsCsv,
    );
  }

  /// Exports only the vitals CSV.
  Future<void> exportVitals(List<HealthLog> logs) async {
    await _exportSingle< List<HealthLog> >(
      target: ExportTarget.vitals,
      data: logs,
      filenamePrefix: _vitalsPrefix,
      generator: csvExportService.generateVitalsCsv,
    );
  }

  /// Exports only the trends CSV.
  Future<void> exportTrends(List<TrendMetricSeries> series) async {
    await _exportSingle< List<TrendMetricSeries> >(
      target: ExportTarget.trends,
      data: series,
      filenamePrefix: _trendsPrefix,
      generator: csvExportService.generateTrendsCsv,
    );
  }

  /// Exports all CSV files sequentially, updating progress after each step.
  Future<void> exportAll({
    required List<Report> reports,
    required List<HealthLog> healthLogs,
    required List<TrendMetricSeries> trends,
  }) async {
    const total = 3;
    final results = <ExportResult>[];
    state = state.asProgress(completed: 0, total: total);

    final firstFailure = await _processStep<List<Report>>(
      data: reports,
      target: ExportTarget.reports,
      filenamePrefix: _reportsPrefix,
      generator: csvExportService.generateReportsCsv,
      results: results,
      total: total,
    );

    if (firstFailure != null) {
      state = state.asError(
        firstFailure,
        results,
        total: total,
        completed: results.length,
      );
      return;
    }

    final secondFailure = await _processStep<List<HealthLog>>(
      data: healthLogs,
      target: ExportTarget.vitals,
      filenamePrefix: _vitalsPrefix,
      generator: csvExportService.generateVitalsCsv,
      results: results,
      total: total,
    );

    if (secondFailure != null) {
      state = state.asError(
        secondFailure,
        results,
        total: total,
        completed: results.length,
      );
      return;
    }

    final thirdFailure = await _processStep<List<TrendMetricSeries>>(
      data: trends,
      target: ExportTarget.trends,
      filenamePrefix: _trendsPrefix,
      generator: csvExportService.generateTrendsCsv,
      results: results,
      total: total,
    );

    if (thirdFailure != null) {
      state = state.asError(
        thirdFailure,
        results,
        total: total,
        completed: results.length,
      );
      return;
    }

    state = state.asSuccess(results, total: total);
  }

  Future<void> _exportSingle<T>({
    required ExportTarget target,
    required T data,
    required String filenamePrefix,
    required _CsvGenerator<T> generator,
  }) async {
    state = state.asProgress(completed: 0, total: 1);

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

    final csv = (csvResult as Right<Failure, String>).value;
    final writeResult = await fileWriterService.writeCsv(
      filenamePrefix: filenamePrefix,
      contents: csv,
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
  }) async {
    final csvResult = generator(data);
    if (csvResult.isLeft()) {
      return (csvResult as Left<Failure, String>).value;
    }

    final csv = (csvResult as Right<Failure, String>).value;
    final writeResult = await fileWriterService.writeCsv(
      filenamePrefix: filenamePrefix,
      contents: csv,
    );

    return writeResult.fold(
      (failure) => failure,
      (path) {
        results.add(ExportResult(target: target, path: path));
        state = state.asProgress(
          completed: results.length,
          total: total,
        );
        return null;
      },
    );
  }
}
