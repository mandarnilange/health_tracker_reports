import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/entities/structured_data.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

/// Abstract service for specific LLM provider API
abstract class LlmProviderService {
  Future<Either<Failure, StructuredData>> extractBiomarkers(String extractedText, String apiKey);
  LlmProvider get provider;
}