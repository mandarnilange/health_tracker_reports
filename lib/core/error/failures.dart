import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
///
/// Failures represent errors that occur at the domain/use case level
/// and are returned via `Either<Failure, T>` to enable functional error handling.
abstract class Failure extends Equatable {
  /// Error message describing what went wrong
  final String message;

  /// Creates a [Failure] with an optional error message
  const Failure([this.message = 'An unexpected error occurred']);

  @override
  List<Object> get props => [message];
}

/// Failure that occurs when there's an issue with local storage (Hive)
class CacheFailure extends Failure {
  /// Creates a [CacheFailure] with an optional custom message
  const CacheFailure([super.message = 'Failed to access local storage']);
}

/// Failure that occurs during OCR text extraction
class OcrFailure extends Failure {
  /// Creates an [OcrFailure] with a required error message
  const OcrFailure({required String message}) : super(message);
}

/// Failure that occurs during LLM API calls or extraction
class LlmFailure extends Failure {
  /// Creates an [LlmFailure] with a required error message
  const LlmFailure({required String message}) : super(message);
}

/// Failure that occurs during data validation
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure] with a required error message
  const ValidationFailure({required String message}) : super(message);
}

/// Failure that occurs when file picking/selection fails
class FilePickerFailure extends Failure {
  /// Creates a [FilePickerFailure] with an optional custom message
  const FilePickerFailure([super.message = 'Failed to select file']);
}

/// Failure that occurs during PDF processing
class PdfProcessingFailure extends Failure {
  /// Creates a [PdfProcessingFailure] with a required error message
  const PdfProcessingFailure({required String message}) : super(message);
}

/// Failure that occurs during network operations (LLM API, Drive sync, etc.)
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure] with an optional custom message
  const NetworkFailure([super.message = 'Network connection failed']);
}
