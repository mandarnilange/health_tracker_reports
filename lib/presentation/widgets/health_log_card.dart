import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/presentation/providers/health_log_provider.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
import 'package:intl/intl.dart';

class HealthLogCard extends ConsumerWidget {
  const HealthLogCard({super.key, required this.log});

  final HealthLog log;

  static final DateFormat _timestampFormatter =
      DateFormat('MMM d, yyyy • h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaries = _buildSummaries(log.vitals);

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
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
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await ref.read(healthLogsProvider.notifier).deleteHealthLog(log.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health log deleted')),
        );
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.push(RouteNames.healthLogDetailWithId(log.id), extra: log);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.note_alt, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _timestampFormatter.format(log.timestamp),
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                if (summaries.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...summaries.map(
                    (summary) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          _StatusDot(
                            key: Key('vital-status-${summary.key}'),
                            status: summary.status,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              summary.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_VitalSummary> _buildSummaries(List<VitalMeasurement> vitals) {
    if (vitals.isEmpty) {
      return const [];
    }

    final summaries = <_VitalSummary>[];
    final visibleVitals =
        vitals.where((vital) => vital.type.isDefaultVisible).toList();

    VitalMeasurement? safeSystolic;
    VitalMeasurement? safeDiastolic;
    for (final vital in visibleVitals) {
      if (vital.type == VitalType.bloodPressureSystolic && safeSystolic == null) {
        safeSystolic = vital;
      } else if (vital.type == VitalType.bloodPressureDiastolic &&
          safeDiastolic == null) {
        safeDiastolic = vital;
      }
    }

    if (safeSystolic != null && safeDiastolic != null) {
      summaries.add(
        _VitalSummary(
          key: 'bloodPressure',
          label:
              'BP - ${_formatNumber(safeSystolic.value)}/${_formatNumber(safeDiastolic.value)}',
          status: _combineStatuses([
            safeSystolic.status,
            safeDiastolic.status,
          ]),
        ),
      );
    } else {
      if (safeSystolic != null) {
        summaries.add(
          _VitalSummary(
            key: VitalType.bloodPressureSystolic.name,
            label:
                'BP Systolic - ${_formatMeasurementValue(safeSystolic)}',
            status: safeSystolic.status,
          ),
        );
      }
      if (safeDiastolic != null) {
        summaries.add(
          _VitalSummary(
            key: VitalType.bloodPressureDiastolic.name,
            label:
                'BP Diastolic - ${_formatMeasurementValue(safeDiastolic)}',
            status: safeDiastolic.status,
          ),
        );
      }
    }

    for (final measurement in visibleVitals) {
      if (measurement.type == VitalType.bloodPressureSystolic ||
          measurement.type == VitalType.bloodPressureDiastolic) {
        // Already handled above
        continue;
      }

      summaries.add(
        _VitalSummary(
          key: measurement.type.name,
          label:
              '${measurement.type.displayName} - ${_formatMeasurementValue(measurement)}',
          status: measurement.status,
        ),
      );
    }

    if (summaries.isEmpty) {
      for (final measurement in vitals.take(3)) {
        summaries.add(
          _VitalSummary(
            key: measurement.type.name,
            label:
                '${measurement.type.displayName} - ${_formatMeasurementValue(measurement)}',
            status: measurement.status,
          ),
        );
      }
    }

    return summaries.take(3).toList();
  }

  String _formatMeasurementValue(VitalMeasurement measurement) {
    final value = _formatNumber(measurement.value);
    final unit = measurement.unit.trim();

    if (unit.isEmpty) {
      return value;
    }

    if (unit == '%') {
      return '$value%';
    }

    return '$value $unit';
  }

  String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  VitalStatus _combineStatuses(List<VitalStatus> statuses) {
    if (statuses.contains(VitalStatus.critical)) {
      return VitalStatus.critical;
    }
    if (statuses.contains(VitalStatus.warning)) {
      return VitalStatus.warning;
    }
    return VitalStatus.normal;
  }
}

class _VitalSummary {
  const _VitalSummary({
    required this.key,
    required this.label,
    required this.status,
  });

  final String key;
  final String label;
  final VitalStatus status;
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status, super.key});

  final VitalStatus status;

  Color _colorForStatus() {
    switch (status) {
      case VitalStatus.normal:
        return Colors.green.shade600;
      case VitalStatus.warning:
        return Colors.orange.shade700;
      case VitalStatus.critical:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _colorForStatus(),
        shape: BoxShape.circle,
      ),
    );
  }
}
