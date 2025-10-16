import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/report_scan_service.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/usecases/normalize_biomarker_name.dart';
import 'package:meta/meta.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
typedef Clock = DateTime Function();

@lazySingleton
class ExtractReportFromFile {
  final ReportScanService reportScanService;
  final NormalizeBiomarkerName normalizeBiomarker;
  final IdGenerator _idGenerator;
  final Clock _now;

  ExtractReportFromFile({
    required this.reportScanService,
    required this.normalizeBiomarker,
  })  : _idGenerator = (() => const Uuid().v4()),
        _now = DateTime.now;

  @visibleForTesting
  ExtractReportFromFile.test({
    required this.reportScanService,
    required this.normalizeBiomarker,
    required IdGenerator idGenerator,
    required Clock now,
  })  : _idGenerator = idGenerator,
        _now = now;

  Future<Either<Failure, Report>> call(String filePath) async {
    final request = _buildRequest(filePath);
    final collectedBiomarkers = <StructuredBiomarker>[];
    final rawTexts = <String>[];

    try {
      await for (final event in reportScanService.scanReport(request)) {
        if (event is ReportScanEventStructured) {
          collectedBiomarkers.addAll(event.payload.biomarkers);
          if (event.payload.rawText.isNotEmpty) {
            rawTexts.add(event.payload.rawText);
          }
        } else if (event is ReportScanEventText) {
          if (event.text.isNotEmpty) {
            rawTexts.add(event.text);
          }
        } else if (event is ReportScanEventError) {
          final message = event.message ?? 'Report scan failed';
          return Left(OcrFailure(message: message));
        } else if (event is ReportScanEventComplete) {
          final report = _buildReport(
            filePath: filePath,
            biomarkers: collectedBiomarkers,
            rawTexts: rawTexts,
          );
          if (report == null) {
            return const Left(
              ValidationFailure(message: 'No biomarkers detected'),
            );
          }
          return Right(report);
        }
      }
      // Stream ended without completion event
      return const Left(CacheFailure('Scan ended unexpectedly'));
    } on PlatformException catch (error) {
      return Left(OcrFailure(message: error.message ?? error.code));
    } catch (error) {
      return Left(CacheFailure(error.toString()));
    }
  }

  ReportScanRequest _buildRequest(String filePath) {
    final uri = Uri.file(filePath).toString();
    final extension = p.extension(filePath).toLowerCase();
    if (extension == '.pdf') {
      return ReportScanRequest(
        source: ScanSource.pdf,
        uri: uri,
        imageUris: const [],
      );
    }
    return ReportScanRequest(
      source: ScanSource.images,
      uri: uri,
      imageUris: [uri],
    );
  }

  Report? _buildReport({
    required String filePath,
    required List<StructuredBiomarker> biomarkers,
    required List<String> rawTexts,
  }) {
    final now = _now();
    final parsedBiomarkers = <Biomarker>[];

    for (final structured in biomarkers) {
      final value = _parseDouble(structured.value);
      if (value == null) continue;

      final normalizedName = normalizeBiomarker(structured.name);
      final name =
          normalizedName.isNotEmpty ? normalizedName : structured.name.trim();

      if (name.isEmpty) continue;

      final referenceMin = _parseDouble(structured.referenceMin) ?? value;
      final referenceMax = _parseDouble(structured.referenceMax) ?? value;

      parsedBiomarkers.add(
        Biomarker(
          id: _idGenerator(),
          name: name,
          value: value,
          unit: structured.unit?.trim() ?? '',
          referenceRange: ReferenceRange(
            min: referenceMin,
            max: referenceMax,
          ),
          measuredAt: now,
        ),
      );
    }

    if (parsedBiomarkers.isEmpty) {
      return null;
    }

    return Report(
      id: '',
      date: now,
      labName: 'Unknown Lab',
      biomarkers: parsedBiomarkers,
      originalFilePath: filePath,
      notes: rawTexts.isNotEmpty ? rawTexts.join('\n') : null,
      createdAt: now,
      updatedAt: now,
    );
  }

  double? _parseDouble(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final sanitized =
        trimmed.replaceAll(RegExp(r'[^0-9.,+-]'), '').replaceAll(',', '.');
    return double.tryParse(sanitized);
  }
}
