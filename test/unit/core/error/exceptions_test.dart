import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';

void main() {
  test('AppException toString returns message', () {
    const exception = ValidationException('Invalid');
    expect(exception.toString(), 'Invalid');
  });

  test('ServerException includes status code in toString', () {
    const exception = ServerException('Failed', statusCode: 500);
    expect(exception.toString(), 'ServerException (500): Failed');
  });

  test('ServerException without status code omits parentheses', () {
    const exception = ServerException('Oops');
    expect(exception.toString(), 'ServerException: Oops');
  });

  test('Other exceptions delegate to AppException toString', () {
    const cache = CacheException();
    const ocr = OcrException('ocr');
    const llm = LlmException('llm');
    const validation = ValidationException('validation');
    const filePicker = FilePickerException();
    const pdf = PdfProcessingException('pdf');
    const network = NetworkException();
    const modelDownload = ModelDownloadException('model');
    const ner = NerException('ner');
    const fileSystem = FileSystemException('fs');

    expect(cache.toString(), 'Cache operation failed');
    expect(ocr.toString(), 'ocr');
    expect(llm.toString(), 'llm');
    expect(validation.toString(), 'validation');
    expect(filePicker.toString(), 'File selection cancelled or failed');
    expect(pdf.toString(), 'pdf');
    expect(network.toString(), 'Network request failed');
    expect(modelDownload.toString(), 'model');
    expect(ner.toString(), 'ner');
    expect(fileSystem.toString(), 'fs');
  });
}
