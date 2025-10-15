import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';

/// StateNotifier responsible for managing the list of reports.
class ReportsNotifier extends StateNotifier<AsyncValue<List<Report>>> {
  ReportsNotifier({
    required GetAllReports getAllReports,
    required SaveReport Function() saveReportProvider,
  })  : _getAllReports = getAllReports,
        _saveReportProvider = saveReportProvider,
        super(const AsyncValue.loading());

  final GetAllReports _getAllReports;
  final SaveReport Function() _saveReportProvider;

  /// Loads all reports from the repository.
  Future<void> loadReports() async {
    state = const AsyncValue.loading();

    final result = await _getAllReports();

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (reports) => AsyncValue.data(reports),
    );
  }

  /// Persists a report and refreshes the list.
  Future<Either<Failure, Report>> saveReport(Report report) async {
    final result = await _saveReportProvider()(report);

    return await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
        return Left(failure);
      },
      (savedReport) async {
        await loadReports();
        return Right(savedReport);
      },
    );
  }

  /// Public refresh helper for UI triggers.
  Future<void> refresh() async {
    await loadReports();
  }
}

/// Provider for [ReportsNotifier] using dependency injection.
final reportsProvider =
    StateNotifierProvider<ReportsNotifier, AsyncValue<List<Report>>>(
  (ref) => ReportsNotifier(
    getAllReports: ref.watch(getAllReportsProvider),
    saveReportProvider: () => ref.read(saveReportUseCaseProvider),
  ),
);
