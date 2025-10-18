import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/image_processing_service.dart';
import 'package:health_tracker_reports/domain/entities/biomarker.dart';
import 'package:health_tracker_reports/domain/entities/report.dart';
import 'package:health_tracker_reports/domain/entities/reference_range.dart';
import 'package:health_tracker_reports/domain/repositories/llm_extraction_repository.dart';
import 'package:health_tracker_reports/domain/repositories/report_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Extracts biomarker data from lab report files using LLM vision APIs
@injectable
class ExtractReportFromFileLlm {
  final LlmExtractionRepository llmRepository;
  final ImageProcessingService imageService;
  final ReportRepository reportRepository;

  ExtractReportFromFileLlm({
    required this.llmRepository,
    required this.imageService,
    required this.reportRepository,
  });

  Future<Either<Failure, Report>> call(String filePath) async {
    try {
      // 1. Get existing biomarker names for normalization
      final existingNamesResult = await reportRepository.getDistinctBiomarkerNames();
      final existingBiomarkerNames = existingNamesResult.fold(
        (failure) => <String>[], // If no existing reports, use empty list
        (names) => names,
      );

      // 2. Convert file to base64 images
      final extension = p.extension(filePath).toLowerCase();
      final List<String> base64Images;

      if (extension == '.pdf') {
        base64Images = await imageService.pdfToBase64Images(filePath);
      } else {
        final image = await imageService.imageToBase64(filePath);
        base64Images = [image];
      }

      if (base64Images.isEmpty) {
        return const Left(
          ValidationFailure(message: 'No images extracted from file'),
        );
      }

      // 3. Extract biomarkers from each page using LLM
      final allBiomarkers = <Biomarker>[];
      String? patientName;
      DateTime? reportDate;
      String? labName;

      for (final (index, base64Image) in base64Images.indexed) {
        // Compress if needed
        final compressed = await imageService.compressImageBase64(base64Image);

        // Call LLM API with existing biomarker names for normalization
        final result = await llmRepository.extractFromImage(
          base64Image: compressed,
          existingBiomarkerNames: existingBiomarkerNames,
        );

        await result.fold(
          (failure) {
            // Continue to next page on failure, don't abort entire extraction
            return Future.value();
          },
          (extraction) async {
            // Use metadata from first page
            if (index == 0 && extraction.metadata != null) {
              patientName = extraction.metadata!.patientName;
              reportDate = extraction.metadata!.reportDate;
              labName = extraction.metadata!.labName;
            }

            // Convert extracted biomarkers to domain entities
            // LLM already normalized the names based on existing biomarkers
            for (final extracted in extraction.biomarkers) {
              // Parse value
              final value = _parseDouble(extracted.value);
              if (value == null) continue; // Skip non-numeric values for now

              // Parse reference range
              final range = _parseReferenceRange(extracted.referenceRange);

              allBiomarkers.add(
                Biomarker(
                  id: const Uuid().v4(),
                  name: extracted.name, // Use LLM-normalized name directly
                  value: value,
                  unit: extracted.unit ?? '',
                  referenceRange: range ?? ReferenceRange(min: value, max: value),
                  measuredAt: reportDate ?? DateTime.now(),
                ),
              );
            }
          },
        );
      }

      // 3. Build Report entity
      if (allBiomarkers.isEmpty) {
        return const Left(
          ValidationFailure(message: 'No biomarkers detected'),
        );
      }

      final now = DateTime.now();
      final report = Report(
        id: '', // Will be set by SaveReport use case
        date: reportDate ?? now,
        labName: labName ?? 'Unknown Lab',
        biomarkers: allBiomarkers,
        originalFilePath: filePath,
        notes: patientName != null ? 'Patient: $patientName' : null,
        createdAt: now,
        updatedAt: now,
      );

      return Right(report);
    } catch (e) {
      return Left(OcrFailure(message: 'Extraction failed: $e'));
    }
  }

  double? _parseDouble(String input) {
    final trimmed = input.trim();
    final sanitized = trimmed
        .replaceAll(RegExp(r'[^0-9.,+-]'), '')
        .replaceAll(',', '.');
    return double.tryParse(sanitized);
  }

  ReferenceRange? _parseReferenceRange(String? rangeString) {
    if (rangeString == null || rangeString.isEmpty) return null;

    // Parse ranges like "10-20", "10.5-15.2", etc.
    final hyphenPattern = RegExp(r'([+\-]?\d+(?:[.,]\d+)?)\s*[-–]\s*([+\-]?\d+(?:[.,]\d+)?)');
    final match = hyphenPattern.firstMatch(rangeString);

    if (match != null) {
      final min = _parseDouble(match.group(1)!);
      final max = _parseDouble(match.group(2)!);
      if (min != null && max != null) {
        return ReferenceRange(min: min, max: max);
      }
    }

    // Parse "<X" or ">X" format
    final lessMatch = RegExp(r'<\s*([0-9.,]+)').firstMatch(rangeString);
    if (lessMatch != null) {
      final max = _parseDouble(lessMatch.group(1)!);
      if (max != null) {
        return ReferenceRange(min: 0, max: max);
      }
    }

    final greaterMatch = RegExp(r'>\s*([0-9.,]+)').firstMatch(rangeString);
    if (greaterMatch != null) {
      final min = _parseDouble(greaterMatch.group(1)!);
      if (min != null) {
        return ReferenceRange(min: min, max: min * 10); // Arbitrary upper bound
      }
    }

    return null;
  }
}
