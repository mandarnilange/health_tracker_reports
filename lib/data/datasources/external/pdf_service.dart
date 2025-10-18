import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_document_wrapper.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PdfService {
  final PdfDocumentWrapper pdfDocumentWrapper;

  PdfService({required this.pdfDocumentWrapper});

  Future<List<Uint8List>> convertToImages(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw FileSystemException('File not found: $path');
    }

    try {
      final doc = await pdfDocumentWrapper.openFile(path);
      final images = <Uint8List>[];
      for (var i = 1; i <= doc.pageCount; i++) {
        final page = await doc.getPage(i);
        final pageImage = await page.render();
        final image = await pageImage.createImageDetached();
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final png = byteData!.buffer.asUint8List();
        images.add(png);
      }
      return images;
    } catch (e) {
      throw OcrException('Failed to convert PDF to images');
    }
  }
}
