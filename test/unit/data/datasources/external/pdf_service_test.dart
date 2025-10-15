import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_document_wrapper.dart';
import 'package:health_tracker_reports/data/datasources/external/pdf_service.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pdf_render/pdf_render.dart';

class MockPdfDocumentWrapper extends Mock implements PdfDocumentWrapper {}
class MockPdfDocument implements PdfDocument {
  @override
  bool operator ==(Object? other) => identical(this, other) || other is PdfDocument;

  @override
  int get hashCode => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
class MockPdfPage implements PdfPage {
  @override
  bool operator ==(Object? other) => identical(this, other) || other is PdfPage;

  @override
  int get hashCode => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
class MockPdfPageImage extends Mock implements PdfPageImage {}
class MockImage extends Mock implements ui.Image {}

void main() {
  late PdfService pdfService;
  late MockPdfDocumentWrapper mockPdfDocumentWrapper;

  setUp(() {
    mockPdfDocumentWrapper = MockPdfDocumentWrapper();
    pdfService = PdfService(pdfDocumentWrapper: mockPdfDocumentWrapper);
    registerFallbackValue(ui.ImageByteFormat.png);
  });

  group('convertToImages', () {
    final tPdfPath = 'test.pdf';

    test('should convert a single-page PDF to a single image', () async {
      // Arrange
      final mockDocument = MockPdfDocument();
      final mockPage = MockPdfPage();
      final mockPageImage = MockPdfPageImage();
      final file = File(tPdfPath);
      await file.writeAsBytes([0, 1, 2, 3]);

      when(() => mockPdfDocumentWrapper.openFile(any())).thenAnswer((_) async => mockDocument);
      when(() => mockDocument.pageCount).thenReturn(1);
      when(() => mockDocument.getPage(1)).thenAnswer((_) async => mockPage);
      when(() => mockPage.render()).thenAnswer((_) async => mockPageImage);
      final mockImage = MockImage();
      when(() => mockPageImage.createImageDetached()).thenAnswer((_) async => mockImage);
      when(() => mockImage.toByteData(format: any(named: 'format'))).thenAnswer((_) async => ByteData(0));
      when(() => mockPageImage.pixels).thenReturn(Uint8List(0));
      when(() => mockPageImage.width).thenReturn(100);
      when(() => mockPageImage.height).thenReturn(100);

      // Act
      final result = await pdfService.convertToImages(tPdfPath);

      // Assert
      expect(result, isA<List<Uint8List>>());
      expect(result.length, 1);

      // Clean up
      await file.delete();
    });

    test('should convert a multi-page PDF to multiple images', () async {
      // Arrange
      final mockDocument = MockPdfDocument();
      final mockPage1 = MockPdfPage();
      final mockPage2 = MockPdfPage();
      final mockPageImage1 = MockPdfPageImage();
      final mockPageImage2 = MockPdfPageImage();
      final file = File(tPdfPath);
      await file.writeAsBytes([0, 1, 2, 3]);

      when(() => mockPdfDocumentWrapper.openFile(any())).thenAnswer((_) async => mockDocument);
      when(() => mockDocument.pageCount).thenReturn(2);
      when(() => mockDocument.getPage(1)).thenAnswer((_) async => mockPage1);
      when(() => mockDocument.getPage(2)).thenAnswer((_) async => mockPage2);
      when(() => mockPage1.render(width: any(named: 'width'), height: any(named: 'height'))).thenAnswer((_) async => mockPageImage1);
      when(() => mockPage2.render(width: any(named: 'width'), height: any(named: 'height'))).thenAnswer((_) async => mockPageImage2);
      final mockImage1 = MockImage();
      final mockImage2 = MockImage();
      when(() => mockPageImage1.createImageDetached()).thenAnswer((_) async => mockImage1);
      when(() => mockImage1.toByteData(format: any(named: 'format'))).thenAnswer((_) async => ByteData(0));
      when(() => mockPageImage2.createImageDetached()).thenAnswer((_) async => mockImage2);
      when(() => mockImage2.toByteData(format: any(named: 'format'))).thenAnswer((_) async => ByteData(0));

      // Act
      final result = await pdfService.convertToImages(tPdfPath);

      // Assert
      expect(result, isA<List<Uint8List>>());
      expect(result.length, 2);

      // Clean up
      await file.delete();
    });

    test('should throw a FileSystemException for an invalid PDF path', () async {
      // Act
      final call = pdfService.convertToImages;

      // Assert
      expect(() => call('invalid.pdf'), throwsA(isA<FileSystemException>()));
    });

    test('should throw an OcrException when pdf rendering fails', () async {
      // Arrange
      final file = File(tPdfPath);
      await file.writeAsBytes([0, 1, 2, 3]);
      when(() => mockPdfDocumentWrapper.openFile(any())).thenThrow(Exception());

      // Act
      final call = pdfService.convertToImages;

      // Assert
      expect(() => call(tPdfPath), throwsA(isA<OcrException>()));

      // Clean up
      await file.delete();
    });
  });
}
