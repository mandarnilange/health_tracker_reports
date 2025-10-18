import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/extract_report_from_file_llm.dart';

/// StateNotifier for managing extraction workflow.
class ExtractionNotifier extends StateNotifier<AsyncValue<Report?>> {
  ExtractionNotifier(this._extractReportFromFileLlm)
      : super(const AsyncValue.data(null));

  final ExtractReportFromFileLlm _extractReportFromFileLlm;

  /// Extracts report data from the supplied file path using LLM.
  Future<Either<Failure, Report>> extractFromFile(String filePath) async {
    state = const AsyncValue.loading();

    final result = await _extractReportFromFileLlm(filePath);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (report) => AsyncValue.data(report),
    );

    return result;
  }

  /// Resets the state to the initial null report.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for [ExtractionNotifier].
final extractionProvider =
    StateNotifierProvider<ExtractionNotifier, AsyncValue<Report?>>(
  (ref) => ExtractionNotifier(getIt<ExtractReportFromFileLlm>()),
);
