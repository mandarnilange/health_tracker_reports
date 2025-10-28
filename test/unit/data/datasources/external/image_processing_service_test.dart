import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/external/image_processing_service.dart';
import 'package:image/image.dart' as img;
import 'package:pdfx/pdfx.dart';

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

  test('pdfToBase64Images renders each page and closes resources', () async {
    final document = TestPdfDocument(pagesCount: 2);
    final page1Image = TestPdfPageImage(
      pageNumber: 1,
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    final page2Image = TestPdfPageImage(
      pageNumber: 2,
      bytes: Uint8List.fromList([4, 5, 6, 7]),
    );

    final page1 = TestPdfPage(
      document: document,
      pageNumber: 1,
      width: 200,
      height: 300,
      images: [page1Image],
    );

    final page2 = TestPdfPage(
      document: document,
      pageNumber: 2,
      width: 150,
      height: 250,
      images: [page2Image],
    );

    document.pages = [page1, page2];

    final result = await service.pdfToBase64Images(
      'test.pdf',
      openDocument: (_) async => document,
    );

    expect(result, [
      base64Encode(page1Image.bytes),
      base64Encode(page2Image.bytes),
    ]);
    expect(page1.closed, isTrue);
    expect(page2.closed, isTrue);
    expect(document.closed, isTrue);
    expect(page1.lastRenderWidth, equals(page1.width * 2));
    expect(page2.lastRenderWidth, equals(page2.width * 2));
  });
}

class TestPdfDocument extends PdfDocument {
  TestPdfDocument({required int pagesCount})
      : super(sourceName: 'test', id: 'doc-id', pagesCount: pagesCount);

  late List<TestPdfPage> pages;
  bool closed = false;

  @override
  Future<void> close() async {
    closed = true;
  }

  @override
  Future<PdfPage> getPage(int pageNumber, {bool autoCloseAndroid = false}) async {
    return pages[pageNumber - 1];
  }

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

class TestPdfPage extends PdfPage {
  TestPdfPage({
    required PdfDocument document,
    required int pageNumber,
    required double width,
    required double height,
    required this.images,
  }) : super(
          document: document,
          id: 'page-$pageNumber',
          pageNumber: pageNumber,
          width: width,
          height: height,
          autoCloseAndroid: false,
        );

  final List<PdfPageImage?> images;
  bool closed = false;
  double? lastRenderWidth;

  @override
  Future<PdfPageImage?> render({
    required double width,
    required double height,
    PdfPageImageFormat format = PdfPageImageFormat.jpeg,
    String? backgroundColor,
    Rect? cropRect,
    int quality = 100,
    bool forPrint = false,
    bool removeTempFile = true,
  }) async {
    lastRenderWidth = width;
    if (images.isEmpty) return null;
    return images.removeAt(0);
  }

  @override
  Future<PdfPageTexture> createTexture() {
    throw UnimplementedError('Texture rendering not required for tests');
  }

  @override
  Future<void> close() async {
    closed = true;
  }

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

class TestPdfPageImage extends PdfPageImage {
  TestPdfPageImage({
    required int pageNumber,
    required Uint8List bytes,
  }) : super(
          id: 'img-$pageNumber',
          pageNumber: pageNumber,
          width: bytes.length,
          height: bytes.length,
          bytes: bytes,
          format: PdfPageImageFormat.png,
          quality: 100,
        );

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}
