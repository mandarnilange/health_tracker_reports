import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

typedef DateTimeProvider = DateTime Function();
typedef FileWriterCallback = Future<void> Function(
  String path,
  String contents,
);

typedef BinaryWriterCallback = Future<void> Function(
  String path,
  List<int> bytes,
);

/// Provides the absolute downloads directory path for the current platform.
abstract class DownloadsPathProvider {
  /// Returns the absolute path to the preferred downloads directory.
  Future<String> getDownloadsPath();
}

/// Default implementation that relies on `path_provider`.
@LazySingleton(as: DownloadsPathProvider)
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
  })  : now = DateTime.now,
        _stringWriter = _defaultStringWriter,
        _bytesWriter = _defaultBytesWriter;

  @visibleForTesting
  FileWriterService.test({
    required this.downloadsPathProvider,
    DateTimeProvider? nowOverride,
    FileWriterCallback? stringWriter,
    BinaryWriterCallback? bytesWriter,
  })  : now = nowOverride ?? DateTime.now,
        _stringWriter = stringWriter ?? _defaultStringWriter,
        _bytesWriter = bytesWriter ?? _defaultBytesWriter;

  final DownloadsPathProvider downloadsPathProvider;
  final DateTimeProvider now;
  final FileWriterCallback _stringWriter;
  final BinaryWriterCallback _bytesWriter;

  static Future<void> _defaultStringWriter(String path, String contents) async {
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(contents);
  }

  static Future<void> _defaultBytesWriter(String path, List<int> bytes) async {
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  /// Writes the provided CSV contents to disk and returns the saved file path.
  Future<Either<Failure, String>> writeCsv({
    required String filenamePrefix,
    required String contents,
  }) async {
    return _writeString(
      filenamePrefix: filenamePrefix,
      extension: 'csv',
      contents: contents,
    );
  }

  Future<Either<Failure, String>> writeBytes({
    required String filenamePrefix,
    required List<int> bytes,
    String extension = 'bin',
  }) async {
    final downloadPath = await _resolveDownloadsPath();
    return downloadPath.fold(
      Left.new,
      (basePath) async {
        final fullPath = _buildFilePath(
          basePath,
          filenamePrefix: filenamePrefix,
          extension: extension,
        );

        try {
          await _bytesWriter(fullPath, bytes);
          return Right(fullPath);
        } on FileSystemException catch (e) {
          return Left(_mapFileSystemException(e));
        } catch (e) {
          return Left(
            FileSystemFailure(
              message: 'Failed to save file: ${e.toString()}',
            ),
          );
        }
      },
    );
  }

  Future<Either<Failure, String>> _writeString({
    required String filenamePrefix,
    required String extension,
    required String contents,
  }) async {
    final downloadPath = await _resolveDownloadsPath();
    return downloadPath.fold(
      Left.new,
      (basePath) async {
        final fullPath = _buildFilePath(
          basePath,
          filenamePrefix: filenamePrefix,
          extension: extension,
        );

        try {
          await _stringWriter(fullPath, contents);
          return Right(fullPath);
        } on FileSystemException catch (e) {
          return Left(_mapFileSystemException(e));
        } catch (e) {
          return Left(
            FileSystemFailure(
              message: 'Failed to save file: ${e.toString()}',
            ),
          );
        }
      },
    );
  }

  String _buildFilePath(
    String basePath, {
    required String filenamePrefix,
    required String extension,
  }) {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now());
    final sanitizedPrefix =
        filenamePrefix.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
    final sanitizedExtension =
        extension.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();
    final fileName = '$sanitizedPrefix\_$timestamp.$sanitizedExtension';
    return p.join(basePath, fileName);
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
