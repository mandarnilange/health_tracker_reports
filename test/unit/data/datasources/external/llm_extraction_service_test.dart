
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_extraction_service.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:mocktail/mocktail.dart';

class MockAppConfigModel extends Mock implements AppConfigModel {}

void main() {
  late LlmExtractionServiceImpl llmExtractionService;
  late MockAppConfigModel mockAppConfigModel;

  setUp(() {
    mockAppConfigModel = MockAppConfigModel();
    llmExtractionService = LlmExtractionServiceImpl(appConfig: mockAppConfigModel);
  });

  group('extractBiomarkers', () {
    final tOcrText = 'Sample OCR text';

    test('should return a ReportModel when extraction is successful', () async {
      // Arrange
      when(() => mockAppConfigModel.useLlmExtraction).thenReturn(true);
      when(() => mockAppConfigModel.llmApiKey).thenReturn('test_api_key');

      // Act
      final result = await llmExtractionService.extractBiomarkers(tOcrText);

      // Assert
      expect(result, isA<ReportModel>());
    });

    test('should fallback to regex parsing when useLlmExtraction is false', () async {
      // Arrange
      when(() => mockAppConfigModel.useLlmExtraction).thenReturn(false);
      when(() => mockAppConfigModel.llmApiKey).thenReturn(null);

      // Act
      final result = await llmExtractionService.extractBiomarkers(tOcrText);

      // Assert
      expect(result, isA<ReportModel>());
    });

    test('should throw an LlmException when the API call fails', () async {
      // Arrange
      when(() => mockAppConfigModel.useLlmExtraction).thenReturn(true);
      when(() => mockAppConfigModel.llmApiKey).thenReturn('test_api_key_failure');
      final service = LlmExtractionServiceImpl(appConfig: mockAppConfigModel);
      
      // Act
      final call = service.extractBiomarkers;

      // Assert
      await expectLater(() => call(tOcrText), throwsA(isA<LlmException>()));
    });

    test('should throw an LlmException for malformed JSON', () async {
      // Arrange
      when(() => mockAppConfigModel.useLlmExtraction).thenReturn(true);
      when(() => mockAppConfigModel.llmApiKey).thenReturn('test_api_key_malformed_json');
      final service = LlmExtractionServiceImpl(appConfig: mockAppConfigModel);

      // Act
      final call = service.extractBiomarkers;

      // Assert
      await expectLater(() => call(tOcrText), throwsA(isA<LlmException>()));
    });
  });
}
