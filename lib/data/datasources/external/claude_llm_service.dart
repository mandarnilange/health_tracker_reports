import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_provider_service.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

@LazySingleton()
class ClaudeLlmService implements LlmProviderService {
  static const _baseUrl = 'https://api.anthropic.com/v1';
  static const _model = 'claude-3-5-sonnet-20241022';

  final Dio _dio;
  CancelToken? _cancelToken;

  ClaudeLlmService(this._dio);

  @override
  LlmProvider get provider => LlmProvider.claude;

  @override
  Future<LlmExtractionResult> extractFromImage({
    required String base64Image,
    required String apiKey,
    List<String> existingBiomarkerNames = const [],
    int timeoutSeconds = 30,
  }) async {
    _cancelToken = CancelToken();

    final response = await _dio.post(
      '$_baseUrl/messages',
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        sendTimeout: Duration(seconds: timeoutSeconds),
        receiveTimeout: Duration(seconds: timeoutSeconds),
      ),
      data: {
        'model': _model,
        'max_tokens': 4096,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/png',
                  'data': base64Image,
                }
              },
              {
                'type': 'text',
                'text': _getPrompt(existingBiomarkerNames),
              }
            ]
          }
        ]
      },
      cancelToken: _cancelToken,
    );

    return _parseResponse(response.data);
  }

  @override
  void cancel() {
    _cancelToken?.cancel();
  }

  String _getPrompt(List<String> existingBiomarkerNames) {
    final normalizationGuidance = existingBiomarkerNames.isEmpty
        ? ''
        : '''

IMPORTANT - Biomarker Name Normalization:
The user has the following biomarker names in their historical reports:
${existingBiomarkerNames.map((name) => '  - $name').join('\n')}

When extracting biomarkers, if you identify a biomarker that matches one of these existing names (considering common aliases, abbreviations, or slight variations), use the EXACT name from the list above. For example:
- If you see "Hb" or "HGB" and "Hemoglobin" exists in the list, use "Hemoglobin"
- If you see "WBC Count" and "White Blood Cell Count" exists, use "White Blood Cell Count"
- If you see "Chol" and "Cholesterol" exists, use "Cholesterol"

This ensures consistency across all reports for trend analysis.
''';

    return '''You are a medical lab report analyzer. Extract biomarker data from the provided blood test report image.
$normalizationGuidance
Return ONLY valid JSON in this exact format (no markdown, no explanations):

{
  "confidence": 0.95,
  "metadata": {
    "patientName": "John Doe",
    "reportDate": "2025-01-15",
    "collectionDate": "2025-01-14",
    "labName": "Quest Diagnostics",
    "labReference": "REF123456"
  },
  "biomarkers": [
    {
      "name": "Hemoglobin",
      "value": "13.5",
      "unit": "g/dL",
      "referenceRange": "12.0-16.0",
      "confidence": 0.98
    }
  ]
}

Rules:
1. Extract ALL biomarkers visible in the report
2. Use exact names from the historical list when applicable (see normalization guidance above)
3. Include units even if they're in column headers
4. Parse reference ranges (e.g., "10-20", "<5", ">100")
5. Set confidence scores based on clarity (0.0-1.0)
6. If a field is unclear or missing, use null
7. For dates, use ISO format (YYYY-MM-DD)
8. For qualitative values (Reactive, Not Detected), include in value field
9. Return ONLY the JSON object, no markdown formatting''';
  }

  LlmExtractionResult _parseResponse(Map<String, dynamic> response) {
    try {
      // Parse Claude response format
      final content = response['content'] as List;
      final textBlock = content.firstWhere((c) => c['type'] == 'text');
      var jsonString = textBlock['text'] as String;

      // Remove markdown code blocks if present
      jsonString = jsonString.replaceAll(RegExp(r'```json\s*'), '');
      jsonString = jsonString.replaceAll(RegExp(r'```\s*$'), '');
      jsonString = jsonString.trim();

      // Parse JSON response
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Extract biomarkers
      final biomarkersList = data['biomarkers'] as List? ?? [];
      final biomarkers = biomarkersList.map((b) {
        final biomarkerMap = b as Map<String, dynamic>;
        return ExtractedBiomarker(
          name: biomarkerMap['name'] as String,
          value: biomarkerMap['value']?.toString() ?? '',
          unit: biomarkerMap['unit'] as String?,
          referenceRange: biomarkerMap['referenceRange'] as String?,
          confidence: (biomarkerMap['confidence'] as num?)?.toDouble(),
        );
      }).toList();

      // Extract metadata
      ExtractedMetadata? metadata;
      if (data['metadata'] != null) {
        final metadataMap = data['metadata'] as Map<String, dynamic>;
        metadata = ExtractedMetadata(
          patientName: metadataMap['patientName'] as String?,
          reportDate: _parseDate(metadataMap['reportDate']),
          collectionDate: _parseDate(metadataMap['collectionDate']),
          labName: metadataMap['labName'] as String?,
          labReference: metadataMap['labReference'] as String?,
        );
      }

      final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.8;

      return LlmExtractionResult(
        biomarkers: biomarkers,
        metadata: metadata,
        confidence: confidence,
        rawResponse: jsonString,
        provider: LlmProvider.claude,
      );
    } catch (e) {
      throw Exception('Failed to parse Claude response: $e');
    }
  }

  DateTime? _parseDate(dynamic dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return null;
    }
  }
}
