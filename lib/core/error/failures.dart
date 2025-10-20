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

/// Failure that occurs when a requested resource is not found
class NotFoundFailure extends Failure {
  /// Creates a [NotFoundFailure] with a required error message
  const NotFoundFailure({required String message}) : super(message);
}

/// Failure that occurs during model download operations
class ModelDownloadFailure extends Failure {
  /// Creates a [ModelDownloadFailure] with a required error message
  const ModelDownloadFailure({required String message}) : super(message);
}

/// Failure that occurs during NER model initialization or extraction
class NerFailure extends Failure {
  /// Creates a [NerFailure] with a required error message
  const NerFailure({required String message}) : super(message);
}

/// Failure that occurs during file system operations
class FileSystemFailure extends Failure {
  /// Creates a [FileSystemFailure] with a required error message
  const FileSystemFailure({required String message}) : super(message);
}

/// Failure that occurs when the app lacks permission to write to storage.
class PermissionFailure extends Failure {
  /// Creates a [PermissionFailure] with a required error message.
  const PermissionFailure({required String message}) : super(message);
}

/// Failure that occurs when device storage is full.
class StorageFailure extends Failure {
  /// Creates a [StorageFailure] with a required error message.
  const StorageFailure({required String message}) : super(message);
}

/// Failure that occurs during embedding operations (loading, matching, etc.)
class EmbeddingFailure extends Failure {
  /// Creates an [EmbeddingFailure] with a required error message
  const EmbeddingFailure({required String message}) : super(message);
}

/// Failure that occurs when LLM API key is missing or invalid
class ApiKeyMissingFailure extends Failure {
  /// The LLM provider that requires an API key
  final String provider;

  /// Creates an [ApiKeyMissingFailure] for a specific provider
  const ApiKeyMissingFailure(this.provider)
      : super('API key required for $provider');

  @override
  List<Object> get props => [message, provider];
}

/// Failure that occurs when API rate limit is exceeded
class RateLimitFailure extends Failure {
  /// When the request can be retried
  final DateTime retryAfter;

  /// Creates a [RateLimitFailure] with retry timestamp
  const RateLimitFailure(this.retryAfter)
      : super('Rate limit exceeded. Retry after $retryAfter');

  @override
  List<Object> get props => [message, retryAfter];
}

/// Failure that occurs when LLM response is invalid or malformed
class InvalidResponseFailure extends Failure {
  /// Creates an [InvalidResponseFailure] with a required error message
  const InvalidResponseFailure({required String message}) : super(message);
}

/// Failure that occurs during sharing operations
class ShareFailure extends Failure {
  /// Creates a [ShareFailure] with a required error message
  const ShareFailure({required String message}) : super(message);
}
