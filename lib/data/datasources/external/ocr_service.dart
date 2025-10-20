import 'package:flutter/services.dart';

abstract class OcrService {
  Future<String> extractText(String filePath);
}

class OcrServiceImpl implements OcrService {
  @override
  Future<String> extractText(String filePath) async {
    // Placeholder implementation
    return 'Dummy extracted text from $filePath';
  }
}
