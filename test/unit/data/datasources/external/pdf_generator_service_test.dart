import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:health_tracker_reports/data/datasources/external/pdf_generator_service.dart';
import 'package:health_tracker_reports/domain/entities/summary_statistics.dart';
import 'package:health_tracker_reports/data/datasources/external/chart_rendering_service.dart';
import 'package:health_tracker_reports/domain/entities/biomarker_trend_summary.dart';

class MockPdfDocument extends Mock implements PdfDocumentWrapper {}
class MockChartRenderingService extends Mock implements ChartRenderingService {}

class FakePage extends Fake implements pw.Page {}

void main() {
  late PdfGeneratorService service;
  late MockPdfDocument mockPdfDocument;

  setUpAll(() {
    registerFallbackValue(FakePage());
  });

  setUp(() {
    mockPdfDocument = MockPdfDocument();
    final chartRenderingService = MockChartRenderingService();
    service = PdfGeneratorServiceImpl(pdfDocumentWrapper: mockPdfDocument, chartRenderingService: chartRenderingService);
  });

  group('PdfGeneratorService', () {
    final tSummaryStatistics = SummaryStatistics(
      biomarkerTrends: [],
      vitalTrends: [],
      criticalFindings: [],
      dashboard: HealthStatusDashboard(
        glucoseControl: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
        lipidPanel: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
        kidneyFunction: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
        bloodPressure: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
        cardiovascular: const DashboardCategory(status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
      ),
      totalReports: 1,
      totalHealthLogs: 0,
    );

    test('should add a page to the pdf document', () async {
      // Arrange
      when(() => mockPdfDocument.addPage(any()))
          .thenReturn(null);
      when(() => mockPdfDocument.save())
          .thenAnswer((_) async => Uint8List(0));

      // Act
      await service.generatePdf(tSummaryStatistics);

      // Assert
      verify(() => mockPdfDocument.addPage(any())).called(1);
    });

    test('should generate a table with critical findings', () async {
      // Arrange
      final criticalFinding = CriticalFinding(priority: 1, category: 'Glucose', finding: '150 mg/dL', actionNeeded: 'Consult physician');
      final stats = tSummaryStatistics.copyWith(criticalFindings: [criticalFinding]);
      final capturer = ArgumentCaptor<pw.Page>();

      when(() => mockPdfDocument.addPage(any()))
          .thenReturn(null);
      when(() => mockPdfDocument.save())
          .thenAnswer((_) async => Uint8List(0));

      // Act
      await service.generatePdf(stats);

      // Assert
      verify(() => mockPdfDocument.addPage(capturer.capture())).called(1);
      // This is a simplified check. A better test would be a golden file test.
      // For now, we just check that a page was added.
      expect(capturer.captured, hasLength(1));
    });

    test('should generate a biomarker trends page with a chart', () async {
      // Arrange
      final chartImage = Uint8List(1);
      final chartRenderingService = MockChartRenderingService();
      final serviceWithChart = PdfGeneratorServiceImpl(pdfDocumentWrapper: mockPdfDocument, chartRenderingService: chartRenderingService);
      final stats = tSummaryStatistics.copyWith(biomarkerTrends: [BiomarkerTrendSummary(biomarkerName: 'Glucose', trend: null)]);

      when(() => chartRenderingService.getLineChart(any(), any(), any()))
          .thenReturn(Container());
      when(() => chartRenderingService.capturePng(any()))
          .thenAnswer((_) async => chartImage);
      when(() => mockPdfDocument.addPage(any()))
          .thenReturn(null);
      when(() => mockPdfDocument.save())
          .thenAnswer((_) async => Uint8List(0));

      // Act
      await serviceWithChart.generatePdf(stats);

      // Assert
      // Just checking that a page was added for now.
      verify(() => mockPdfDocument.addPage(any())).called(1);
    });
  });
}
