import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';
import 'package:pdfx/pdfx.dart';

/// Service for processing PDFs and images for LLM extraction
@LazySingleton()
class ImageProcessingService {
  /// Converts PDF file to list of base64-encoded PNG images
  Future<List<String>> pdfToBase64Images(
    String pdfPath, {
    Future<PdfDocument> Function(String path)? openDocument,
  }) async {
    final document = await (openDocument ?? PdfDocument.openFile)(pdfPath);
    final pageCount = document.pagesCount;
    final images = <String>[];

    try {
      for (var i = 1; i <= pageCount; i++) {
        final page = await document.getPage(i);
        try {
          // Render at 2x resolution for better OCR
          final pageImage = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: PdfPageImageFormat.png,
          );

          if (pageImage != null) {
            final base64 = base64Encode(pageImage.bytes);
            images.add(base64);
          }
        } finally {
          await page.close();
        }
      }
    } finally {
      await document.close();
    }

    return images;
  }

  /// Converts image file to base64-encoded string
  Future<String> imageToBase64(String imagePath) async {
    final bytes = await _readImageBytes(imagePath);
    return base64Encode(bytes);
  }

  /// Compresses image to reduce API payload size (target <5MB)
  Future<String> compressImageBase64(
    String base64Image, {
    int maxSizeBytes = 5 * 1024 * 1024,
  }) async {
    final bytes = base64Decode(base64Image);

    // If already under limit, return as-is
    if (bytes.length <= maxSizeBytes) {
      return base64Image;
    }

    // Decode image
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image for compression');
    }

    // Calculate scale factor to meet size target
    final currentSize = bytes.length;
    final scaleFactor = (maxSizeBytes / currentSize) * 0.9; // 90% of target
    final newWidth = (image.width * scaleFactor).round();

    // Resize and re-encode
    final resized = img.copyResize(image, width: newWidth);
    final compressed = img.encodePng(resized, level: 6);

    return base64Encode(compressed);
  }

  Future<Uint8List> _readImageBytes(String path) async {
    final file = File(path);
    return await file.readAsBytes();
  }
}
