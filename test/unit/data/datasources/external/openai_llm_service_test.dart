import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/external/openai_llm_service.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late OpenAiLlmService service;
  const apiKey = 'openai-key';
  const base64Image = 'base64-image';

  setUp(() {
    dio = _MockDio();
    service = OpenAiLlmService(dio);
  });

  group('extractFromImage', () {
    test('sends expected request payload to OpenAI endpoint', () async {
      final capturedData = <String, dynamic>{};

      when(
        () => dio.post(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) async {
        capturedData
            .addAll(Map<String, dynamic>.from(invocation.namedArguments[#data]));

        final options = invocation.namedArguments[#options] as Options;
        expect(invocation.positionalArguments.first,
            'https://api.openai.com/v1/chat/completions');
        expect(
          options.headers,
          containsPair('Authorization', 'Bearer $apiKey'),
        );
        expect(options.headers, containsPair('Content-Type', 'application/json'));

        return Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: ''),
          data: {
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'confidence': 0.9,
                    'biomarkers': [
                      {
                        'name': 'Hemoglobin',
                        'value': '13.4',
                        'unit': 'g/dL',
                        'referenceRange': '12-16',
                        'confidence': 0.9,
                      }
                    ],
                    'metadata': {
                      'patientName': 'Test',
                      'reportDate': '2025-01-01',
                      'labName': 'Quest',
                    },
                  }),
                },
              }
            ],
          },
        );
      });

      final result = await service.extractFromImage(
        base64Image: base64Image,
        apiKey: apiKey,
        existingBiomarkerNames: const ['Hemoglobin'],
      );

      expect(result.provider, LlmProvider.openai);
      expect(result.biomarkers.first.name, 'Hemoglobin');
      expect(result.metadata?.labName, 'Quest');
      expect(capturedData['messages'], isNotEmpty);

      final message = capturedData['messages'].first as Map<String, dynamic>;
      expect(message['content'], isA<List>());
      final prompt = (message['content'] as List).first['text'] as String;
      expect(prompt, contains('Hemoglobin'));
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
            'choices': [
              {
                'message': {
                  'content': '```json {"confidence":0.5,"biomarkers":[]} ```',
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

      expect(result.confidence, 0.5);
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
          data: {'choices': []},
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
