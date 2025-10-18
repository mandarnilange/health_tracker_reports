import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'llm_extraction.g.dart';

/// Supported LLM providers for biomarker extraction
@HiveType(typeId: 10)
enum LlmProvider {
  /// Anthropic Claude 3.5 Sonnet
  @HiveField(0)
  claude,

  /// OpenAI GPT-4 Vision
  @HiveField(1)
  openai,

  /// Google Gemini Pro Vision
  @HiveField(2)
  gemini,
}

/// Biomarker extracted from LLM API response
class ExtractedBiomarker extends Equatable {
  final String name;
  final String value;
  final String? unit;
  final String? referenceRange;
  final double? confidence;

  const ExtractedBiomarker({
    required this.name,
    required this.value,
    this.unit,
    this.referenceRange,
    this.confidence,
  });

  @override
  List<Object?> get props => [name, value, unit, referenceRange, confidence];

  @override
  String toString() =>
      'ExtractedBiomarker(name: $name, value: $value, unit: $unit, range: $referenceRange, confidence: $confidence)';
}

/// Metadata extracted from lab report
class ExtractedMetadata extends Equatable {
  final String? patientName;
  final DateTime? reportDate;
  final DateTime? collectionDate;
  final String? labName;
  final String? labReference;

  const ExtractedMetadata({
    this.patientName,
    this.reportDate,
    this.collectionDate,
    this.labName,
    this.labReference,
  });

  @override
  List<Object?> get props =>
      [patientName, reportDate, collectionDate, labName, labReference];

  @override
  String toString() =>
      'ExtractedMetadata(patient: $patientName, reportDate: $reportDate, lab: $labName)';
}

/// Result from LLM extraction
class LlmExtractionResult extends Equatable {
  final List<ExtractedBiomarker> biomarkers;
  final ExtractedMetadata? metadata;
  final double confidence;
  final String? rawResponse;
  final LlmProvider provider;

  const LlmExtractionResult({
    required this.biomarkers,
    this.metadata,
    required this.confidence,
    this.rawResponse,
    required this.provider,
  });

  @override
  List<Object?> get props =>
      [biomarkers, metadata, confidence, rawResponse, provider];

  @override
  String toString() =>
      'LlmExtractionResult(provider: $provider, biomarkers: ${biomarkers.length}, confidence: $confidence)';
}
