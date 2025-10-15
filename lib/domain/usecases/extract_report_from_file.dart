import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_extraction_service.dart';
import 'package:health_tracker_reports/data/datasources/external/ocr_service.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_service.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/usecases/normalize_biomarker_name.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../core/error/exceptions.dart';

@lazySingleton
class ExtractReportFromFile {
  final PdfService pdfService;
  final OcrService ocrService;
  final LlmExtractionService llmService;
  final NormalizeBiomarkerName normalizeBiomarker;

  ExtractReportFromFile({
    required this.pdfService,
    required this.ocrService,
    required this.llmService,
    required this.normalizeBiomarker,
  });

  Future<Either<Failure, Report>> call(String filePath) async {
    try {
      List<Uint8List> images;
      if (p.extension(filePath).toLowerCase() == '.pdf') {
        images = await pdfService.convertToImages(filePath);
      } else {
        images = [await File(filePath).readAsBytes()];
      }

      final ocrText = await ocrService.extractText(images);
      final reportModel = await llmService.extractBiomarkers(ocrText);

      final normalizedBiomarkers = reportModel.biomarkers.map((biomarker) {
        final normalizedName = normalizeBiomarker(biomarker.name);
        return biomarker.copyWith(name: normalizedName);
      }).toList();

      return Right(
          reportModel.toEntity().copyWith(biomarkers: normalizedBiomarkers));
    } on OcrException catch (e) {
      return Left(OcrFailure(message: e.message));
    } on LlmException catch (e) {
      return Left(LlmFailure(message: e.message));
    } on FileSystemException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
