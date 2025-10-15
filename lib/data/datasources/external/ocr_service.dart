import 'dart:typed_data';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class OcrService {
  final TextRecognizer textRecognizer;

  OcrService({required this.textRecognizer});

  Future<String> extractText(List<Uint8List> images) async {
    try {
      final recognizedText = <String>[];
      for (final image in images) {
        final inputImage = InputImage.fromBytes(
          bytes: image,
          metadata: InputImageMetadata(
            size: Size(1, 1),
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.nv21,
            bytesPerRow: 0,
          ),
        );
        final text = await textRecognizer.processImage(inputImage);
        recognizedText.add(text.text);
      }
      return recognizedText.join('\n');
    } catch (e) {
      throw OcrException('Failed to extract text from images');
    }
  }
}
