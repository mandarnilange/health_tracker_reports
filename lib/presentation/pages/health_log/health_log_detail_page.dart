import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/presentation/pages/health_log/health_log_entry_sheet.dart';
import 'package:health_tracker_reports/presentation/pages/trends/trends_page_args.dart';
import 'package:health_tracker_reports/presentation/providers/health_log_provider.dart';
import 'package:health_tracker_reports/presentation/providers/vital_trend_provider.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:intl/intl.dart';

/// Detail page that displays a complete health log entry with all vitals and their statuses.
///
/// Shows:
/// - Timestamp of the log entry
/// - All vital measurements with values, units, and status indicators
/// - Visual range indicators (green/orange/red)
/// - Reference ranges for each vital
/// - Notes (if present)
/// - Edit and delete actions
class HealthLogDetailPage extends ConsumerWidget {
  const HealthLogDetailPage({
    super.key,
    required this.log,
  });

  /// The health log to display
  final HealthLog log;

  static final DateFormat _timestampFormatter =
      DateFormat('MMM d, yyyy • h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Log Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => _onEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: () => _onDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimestampCard(context),
            const SizedBox(height: 16),
            ..._buildVitalCards(context, ref),
            if (log.notes != null && log.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildNotesCard(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the timestamp card at the top of the page
  Widget _buildTimestampCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Text(
              _timestampFormatter.format(log.timestamp),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of vital measurement cards
  List<Widget> _buildVitalCards(BuildContext context, WidgetRef ref) {
    return log.vitals
        .map((vital) => _buildVitalCard(context, ref, vital))
        .toList();
  }

  /// Builds a single vital measurement card
  Widget _buildVitalCard(
    BuildContext context,
    WidgetRef ref,
    VitalMeasurement vital,
  ) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(vital.status);
    final statusEmoji = _getStatusEmoji(vital.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openTrendForVital(context, ref, vital),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    vital.type.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      vital.type.displayName,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    statusEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${_formatValue(vital.value)} ${vital.unit}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (vital.referenceRange != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Reference: ${_formatValue(vital.referenceRange!.min)}-${_formatValue(vital.referenceRange!.max)} ${vital.unit}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the notes card
  Widget _buildNotesCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              log.notes!.trim(),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Formats a numeric value for display
  String _formatValue(double value) {
    // If it's a whole number, don't show decimal places
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    // Otherwise show 1 decimal place
    return value.toStringAsFixed(1);
  }

  /// Gets the color for a vital status
  Color _getStatusColor(VitalStatus status) {
    switch (status) {
      case VitalStatus.normal:
        return Colors.green.shade700;
      case VitalStatus.warning:
        return Colors.orange.shade700;
      case VitalStatus.critical:
        return Colors.red.shade700;
    }
  }

  /// Gets the emoji indicator for a vital status
  String _getStatusEmoji(VitalStatus status) {
    switch (status) {
      case VitalStatus.normal:
        return '🟢';
      case VitalStatus.warning:
        return '🟡';
      case VitalStatus.critical:
        return '🔴';
    }
  }

  /// Handles edit action
  void _onEdit(BuildContext context) {
    HealthLogEntrySheet.show(context, initialLog: log);
  }

  void _openTrendForVital(
    BuildContext context,
    WidgetRef ref,
    VitalMeasurement vital,
  ) {
    ref.read(selectedVitalTypeProvider.notifier).state = vital.type;
    context.push(
      RouteNames.trends,
      extra: TrendsPageArgs(
        initialTab: TrendsTab.vitals,
        initialVitalType: vital.type,
      ),
    );
  }

  /// Handles delete action
  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Health Log'),
        content: const Text(
          'Are you sure you want to delete this health log? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Perform the delete
    await ref.read(healthLogsProvider.notifier).deleteHealthLog(log.id);

    if (!context.mounted) return;

    // Check if delete was successful
    final state = ref.read(healthLogsProvider);
    state.when(
      data: (_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health log deleted.')),
        );
      },
      loading: () {},
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $error')),
        );
      },
    );
  }
}
