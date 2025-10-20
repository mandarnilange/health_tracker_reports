import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/chart_rendering_service.dart';
import 'package:health_tracker_reports/data/datasources/external/file_writer_service.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_generator_service.dart';
import 'package:health_tracker_reports/domain/entities/doctor_summary_config.dart';
import 'package:health_tracker_reports/domain/entities/summary_statistics.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pdf/widgets.dart' as pw;

class _MockPdfWrapper extends Mock implements PdfDocumentWrapper {}

class _MockChartRenderingService extends Mock
    implements ChartRenderingService {}

class _MockFileWriterService extends Mock implements FileWriterService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PdfGeneratorService service;
  late _MockPdfWrapper mockWrapper;
  late _MockChartRenderingService mockChartService;
  late _MockFileWriterService mockFileWriter;
  late pw.Document document;
  final pdfBytes = Uint8List.fromList([1, 2, 3]);

  setUpAll(() {
    registerFallbackValue(GlobalKey());
    registerFallbackValue(Container());
  });

  setUp(() {
    document = pw.Document();
    mockWrapper = _MockPdfWrapper();
    mockChartService = _MockChartRenderingService();
    mockFileWriter = _MockFileWriterService();

    when(() => mockWrapper.document).thenReturn(document);
    when(() => mockWrapper.save()).thenAnswer((_) async => pdfBytes);
    when(() => mockChartService.getLineChart(any(), any(), any()))
        .thenReturn(Container());
    when(
      () => mockFileWriter.writeBytes(
        filenamePrefix: any(named: 'filenamePrefix'),
        bytes: any(named: 'bytes'),
        extension: any(named: 'extension'),
      ),
    ).thenAnswer((_) async => const Right('/tmp/doctor_summary.pdf'));

    service = PdfGeneratorServiceImpl(
      pdfDocumentWrapper: mockWrapper,
      chartRenderingService: mockChartService,
      fileWriterService: mockFileWriter,
    );
  });

  SummaryStatistics _stats() => SummaryStatistics(
        biomarkerTrends: const [],
        vitalTrends: const [],
        criticalFindings: const [],
        dashboard: const HealthStatusDashboard(
          glucoseControl: DashboardCategory(
              status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
          lipidPanel: DashboardCategory(
              status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
          kidneyFunction: DashboardCategory(
              status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
          bloodPressure: DashboardCategory(
              status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
          cardiovascular: DashboardCategory(
              status: 'N/A', trend: 'N/A', latestValue: 'N/A'),
        ),
        totalReports: 1,
        totalHealthLogs: 0,
      );

  DoctorSummaryConfig _config({
    bool includeVitals = true,
    bool includeTable = false,
  }) =>
      DoctorSummaryConfig(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
        includeVitals: includeVitals,
        includeFullDataTable: includeTable,
      );

  test('saves generated PDF bytes to disk and returns path', () async {
    final result = await service.generatePdf(_stats(), _config());

    expect(result, equals(const Right('/tmp/doctor_summary.pdf')));

    final verification = verify(
      () => mockFileWriter.writeBytes(
        filenamePrefix: captureAny(named: 'filenamePrefix'),
        bytes: captureAny(named: 'bytes'),
        extension: captureAny(named: 'extension'),
      ),
    )..called(1);

    final capturedPrefix = verification.captured[0] as String;
    final capturedBytes = verification.captured[1] as List<int>;
    final capturedExtension = verification.captured[2] as String;

    expect(capturedPrefix, startsWith('doctor_summary_20260101_20260131'));
    expect(capturedBytes, pdfBytes);
    expect(capturedExtension, 'pdf');
  });

  test('returns failure when file writer reports error', () async {
    when(
      () => mockFileWriter.writeBytes(
        filenamePrefix: any(named: 'filenamePrefix'),
        bytes: any(named: 'bytes'),
        extension: any(named: 'extension'),
      ),
    ).thenAnswer(
      (_) async => Left(FileSystemFailure(message: 'disk full')),
    );

    final result = await service.generatePdf(_stats(), _config());

    expect(result, equals(Left(FileSystemFailure(message: 'disk full'))));
  });
}
