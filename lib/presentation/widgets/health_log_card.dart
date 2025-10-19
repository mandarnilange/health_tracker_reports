import 'package:flutter/material.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:intl/intl.dart';

class HealthLogCard extends StatelessWidget {
  const HealthLogCard({super.key, required this.log});

  final HealthLog log;

  static final DateFormat _timestampFormatter =
      DateFormat('MMM d, yyyy • h:mm a');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vitals = log.vitals;
    final displayedVitals = vitals.take(3).toList();

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
                const Icon(Icons.note_alt, size: 20),
                const SizedBox(width: 8),
                Text(
                  _timestampFormatter.format(log.timestamp),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (displayedVitals.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displayedVitals.map(_buildVitalChip).toList(),
              ),
            if (vitals.length > displayedVitals.length)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${vitals.length - displayedVitals.length} more',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            if (log.notes != null && log.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                log.notes!.trim(),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVitalChip(VitalMeasurement measurement) {
    Color backgroundColor;
    IconData? statusIcon;

    switch (measurement.status) {
      case VitalStatus.normal:
        backgroundColor = Colors.green.shade50;
        break;
      case VitalStatus.warning:
        backgroundColor = Colors.orange.shade50;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case VitalStatus.critical:
        backgroundColor = Colors.red.shade50;
        statusIcon = Icons.error_outline;
        break;
    }

    final displayName = measurement.type.displayName;
    final unit = measurement.unit;

    return Chip(
      avatar: statusIcon != null
          ? Icon(statusIcon, color: Colors.orange.shade700, size: 18)
          : null,
      backgroundColor: backgroundColor,
      label: Text(
        '$displayName • ${measurement.value.toStringAsFixed(0)} $unit',
      ),
    );
  }
}
