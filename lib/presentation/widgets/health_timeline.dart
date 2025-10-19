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

class HealthTimeline extends ConsumerWidget {
  const HealthTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(timelineFilterProvider);
    final timeline = ref.watch(filteredTimelineProvider);

    return Column(
      children: [
        Padding(
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
                onSelected: (_) => ref
                    .read(timelineFilterProvider.notifier)
                    .state = HealthEntryType.labReport,
              ),
              _FilterChip(
                label: 'Health Logs',
                selected: filter == HealthEntryType.healthLog,
                onSelected: (_) => ref
                    .read(timelineFilterProvider.notifier)
                    .state = HealthEntryType.healthLog,
              ),
            ],
          ),
        ),
        Expanded(
          child: timeline.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _TimelineError(message: error.toString()),
            data: (entries) {
              if (entries.isEmpty) {
                return const _TimelineEmpty();
              }

              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(timelineProvider.notifier).refresh(),
                child: _TimelineList(entries: entries),
              );
            },
          ),
        ),
      ],
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

class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.entries});

  final List<HealthEntry> entries;

  static final DateFormat _dateGroupFormat = DateFormat('MMMM d, yyyy');

  @override
  Widget build(BuildContext context) {
    // Group entries by date
    final groupedEntries = <String, List<HealthEntry>>{};
    for (final entry in entries) {
      final dateKey = _dateGroupFormat.format(entry.timestamp);
      groupedEntries.putIfAbsent(dateKey, () => []).add(entry);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        final dateKey = groupedEntries.keys.elementAt(index);
        final dateEntries = groupedEntries[dateKey]!;
        return _DateGroup(dateKey: dateKey, entries: dateEntries);
      },
    );
  }
}

class _DateGroup extends StatelessWidget {
  const _DateGroup({required this.dateKey, required this.entries});

  final String dateKey;
  final List<HealthEntry> entries;

  String _getRelativeDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final firstEntry = entries.first.timestamp;
    final entryDate = DateTime(firstEntry.year, firstEntry.month, firstEntry.day);

    if (entryDate == today) {
      return 'Today • $dateKey';
    } else if (entryDate == yesterday) {
      return 'Yesterday • $dateKey';
    } else {
      return dateKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            _getRelativeDate(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...entries.asMap().entries.map((e) {
          final index = e.key;
          final entry = e.value;
          final isLast = index == entries.length - 1;
          return _TimelineItem(
            entry: entry,
            showLine: !isLast,
          );
        }).toList(),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.entry,
    required this.showLine,
  });

  final HealthEntry entry;
  final bool showLine;

  Color _getDotColor(BuildContext context) {
    if (entry is Report) {
      return Colors.blue.shade700;
    } else if (entry is HealthLog) {
      final log = entry as HealthLog;
      return log.hasWarnings ? Colors.orange.shade700 : Colors.green.shade700;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 16),
          // Timeline dot and line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getDotColor(context),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
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
                  const Icon(Icons.insert_drive_file_outlined, size: 18),
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
