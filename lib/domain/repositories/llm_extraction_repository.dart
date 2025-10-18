import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

/// Repository for LLM-based biomarker extraction
/// Abstracts provider-specific implementations
abstract class LlmExtractionRepository {
  /// Extracts biomarkers from a base64-encoded image
  /// Uses configured provider if [provider] is null
  Future<Either<Failure, LlmExtractionResult>> extractFromImage({
    required String base64Image,
    LlmProvider? provider,
  });

  /// Returns the currently configured LLM provider
  LlmProvider getCurrentProvider();

  /// Cancels ongoing extraction request
  void cancel();
}
