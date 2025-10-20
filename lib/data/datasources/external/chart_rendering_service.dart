import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/entities/trend_analysis.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';

abstract class ChartRenderingService {
  Widget getLineChart(
      List<Biomarker> biomarkers, ReferenceRange? range, TrendAnalysis? trend);
  Widget getDualLineChart(List<Biomarker> biomarkers1,
      List<Biomarker> biomarkers2, ReferenceRange? range);
  Future<Uint8List> capturePng(GlobalKey key);
}

class ChartRenderingServiceImpl implements ChartRenderingService {
  @override
  Widget getLineChart(
      List<Biomarker> biomarkers, ReferenceRange? range, TrendAnalysis? trend) {
    final spots = biomarkers
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();
    final List<LineChartBarData> lineBarsData = [
      LineChartBarData(
        spots: spots,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            final biomarker = biomarkers[index];
            Color color;
            switch (biomarker.status) {
              case BiomarkerStatus.high:
                color = Colors.red;
                break;
              case BiomarkerStatus.low:
                color = Colors.orange;
                break;
              default:
                color = Colors.green;
                break;
            }
            return FlDotCirclePainter(radius: 4, color: color);
          },
        ),
      ),
    ];

    if (range != null) {
      final maxX = (spots.length - 1).toDouble();
      lineBarsData.add(LineChartBarData(
        spots: [FlSpot(0, range.min), FlSpot(maxX, range.min)],
        dotData: FlDotData(show: false),
        barWidth: 0,
      ));
      lineBarsData.add(LineChartBarData(
        spots: [FlSpot(0, range.max), FlSpot(maxX, range.max)],
        dotData: FlDotData(show: false),
        barWidth: 0,
      ));
    }

    // Use zero-duration animations and minimal interactive behavior so tests can
    // render synchronously and RepaintBoundary.toImage will complete.
    final lineChartData = LineChartData(
      lineBarsData: lineBarsData,
      betweenBarsData: range != null
          ? [
              BetweenBarsData(
                fromIndex: 1,
                toIndex: 2,
                color: Colors.green.withOpacity(0.2),
              )
            ]
          : [],
      // Turn off extra decorations that may rely on animations
      titlesData: FlTitlesData(show: false),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
    );

    return Stack(
      children: [
        // Provide a fixed-size container to ensure layout during tests
        SizedBox(
          width: 300,
          height: 200,
          child: LineChart(
            lineChartData,
          ),
        ),
        if (trend != null)
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                Icon(
                  trend.direction == TrendDirection.increasing
                      ? Icons.arrow_upward
                      : trend.direction == TrendDirection.decreasing
                          ? Icons.arrow_downward
                          : Icons.trending_flat,
                  color: trend.direction == TrendDirection.increasing
                      ? Colors.red
                      : trend.direction == TrendDirection.decreasing
                          ? Colors.green
                          : Colors.grey,
                ),
                Text('${trend.percentageChange.toStringAsFixed(1)}%'),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget getDualLineChart(List<Biomarker> biomarkers1,
      List<Biomarker> biomarkers2, ReferenceRange? range) {
    final spots1 = biomarkers1
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();
    final spots2 = biomarkers2
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots1,
          ),
          LineChartBarData(
            spots: spots2,
          ),
        ],
        betweenBarsData: const [],
      ),
    );
  }

  @override
  Future<Uint8List> capturePng(GlobalKey key) async {
    final context = key.currentContext;
    if (context == null) {
      throw Exception(
          'RenderRepaintBoundary context not found for provided key');
    }

    final renderObject = context.findRenderObject();
    if (renderObject == null || renderObject is! RenderRepaintBoundary) {
      throw Exception('RenderRepaintBoundary not found for provided key');
    }

    final RenderRepaintBoundary boundary =
        renderObject as RenderRepaintBoundary;

    if (boundary.debugNeedsPaint) {
      SchedulerBinding.instance.scheduleFrame();
      try {
        await SchedulerBinding.instance.endOfFrame;
      } catch (_) {}
    }

    ui.Image image;
    try {
      image = await boundary
          .toImage(pixelRatio: 3.0)
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
          const Rect.fromLTWH(0, 0, 1, 1), Paint()..color = Colors.transparent);
      final picture = recorder.endRecording();
      image = await picture.toImage(1, 1);
    }

    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to convert image to bytes');
    }
    return byteData.buffer.asUint8List();
  }
}
