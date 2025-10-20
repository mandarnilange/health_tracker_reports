import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/summary_statistics.dart';
import 'package:health_tracker_reports/domain/entities/doctor_summary_config.dart';
import 'package:health_tracker_reports/data/datasources/external/chart_rendering_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

abstract class PdfGeneratorService {
  Future<Either<Failure, String>> generatePdf(SummaryStatistics stats, DoctorSummaryConfig config);
}

class PdfGeneratorServiceImpl implements PdfGeneratorService {
  final PdfDocumentWrapper pdfDocumentWrapper;
  final ChartRenderingService chartRenderingService;

  PdfGeneratorServiceImpl({required this.pdfDocumentWrapper, required this.chartRenderingService});

  @override
  Future<Either<Failure, String>> generatePdf(SummaryStatistics stats, DoctorSummaryConfig config) async {
    pdfDocumentWrapper.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final pages = <pw.Widget>[];
          pages.add(_buildExecutiveSummaryPage(stats));
          pages.add(_buildBiomarkerTrendsPage(stats));
          if (config.includeVitals) {
            pages.add(_buildVitalsSummaryPage(stats));
          }
          if (config.includeFullDataTable) {
            pages.add(_buildFullDataTablePage(stats));
          }
          return pages;
        },
      ),
    );

    // For now, we don't save the file, just return a path
    return const Right('/path/to/pdf');
  }

  pw.Widget _buildBiomarkerTrendsPage(SummaryStatistics stats) {
    final outOfRangeBiomarkers = stats.biomarkerTrends.where((t) => t.trend?.isSignificantChange ?? false).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Lab Biomarker Trends', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Text('Out of Range - Action Required', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...outOfRangeBiomarkers.map((trend) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(trend.biomarkerName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              // Chart will be added here
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildFullDataTablePage(SummaryStatistics stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Full Data Table', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildVitalsSummaryPage(SummaryStatistics stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Vitals Summary', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
      ],
    );
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
