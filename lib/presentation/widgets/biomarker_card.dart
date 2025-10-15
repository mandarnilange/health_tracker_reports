import 'package:flutter/material.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';

/// A reusable widget for displaying a biomarker with color-coded status.
///
/// Shows the biomarker name, value, unit, reference range, and status indicator.
/// The card background color changes based on the biomarker status:
/// - Green for normal values
/// - Red for high values
/// - Yellow for low values
class BiomarkerCard extends StatelessWidget {
  final Biomarker biomarker;

  const BiomarkerCard({
    super.key,
    required this.biomarker,
  });

  @override
  Widget build(BuildContext context) {
    final status = biomarker.status;
    final statusColor = _getStatusColor(status);
    final backgroundColor = _getBackgroundColor(status);
    final statusText = _getStatusText(status);

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Biomarker name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      biomarker.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // Value and unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    biomarker.value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    biomarker.unit,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              // Reference range
              Text(
                'Reference Range: ${biomarker.referenceRange.min.toStringAsFixed(1)} - ${biomarker.referenceRange.max.toStringAsFixed(1)} ${biomarker.unit}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BiomarkerStatus status) {
    switch (status) {
      case BiomarkerStatus.normal:
        return Colors.green;
      case BiomarkerStatus.high:
        return Colors.red;
      case BiomarkerStatus.low:
        return Colors.orange;
    }
  }

  Color _getBackgroundColor(BiomarkerStatus status) {
    switch (status) {
      case BiomarkerStatus.normal:
        return Colors.green.shade50;
      case BiomarkerStatus.high:
        return Colors.red.shade50;
      case BiomarkerStatus.low:
        return Colors.yellow.shade50;
    }
  }

  String _getStatusText(BiomarkerStatus status) {
    switch (status) {
      case BiomarkerStatus.normal:
        return 'Normal';
      case BiomarkerStatus.high:
        return 'High';
      case BiomarkerStatus.low:
        return 'Low';
    }
  }
}
