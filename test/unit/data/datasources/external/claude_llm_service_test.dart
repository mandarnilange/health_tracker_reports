import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/external/claude_llm_service.dart';
import 'package:health_tracker_reports/domain/entities/llm_extraction.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ClaudeLlmService service;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    service = ClaudeLlmService(mockDio);
  });

  setUpAll(() {
    registerFallbackValue(Options());
  });

  group('ClaudeLlmService', () {
    const testApiKey = 'sk-ant-test-key';
    const testBase64Image = 'base64encodedimage==';

    test('should return LlmProvider.claude', () {
      expect(service.provider, LlmProvider.claude);
    });

    group('extractFromImage', () {
      test('should successfully extract biomarkers from valid response', () async {
        // Arrange
        final responseData = {
          'content': [
            {
              'text': '''```json
{
  "biomarkers": [
    {
      "name": "Hemoglobin",
      "value": "14.5",
      "unit": "g/dL",
      "reference_range": "12.0-16.0",
      "confidence": 0.95
    },
    {
      "name": "Glucose",
      "value": "95",
      "unit": "mg/dL",
      "reference_range": "70-100",
      "confidence": 0.92
    }
  ],
  "metadata": {
    "patient_name": "John Doe",
    "report_date": "2025-10-15",
    "lab_name": "Quest Diagnostics"
  }
}
```'''
            }
          ],
          'usage': {'input_tokens': 100, 'output_tokens': 200}
        };

        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await service.extractFromImage(
          base64Image: testBase64Image,
          apiKey: testApiKey,
        );

        // Assert
        expect(result.biomarkers.length, 2);
        expect(result.biomarkers[0].name, 'Hemoglobin');
        expect(result.biomarkers[0].value, '14.5');
        expect(result.biomarkers[0].unit, 'g/dL');
        expect(result.biomarkers[0].referenceRange, '12.0-16.0');
        expect(result.biomarkers[0].confidence, 0.95);

        expect(result.biomarkers[1].name, 'Glucose');
        expect(result.biomarkers[1].value, '95');

        expect(result.metadata, isNotNull);
        expect(result.metadata!.patientName, 'John Doe');
        expect(result.metadata!.reportDate, DateTime(2025, 10, 15));
        expect(result.metadata!.labName, 'Quest Diagnostics');

        expect(result.provider, LlmProvider.claude);
        expect(result.confidence, greaterThan(0.9));
      });

      test('should extract biomarkers without metadata', () async {
        // Arrange
        final responseData = {
          'content': [
            {
              'text': '''```json
{
  "biomarkers": [
    {
      "name": "Hemoglobin",
      "value": "14.5",
      "unit": "g/dL",
      "reference_range": "12.0-16.0"
    }
  ]
}
```'''
            }
          ],
        };

        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await service.extractFromImage(
          base64Image: testBase64Image,
          apiKey: testApiKey,
        );

        // Assert
        expect(result.biomarkers.length, 1);
        expect(result.metadata, isNull);
        expect(result.confidence, greaterThan(0));
      });

      test('should handle response without json markdown blocks', () async {
        // Arrange
        final responseData = {
          'content': [
            {
              'text': '''{
  "biomarkers": [
    {
      "name": "Hemoglobin",
      "value": "14.5",
      "unit": "g/dL"
    }
  ]
}'''
            }
          ],
        };

        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await service.extractFromImage(
          base64Image: testBase64Image,
          apiKey: testApiKey,
        );

        // Assert
        expect(result.biomarkers.length, 1);
        expect(result.biomarkers[0].name, 'Hemoglobin');
      });

      test('should use correct API endpoint and headers', () async {
        // Arrange
        final responseData = {
          'content': [
            {'text': '{"biomarkers": []}'}
          ],
        };

        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        await service.extractFromImage(
          base64Image: testBase64Image,
          apiKey: testApiKey,
        );

        // Assert
        verify(() => mockDio.post(
              'https://api.anthropic.com/v1/messages',
              options: any(
                named: 'options',
                that: predicate<Options>((opts) {
                  return opts.headers?['x-api-key'] == testApiKey &&
                      opts.headers?['anthropic-version'] == '2023-06-01' &&
                      opts.headers?['content-type'] == 'application/json';
                }),
              ),
              data: any(
                named: 'data',
                that: predicate<Map<String, dynamic>>((data) {
                  return data['model'] == 'claude-3-5-sonnet-20241022' &&
                      data['max_tokens'] == 4096;
                }),
              ),
            )).called(1);
      });

      test('should throw exception on network error', () async {
        // Arrange
        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.connectionTimeout,
            ));

        // Act & Assert
        expect(
          () => service.extractFromImage(
            base64Image: testBase64Image,
            apiKey: testApiKey,
          ),
          throwsA(isA<DioException>()),
        );
      });

      test('should throw exception on invalid JSON response', () async {
        // Arrange
        final responseData = {
          'content': [
            {'text': 'This is not valid JSON'}
          ],
        };

        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(
          () => service.extractFromImage(
            base64Image: testBase64Image,
            apiKey: testApiKey,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when biomarkers array is missing', () async {
        // Arrange
        final responseData = {
          'content': [
            {'text': '{"metadata": {}}'}
          ],
        };

        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(
          () => service.extractFromImage(
            base64Image: testBase64Image,
            apiKey: testApiKey,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle API error response', () async {
        // Arrange
        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              response: Response(
                statusCode: 401,
                data: {'error': {'message': 'Invalid API key'}},
                requestOptions: RequestOptions(path: ''),
              ),
              type: DioExceptionType.badResponse,
            ));

        // Act & Assert
        expect(
          () => service.extractFromImage(
            base64Image: testBase64Image,
            apiKey: testApiKey,
          ),
          throwsA(isA<DioException>()),
        );
      });

      test('should handle rate limit error', () async {
        // Arrange
        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              response: Response(
                statusCode: 429,
                data: {'error': {'message': 'Rate limit exceeded'}},
                requestOptions: RequestOptions(path: ''),
              ),
              type: DioExceptionType.badResponse,
            ));

        // Act & Assert
        expect(
          () => service.extractFromImage(
            base64Image: testBase64Image,
            apiKey: testApiKey,
          ),
          throwsA(isA<DioException>()),
        );
      });

      test('should handle biomarkers with missing optional fields', () async {
        // Arrange
        final responseData = {
          'content': [
            {
              'text': '''```json
{
  "biomarkers": [
    {
      "name": "Hemoglobin",
      "value": "14.5"
    }
  ]
}
```'''
            }
          ],
        };

        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await service.extractFromImage(
          base64Image: testBase64Image,
          apiKey: testApiKey,
        );

        // Assert
        expect(result.biomarkers.length, 1);
        expect(result.biomarkers[0].name, 'Hemoglobin');
        expect(result.biomarkers[0].value, '14.5');
        expect(result.biomarkers[0].unit, isNull);
        expect(result.biomarkers[0].referenceRange, isNull);
        expect(result.biomarkers[0].confidence, isNull);
      });

      test('should calculate average confidence correctly', () async {
        // Arrange
        final responseData = {
          'content': [
            {
              'text': '''```json
{
  "biomarkers": [
    {
      "name": "Test1",
      "value": "1",
      "confidence": 0.8
    },
    {
      "name": "Test2",
      "value": "2",
      "confidence": 0.9
    },
    {
      "name": "Test3",
      "value": "3",
      "confidence": 1.0
    }
  ]
}
```'''
            }
          ],
        };

        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await service.extractFromImage(
          base64Image: testBase64Image,
          apiKey: testApiKey,
        );

        // Assert
        expect(result.confidence, closeTo(0.9, 0.01)); // (0.8 + 0.9 + 1.0) / 3 = 0.9
      });

      test('should default confidence to 0.5 when no biomarker confidences', () async {
        // Arrange
        final responseData = {
          'content': [
            {
              'text': '''```json
{
  "biomarkers": [
    {
      "name": "Test1",
      "value": "1"
    }
  ]
}
```'''
            }
          ],
        };

        when(() => mockDio.post(
              any(),
              options: any(named: 'options'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await service.extractFromImage(
          base64Image: testBase64Image,
          apiKey: testApiKey,
        );

        // Assert
        expect(result.confidence, 0.5);
      });
    });

    group('cancel', () {
      test('should not throw when called', () {
        expect(() => service.cancel(), returnsNormally);
      });
    });
  });
}
