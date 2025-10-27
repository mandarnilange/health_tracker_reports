import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/external/image_processing_service.dart';
import 'package:image/image.dart' as img;

void main() {
  late ImageProcessingService service;

  setUp(() {
    service = ImageProcessingService();
  });

  test('imageToBase64 reads file bytes and encodes as base64', () async {
    final image = img.Image(width: 2, height: 2);
    final pngBytes = img.encodePng(image);
    final tempFile = File('${Directory.systemTemp.path}/test_image.png');
    await tempFile.writeAsBytes(pngBytes);

    final base64 = await service.imageToBase64(tempFile.path);

    expect(base64, base64Encode(pngBytes));
    await tempFile.delete();
  });

  test('compressImageBase64 returns original when already below threshold',
      () async {
    final image = img.Image(width: 8, height: 8);
    final pngBytes = img.encodePng(image);
    final base64 = base64Encode(pngBytes);

    final result = await service.compressImageBase64(
      base64,
      maxSizeBytes: pngBytes.length * 2,
    );

    expect(result, base64);
  });

  test('compressImageBase64 reduces payload when above threshold', () async {
    final largeImage = img.Image(width: 300, height: 300);
    final pngBytes = img.encodePng(largeImage, level: 0);
    final base64 = base64Encode(pngBytes);

    final result = await service.compressImageBase64(
      base64,
      maxSizeBytes: pngBytes.length ~/ 3,
    );

    final compressedBytes = base64Decode(result);
    expect(compressedBytes.length, lessThan(pngBytes.length));
  });
}
