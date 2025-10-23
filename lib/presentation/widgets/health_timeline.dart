import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/presentation/providers/timeline_provider.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:health_tracker_reports/presentation/widgets/health_log_card.dart';
import 'package:intl/intl.dart';

const double _timelineLeftPadding = 16;
const double _timelineMarkerColumnWidth = 38;
const double _timelineSpacing = 12;
const double _timelineLineWidth = 2;
const double _markerDiameter = 18;

Color _timelineRailColor(BuildContext context) {
  final theme = Theme.of(context);
  return theme.colorScheme.outlineVariant.withOpacity(0.22);
}

class HealthTimeline extends ConsumerWidget {
  const HealthTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(timelineFilterProvider);
    final timeline = ref.watch(filteredTimelineProvider);

    return Column(
      children: [
        _FilterBar(filter: filter),
        Expanded(
          child: timeline.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _TimelineError(message: error.toString()),
            data: (entries) {
              if (entries.isEmpty) {
                return const _TimelineEmpty();
              }

              return RefreshIndicator(
                onRefresh: () => ref.read(timelineProvider.notifier).refresh(),
                child: _TimelineScroll(entries: entries),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter});

  final HealthEntryType? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        children: [
          _FilterChip(
            label: 'All',
            selected: filter == null,
            onSelected: (_) =>
                ref.read(timelineFilterProvider.notifier).state = null,
          ),
          _FilterChip(
            label: 'Lab Reports',
            selected: filter == HealthEntryType.labReport,
            onSelected: (_) => ref.read(timelineFilterProvider.notifier).state =
                HealthEntryType.labReport,
          ),
          _FilterChip(
            label: 'Health Logs',
            selected: filter == HealthEntryType.healthLog,
            onSelected: (_) => ref.read(timelineFilterProvider.notifier).state =
                HealthEntryType.healthLog,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

class _TimelineScroll extends StatelessWidget {
  const _TimelineScroll({required this.entries});

  final List<HealthEntry> entries;

  static const int _maxVisibleGroups = 2;

  @override
  Widget build(BuildContext context) {
    final groups = _TimelineGroup.fromEntries(entries);
    // Limit to 2 most recent date groups to prevent sticky header clutter
    final visibleGroups = groups.take(_maxVisibleGroups).toList();
    final hasMoreGroups = groups.length > _maxVisibleGroups;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 4)),
        for (var i = 0; i < visibleGroups.length; i++) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _DateHeaderDelegate(
              label: visibleGroups[i].label,
              isFirstGroup: i == 0,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _TimelineItem(model: visibleGroups[i].items[index]),
              childCount: visibleGroups[i].items.length,
            ),
          ),
        ],
        if (hasMoreGroups)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: FilledButton.tonal(
                  onPressed: () {
                    // TODO: Implement load more functionality with pagination
                  },
                  child: const Text('Load older entries'),
                ),
              ),
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

class _TimelineGroup {
  _TimelineGroup(this.date, this.items) : label = _formatRelativeDate(date);

  final DateTime date;
  final String label;
  final List<_TimelineEntryModel> items;

  static List<_TimelineGroup> fromEntries(List<HealthEntry> entries) {
    final sorted = entries.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final groups = <_TimelineGroup>[];
    _TimelineGroup? current;

    for (var i = 0; i < sorted.length; i++) {
      final entry = sorted[i];
      final dateKey = DateTime(
          entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);

      if (current == null || !_sameDay(current.date, dateKey)) {
        current = _TimelineGroup(dateKey, []);
        groups.add(current);
      }

      current.items.add(
        _TimelineEntryModel(
          entry: entry,
          showTopConnector: i != 0,
          showBottomConnector: i != sorted.length - 1,
        ),
      );
    }

    return groups;
  }

  static bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (_sameDay(date, today)) {
      return 'Today • ${DateFormat('MMMM d, yyyy').format(date)}';
    }
    if (_sameDay(date, yesterday)) {
      return 'Yesterday • ${DateFormat('MMMM d, yyyy').format(date)}';
    }
    return DateFormat('MMMM d, yyyy').format(date);
  }
}

class _TimelineEntryModel {
  const _TimelineEntryModel({
    required this.entry,
    required this.showTopConnector,
    required this.showBottomConnector,
  });

  final HealthEntry entry;
  final bool showTopConnector;
  final bool showBottomConnector;
}

class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  _DateHeaderDelegate({
    required this.label,
    required this.isFirstGroup,
  });

  final String label;
  final bool isFirstGroup;

  @override
  double get minExtent => 44;

  @override
  double get maxExtent => 44;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final lineColor = _timelineRailColor(context);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: _timelineLeftPadding),
          SizedBox(
            width: _timelineMarkerColumnWidth,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: _timelineLineWidth,
                height: double.infinity,
                color: isFirstGroup ? Colors.transparent : lineColor,
              ),
            ),
          ),
          const SizedBox(width: _timelineSpacing),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DateHeaderDelegate oldDelegate) {
    return oldDelegate.label != label ||
        oldDelegate.isFirstGroup != isFirstGroup;
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.model});

  final _TimelineEntryModel model;

  Color _getDotColor(BuildContext context) {
    final entry = model.entry;
    if (entry is Report) {
      return Colors.blue.shade700;
    }
    if (entry is HealthLog) {
      return entry.hasWarnings ? Colors.orange.shade700 : Colors.green.shade700;
    }
    return Colors.grey;
  }

  Color _timelineLineColor(BuildContext context) {
    final theme = Theme.of(context);
    return _timelineRailColor(context);
  }

  @override
  Widget build(BuildContext context) {
    final entry = model.entry;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: _timelineLeftPadding),
          SizedBox(
            width: _timelineMarkerColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: _timelineLineWidth,
                      color: model.showTopConnector
                          ? _timelineLineColor(context)
                          : Colors.transparent,
                    ),
                  ),
                ),
                Container(
                  width: _markerDiameter,
                  height: _markerDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getDotColor(context),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: _timelineLineWidth,
                      color: model.showBottomConnector
                          ? _timelineLineColor(context)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: _timelineSpacing),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 16),
              child: _TimelineContent(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineContent extends StatelessWidget {
  const _TimelineContent({required this.entry});

  final HealthEntry entry;

  @override
  Widget build(BuildContext context) {
    if (entry is HealthLog) {
      return HealthLogCard(log: entry as HealthLog);
    }

    if (entry is Report) {
      return _ReportTimelineCard(report: entry as Report);
    }

    return const SizedBox.shrink();
  }
}

class _ReportTimelineCard extends StatelessWidget {
  const _ReportTimelineCard({required this.report});

  final Report report;

  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outOfRange = report.outOfRangeCount;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(RouteNames.reportDetailWithId(report.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('📄', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.labName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '${report.totalBiomarkerCount} biomarkers',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    _dateFormat.format(report.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (outOfRange > 0) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade700, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$outOfRange out of range',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineEmpty extends StatelessWidget {
  const _TimelineEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.medical_information_outlined, size: 48),
          SizedBox(height: 12),
          Text('No entries yet'),
          SizedBox(height: 4),
          Text('Add a lab report or health log to see it here.'),
        ],
      ),
    );
  }
}

class _TimelineError extends StatelessWidget {
  const _TimelineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
