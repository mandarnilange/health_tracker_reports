import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/presentation/providers/trend_provider.dart';
import 'package:health_tracker_reports/presentation/router/route_names.dart';

/// A reusable widget for displaying a biomarker with color-coded status.
///
/// Shows the biomarker name, value, unit, reference range, and status indicator.
/// Tapping the card navigates to the trends page for this biomarker.
class BiomarkerCard extends ConsumerWidget {
  final Biomarker biomarker;

  const BiomarkerCard({
    super.key,
    required this.biomarker,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = biomarker.status;
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: statusColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to trends page with this biomarker selected
          ref.read(trendProvider.notifier).selectBiomarker(biomarker.name);
          context.push(RouteNames.trends);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                statusColor.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Biomarker name and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        biomarker.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[900],
                              letterSpacing: -0.3,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.0,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),
                // Value and unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      biomarker.value.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      biomarker.unit,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                // Reference range
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.straighten,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${biomarker.referenceRange.min.toStringAsFixed(1)} - ${biomarker.referenceRange.max.toStringAsFixed(1)} ${biomarker.unit}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                // Tap hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to view trends',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ],
            ),
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
