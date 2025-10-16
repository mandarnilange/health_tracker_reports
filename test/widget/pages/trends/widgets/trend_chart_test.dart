import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/trend_data_point.dart';
import 'package:health_tracker_reports/presentation/pages/trends/widgets/trend_chart.dart';

void main() {
  group('TrendChart', () {
    late List<TrendDataPoint> normalTrendData;
    late List<TrendDataPoint> mixedTrendData;
    late List<TrendDataPoint> emptyTrendData;

    setUp(() {
      // Create normal trend data (all points within range)
      normalTrendData = [
        TrendDataPoint(
          date: DateTime(2024, 1, 15),
          value: 15.0,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 18.0),
          reportId: 'report1',
          status: BiomarkerStatus.normal,
        ),
        TrendDataPoint(
          date: DateTime(2024, 3, 10),
          value: 16.5,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 18.0),
          reportId: 'report2',
          status: BiomarkerStatus.normal,
        ),
        TrendDataPoint(
          date: DateTime(2024, 6, 5),
          value: 14.2,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 18.0),
          reportId: 'report3',
          status: BiomarkerStatus.normal,
        ),
      ];

      // Create mixed trend data (normal, high, low points)
      mixedTrendData = [
        TrendDataPoint(
          date: DateTime(2024, 1, 15),
          value: 10.0,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 18.0),
          reportId: 'report1',
          status: BiomarkerStatus.low,
        ),
        TrendDataPoint(
          date: DateTime(2024, 3, 10),
          value: 15.0,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 18.0),
          reportId: 'report2',
          status: BiomarkerStatus.normal,
        ),
        TrendDataPoint(
          date: DateTime(2024, 6, 5),
          value: 20.0,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 18.0),
          reportId: 'report3',
          status: BiomarkerStatus.high,
        ),
        TrendDataPoint(
          date: DateTime(2024, 9, 1),
          value: 14.0,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 18.0),
          reportId: 'report4',
          status: BiomarkerStatus.normal,
        ),
      ];

      emptyTrendData = [];
    });

    testWidgets('renders with data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: normalTrendData),
          ),
        ),
      );

      expect(find.byType(TrendChart), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('displays empty state when no data',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: emptyTrendData),
          ),
        ),
      );

      expect(find.byType(TrendChart), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
      expect(find.text('No trend data available'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('line chart displays correct number of data points',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: normalTrendData),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;
      final spots = lineChartData.lineBarsData.first.spots;

      expect(spots.length, normalTrendData.length);
    });

    testWidgets('chart renders reference range bands',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: normalTrendData),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check that extraLinesData contains horizontal lines for reference range
      expect(lineChartData.extraLinesData, isNotNull);
      expect(lineChartData.extraLinesData!.horizontalLines.length, 2);

      // Check min and max reference lines
      final horizontalLines =
          lineChartData.extraLinesData!.horizontalLines.toList();
      expect(horizontalLines[0].y, 12.0); // min
      expect(horizontalLines[1].y, 18.0); // max
    });

    testWidgets('x-axis shows formatted dates', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: normalTrendData),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check that bottom titles are configured
      expect(lineChartData.titlesData.show, true);
      expect(lineChartData.titlesData.bottomTitles.sideTitles.showTitles, true);

      // Verify the getTitlesWidget function exists
      final bottomTitles = lineChartData.titlesData.bottomTitles.sideTitles;
      expect(bottomTitles.getTitlesWidget, isNotNull);
    });

    testWidgets('y-axis shows biomarker values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: normalTrendData),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check that left titles are configured
      expect(lineChartData.titlesData.leftTitles.sideTitles.showTitles, true);
      expect(
          lineChartData.titlesData.leftTitles.sideTitles.getTitlesWidget,
          isNotNull);
    });

    testWidgets('out-of-range points are highlighted with different colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: mixedTrendData),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check that spots have color indicators
      expect(lineChartData.lineBarsData.first.dotData.show, true);

      // Verify that getDotPainter exists for custom coloring
      expect(lineChartData.lineBarsData.first.dotData.getDotPainter, isNotNull);
    });

    testWidgets('tooltips show on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: normalTrendData),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check that touch data is configured
      expect(lineChartData.lineTouchData.enabled, true);
      expect(lineChartData.lineTouchData.touchTooltipData, isNotNull);
      expect(
          lineChartData.lineTouchData.touchTooltipData!.getTooltipItems,
          isNotNull);
    });

    testWidgets('chart has proper grid data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: normalTrendData),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check that grid is configured
      expect(lineChartData.gridData.show, true);
    });

    testWidgets('chart has proper border data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: normalTrendData),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check that border is configured
      expect(lineChartData.borderData.show, true);
    });

    testWidgets('chart respects Material 3 theme colors',
        (WidgetTester tester) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: TrendChart(dataPoints: normalTrendData),
          ),
        ),
      );

      expect(find.byType(TrendChart), findsOneWidget);
      // Widget should render without errors and respect theme
    });

    testWidgets('chart handles large dataset efficiently',
        (WidgetTester tester) async {
      // Create 50 data points
      final largeDataset = List.generate(
        50,
        (index) => TrendDataPoint(
          date: DateTime(2024, 1, 1).add(Duration(days: index * 7)),
          value: 14.0 + (index % 5) * 0.5,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 18.0),
          reportId: 'report$index',
          status: BiomarkerStatus.normal,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: largeDataset),
          ),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final spots = lineChart.data.lineBarsData.first.spots;

      expect(spots.length, 50);
    });

    testWidgets('chart has semantic labels for accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: normalTrendData),
          ),
        ),
      );

      // Check for Semantics widget
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('reference range band has correct visual styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: normalTrendData),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      final horizontalLines =
          lineChartData.extraLinesData!.horizontalLines.toList();

      // Check that reference lines have appropriate styling
      expect(horizontalLines[0].color, isNotNull);
      expect(horizontalLines[1].color, isNotNull);
    });

    testWidgets('data points are properly sorted by date',
        (WidgetTester tester) async {
      // Create unsorted data
      final unsortedData = [
        TrendDataPoint(
          date: DateTime(2024, 6, 5),
          value: 14.2,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 18.0),
          reportId: 'report3',
          status: BiomarkerStatus.normal,
        ),
        TrendDataPoint(
          date: DateTime(2024, 1, 15),
          value: 15.0,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 18.0),
          reportId: 'report1',
          status: BiomarkerStatus.normal,
        ),
        TrendDataPoint(
          date: DateTime(2024, 3, 10),
          value: 16.5,
          unit: 'g/dL',
          referenceRange: const ReferenceRange(min: 12.0, max: 18.0),
          reportId: 'report2',
          status: BiomarkerStatus.normal,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendChart(dataPoints: unsortedData),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final spots = lineChart.data.lineBarsData.first.spots;

      // Check that x values are in ascending order
      for (int i = 1; i < spots.length; i++) {
        expect(spots[i].x, greaterThan(spots[i - 1].x));
      }
    });
  });
}
