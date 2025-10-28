import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/file_writer_service.dart';

class _StubDownloadsPathProvider implements DownloadsPathProvider {
  _StubDownloadsPathProvider(this._path);

  final FutureOr<String> Function() _path;

  @override
  Future<String> getDownloadsPath() async => _path();
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('writeCsv writes to sanitized timestamped path', () async {
    String? writtenPath;
    String? writtenContents;
    final service = FileWriterServiceImpl.test(
      downloadsPathProvider:
          _StubDownloadsPathProvider(() async => '/tmp/downloads'),
      nowOverride: () => DateTime(2024, 1, 2, 3, 4, 5),
      stringWriter: (path, contents) async {
        writtenPath = path;
        writtenContents = contents;
      },
    );

    final result = await service.writeCsv(
      filenamePrefix: 'Doctor Report',
      contents: 'id,value',
    );

    expect(result.isRight(), isTrue);
    expect(
      (result as Right<Failure, String>).value,
      '/tmp/downloads/Doctor_Report_2024-01-02_03-04-05.csv',
    );
    expect(writtenPath, endsWith('.csv'));
    expect(writtenContents, 'id,value');
  });

  test('writeBytes maps permission denied errors to PermissionFailure',
      () async {
    final service = FileWriterServiceImpl.test(
      downloadsPathProvider:
          _StubDownloadsPathProvider(() async => '/tmp/downloads'),
      bytesWriter: (path, bytes) async {
        throw const FileSystemException(
          'Permission denied',
          '',
          OSError('Permission denied', 13),
        );
      },
    );

    final result = await service.writePdf(
      filenamePrefix: 'export',
      bytes: const [1, 2, 3],
      
    );

    expect(result.isLeft(), isTrue);
    expect((result as Left<Failure, String>).value, isA<PermissionFailure>());
  });

  test('writeBytes maps disk full to StorageFailure', () async {
    final service = FileWriterServiceImpl.test(
      downloadsPathProvider:
          _StubDownloadsPathProvider(() async => '/tmp/downloads'),
      bytesWriter: (path, bytes) async {
        throw const FileSystemException(
          'No space left on device',
          '',
          OSError('No space left on device', 28),
        );
      },
    );

    final result = await service.writePdf(
      filenamePrefix: 'export',
      bytes: const [1, 2, 3],
    );

    expect(result.isLeft(), isTrue);
    expect((result as Left<Failure, String>).value, isA<StorageFailure>());
  });


  test('writeBytes maps other file system errors to FileSystemFailure', () async {
    final service = FileWriterServiceImpl.test(
      downloadsPathProvider:
          _StubDownloadsPathProvider(() async => '/tmp/downloads'),
      bytesWriter: (path, bytes) async {
        throw const FileSystemException('Unexpected');
      },
    );

    final result = await service.writePdf(
      filenamePrefix: 'export',
      bytes: const [1, 2, 3],
    );

    expect(result.isLeft(), isTrue);
    final failure = (result as Left<Failure, String>).value;
    expect(failure, isA<FileSystemFailure>());
    expect(failure.message, contains('Unexpected'));
  });

  test('writeBytes writes bytes to sanitized path on success', () async {
    String? capturedPath;
    List<int>? capturedBytes;
    final service = FileWriterServiceImpl.test(
      downloadsPathProvider:
          _StubDownloadsPathProvider(() async => '/downloads'),
      nowOverride: () => DateTime(2025, 5, 6, 7, 8, 9),
      bytesWriter: (path, bytes) async {
        capturedPath = path;
        capturedBytes = bytes;
      },
    );

    final result = await service.writePdf(
      filenamePrefix: 'Doctor Summary!',
      bytes: const [9, 8, 7],
    );

    expect(result.isRight(), isTrue);
    expect(capturedPath, '/downloads/Doctor_Summary__2025-05-06_07-08-09.pdf');
    expect(capturedBytes, [9, 8, 7]);
  });

  test('returns FileSystemFailure when downloads path cannot be resolved',
      () async {
    final service = FileWriterServiceImpl.test(
      downloadsPathProvider: _StubDownloadsPathProvider(() {
        throw Exception('broken');
      }),
    );

    final result = await service.writeCsv(
      filenamePrefix: 'report',
      contents: 'data',
    );

    expect(result.isLeft(), isTrue);
    expect((result as Left<Failure, String>).value, isA<FileSystemFailure>());
  });

  test('writeCsv maps unexpected errors to FileSystemFailure', () async {
    final service = FileWriterServiceImpl.test(
      downloadsPathProvider:
          _StubDownloadsPathProvider(() async => '/downloads'),
      stringWriter: (path, contents) async {
        throw StateError('boom');
      },
    );

    final result = await service.writeCsv(
      filenamePrefix: 'report',
      contents: 'abc',
    );

    expect(result.isLeft(), isTrue);
    final failure = (result as Left<Failure, String>).value;
    expect(failure, isA<FileSystemFailure>());
    expect(failure.message, contains('Failed to save file'));
  });
}
