import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/external/ocr_service.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MockTextRecognizer extends Mock implements TextRecognizer {}
class MockRecognizedText extends Mock implements RecognizedText {}

void main() {
  late OcrService ocrService;
  late MockTextRecognizer mockTextRecognizer;

  setUp(() {
    mockTextRecognizer = MockTextRecognizer();
    ocrService = OcrService(textRecognizer: mockTextRecognizer);
    registerFallbackValue(
      InputImage.fromBytes(
        bytes: Uint8List(0),
        metadata: InputImageMetadata(
          size: const Size(1, 1),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 0,
        ),
      ),
    );
  });

  group('extractText', () {
    final tImage = Uint8List(0);

    test('should extract text from a single image', () async {
      // Arrange
      final tRecognizedText = MockRecognizedText();
      when(() => tRecognizedText.text).thenReturn('Hello');
      when(() => mockTextRecognizer.processImage(any())).thenAnswer((_) async => tRecognizedText);

      // Act
      final result = await ocrService.extractText([tImage]);

      // Assert
      expect(result, 'Hello');
    });

    test('should extract and combine text from multiple images', () async {
      // Arrange
      final tImage1 = Uint8List.fromList([1]);
      final tImage2 = Uint8List.fromList([2]);
      final tRecognizedText1 = MockRecognizedText();
      final tRecognizedText2 = MockRecognizedText();
      when(() => tRecognizedText1.text).thenReturn('Hello');
      when(() => tRecognizedText2.text).thenReturn('World');
      when(() => mockTextRecognizer.processImage(any(that: predicate((i) => (i as InputImage).bytes == tImage1))))
          .thenAnswer((_) async => tRecognizedText1);
      when(() => mockTextRecognizer.processImage(any(that: predicate((i) => (i as InputImage).bytes == tImage2))))
          .thenAnswer((_) async => tRecognizedText2);

      // Act
      final result = await ocrService.extractText([tImage1, tImage2]);

      // Assert
      expect(result, 'Hello\nWorld');
    });

    test('should return an empty string when no text is recognized', () async {
      // Arrange
      final tRecognizedText = MockRecognizedText();
      when(() => tRecognizedText.text).thenReturn('');
      when(() => mockTextRecognizer.processImage(any())).thenAnswer((_) async => tRecognizedText);

      // Act
      final result = await ocrService.extractText([tImage]);

      // Assert
      expect(result, '');
    });

    test('should throw an OcrException when processing fails', () async {
      // Arrange
      when(() => mockTextRecognizer.processImage(any())).thenThrow(Exception());

      // Act
      final call = ocrService.extractText;

      // Assert
      expect(() => call([tImage]), throwsA(isA<OcrException>()));
    });
  });
}