/// Base class for all exceptions in the application.
///
/// Exceptions are thrown at the data layer (data sources, external services)
/// and are caught in repository implementations to be converted to Failures.
abstract class AppException implements Exception {
  /// Error message describing what went wrong
  final String message;

  /// Creates an [AppException] with an error message
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when there's an issue with local storage (Hive)
class CacheException extends AppException {
  /// Creates a [CacheException] with an optional custom message
  const CacheException([super.message = 'Cache operation failed']);
}

/// Exception thrown during OCR text extraction
class OcrException extends AppException {
  /// Creates an [OcrException] with a required error message
  const OcrException(super.message);
}

/// Exception thrown during LLM API calls or extraction
class LlmException extends AppException {
  /// Creates an [LlmException] with a required error message
  const LlmException(super.message);
}

/// Exception thrown during data validation
class ValidationException extends AppException {
  /// Creates a [ValidationException] with a required error message
  const ValidationException(super.message);
}

/// Exception thrown when file picking/selection fails
class FilePickerException extends AppException {
  /// Creates a [FilePickerException] with an optional custom message
  const FilePickerException(
      [super.message = 'File selection cancelled or failed']);
}

/// Exception thrown during PDF processing
class PdfProcessingException extends AppException {
  /// Creates a [PdfProcessingException] with a required error message
  const PdfProcessingException(super.message);
}

/// Exception thrown during network operations (LLM API, Drive sync, etc.)
class NetworkException extends AppException {
  /// Creates a [NetworkException] with an optional custom message
  const NetworkException([super.message = 'Network request failed']);
}

/// Exception thrown when a server returns an error response
class ServerException extends AppException {
  /// HTTP status code
  final int? statusCode;

  /// Creates a [ServerException] with a message and optional status code
  const ServerException(super.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'ServerException ($statusCode): $message'
      : 'ServerException: $message';
}
