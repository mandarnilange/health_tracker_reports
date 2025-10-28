import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_tracker_reports/data/datasources/external/chart_rendering_service.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';

Biomarker _biomarker({
  required String id,
  required BiomarkerStatus status,
}) {
  final double value;
  switch (status) {
    case BiomarkerStatus.low:
      value = 60;
      break;
    case BiomarkerStatus.normal:
      value = 90;
      break;
    case BiomarkerStatus.high:
      value = 120;
      break;
  }
  return Biomarker(
    id: id,
    name: 'Glucose',
    value: value,
    unit: 'mg/dL',
    referenceRange: const ReferenceRange(min: 70, max: 110),
    measuredAt: DateTime(2024, 1, 1).add(Duration(days: int.parse(id))),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = ChartRenderingServiceImpl();
  final referenceRange = const ReferenceRange(min: 70, max: 110);
  const trendAnalysis = TrendAnalysis(
    direction: TrendDirection.increasing,
    percentageChange: 12.5,
    firstValue: 90,
    lastValue: 101,
    dataPointsCount: 3,
  );

  testWidgets('getLineChart renders chart with trend overlay', (tester) async {
    final biomarkers = [
      _biomarker(id: '0', status: BiomarkerStatus.normal),
      _biomarker(id: '1', status: BiomarkerStatus.high),
      _biomarker(id: '2', status: BiomarkerStatus.normal),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: service.getLineChart(
            biomarkers,
            referenceRange,
            trendAnalysis,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.textContaining('%'), findsOneWidget);
  });

  testWidgets('getDualLineChart renders multiple lines', (tester) async {
    final biomarkersA = [
      _biomarker(id: '0', status: BiomarkerStatus.low),
      _biomarker(id: '1', status: BiomarkerStatus.normal),
    ];
    final biomarkersB = [
      _biomarker(id: '0', status: BiomarkerStatus.normal),
      _biomarker(id: '1', status: BiomarkerStatus.high),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 200,
            child: service.getDualLineChart(
              biomarkersA,
              biomarkersB,
              referenceRange,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('capturePng returns bytes for rendered chart', (tester) async {
    final key = GlobalKey();
    final biomarkers = [
      _biomarker(id: '0', status: BiomarkerStatus.normal),
      _biomarker(id: '1', status: BiomarkerStatus.high),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: key,
            child: service.getLineChart(
              biomarkers,
              referenceRange,
              trendAnalysis,
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final pngBytes = await tester.runAsync(() => service.capturePng(key));

    expect(pngBytes, isA<Uint8List>());
    expect(pngBytes, isNotEmpty);
  });

  test('capturePng throws when widget not attached', () async {
    final key = GlobalKey();

    await expectLater(
      () => service.capturePng(key),
      throwsException,
    );
  });
}
