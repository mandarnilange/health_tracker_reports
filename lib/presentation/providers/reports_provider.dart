import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/get_all_reports.dart';
import 'package:health_tracker_reports/domain/usecases/save_report.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';

/// Enum representing available sorting options for reports.
enum ReportSortOption {
  /// Sort by date, newest first (default)
  newestFirst,

  /// Sort by date, oldest first
  oldestFirst,

  /// Sort by number of out-of-range biomarkers (highest first)
  mostOutOfRange,

  /// Sort by lab name alphabetically
  labName,
}

/// StateNotifier responsible for managing the list of reports.
class ReportsNotifier extends StateNotifier<AsyncValue<List<Report>>> {
  ReportsNotifier({
    required GetAllReports getAllReports,
    required SaveReport Function() saveReportProvider,
  })  : _getAllReports = getAllReports,
        _saveReportProvider = saveReportProvider,
        super(const AsyncValue.loading()) {
    _initialize();
  }

  final GetAllReports _getAllReports;
  final SaveReport Function() _saveReportProvider;

  /// Current sort option for the reports list
  ReportSortOption _sortOption = ReportSortOption.newestFirst;

  /// Gets the current sort option
  ReportSortOption get currentSortOption => _sortOption;

  /// Loads all reports from the repository.
  Future<void> loadReports() async {
    state = const AsyncValue.loading();

    final result = await _getAllReports();

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (reports) => AsyncValue.data(_sortReports(reports)),
    );
  }

  /// Sorts a list of reports based on the current sort option.
  List<Report> _sortReports(List<Report> reports) {
    final sortedReports = List<Report>.from(reports);

    switch (_sortOption) {
      case ReportSortOption.newestFirst:
        sortedReports.sort((a, b) => b.date.compareTo(a.date));
        break;
      case ReportSortOption.oldestFirst:
        sortedReports.sort((a, b) => a.date.compareTo(b.date));
        break;
      case ReportSortOption.mostOutOfRange:
        sortedReports
            .sort((a, b) => b.outOfRangeCount.compareTo(a.outOfRangeCount));
        break;
      case ReportSortOption.labName:
        sortedReports.sort((a, b) => a.labName.compareTo(b.labName));
        break;
    }

    return sortedReports;
  }

  /// Sets the sort option and re-sorts the current reports list.
  void setSortOption(ReportSortOption option) {
    _sortOption = option;

    state.whenData((reports) {
      state = AsyncValue.data(_sortReports(reports));
    });
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

  void _initialize() {
    Future<void>.microtask(loadReports);
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
