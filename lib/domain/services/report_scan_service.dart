/// Types of supported scan inputs.
enum ScanSource { pdf, images }

/// Request describing a scan invocation.
class ReportScanRequest {
  const ReportScanRequest({
    required this.source,
    required this.uri,
    this.imageUris = const [],
    this.pageLimit,
  });

  final ScanSource source;
  final String uri;
  final List<String> imageUris;
  final int? pageLimit;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'source': source.name,
        'uri': uri,
        'imageUris': imageUris,
        if (pageLimit != null) 'pageLimit': pageLimit,
      };
}

/// Structured biomarker information emitted from OCR passes.
class StructuredBiomarker {
  const StructuredBiomarker({
    required this.name,
    this.value,
    this.unit,
    this.referenceMin,
    this.referenceMax,
  });

  final String name;
  final String? value;
  final String? unit;
  final String? referenceMin;
  final String? referenceMax;
}

/// Bounding box coordinates for recognized text (normalized 0-1).
class BoundingBox {
  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;
}

/// A line of recognized text with its position.
class RecognizedLine {
  const RecognizedLine({
    required this.text,
    required this.boundingBox,
  });

  final String text;
  final BoundingBox boundingBox;
}

/// Payload emitted with structured scan results.
class ReportScanPayload {
  const ReportScanPayload({
    this.rawText = '',
    this.biomarkers = const <StructuredBiomarker>[],
    this.lines = const <RecognizedLine>[],
    this.metadata,
  });

  final String rawText;
  final List<StructuredBiomarker> biomarkers;
  final List<RecognizedLine> lines;
  final Map<String, dynamic>? metadata;
}

/// Base class for events emitted during scanning.
abstract class ReportScanEvent {
  const ReportScanEvent();
}

/// Progress event indicating current page being processed.
class ReportScanEventProgress extends ReportScanEvent {
  const ReportScanEventProgress({
    required this.page,
    this.totalPages,
  });

  final int page;
  final int? totalPages;
}

/// Event containing structured biomarker data.
class ReportScanEventStructured extends ReportScanEvent {
  const ReportScanEventStructured({
    required this.page,
    this.totalPages,
    required this.payload,
  });

  final int page;
  final int? totalPages;
  final ReportScanPayload payload;
}

/// Event containing raw text extracted from a page.
class ReportScanEventText extends ReportScanEvent {
  const ReportScanEventText({
    required this.page,
    this.totalPages,
    required this.text,
  });

  final int page;
  final int? totalPages;
  final String text;
}

/// Event indicating an error occurred during scanning.
class ReportScanEventError extends ReportScanEvent {
  const ReportScanEventError({
    required this.code,
    this.message,
  });

  final String code;
  final String? message;
}

/// Event indicating scan completion.
class ReportScanEventComplete extends ReportScanEvent {
  const ReportScanEventComplete();
}

/// Domain service for scanning reports and extracting data.
///
/// This is a domain abstraction - implementations should be in the data layer.
abstract class ReportScanService {
  /// Scans a report file and emits events as data is extracted.
  ///
  /// The stream will emit various event types:
  /// - [ReportScanEventProgress]: Progress updates
  /// - [ReportScanEventStructured]: Structured biomarker data
  /// - [ReportScanEventText]: Raw text extraction
  /// - [ReportScanEventError]: Error occurred
  /// - [ReportScanEventComplete]: Scan finished successfully
  Stream<ReportScanEvent> scanReport(ReportScanRequest request);
}
