import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';

/// Service for writing files to the file system
abstract class FileWriterService {
  /// Writes CSV content to a file in the downloads directory
  /// Returns the absolute path to the written file
  Future<Either<Failure, String>> writeCsv({
    required String filenamePrefix,
    required String contents,
  });

  /// Writes binary PDF content to a file in the downloads directory
  /// Returns the absolute path to the written file
  Future<Either<Failure, String>> writePdf({
    required String filenamePrefix,
    required List<int> bytes,
  });
}
