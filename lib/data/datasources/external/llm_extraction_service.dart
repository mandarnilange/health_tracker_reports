import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/structured_data.dart';

abstract class LlmExtractionService {
  Future<Either<Failure, StructuredData>> extractBiomarkers(String extractedText);
}
