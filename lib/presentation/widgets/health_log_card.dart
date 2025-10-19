import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/domain/entities/health_log.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(RouteNames.healthLogDetailWithId(log.id), extra: log);
        },
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
      ),
    );
  }

  Widget _buildVitalChip(VitalMeasurement measurement) {
    Color backgroundColor;
    Color textColor;
    IconData? statusIcon;

    switch (measurement.status) {
      case VitalStatus.normal:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case VitalStatus.warning:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case VitalStatus.critical:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        statusIcon = Icons.error_outline;
        break;
    }

    final displayName = measurement.type.displayName;
    final unit = measurement.unit;
    final value = measurement.value;
    final formattedValue = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);

    return Chip(
      avatar: statusIcon != null
          ? Icon(statusIcon, color: textColor, size: 16)
          : null,
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(
        '$displayName: $formattedValue $unit',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
