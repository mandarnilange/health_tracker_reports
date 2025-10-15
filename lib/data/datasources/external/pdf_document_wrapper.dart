import 'package:pdf_render/pdf_render.dart';

class PdfDocumentWrapper {
  Future<PdfDocument> openFile(String path) {
    return PdfDocument.openFile(path);
  }
}
