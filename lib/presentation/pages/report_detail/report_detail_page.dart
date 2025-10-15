import 'package:flutter/material.dart';

/// Report detail page that displays comprehensive information about a specific report.
///
/// This page shows all biomarkers, trends, and allows users to view
/// detailed analysis of a single health report.
class ReportDetailPage extends StatelessWidget {
  /// The ID of the report to display
  final String reportId;

  const ReportDetailPage({
    super.key,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: Center(
        child: Text('Report Detail Page - Coming Soon\nReport ID: $reportId'),
      ),
    );
  }
}
