import 'package:flutter/material.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_comparison.dart';
import 'package:intl/intl.dart';

/// Widget that displays a comparison table for biomarker values across multiple reports.
class ComparisonTable extends StatelessWidget {
  final BiomarkerComparison comparison;

  const ComparisonTable({
    super.key,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        columns: [
          const DataColumn(
            label: Text(
              'Report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...comparison.comparisons.map((dataPoint) {
            return DataColumn(
              label: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(dataPoint.reportDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dataPoint.reportId,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
        rows: [
          // Value row
          DataRow(
            cells: [
              const DataCell(
                Text(
                  'Value',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ...comparison.comparisons.map((dataPoint) {
                final color = _getStatusColor(context, dataPoint.status);
                return DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      border: Border.all(color: color.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${dataPoint.value} ${dataPoint.unit}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          // Change row
          DataRow(
            cells: [
              const DataCell(
                Text(
                  'Change',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ...comparison.comparisons.map((dataPoint) {
                if (dataPoint.deltaFromPrevious == null) {
                  return const DataCell(
                    Text(
                      '-',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final delta = dataPoint.deltaFromPrevious!;
                final percentage = dataPoint.percentageChangeFromPrevious!;
                final isIncrease = delta > 0;

                return DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: isIncrease ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${delta.abs().toStringAsFixed(1)} ${dataPoint.unit}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isIncrease ? Colors.red : Colors.green,
                            ),
                          ),
                          Text(
                            '(${percentage.abs().toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          // Status row
          DataRow(
            cells: [
              const DataCell(
                Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ...comparison.comparisons.map((dataPoint) {
                final statusText = dataPoint.status == BiomarkerStatus.normal
                    ? 'Normal'
                    : dataPoint.status == BiomarkerStatus.high
                        ? 'High'
                        : 'Low';

                return DataCell(
                  Chip(
                    label: Text(
                      statusText,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(context, dataPoint.status)
                        .withOpacity(0.2),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, BiomarkerStatus status) {
    switch (status) {
      case BiomarkerStatus.normal:
        return Colors.green;
      case BiomarkerStatus.high:
        return Colors.red;
      case BiomarkerStatus.low:
        return Colors.orange;
    }
  }
}
