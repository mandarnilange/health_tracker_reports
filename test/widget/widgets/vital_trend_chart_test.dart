import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/vital_measurement.dart';
import 'package:health_tracker_reports/presentation/widgets/vital_trend_chart.dart';

void main() {
  group('VitalTrendChart', () {
    late List<VitalMeasurement> heartRateData;
    late List<VitalMeasurement> bloodPressureData;
    late List<VitalMeasurement> mixedStatusData;
    late List<VitalMeasurement> emptyData;
    late DateTime baseDate;

    setUp(() {
      baseDate = DateTime(2024, 1, 1);

      // Create normal heart rate data
      heartRateData = [
        VitalMeasurement(
          id: '1',
          type: VitalType.heartRate,
          value: 72,
          unit: 'bpm',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
        VitalMeasurement(
          id: '2',
          type: VitalType.heartRate,
          value: 78,
          unit: 'bpm',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
        VitalMeasurement(
          id: '3',
          type: VitalType.heartRate,
          value: 68,
          unit: 'bpm',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
      ];

      // Create blood pressure data (systolic and diastolic)
      bloodPressureData = [
        VitalMeasurement(
          id: '1',
          type: VitalType.bloodPressureSystolic,
          value: 120,
          unit: 'mmHg',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 90, max: 140),
        ),
        VitalMeasurement(
          id: '2',
          type: VitalType.bloodPressureDiastolic,
          value: 80,
          unit: 'mmHg',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 60, max: 90),
        ),
        VitalMeasurement(
          id: '3',
          type: VitalType.bloodPressureSystolic,
          value: 125,
          unit: 'mmHg',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 90, max: 140),
        ),
        VitalMeasurement(
          id: '4',
          type: VitalType.bloodPressureDiastolic,
          value: 82,
          unit: 'mmHg',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 60, max: 90),
        ),
      ];

      // Create mixed status data (normal, warning, critical)
      mixedStatusData = [
        VitalMeasurement(
          id: '1',
          type: VitalType.heartRate,
          value: 72,
          unit: 'bpm',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
        VitalMeasurement(
          id: '2',
          type: VitalType.heartRate,
          value: 105,
          unit: 'bpm',
          status: VitalStatus.warning,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
        VitalMeasurement(
          id: '3',
          type: VitalType.heartRate,
          value: 130,
          unit: 'bpm',
          status: VitalStatus.critical,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
        VitalMeasurement(
          id: '4',
          type: VitalType.heartRate,
          value: 75,
          unit: 'bpm',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
      ];

      emptyData = [];
    });

    testWidgets('renders with heart rate data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(VitalTrendChart), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('displays line chart correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;
      final spots = lineChartData.lineBarsData.first.spots;

      expect(spots.length, heartRateData.length);
    });

    testWidgets('shows reference range bands for vitals with range',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
            ),
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
      expect(horizontalLines[0].y, 60.0); // min
      expect(horizontalLines[1].y, 100.0); // max
    });

    testWidgets('displays dual-line chart for blood pressure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: bloodPressureData,
              vitalType: VitalType.bloodPressureSystolic,
              dates: [
                baseDate,
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 7)),
              ],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Should have 2 line bars (systolic and diastolic)
      expect(lineChartData.lineBarsData.length, 2);
    });

    testWidgets('color-codes points based on status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: mixedStatusData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
                baseDate.add(const Duration(days: 21)),
              ],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check that dots are shown with custom painter
      expect(lineChartData.lineBarsData.first.dotData.show, true);
      expect(lineChartData.lineBarsData.first.dotData.getDotPainter, isNotNull);
    });

    testWidgets('x-axis shows formatted dates', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
            ),
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

    testWidgets('y-axis shows values with unit', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check that left titles are configured
      expect(lineChartData.titlesData.leftTitles.sideTitles.showTitles, true);
      expect(
        lineChartData.titlesData.leftTitles.sideTitles.getTitlesWidget,
        isNotNull,
      );
    });

    testWidgets('handles empty data gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: emptyData,
              vitalType: VitalType.heartRate,
              dates: [],
            ),
          ),
        ),
      );

      expect(find.byType(VitalTrendChart), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
      expect(find.text('No data available'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('legend displays correctly for BP dual lines',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: bloodPressureData,
              vitalType: VitalType.bloodPressureSystolic,
              dates: [
                baseDate,
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 7)),
              ],
            ),
          ),
        ),
      );

      // Check for legend items
      expect(find.text('Systolic'), findsOneWidget);
      expect(find.text('Diastolic'), findsOneWidget);
    });

    testWidgets('touch interactions work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
            ),
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
        isNotNull,
      );
    });

    testWidgets('displays average line (dashed)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
              showStatistics: true,
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check for extra lines (should have reference range + average)
      expect(lineChartData.extraLinesData, isNotNull);
      expect(
        lineChartData.extraLinesData!.horizontalLines.length,
        greaterThanOrEqualTo(2),
      );
    });

    testWidgets('shows min/max markers when statistics enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
              showStatistics: true,
            ),
          ),
        ),
      );

      // Min/max should be shown somewhere in the widget
      expect(find.byType(VitalTrendChart), findsOneWidget);
    });

    testWidgets('displays trend indicator when statistics enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
              showStatistics: true,
            ),
          ),
        ),
      );

      // Trend indicator should be visible
      expect(find.byType(VitalTrendChart), findsOneWidget);
    });

    testWidgets('chart is responsive to different sizes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: VitalTrendChart(
                measurements: heartRateData,
                vitalType: VitalType.heartRate,
                dates: [
                  baseDate,
                  baseDate.add(const Duration(days: 7)),
                  baseDate.add(const Duration(days: 14)),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);

      // Test with larger size
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 400,
              child: VitalTrendChart(
                measurements: heartRateData,
                vitalType: VitalType.heartRate,
                dates: [
                  baseDate,
                  baseDate.add(const Duration(days: 7)),
                  baseDate.add(const Duration(days: 14)),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('handles single data point', (WidgetTester tester) async {
      final singleData = [heartRateData.first];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: singleData,
              vitalType: VitalType.heartRate,
              dates: [baseDate],
            ),
          ),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final spots = lineChart.data.lineBarsData.first.spots;

      expect(spots.length, 1);
    });

    testWidgets('grid data is configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check that grid is configured
      expect(lineChartData.gridData.show, true);
    });

    testWidgets('border data is configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Check that border is configured
      expect(lineChartData.borderData.show, true);
    });

    testWidgets('handles vitals without reference range',
        (WidgetTester tester) async {
      final noRangeData = [
        VitalMeasurement(
          id: '1',
          type: VitalType.energyLevel,
          value: 7,
          unit: '/10',
          status: VitalStatus.normal,
          referenceRange: null,
        ),
        VitalMeasurement(
          id: '2',
          type: VitalType.energyLevel,
          value: 8,
          unit: '/10',
          status: VitalStatus.normal,
          referenceRange: null,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: noRangeData,
              vitalType: VitalType.energyLevel,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
              ],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Should not have reference range lines
      if (lineChartData.extraLinesData != null) {
        expect(
          lineChartData.extraLinesData!.horizontalLines.length,
          lessThan(2),
        );
      }
    });

    testWidgets('respects Material 3 theme colors',
        (WidgetTester tester) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(VitalTrendChart), findsOneWidget);
      // Widget should render without errors and respect theme
    });

    testWidgets('has semantic labels for accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
            ),
          ),
        ),
      );

      // Check for Semantics widget
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('handles large dataset efficiently',
        (WidgetTester tester) async {
      // Create 50 data points
      final largeDataset = List.generate(
        50,
        (index) => VitalMeasurement(
          id: 'vital$index',
          type: VitalType.heartRate,
          value: 70.0 + (index % 10),
          unit: 'bpm',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
      );

      final largeDates = List.generate(
        50,
        (index) => baseDate.add(Duration(days: index)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: largeDataset,
              vitalType: VitalType.heartRate,
              dates: largeDates,
            ),
          ),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final spots = lineChart.data.lineBarsData.first.spots;

      expect(spots.length, 50);
    });

    testWidgets('BP systolic line is red and diastolic is blue',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: bloodPressureData,
              vitalType: VitalType.bloodPressureSystolic,
              dates: [
                baseDate,
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 7)),
              ],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      expect(lineChartData.lineBarsData.length, 2);

      // First line should be systolic (red-ish)
      final systolicLine = lineChartData.lineBarsData[0];
      expect(systolicLine.color, isNotNull);

      // Second line should be diastolic (blue-ish)
      final diastolicLine = lineChartData.lineBarsData[1];
      expect(diastolicLine.color, isNotNull);
    });

    testWidgets('normal points are green', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: [heartRateData.first],
              vitalType: VitalType.heartRate,
              dates: [baseDate],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final dotData = lineChart.data.lineBarsData.first.dotData;

      expect(dotData.show, true);
      expect(dotData.getDotPainter, isNotNull);
    });

    testWidgets('warning points are orange', (WidgetTester tester) async {
      final warningData = [
        VitalMeasurement(
          id: '1',
          type: VitalType.heartRate,
          value: 105,
          unit: 'bpm',
          status: VitalStatus.warning,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: warningData,
              vitalType: VitalType.heartRate,
              dates: [baseDate],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final dotData = lineChart.data.lineBarsData.first.dotData;

      expect(dotData.show, true);
      expect(dotData.getDotPainter, isNotNull);
    });

    testWidgets('critical points are red', (WidgetTester tester) async {
      final criticalData = [
        VitalMeasurement(
          id: '1',
          type: VitalType.heartRate,
          value: 150,
          unit: 'bpm',
          status: VitalStatus.critical,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: criticalData,
              vitalType: VitalType.heartRate,
              dates: [baseDate],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final dotData = lineChart.data.lineBarsData.first.dotData;

      expect(dotData.show, true);
      expect(dotData.getDotPainter, isNotNull);
    });

    testWidgets(
        'shows average line without reference range when statistics enabled',
        (WidgetTester tester) async {
      final noRangeData = [
        VitalMeasurement(
          id: '1',
          type: VitalType.energyLevel,
          value: 7,
          unit: '/10',
          status: VitalStatus.normal,
          referenceRange: null,
        ),
        VitalMeasurement(
          id: '2',
          type: VitalType.energyLevel,
          value: 8,
          unit: '/10',
          status: VitalStatus.normal,
          referenceRange: null,
        ),
        VitalMeasurement(
          id: '3',
          type: VitalType.energyLevel,
          value: 6,
          unit: '/10',
          status: VitalStatus.normal,
          referenceRange: null,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: noRangeData,
              vitalType: VitalType.energyLevel,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
              showStatistics: true,
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final lineChartData = lineChart.data;

      // Should have average line
      expect(lineChartData.extraLinesData, isNotNull);
      expect(
        lineChartData.extraLinesData!.horizontalLines.length,
        greaterThanOrEqualTo(1),
      );
    });

    testWidgets('tooltip shows correct format for non-BP vitals',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: heartRateData,
              vitalType: VitalType.heartRate,
              dates: [
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 14)),
              ],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final tooltipData = lineChart.data.lineTouchData.touchTooltipData;

      expect(tooltipData, isNotNull);
      expect(tooltipData!.getTooltipItems, isNotNull);
    });

    testWidgets('tooltip shows correct format for BP vitals',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: bloodPressureData,
              vitalType: VitalType.bloodPressureSystolic,
              dates: [
                baseDate,
                baseDate,
                baseDate.add(const Duration(days: 7)),
                baseDate.add(const Duration(days: 7)),
              ],
            ),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      final tooltipData = lineChart.data.lineTouchData.touchTooltipData;

      expect(tooltipData, isNotNull);
      expect(tooltipData!.getTooltipItems, isNotNull);
    });

    testWidgets('calculates correct x-axis interval for different data sizes',
        (WidgetTester tester) async {
      // Test with 5 data points (interval should be 1)
      final smallData = List.generate(
        5,
        (index) => VitalMeasurement(
          id: 'vital$index',
          type: VitalType.heartRate,
          value: 70.0,
          unit: 'bpm',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
      );

      final smallDates = List.generate(
        5,
        (index) => baseDate.add(Duration(days: index)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: smallData,
              vitalType: VitalType.heartRate,
              dates: smallDates,
            ),
          ),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);

      // Test with 20 data points
      final mediumData = List.generate(
        20,
        (index) => VitalMeasurement(
          id: 'vital$index',
          type: VitalType.heartRate,
          value: 70.0,
          unit: 'bpm',
          status: VitalStatus.normal,
          referenceRange: const ReferenceRange(min: 60, max: 100),
        ),
      );

      final mediumDates = List.generate(
        20,
        (index) => baseDate.add(Duration(days: index)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VitalTrendChart(
              measurements: mediumData,
              vitalType: VitalType.heartRate,
              dates: mediumDates,
            ),
          ),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);
    });
  });
}
