import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_comparison.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/comparison_table.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final comparison = BiomarkerComparison(
    biomarkerName: 'Hemoglobin',
    comparisons: [
      ComparisonDataPoint(
        reportId: 'R1',
        reportDate: DateTime(2024, 1, 1),
        value: 13.5,
        unit: 'g/dL',
        status: BiomarkerStatus.normal,
        deltaFromPrevious: null,
        percentageChangeFromPrevious: null,
      ),
      ComparisonDataPoint(
        reportId: 'R2',
        reportDate: DateTime(2024, 2, 1),
        value: 14.2,
        unit: 'g/dL',
        status: BiomarkerStatus.high,
        deltaFromPrevious: 0.7,
        percentageChangeFromPrevious: 5.2,
      ),
    ],
    overallTrend: TrendDirection.increasing,
  );

  testWidgets('renders headings, values, deltas, and status chips',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComparisonTable(comparison: comparison),
        ),
      ),
    );

    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);

    // Header column should include report dates and IDs
    expect(find.text('Jan 01, 2024'), findsOneWidget);
    expect(find.text('R2'), findsOneWidget);

    // Value row should show values with units and status coloration
    expect(find.textContaining('13.5 g/dL'), findsOneWidget);
    expect(find.textContaining('14.2 g/dL'), findsOneWidget);

    // Change row should show arrow icon and delta text
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    expect(find.textContaining('0.7 g/dL'), findsOneWidget);
    expect(find.textContaining('(5.2%)'), findsOneWidget);

    // Status chips should render for each datapoint
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });

  testWidgets('shows placeholder when no previous value', (tester) async {
    final singlePointComparison = comparison.copyWith(
      comparisons: [
        ComparisonDataPoint(
          reportId: 'R1',
          reportDate: DateTime(2024, 1, 1),
          value: 9.8,
          unit: 'g/dL',
          status: BiomarkerStatus.low,
          deltaFromPrevious: null,
          percentageChangeFromPrevious: null,
        ),
      ],
      overallTrend: TrendDirection.insufficient,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComparisonTable(comparison: singlePointComparison),
        ),
      ),
    );

    expect(find.text('-'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
  });
}
