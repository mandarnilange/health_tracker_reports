import 'package:equatable/equatable.dart';

/// Abstract class representing a failure in the application.
///
/// All failures extend this class and are used in the `Either<Failure, T>`
/// pattern for error handling across repository boundaries.
abstract class Failure extends Equatable {
  /// Optional message describing the failure
  final String message;

  /// Creates a [Failure] with an optional [message]
  const Failure([this.message = 'An unexpected error occurred']);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

/// Failure that occurs when local cache operations fail.
///
/// This includes Hive database read/write errors, data corruption,
/// or any local storage issues.
class CacheFailure extends Failure {
  /// Creates a [CacheFailure] with an optional [message]
  const CacheFailure([super.message = 'Failed to access local storage']);
}

/// Failure that occurs during OCR (Optical Character Recognition) operations.
///
/// This includes ML Kit text recognition errors, image processing failures,
/// or when no text can be extracted from an image.
class OcrFailure extends Failure {
  /// Creates an [OcrFailure] with a required [message]
  const OcrFailure({required String message}) : super(message);
}

/// Failure that occurs during LLM (Large Language Model) operations.
///
/// This includes API communication errors, invalid responses,
/// JSON parsing failures, or rate limiting issues.
class LlmFailure extends Failure {
  /// Creates an [LlmFailure] with a required [message]
  const LlmFailure({required String message}) : super(message);
}

/// Failure that occurs during data validation.
///
/// This includes invalid biomarker values, malformed report data,
/// or any business logic validation errors.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure] with a required [message]
  const ValidationFailure({required String message}) : super(message);
}

/// Failure that occurs during file picking operations.
///
/// This includes user cancellation, permission denials,
/// or unsupported file formats.
class FilePickerFailure extends Failure {
  /// Creates a [FilePickerFailure] with an optional [message]
  const FilePickerFailure([super.message = 'Failed to pick file']);
}
