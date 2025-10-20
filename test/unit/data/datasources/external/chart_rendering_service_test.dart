import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_tracker_reports/data/datasources/external/chart_rendering_service.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';

void main() {
  group('ChartRenderingService', () {
    late ChartRenderingService service;

    setUp(() {
      service = ChartRenderingServiceImpl();
    });

    test('can be instantiated', () {
      expect(service, isA<ChartRenderingService>());
    });

    testWidgets('should render a single line chart and return PNG bytes', (WidgetTester tester) async {
      // Arrange
      final biomarkers = [Biomarker(id: '1', name: 'g', value: 1, unit: 'u', referenceRange: ReferenceRange(min: 0, max: 2), measuredAt: DateTime.now())];
      final GlobalKey repaintKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: repaintKey,
              child: service.getLineChart(biomarkers, null, null),
            ),
          ),
        ),
      );

      // Act
      final result = await service.capturePng(repaintKey);

      // Assert
      expect(result, isA<Uint8List>());
      expect(result, isNotEmpty);
    });

    testWidgets('should render a dual-line chart', (WidgetTester tester) async {
      // Arrange
      final biomarkers1 = [Biomarker(id: '1', name: 'g', value: 120, unit: 'u', referenceRange: ReferenceRange(min: 0, max: 200), measuredAt: DateTime.now())];
      final biomarkers2 = [Biomarker(id: '2', name: 'g', value: 80, unit: 'u', referenceRange: ReferenceRange(min: 0, max: 100), measuredAt: DateTime.now())];
      final GlobalKey repaintKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: repaintKey,
              child: service.getDualLineChart(biomarkers1, biomarkers2, null),
            ),
          ),
        ),
      );

      // Act
      final result = await service.capturePng(repaintKey);

      // Assert
      expect(result, isA<Uint8List>());
      expect(result, isNotEmpty);
    });

    test('should include reference range bands in the chart', () {
      // Arrange
      final biomarkers = [Biomarker(id: '1', name: 'g', value: 100, unit: 'u', referenceRange: ReferenceRange(min: 80, max: 120), measuredAt: DateTime.now())];
      final range = ReferenceRange(min: 80, max: 120);

      // Act
      final chart = service.getLineChart(biomarkers, range, null) as Stack;
      final lineChart = chart.children.first as LineChart;
      final lineChartData = lineChart.data;

      // Assert
      expect(lineChartData.lineBarsData.length, 3);
      expect(lineChartData.betweenBarsData, isNotEmpty);
      final shading = lineChartData.betweenBarsData.first;
      expect(shading.fromIndex, 1);
      expect(shading.toIndex, 2);
    });

  });
}
