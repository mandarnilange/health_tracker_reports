import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/core/di/injection_container.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/usecases/get_unified_timeline.dart';

final getUnifiedTimelineUseCaseProvider = Provider<GetUnifiedTimeline>(
  (ref) => getIt<GetUnifiedTimeline>(),
);

final timelineFilterProvider = StateProvider<HealthEntryType?>((ref) => null);

final timelineProvider =
    StateNotifierProvider<TimelineNotifier, AsyncValue<List<HealthEntry>>>(
  (ref) => TimelineNotifier(
    getUnifiedTimeline: ref.read(getUnifiedTimelineUseCaseProvider),
  ),
);

final filteredTimelineProvider = Provider<AsyncValue<List<HealthEntry>>>((ref) {
  final timeline = ref.watch(timelineProvider);
  final filter = ref.watch(timelineFilterProvider);

  if (filter == null) {
    return timeline;
  }

  return timeline.whenData(
    (entries) =>
        entries.where((entry) => entry.entryType == filter).toList(),
  );
});

class TimelineNotifier extends StateNotifier<AsyncValue<List<HealthEntry>>> {
  TimelineNotifier({required GetUnifiedTimeline getUnifiedTimeline})
      : _getUnifiedTimeline = getUnifiedTimeline,
        super(const AsyncValue.loading()) {
    loadTimeline();
  }

  final GetUnifiedTimeline _getUnifiedTimeline;

  Future<void> loadTimeline({HealthEntryType? filter}) async {
    state = const AsyncValue.loading();
    final result = await _getUnifiedTimeline(filterType: filter);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (entries) => AsyncValue.data(entries),
    );
  }

  Future<void> refresh() => loadTimeline();
}
