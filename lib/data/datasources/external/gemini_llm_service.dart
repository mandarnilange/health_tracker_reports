import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_provider_service.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

@LazySingleton()
class GeminiLlmService implements LlmProviderService {
  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1';
  static const _model = 'gemini-2.5-flash-latest';

  final Dio _dio;
  CancelToken? _cancelToken;

  GeminiLlmService(this._dio);

  @override
  LlmProvider get provider => LlmProvider.gemini;

  @override
  Future<LlmExtractionResult> extractFromImage({
    required String base64Image,
    required String apiKey,
    List<String> existingBiomarkerNames = const [],
    int timeoutSeconds = 30,
  }) async {
    _cancelToken = CancelToken();

    final response = await _dio.post(
      '$_baseUrl/models/$_model:generateContent?key=$apiKey',
      options: Options(
        headers: {'Content-Type': 'application/json'},
        sendTimeout: Duration(seconds: timeoutSeconds),
        receiveTimeout: Duration(seconds: timeoutSeconds),
      ),
      data: {
        'contents': [
          {
            'parts': [
              {'text': _getPrompt(existingBiomarkerNames)},
              {
                'inline_data': {
                  'mime_type': 'image/png',
                  'data': base64Image,
                }
              }
            ]
          }
        ],
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
1. Extract ALL biomarkers visible
2. Use exact names from the historical list when applicable (see normalization guidance above)
3. Include units
4. Parse reference ranges
5. Set confidence scores (0.0-1.0)
6. Use null for missing fields
7. Dates in YYYY-MM-DD format
8. Return ONLY JSON, no markdown''';
  }

  LlmExtractionResult _parseResponse(Map<String, dynamic> response) {
    try {
      final candidates = response['candidates'] as List;
      final content = candidates.first['content'];
      final parts = content['parts'] as List;
      var jsonString = parts.first['text'] as String;

      // Remove markdown if present
      jsonString = jsonString.replaceAll(RegExp(r'```json\s*'), '');
      jsonString = jsonString.replaceAll(RegExp(r'```\s*$'), '');
      jsonString = jsonString.trim();

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
        provider: LlmProvider.gemini,
      );
    } catch (e) {
      throw Exception('Failed to parse Gemini response: $e');
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
