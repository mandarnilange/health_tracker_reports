import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/data/datasources/external/file_writer_service.dart';

class _StubDownloadsPathProvider implements DownloadsPathProvider {
  _StubDownloadsPathProvider(this.directoryPath);

  final String directoryPath;

  @override
  Future<String> getDownloadsPath() async => directoryPath;
}

class _ThrowingDownloadsPathProvider implements DownloadsPathProvider {
  _ThrowingDownloadsPathProvider(this.error);

  final Exception error;

  @override
  Future<String> getDownloadsPath() => Future.error(error);
}

void main() {
  late Directory tempDir;
  late DateTime fixedNow;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('file_writer_test_');
    fixedNow = DateTime(2026, 1, 15, 7, 45, 30);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FileWriterService', () {
    test('writes CSV file to downloads directory and returns path', () async {
      final service = FileWriterService.test(
        downloadsPathProvider: _StubDownloadsPathProvider(tempDir.path),
        nowOverride: () => fixedNow,
        fileWriter: (path, contents) async {
          final file = File(path);
          await file.create(recursive: true);
          await file.writeAsString(contents);
        },
      );

      const contents = 'sample csv contents';
      final result = await service.writeCsv(
        filenamePrefix: 'reports_biomarkers',
        contents: contents,
      );

      expect(result, isA<Right>());

      result.fold(
        (l) => fail('expected success'),
        (path) async {
          final file = File(path);
          expect(await file.exists(), isTrue);
          expect(await file.readAsString(), contents);
          expect(
            path,
            endsWith('reports_biomarkers_2026-01-15_07-45-30.csv'),
          );
        },
      );
    });

    test('returns PermissionFailure when writer throws permission error',
        () async {
      final service = FileWriterService.test(
        downloadsPathProvider: _StubDownloadsPathProvider(tempDir.path),
        nowOverride: () => fixedNow,
        fileWriter: (path, _) async {
          throw FileSystemException('Permission denied', path);
        },
      );

      final result = await service.writeCsv(
        filenamePrefix: 'reports_biomarkers',
        contents: 'data',
      );

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<PermissionFailure>()),
        (_) => fail('expected failure'),
      );
    });

    test('returns StorageFailure when writer throws storage full error',
        () async {
      final service = FileWriterService.test(
        downloadsPathProvider: _StubDownloadsPathProvider(tempDir.path),
        nowOverride: () => fixedNow,
        fileWriter: (path, _) async {
          throw FileSystemException('No space left on device', path);
        },
      );

      final result = await service.writeCsv(
        filenamePrefix: 'trends_statistics',
        contents: 'data',
      );

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<StorageFailure>()),
        (_) => fail('expected failure'),
      );
    });

    test('returns FileSystemFailure when downloads path cannot be resolved',
        () async {
      final service = FileWriterService.test(
        downloadsPathProvider: _ThrowingDownloadsPathProvider(
          Exception('unavailable'),
        ),
        nowOverride: () => fixedNow,
      );

      final result = await service.writeCsv(
        filenamePrefix: 'reports_biomarkers',
        contents: 'data',
      );

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<FileSystemFailure>()),
        (_) => fail('expected failure'),
      );
    });
  });
}
