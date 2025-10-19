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
    final overview = _buildOverview(log.vitals);

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
                if (overview.bp != null || overview.spo2 != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (overview.bp != null)
                        Expanded(
                          child: _VitalLabel(
                            summary: overview.bp!,
                            keySuffix: 'bloodPressure',
                          ),
                        ),
                      if (overview.bp != null && overview.spo2 != null)
                        const SizedBox(width: 12),
                      if (overview.spo2 != null)
                        Expanded(
                          child: _VitalLabel(
                            summary: overview.spo2!,
                            keySuffix: 'oxygenSaturation',
                          ),
                        ),
                    ],
                  ),
                ],
                if (overview.hr != null || overview.extraCount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (overview.hr != null)
                        Expanded(
                          child: _VitalLabel(
                            summary: overview.hr!,
                            keySuffix: 'heartRate',
                          ),
                        )
                      else
                        const Spacer(),
                      if (overview.extraCount > 0)
                        Text(
                          '+${overview.extraCount}',
                          style: theme.textTheme.bodyMedium?.copyWith(
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
      ),
    );
  }

  _VitalOverview _buildOverview(List<VitalMeasurement> vitals) {
    if (vitals.isEmpty) {
      return const _VitalOverview();
    }

    VitalMeasurement? findVital(VitalType type) {
      for (final measurement in vitals) {
        if (measurement.type == type) {
          return measurement;
        }
      }
      return null;
    }

    final systolic = findVital(VitalType.bloodPressureSystolic);
    final diastolic = findVital(VitalType.bloodPressureDiastolic);
    final spo2 = findVital(VitalType.oxygenSaturation);
    final heartRate = findVital(VitalType.heartRate);

    final usedIds = <String?>{
      systolic?.id,
      diastolic?.id,
      spo2?.id,
      heartRate?.id,
    }..removeWhere((id) => id == null);

    final extras = vitals
        .where((measurement) => !usedIds.contains(measurement.id))
        .toList();

    _VitalHighlight? bp;
    if (systolic != null && diastolic != null) {
      bp = _VitalHighlight(
        label:
            'BP - ${_formatNumber(systolic.value)}/${_formatNumber(diastolic.value)}',
        status: _combineStatuses([systolic.status, diastolic.status]),
      );
    } else if (systolic != null) {
      bp = _VitalHighlight(
        label: 'BP Systolic - ${_formatMeasurementValue(systolic)}',
        status: systolic.status,
      );
    } else if (diastolic != null) {
      bp = _VitalHighlight(
        label: 'BP Diastolic - ${_formatMeasurementValue(diastolic)}',
        status: diastolic.status,
      );
    }

    _VitalHighlight? spo2Summary;
    if (spo2 != null) {
      spo2Summary = _VitalHighlight(
        label: 'SpO2 - ${_formatMeasurementValue(spo2)}',
        status: spo2.status,
      );
    }

    _VitalHighlight? hrSummary;
    if (heartRate != null) {
      hrSummary = _VitalHighlight(
        label: 'HR - ${_formatMeasurementValue(heartRate)}',
        status: heartRate.status,
      );
    }

    final extraCount = extras.length +
        ((systolic != null && diastolic == null) ? 1 : 0) +
        ((diastolic != null && systolic == null) ? 1 : 0);

    return _VitalOverview(
      bp: bp,
      spo2: spo2Summary,
      hr: hrSummary,
      extraCount: extraCount,
    );
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

class _VitalHighlight {
  const _VitalHighlight({required this.label, required this.status});

  final String label;
  final VitalStatus status;
}

class _VitalOverview {
  const _VitalOverview({
    this.bp,
    this.spo2,
    this.hr,
    this.extraCount = 0,
  });

  final _VitalHighlight? bp;
  final _VitalHighlight? spo2;
  final _VitalHighlight? hr;
  final int extraCount;
}

class _VitalLabel extends StatelessWidget {
  const _VitalLabel({required this.summary, required this.keySuffix});

  final _VitalHighlight summary;
  final String keySuffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _StatusDot(
          key: Key('vital-status-$keySuffix'),
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
    );
  }
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
