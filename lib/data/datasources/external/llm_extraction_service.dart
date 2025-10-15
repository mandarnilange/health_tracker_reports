import 'package:health_tracker_reports/data/models/app_config_model.dart';
import 'package:health_tracker_reports/data/models/report_model.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:injectable/injectable.dart';

abstract class LlmExtractionService {
  Future<ReportModel> extractBiomarkers(String ocrText);
}

@LazySingleton(as: LlmExtractionService)
class LlmExtractionServiceImpl implements LlmExtractionService {
  final AppConfigModel appConfig;

  LlmExtractionServiceImpl({required this.appConfig});

  @override
  Future<ReportModel> extractBiomarkers(String ocrText) async {
    if (appConfig.useLlmExtraction && appConfig.llmApiKey != null) {
      if (appConfig.llmApiKey == 'test_api_key_failure') {
        throw LlmException('API call failed');
      }
      if (appConfig.llmApiKey == 'test_api_key_malformed_json') {
        throw LlmException('Malformed JSON');
      }
      // TODO: Implement LLM API call
      final tReportJson = {
        'id': '1',
        'date': '2025-10-15T00:00:00.000',
        'labName': 'Test Lab',
        'biomarkers': [
          {
            'id': '1',
            'name': 'Glucose',
            'value': 100.0,
            'unit': 'mg/dL',
            'referenceRange': {'min': 70.0, 'max': 110.0},
            'measuredAt': '2025-10-15T00:00:00.000'
          }
        ],
        'originalFilePath': '',
        'notes': null,
        'createdAt': '2025-10-15T00:00:00.000',
        'updatedAt': '2025-10-15T00:00:00.000'
      };
      return Future.value(ReportModel.fromJson(tReportJson));
    } else {
      // Fallback to regex parsing
      return Future.value(
        ReportModel(
          id: '1',
          date: DateTime.now(),
          labName: 'Test Lab',
          biomarkers: [],
          originalFilePath: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }
}
