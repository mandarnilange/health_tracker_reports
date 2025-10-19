import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/domain/entities/health_entry.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/presentation/providers/timeline_provider.dart';
import 'package:health_tracker_reports/presentation/widgets/health_log_card.dart';
import 'package:intl/intl.dart';

class HealthTimeline extends ConsumerWidget {
  const HealthTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(timelineFilterProvider);
    final timeline = ref.watch(timelineProvider);

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
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _TimelineEntry(entry: entry);
                  },
                ),
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

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.entry});

  final HealthEntry entry;

  @override
  Widget build(BuildContext context) {
    if (entry is HealthLog) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: HealthLogCard(log: entry as HealthLog),
      );
    }

    if (entry is Report) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _ReportTimelineCard(report: entry as Report),
      );
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insert_drive_file_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  report.labName,
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  _dateFormat.format(report.date),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${report.totalBiomarkerCount} biomarkers',
              style: theme.textTheme.bodyMedium,
            ),
            if (outOfRange > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$outOfRange out of range',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
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
