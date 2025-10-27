import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/external/gemini_llm_service.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late GeminiLlmService service;
  const apiKey = 'gemini-key';
  const base64Image = 'base64-image';

  setUp(() {
    dio = _MockDio();
    service = GeminiLlmService(dio);
  });

  group('extractFromImage', () {
    test('sends expected payload to Gemini endpoint', () async {
      Map<String, dynamic>? capturedData;

      when(
        () => dio.post(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) async {
        capturedData =
            Map<String, dynamic>.from(invocation.namedArguments[#data]);
        final options = invocation.namedArguments[#options] as Options;

        expect(
          invocation.positionalArguments.first,
          'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey',
        );
        expect(options.headers, containsPair('Content-Type', 'application/json'));

        return Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          data: {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': jsonEncode({
                        'confidence': 0.8,
                        'metadata': {
                          'patientName': 'Jane Doe',
                        },
                        'biomarkers': [
                          {
                            'name': 'LDL',
                            'value': '120',
                            'unit': 'mg/dL',
                            'referenceRange': '0-100',
                          }
                        ],
                      }),
                    }
                  ],
                },
              }
            ],
          },
        );
      });

      final result = await service.extractFromImage(
        base64Image: base64Image,
        apiKey: apiKey,
        existingBiomarkerNames: const ['LDL'],
      );

      expect(result.provider, LlmProvider.gemini);
      expect(result.biomarkers.first.name, 'LDL');
      expect(result.metadata?.patientName, 'Jane Doe');
      expect(capturedData, isNotNull);
      final parts = (capturedData!['contents'] as List).first['parts'] as List;
      expect(parts.first['text'], contains('LDL'));
      expect((parts[1] as Map)['inline_data']['data'], base64Image);
    });

    test('parses markdown JSON payloads', () async {
      when(
        () => dio.post(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async {
        return Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          data: {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': '```json {"confidence":0.42,"biomarkers":[]} ```'},
                  ],
                },
              }
            ],
          },
        );
      });

      final result = await service.extractFromImage(
        base64Image: base64Image,
        apiKey: apiKey,
      );

      expect(result.confidence, 0.42);
    });

    test('throws parse exception when response invalid', () async {
      when(
        () => dio.post(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async {
        return Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          data: {'candidates': []},
        );
      });

      expect(
        () async => service.extractFromImage(
          base64Image: base64Image,
          apiKey: apiKey,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
