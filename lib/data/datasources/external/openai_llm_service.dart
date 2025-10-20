import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/entities/structured_data.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_provider_service.dart';
import 'package:injectable/injectable.dart';

@lazySingleton // Assuming OpenAI is also a default
class OpenAiLlmService implements LlmProviderService {
  // TODO: Add actual OpenAI API client

  @override
  Future<Either<Failure, StructuredData>> extractBiomarkers(String extractedText, String apiKey) async {
    // Placeholder implementation
    return Right(StructuredData(
      reportDate: DateTime.now(),
      labName: 'Dummy Lab (OpenAI)',
      biomarkers: [],
    ));
  }

  @override
  LlmProvider get provider => LlmProvider.openai;
}