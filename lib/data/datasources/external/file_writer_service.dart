import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef _DateTimeProvider = DateTime Function();
typedef FileWriterCallback = Future<void> Function(
  String path,
  String contents,
);

/// Provides the absolute downloads directory path for the current platform.
abstract class DownloadsPathProvider {
  /// Returns the absolute path to the preferred downloads directory.
  Future<String> getDownloadsPath();
}

/// Default implementation that relies on `path_provider`.
@lazySingleton
class PathProviderDownloadsPath implements DownloadsPathProvider {
  const PathProviderDownloadsPath();

  @override
  Future<String> getDownloadsPath() async {
    if (kIsWeb) {
      // Web should trigger browser download flows; fall back to temp dir
      final tempDir = await getTemporaryDirectory();
      return tempDir.path;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }

    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      return downloadsDir.path;
    }

    final documentsDir = await getApplicationDocumentsDirectory();
    return documentsDir.path;
  }
}

/// Service responsible for writing CSV payloads to disk with friendly names.
@lazySingleton
class FileWriterService {
  FileWriterService({
    required this.downloadsPathProvider,
    _DateTimeProvider? now,
    FileWriterCallback? fileWriter,
  })  : now = now ?? DateTime.now,
        _fileWriter = fileWriter ?? _defaultFileWriter;

  final DownloadsPathProvider downloadsPathProvider;
  final _DateTimeProvider now;
  final FileWriterCallback _fileWriter;

  static Future<void> _defaultFileWriter(String path, String contents) async {
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(contents);
  }

  /// Writes the provided CSV contents to disk and returns the saved file path.
  Future<Either<Failure, String>> writeCsv({
    required String filenamePrefix,
    required String contents,
  }) async {
    final downloadPath = await _resolveDownloadsPath();
    return downloadPath.fold(
      Left.new,
      (basePath) async {
        final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now());
        final sanitizedPrefix =
            filenamePrefix.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
        final fileName = '$sanitizedPrefix\_$timestamp.csv';
        final fullPath = p.join(basePath, fileName);

        try {
          await _fileWriter(fullPath, contents);
          return Right(fullPath);
        } on FileSystemException catch (e) {
          return Left(_mapFileSystemException(e));
        } catch (e) {
          return Left(
            FileSystemFailure(
              message: 'Failed to save CSV: ${e.toString()}',
            ),
          );
        }
      },
    );
  }

  Future<Either<Failure, String>> _resolveDownloadsPath() async {
    try {
      final path = await downloadsPathProvider.getDownloadsPath();
      return Right(path);
    } catch (e) {
      return Left(
        FileSystemFailure(
          message: 'Unable to determine downloads folder: ${e.toString()}',
        ),
      );
    }
  }

  Failure _mapFileSystemException(FileSystemException exception) {
    final message = exception.message.toLowerCase();
    final osMessage = exception.osError?.message.toLowerCase() ?? '';
    final combined = '$message $osMessage';

    if (combined.contains('permission denied') || combined.contains('access')) {
      return const PermissionFailure(
        message:
            'Storage permission denied. Please allow access to save the export.',
      );
    }

    if (combined.contains('no space') ||
        combined.contains('disk full') ||
        combined.contains('space left') ||
        exception.osError?.errorCode == 28) {
      return const StorageFailure(
        message:
            'Not enough storage space to save the export. Free up space and try again.',
      );
    }

    return FileSystemFailure(
      message: 'File system error: ${exception.message}',
    );
  }
}
