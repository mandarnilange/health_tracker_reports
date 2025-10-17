import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:health_tracker_reports/core/error/failures.dart';
import 'package:health_tracker_reports/domain/entities/extracted_entity.dart';
import 'package:injectable/injectable.dart';
import 'ner_model_helper.dart';

/// Abstract interface for NER-based metadata extraction.
///
/// This service uses a TFLite NER model to extract structured entities
/// from text, such as person names, dates, lab values, and biomarkers.
abstract class NerMetadataExtractor {
  /// Initializes the NER model from the given file path.
  ///
  /// Returns [Right] with void on success, or [Left] with [NerFailure] on error.
  Future<Either<Failure, void>> initialize(String modelPath);

  /// Extracts named entities from the given text.
  ///
  /// Returns [Right] with a list of [ExtractedEntity] on success,
  /// or [Left] with [NerFailure] on error.
  Future<Either<Failure, List<ExtractedEntity>>> extractEntities(String text);

  /// Disposes resources used by the NER model.
  void dispose();
}

/// Implementation of [NerMetadataExtractor] with pattern-based extraction.
///
/// This implementation supports offline NER extraction using regex patterns.
/// When TFLite compatibility is resolved, this can be upgraded to use the
/// TFLite model for improved accuracy.
///
/// NOTE: Currently uses pattern-based extraction due to tflite_flutter
/// compatibility issues with Dart 3.10+. Will be upgraded to TFLite
/// when a compatible version is available.
@LazySingleton(as: NerMetadataExtractor)
class NerMetadataExtractorImpl implements NerMetadataExtractor {
  bool _isInitialized = false;
  String? _modelPath;
  final NerModelHelper _modelHelper;

  NerMetadataExtractorImpl({NerModelHelper? modelHelper})
      : _modelHelper = modelHelper ?? NerModelHelper();

  @override
  Future<Either<Failure, void>> initialize(String modelPath) async {
    try {
      // Check if model file exists (for future TFLite integration)
      final file = File(modelPath);
      if (!await file.exists()) {
        return const Left(
          NerFailure(message: 'Failed to initialize: Model file not found'),
        );
      }

      // Store model path for future use
      _modelPath = modelPath;
      _isInitialized = true;

      // TODO: When tflite_flutter is compatible with Dart 3.10+:
      // _interpreter = await Interpreter.fromFile(file);

      return const Right(null);
    } catch (e) {
      _isInitialized = false;
      return Left(
        NerFailure(message: 'Failed to initialize NER model: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ExtractedEntity>>> extractEntities(
    String text,
  ) async {
    try {
      // Check if initialized
      if (!_isInitialized) {
        return const Left(
          NerFailure(message: 'NER model not initialized'),
        );
      }

      // Handle empty text
      if (text.trim().isEmpty) {
        return const Right([]);
      }

      // Use pattern-based extraction
      // TODO: When tflite_flutter is compatible, upgrade to model-based extraction
      final entities = _modelHelper.extractWithPatterns(text);
      return Right(entities);
    } catch (e) {
      return Left(
        NerFailure(message: 'Failed to extract entities: $e'),
      );
    }
  }

  @override
  void dispose() {
    // TODO: When using TFLite: _interpreter?.close();
    _isInitialized = false;
    _modelPath = null;
  }
}
