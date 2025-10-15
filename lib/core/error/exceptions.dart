/// Exception thrown when cache operations fail.
///
/// This exception is thrown in the data layer when Hive operations fail,
/// and is caught by repositories to convert to [CacheFailure].
class CacheException implements Exception {
  /// Message describing the cache error
  final String message;

  /// Creates a [CacheException] with an optional [message]
  const CacheException([this.message = 'Cache operation failed']);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when OCR operations fail.
///
/// This exception is thrown when ML Kit text recognition fails,
/// image processing encounters errors, or no text can be extracted.
class OcrException implements Exception {
  /// Message describing the OCR error
  final String message;

  /// Creates an [OcrException] with a required [message]
  const OcrException(this.message);

  @override
  String toString() => 'OcrException: $message';
}

/// Exception thrown when LLM operations fail.
///
/// This exception is thrown when API calls fail, responses are invalid,
/// JSON parsing fails, or rate limits are exceeded.
class LlmException implements Exception {
  /// Message describing the LLM error
  final String message;

  /// Creates an [LlmException] with a required [message]
  const LlmException(this.message);

  @override
  String toString() => 'LlmException: $message';
}

/// Exception thrown when validation fails.
///
/// This exception is thrown when data validation fails in the data layer,
/// such as invalid biomarker values or malformed report data.
class ValidationException implements Exception {
  /// Message describing the validation error
  final String message;

  /// Creates a [ValidationException] with a required [message]
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when file picking operations fail.
///
/// This exception is thrown when file selection fails, is cancelled,
/// or encounters permission issues.
class FilePickerException implements Exception {
  /// Message describing the file picker error
  final String message;

  /// Creates a [FilePickerException] with an optional [message]
  const FilePickerException([this.message = 'File picker operation failed']);

  @override
  String toString() => 'FilePickerException: $message';
}
