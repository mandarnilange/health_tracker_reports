import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/share_service.dart';

class MockShareWrapper extends Mock implements ShareWrapper {}

void main() {
  late ShareService service;
  late MockShareWrapper mockShareWrapper;

  setUp(() {
    mockShareWrapper = MockShareWrapper();
    service = ShareServiceImpl(shareWrapper: mockShareWrapper);
  });

  group('ShareService', () {
    test('should call Share.shareXFiles with the correct file', () async {
      // Arrange
      final file = XFile('/path/to/file.pdf');
      when(() => mockShareWrapper.shareXFiles([file])).thenAnswer((_) async {});

      // Act
      await service.shareFile(file);

      // Assert
      verify(() => mockShareWrapper.shareXFiles([file])).called(1);
    });

    test('should return ShareFailure when sharing fails', () async {
      // Arrange
      final file = XFile('/path/to/file.pdf');
      when(() => mockShareWrapper.shareXFiles([file])).thenThrow(Exception('Share failed'));

      // Act
      final result = await service.shareFile(file);

      // Assert
            expect(result, isA<Left<Failure, void>>());
            result.fold(
              (failure) => expect(failure, isA<ShareFailure>()),
              (_) => fail('should not succeed'),
            );
          });
      
          test('should return Right(null) when share is cancelled', () async {
            // Arrange
            final file = XFile('/path/to/file.pdf');
            when(() => mockShareWrapper.shareXFiles([file])).thenAnswer((_) async => ShareResult('', ShareResultStatus.dismissed));
      
            // Act
            final result = await service.shareFile(file);
      
            // Assert
            expect(result, const Right(null));
          });
        });
      }
      