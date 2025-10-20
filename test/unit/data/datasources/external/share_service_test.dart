import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';
import 'package:health_tracker_reports/data/datasources/external/share_service.dart';

class MockShare extends Mock implements ShareWrapper {}

void main() {
  late ShareService service;
  late MockShare mockShare;

  setUp(() {
    mockShare = MockShare();
    service = ShareServiceImpl(shareWrapper: mockShare);
  });

  group('ShareService', () {
    test('should call Share.shareXFiles with the correct file', () async {
      // Arrange
      final file = XFile('/path/to/file.pdf');
      when(() => mockShare.shareXFiles([file])).thenAnswer((_) async {});

      // Act
      await service.shareFile(file);

      // Assert
      verify(() => mockShare.shareXFiles([file])).called(1);
    });
  });
}

abstract class ShareWrapper {
  Future<void> shareXFiles(List<XFile> files);
}
