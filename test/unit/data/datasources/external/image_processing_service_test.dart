import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:health_tracker_reports/data/datasources/external/image_processing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getTemporaryDirectory') {
      return '/tmp'; // Return a dummy path
    }
    return null;
  });

  late ImageProcessingService service;

  setUp(() {
    service = ImageProcessingService();
  });

  group('ImageProcessingService', () {
    test('imageToBase64 should convert an image file to a base64 string', () async {
      // Arrange
      final tempDir = await getTemporaryDirectory();
      final testFile = File('${tempDir.path}/test_image.png');
      final bytes = Uint8List.fromList([1, 2, 3, 4]); // Dummy image bytes
      await testFile.writeAsBytes(bytes);

      // Act
      final base64String = await service.imageToBase64(testFile.path);

      // Assert
      expect(base64String, isNotEmpty);
      expect(base64String, 'AQIDBA=='); // Base64 for [1, 2, 3, 4]

      // Clean up
      await testFile.delete();
    });
  });
}
