import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:health_tracker_reports/domain/entities/structured_data.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_provider_service.dart';
import 'package:injectable/injectable.dart';

@lazySingleton // Assuming Claude is also a default
class ClaudeLlmService implements LlmProviderService {
  // TODO: Add actual Claude API client

  @override
  Future<Either<Failure, StructuredData>> extractBiomarkers(String extractedText, String apiKey) async {
    // Placeholder implementation
    return Right(StructuredData(
      reportDate: DateTime.now(),
      labName: 'Dummy Lab (Claude)',
      biomarkers: [],
    ));
  }

  @override
  LlmProvider get provider => LlmProvider.claude;
}