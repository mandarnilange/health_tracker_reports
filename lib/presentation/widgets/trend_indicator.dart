import 'package:flutter/material.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';

/// A compact widget that displays a trend indicator with direction arrow and percentage change.
///
/// This widget is designed for inline display next to biomarker values to show
/// how the biomarker is trending over time.
///
/// Color coding:
/// - Green: Increasing trend (> 5% change)
/// - Red: Decreasing trend (< -5% change)
/// - Orange: Stable trend (-5% to 5% change)
class TrendIndicator extends StatelessWidget {
  /// The trend analysis to display
  final TrendAnalysis trendAnalysis;

  /// Creates a [TrendIndicator] widget.
  const TrendIndicator({
    super.key,
    required this.trendAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getTrendColor();
    final icon = _getTrendIcon();
    final percentageText = _formatPercentage();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 16.0,
        ),
        const SizedBox(width: 4.0),
        Text(
          percentageText,
          style: TextStyle(
            color: color,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Returns the appropriate color based on trend direction.
  Color _getTrendColor() {
    switch (trendAnalysis.direction) {
      case TrendDirection.increasing:
        return Colors.green;
      case TrendDirection.decreasing:
        return Colors.red;
      case TrendDirection.stable:
        return Colors.orange;
    }
  }

  /// Returns the appropriate icon based on trend direction.
  IconData _getTrendIcon() {
    switch (trendAnalysis.direction) {
      case TrendDirection.increasing:
        return Icons.arrow_upward;
      case TrendDirection.decreasing:
        return Icons.arrow_downward;
      case TrendDirection.stable:
        return Icons.arrow_forward;
    }
  }

  /// Formats the percentage change with appropriate sign and one decimal place.
  String _formatPercentage() {
    final value = trendAnalysis.percentageChange;
    final formatted = value.abs().toStringAsFixed(1);

    if (value > 0) {
      return '+$formatted%';
    } else if (value < 0) {
      return '-$formatted%';
    } else {
      return '$formatted%';
    }
  }
}
