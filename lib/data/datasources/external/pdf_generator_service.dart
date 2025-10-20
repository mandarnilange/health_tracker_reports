import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/summary_statistics.dart';
import 'package:health_tracker_reports/data/datasources/external/chart_rendering_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

abstract class PdfGeneratorService {
  Future<Either<Failure, String>> generatePdf(SummaryStatistics stats);
}

class PdfGeneratorServiceImpl implements PdfGeneratorService {
  final PdfDocumentWrapper pdfDocumentWrapper;
  final ChartRenderingService chartRenderingService;

  PdfGeneratorServiceImpl({required this.pdfDocumentWrapper, required this.chartRenderingService});

  @override
  Future<Either<Failure, String>> generatePdf(SummaryStatistics stats) async {
    pdfDocumentWrapper.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildExecutiveSummaryPage(stats),
          ];
        },
      ),
    );

    // For now, we don't save the file, just return a path
    return const Right('/path/to/pdf');
  }

  pw.Widget _buildExecutiveSummaryPage(SummaryStatistics stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Executive Summary', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Text('Critical Priorities', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Priority', 'Category', 'Finding', 'Action Needed'],
          data: stats.criticalFindings.map((finding) => [
            finding.priority.toString(),
            finding.category,
            finding.finding,
            finding.actionNeeded,
          ]).toList(),
        ),
        pw.SizedBox(height: 20),
        pw.Text('Health Status Dashboard', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['System', 'Status', 'Trend', 'Latest Value'],
          data: [
            ['Glucose Control', stats.dashboard.glucoseControl.status, stats.dashboard.glucoseControl.trend, stats.dashboard.glucoseControl.latestValue],
            ['Lipid Panel', stats.dashboard.lipidPanel.status, stats.dashboard.lipidPanel.trend, stats.dashboard.lipidPanel.latestValue],
            ['Kidney Function', stats.dashboard.kidneyFunction.status, stats.dashboard.kidneyFunction.trend, stats.dashboard.kidneyFunction.latestValue],
            ['Blood Pressure', stats.dashboard.bloodPressure.status, stats.dashboard.bloodPressure.trend, stats.dashboard.bloodPressure.latestValue],
            ['Cardiovascular', stats.dashboard.cardiovascular.status, stats.dashboard.cardiovascular.trend, stats.dashboard.cardiovascular.latestValue],
          ],
        ),
      ],
    );
  }
}

abstract class PdfDocumentWrapper {
  void addPage(pw.Page page);
  Future<Uint8List> save();
}

class PdfDocumentWrapperImpl implements PdfDocumentWrapper {
  final pw.Document _doc;

  PdfDocumentWrapperImpl() : _doc = pw.Document();

  @override
  void addPage(pw.Page page) {
    _doc.addPage(page);
  }

  @override
  Future<Uint8List> save() {
    return _doc.save();
  }
}
