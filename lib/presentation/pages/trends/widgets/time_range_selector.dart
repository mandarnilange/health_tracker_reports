import 'package:flutter/material.dart';
import 'package:health_tracker_reports/presentation/providers/trend_provider.dart';

/// Widget that displays time range selection chips.
///
/// Provides a horizontal row of ChoiceChips for selecting different
/// time ranges (3M, 6M, 1Y, All) to filter trend data.
class TimeRangeSelector extends StatelessWidget {
  /// Currently selected time range
  final TimeRange selectedTimeRange;

  /// Callback when a time range is selected
  final void Function(TimeRange) onTimeRangeSelected;

  const TimeRangeSelector({
    super.key,
    required this.selectedTimeRange,
    required this.onTimeRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Time Range',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: TimeRange.values.map((timeRange) {
                final isSelected = timeRange == selectedTimeRange;
                return ChoiceChip(
                  label: Text(timeRange.displayText),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onTimeRangeSelected(timeRange);
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  tooltip: _getTooltip(timeRange),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a tooltip description for the time range
  String _getTooltip(TimeRange range) {
    switch (range) {
      case TimeRange.threeMonths:
        return 'Last 3 months';
      case TimeRange.sixMonths:
        return 'Last 6 months';
      case TimeRange.oneYear:
        return 'Last 1 year';
      case TimeRange.all:
        return 'All available data';
    }
  }
}
