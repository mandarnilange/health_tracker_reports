import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/structured_data.dart';
import 'package:health_tracker_reports/domain/usecases/normalize_biomarker_name.dart';
import 'package:health_tracker_reports/data/datasources/external/ocr_service.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_extraction_service.dart';

@lazySingleton
class ExtractReportFromFile {
  final OcrService ocrService;
  final LlmExtractionService llmService;
  final NormalizeBiomarkerName normalizeBiomarker;
  final Uuid uuid;

  const ExtractReportFromFile({
    required this.ocrService,
    required this.llmService,
    required this.normalizeBiomarker,
    required this.uuid,
  });

  Future<Either<Failure, Report>> call(String filePath) async {
    try {
      // 1. Extract text via OCR
      final extractedText = await ocrService.extractText(filePath);

      // 2. Parse structured data via LLM
      final structuredDataEither = await llmService.extractBiomarkers(extractedText);

      return structuredDataEither.fold(
        (failure) => Left(failure),
        (structuredData) {
          // 3. Normalize biomarker names
          final normalizedBiomarkers = structuredData.biomarkers.map((b) {
            final normalizedName = normalizeBiomarker(b.name);
            return b.copyWith(name: normalizedName);
          }).toList();

          // 4. Build Report entity
          final report = Report(
            id: uuid.v4(),
            date: structuredData.reportDate,
            labName: structuredData.labName,
            biomarkers: normalizedBiomarkers,
            originalFilePath: filePath,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          return Right(report);
        },
      );
    } on OcrException catch (e) {
      return Left(OcrFailure(message: e.message));
    } catch (e) {
      return Left(LlmFailure(message: e.toString())); // Generic catch for now
    }
  }
}
