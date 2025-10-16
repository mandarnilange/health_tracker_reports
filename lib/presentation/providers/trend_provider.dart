import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/domain/usecases/get_biomarker_trend.dart';
import 'package:health_tracker_reports/presentation/providers/report_usecase_providers.dart';
import 'package:health_tracker_reports/presentation/providers/reports_provider.dart';

/// Enum representing the available time range options for trend viewing.
enum TimeRange {
  /// Show data from the last 3 months
  threeMonths,

  /// Show data from the last 6 months
  sixMonths,

  /// Show data from the last 1 year
  oneYear,

  /// Show all available data
  all,
}

/// Extension to convert TimeRange enum to display string
extension TimeRangeDisplay on TimeRange {
  String get displayText {
    switch (this) {
      case TimeRange.threeMonths:
        return '3M';
      case TimeRange.sixMonths:
        return '6M';
      case TimeRange.oneYear:
        return '1Y';
      case TimeRange.all:
        return 'All';
    }
  }

  /// Calculates the cutoff DateTime for this range relative to [referenceDate].
  DateTime? cutoffDate({DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    switch (this) {
      case TimeRange.threeMonths:
        return DateTime(now.year, now.month - 3, now.day);
      case TimeRange.sixMonths:
        return DateTime(now.year, now.month - 6, now.day);
      case TimeRange.oneYear:
        return DateTime(now.year - 1, now.month, now.day);
      case TimeRange.all:
        return null; // No cutoff, show all data
    }
  }
}

/// Provider that exposes the current reference date (primarily for testing).
final nowProvider = Provider<DateTime>((ref) => DateTime.now());

/// State class for trend data.
class TrendState {
  final String? selectedBiomarkerName;
  final TimeRange selectedTimeRange;
  final AsyncValue<List<TrendDataPoint>> trendData;

  const TrendState({
    this.selectedBiomarkerName,
    this.selectedTimeRange = TimeRange.all,
    this.trendData = const AsyncValue.data([]),
  });

  TrendState copyWith({
    String? selectedBiomarkerName,
    TimeRange? selectedTimeRange,
    AsyncValue<List<TrendDataPoint>>? trendData,
  }) {
    return TrendState(
      selectedBiomarkerName:
          selectedBiomarkerName ?? this.selectedBiomarkerName,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
      trendData: trendData ?? this.trendData,
    );
  }
}

/// StateNotifier for managing trend state and orchestrating data loading.
class TrendNotifier extends StateNotifier<TrendState> {
  TrendNotifier(this._ref, this._getBiomarkerTrend) : super(const TrendState());

  final Ref _ref;
  final GetBiomarkerTrend _getBiomarkerTrend;

  /// Selects a biomarker to display trends for and triggers loading.
  Future<void> selectBiomarker(String? biomarkerName) async {
    state = TrendState(
      selectedBiomarkerName: biomarkerName,
      selectedTimeRange: state.selectedTimeRange,
      trendData: state.trendData,
    );

    if (biomarkerName == null || biomarkerName.isEmpty) {
      state = state.copyWith(
        trendData: const AsyncValue.data([]),
      );
      return;
    }

    await _loadTrendData(
      biomarkerName: biomarkerName,
      timeRange: state.selectedTimeRange,
    );
  }

  /// Selects a time range for filtering trend data and reloads if needed.
  Future<void> selectTimeRange(TimeRange timeRange) async {
    state = state.copyWith(selectedTimeRange: timeRange);

    final biomarkerName = state.selectedBiomarkerName;
    if (biomarkerName == null || biomarkerName.isEmpty) {
      return;
    }

    await _loadTrendData(
      biomarkerName: biomarkerName,
      timeRange: timeRange,
    );
  }

  /// Reloads data using the currently selected biomarker and time range.
  Future<void> refresh() async {
    final biomarkerName = state.selectedBiomarkerName;
    if (biomarkerName == null || biomarkerName.isEmpty) {
      return;
    }
    await _loadTrendData(
      biomarkerName: biomarkerName,
      timeRange: state.selectedTimeRange,
    );
  }

  Future<void> _loadTrendData({
    required String biomarkerName,
    required TimeRange timeRange,
  }) async {
    state = state.copyWith(trendData: const AsyncValue.loading());

    final now = _ref.read(nowProvider);
    final startDate = timeRange.cutoffDate(referenceDate: now);

    final result = await _getBiomarkerTrend(
      biomarkerName,
      startDate: startDate,
      endDate: null,
    );

    state = result.fold(
      (failure) => state.copyWith(
          trendData: AsyncValue.error(failure, StackTrace.current)),
      (dataPoints) => state.copyWith(trendData: AsyncValue.data(dataPoints)),
    );
  }
}

/// Provider for the trend state notifier.
final trendProvider = StateNotifierProvider<TrendNotifier, TrendState>((ref) {
  return TrendNotifier(
    ref,
    ref.watch(getBiomarkerTrendProvider),
  );
});

/// Provider that returns available biomarker names from all reports
final availableBiomarkersProvider = Provider<List<String>>((ref) {
  final reportsAsync = ref.watch(reportsProvider);

  return reportsAsync.when(
    data: (reports) {
      // Collect all unique biomarker names
      final Set<String> biomarkerNames = {};
      for (final report in reports) {
        for (final biomarker in report.biomarkers) {
          biomarkerNames.add(biomarker.name);
        }
      }
      // Return sorted list
      final names = biomarkerNames.toList()..sort();
      return names;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
