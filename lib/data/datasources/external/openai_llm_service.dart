import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:health_tracker_reports/data/datasources/external/llm_provider_service.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';

@LazySingleton()
class OpenAiLlmService implements LlmProviderService {
  static const _baseUrl = 'https://api.openai.com/v1';
  static const _model = 'gpt-4-vision-preview';

  final Dio _dio;
  CancelToken? _cancelToken;

  OpenAiLlmService(this._dio);

  @override
  LlmProvider get provider => LlmProvider.openai;

  @override
  Future<LlmExtractionResult> extractFromImage({
    required String base64Image,
    required String apiKey,
    int timeoutSeconds = 30,
  }) async {
    _cancelToken = CancelToken();

    final response = await _dio.post(
      '$_baseUrl/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        sendTimeout: Duration(seconds: timeoutSeconds),
        receiveTimeout: Duration(seconds: timeoutSeconds),
      ),
      data: {
        'model': _model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': _getPrompt(),
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/png;base64,$base64Image',
                }
              }
            ]
          }
        ],
        'max_tokens': 4096,
      },
      cancelToken: _cancelToken,
    );

    return _parseResponse(response.data);
  }

  @override
  void cancel() {
    _cancelToken?.cancel();
  }

  String _getPrompt() {
    return '''You are a medical lab report analyzer. Extract biomarker data from the provided blood test report image.

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
2. Preserve exact names
3. Include units
4. Parse reference ranges
5. Set confidence scores (0.0-1.0)
6. Use null for missing fields
7. Dates in YYYY-MM-DD format
8. Return ONLY JSON, no markdown''';
  }

  LlmExtractionResult _parseResponse(Map<String, dynamic> response) {
    try {
      final choices = response['choices'] as List;
      final message = choices.first['message'];
      var jsonString = message['content'] as String;

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
        provider: LlmProvider.openai,
      );
    } catch (e) {
      throw Exception('Failed to parse OpenAI response: $e');
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
