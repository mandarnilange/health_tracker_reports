# Extract Biomarker Pipeline – Design Notes

## Objective

Deliver a reliable, on-device extraction flow that accepts:
- Multi-page PDF lab reports imported from Files/Drive.
- One or more images captured by the camera or chosen from the gallery.

The pipeline must:
- Run entirely offline (privacy-first requirement).
- Use Google ML Kit text recognition for OCR accuracy.
- Convert OCR output into normalized biomarker entities and persist them locally via Hive.
- Provide responsive UX feedback (progress, errors, cancel support).

## Constraints & Considerations

| Constraint | Notes |
|------------|-------|
| Offline processing | No server calls; all OCR/LLM work must run locally. |
| Supported platforms | iOS, Android, Web (Web currently limited to manual input). |
| Performance | Multi-page PDFs should finish extraction in a few seconds on modern devices. |
| Memory usage | Avoid duplicating large page bitmaps in Dart; release native buffers quickly. |
| User experience | Progress indicator per page, graceful cancel, resilient to malformed files. |

## Problem Analysis

1. **PDF ingestion** – We must render each page to an image format that ML Kit accepts.
2. **Image ingestion** – Direct image inputs should be normalized (rotation, deskew).
3. **OCR** – ML Kit `TextRecognizer` is already integrated; we should feed it platform-native image buffers for best performance.
4. **Post-processing** – Combine OCR text, parse into structured biomarkers, normalize names, then store.

The main issue with the current implementation is the heavy use of `pdf_render` in Dart. It renders pages into PNG byte arrays on the Dart side, which causes:
- Large memory spikes due to copying buffers across platform channels.
- Slow rendering on multi-page PDFs, leading to the “Extracting biomarkers…” spinner hanging.
- Higher crash risk on older devices.

## Candidate Approaches

### 1. **Status Quo (Dart-first pipeline)**

Steps:
1. Use `pdf_render` in Dart to rasterize pages.
2. Convert `Uint8List` to ML Kit images using `InputImage.fromBytes`.
3. Run ML Kit via Riverpod provider.

Pros:
- Already implemented; minimal new work.
- Works uniformly across platforms.

Cons:
- Slow, memory heavy.
- Limited control over platform-specific optimizations (e.g., VisionKit deskewing, PdfRenderer caching).
- Hard to provide granular progress updates or cancel operations mid-way.

### 2. **Hybrid pipeline (Native rendering + existing ML Kit bindings)**

Steps:
1. Move PDF rendering to native code:
   - iOS: `PDFKit` / `CGPDFDocument` to render per-page `UIImage`.
   - Android: `PdfRenderer` (`android.graphics.pdf.PdfRenderer`) to render `Bitmap`s.
2. Use native OCR capabilities to produce both raw text and lightweight structured cues (tables, key/value hints) via ML Kit / Vision APIs.
3. Stream structured payloads back to Dart through a platform channel.
4. Maintain existing Dart logic for interpretation, normalization, and persistence (no domain logic in native layers).

Pros:
- Uses battle-tested native rendering. Faster and less memory churn.
- ML Kit runs on-device as before; no behavioral regression.
- Easier to expose progress (page count) and cancellation because native API calls are synchronous per page.
- Aligns with privacy requirements.

Cons:
- Requires new platform channel code (federated plugin or method channels).
- Need to ensure thread management (do not block UI thread).
- Must supply mocks/stubs for unit tests to preserve TDD approach.

### 3. **Full native extraction (Render + OCR native side)**

Steps:
1. Perform PDF rendering and ML Kit OCR entirely native-side.
2. Return structured biomarker data (JSON) to Dart.

Pros:
- Potentially fastest; minimal cross-platform data movement.
- Opportunity to reuse Objective-C/Swift/Java/Kotlin LLM fallback logic if later desired.

Cons:
- Harder to unit test without native test harnesses.
- Business logic duplicated per platform (normalization, parsing).
- Higher maintenance burden, violates Clean Architecture layering by pushing domain logic into platform code.

### 4. **Use Vision/Doc Scanner for photos**

Regardless of PDF approach, for image inputs we can leverage:
- iOS: `VisionKit` `DataScannerViewController` for enhanced document capture and OCR.
- Android: ML Kit Doc Scanner (when GA) or manual edge detection (OpenCV or `camera` plugin’s analyzer).

These can complement Approach 2.

## Recommended Solution: Hybrid Pipeline (Approach 2)

This balances performance, maintainability, and Clean Architecture adherence.

### High-Level Flow

```
User selects PDF/images
    ↓
Native Scanner Plugin
    - For PDFs: render each page (iOS PDFKit / Android PdfRenderer)
    - For images: optional enhancement (deskew)
    - For each page/image: run ML Kit OCR natively
    - Emit (pageIndex, structuredPayload) events via platform channel stream
    ↓
Dart Extraction Layer
    - Merge structured payloads, fall back to raw text as needed
    - Parse and normalize biomarkers (existing logic)
    - Normalize biomarker names
    - Persist via Hive
```

### Detailed Design

#### Implementation Snapshot (Current State – 2025-XX-XX)

- **Flutter → Native contract**
  - Method channel `report_scan/methods` with commands `startScan` and `cancelScan`.
  - Event channel `report_scan/events` broadcasting maps in the schema documented below.
  - `ReportScanServiceImpl` in Dart serialises requests, listens to the event stream, and maps payloads into strongly typed `ReportScanEvent`s. This layer includes unit coverage (`test/unit/data/datasources/external/report_scan_service_test.dart`).
- **Domain layer**
  - `ExtractReportFromFile` now depends only on `ReportScanService`. It aggregates structured events, normalises biomarker names, generates entity IDs/timestamps, and builds `Report` entities. Error/validation behaviour lives entirely in Dart (`lib/domain/usecases/extract_report_from_file.dart`, `test/unit/domain/usecases/extract_report_from_file_test.dart`).
- **Structured event schema**
  - `progress`: `{ "type": "progress", "page": int, "totalPages": int }`
  - `structured`: `{ "type": "structured", "page": int, "totalPages": int, "payload": { "rawText": String, "biomarkers": [ { "name": String, "value": String, "unit": String?, "referenceMin": String?, "referenceMax": String? } ] } }`
  - `text`: optional raw text fallback events.
  - `error`: `{ "type": "error", "code": String, "message": String }`
  - `complete`: signals completion of the stream.
- **Failure semantics**
  - Native `PlatformException`s surface as `OcrFailure` in Dart.
  - Missing biomarker data yields `ValidationFailure("No biomarkers detected")`.
  - Unexpected stream termination results in `CacheFailure("Scan ended unexpectedly")`.
- **Testing**
  - Dart layer fully covered; native components should be validated via manual QA/instrumentation to ensure the OCR output matches expectations.

#### 1. New Plugin: `native_report_scanner`

- Federated plugin with separate iOS (Swift) and Android (Kotlin) implementations.
- Method: `scanReport(uri, {type: pdf|image, pageLimit?, progressInterval?})`.
- Returns a `Stream` of `ScanEvent` objects:
  ```json
  {
    "type": "progress" | "structured" | "text" | "error" | "complete",
    "page": 3,
    "totalPages": 10,
    "payload": {
      "biomarkers": [
        {"name": "Hemoglobin", "value": "13.5", "unit": "g/dL"}
      ],
      "rawText": "Hemoglobin 13.5 g/dL ..."
    }
  }
  ```
- Handles cancel (`cancelScan(scanId)`).

#### 2. iOS Implementation Notes

- Entry point lives in `AppDelegate.swift`. We initialise method/event channels and delegate to `ReportScanStreamHandler`.
- **PDF handling**: `PDFDocument` is opened once; we iterate pages, emit `progress`, and collect text via `page.string`. If the PDF lacks an embedded text layer, the handler will fall back to rendering and re-running `VNRecognizeTextRequest` (TODO item).
- **Image handling**: `UIImage` instances are loaded for every provided URI. We call `VNRecognizeTextRequest` with `.accurate` recognition level on a background queue. Orientation is preserved via `CGImagePropertyOrientation` mapping.
- **Parsing**: naive heuristic splits each recognised line on whitespace, looking for `[name] [value] [unit] … [range]`. Reference ranges are captured when a `min – max` pattern exists. All biomarker strings are forwarded (normalisation remains in Dart).
- **Threading & cancellation**: work executes on a dedicated `DispatchQueue`. A `DispatchWorkItem` allows cancelling long-running scans when the Dart layer requests `cancel` or listeners detach.

#### 3. Android Implementation Notes

- Entry point lives in `MainActivity.kt`. An `EventChannel` provides the stream while `MethodChannel` receives commands.
- **PDF handling**: `PdfRenderer` renders each page at double resolution for better OCR. Each page is converted to a `Bitmap`, passed to ML Kit `TextRecognition` (Latin model). After OCR, the bitmap is recycled to keep memory low.
- **Image handling**: Provided file paths are decoded into bitmaps (respecting orientation via EXIF is a future enhancement). Each bitmap is OCR’d identically to PDF pages.
- **Scanning loop**: executed on `Dispatchers.IO` inside a coroutine `Job`. We emit `progress` before each page, `structured` after OCR. `Job.cancel()` handles cancellation; we check `ensureActive()` between steps to stop promptly.
- **Dependencies**: app module now depends on `com.google.mlkit:text-recognition` and `kotlinx-coroutines-android`.
- **Parsing**: mirrors the iOS regex heuristics to keep behaviour consistent across platforms.

#### 4. Dart Integration

- Replace `PdfService.convertToImages` with `ReportScanService` abstraction.
- `ExtractReportFromFile` orchestrates:
  1. `nativeReportScanner.scan(...)` to get structured payloads per page.
  2. Aggregate payloads, run existing normalization + parsing in Dart.
- Provide fake scanner implementation for unit tests (simulate multi-page output).

#### 5. Data Flow Summary

1. **User action**: selects a PDF or one/more images.
2. **Flutter**: `ExtractReportFromFile` builds a `ReportScanRequest` and calls `ReportScanService.scanReport`.
3. **Native**: platform handler opens files, OCRs each page/image, emits `progress` + `structured` events.
4. **Flutter**: service maps events to Dart classes; the use case aggregates biomarker payloads, normalises names, and builds a `Report` with generated IDs/timestamps.
5. **Persistence**: caller (Upload workflow) passes the `Report` to `SaveReport`, which stores it in Hive.
6. **Read**: UI reads reports via existing repository/use-case stack.

#### 6. UX Considerations

- Show progress bar (`page n / total`) while scanning.
- Allow cancel button to terminate the stream (`cancelScan`).
- If OCR yields empty text, present actionable error (“Unable to read document; please try again with clearer photo”).

Current implementation emits incremental progress per page; the Upload UI can now surface this data instead of a static spinner (future enhancement).

#### 7. Persistence

- Unchanged: once `Report` entity is constructed, call `SaveReport` use case to persist via Hive.
- Consider caching raw text by report ID for debugging or reprocessing.

### Testing Strategy

1. **Unit tests**
   - Fake scanner stream to cover multi-page progression, error handling, cancellations.
   - Ensure `ExtractReportFromFile` reconstructs text order correctly.
2. **Integration tests (platform-specific)**
   - Use instrumentation tests (iOS XCTest, Android Instrumentation) to render sample PDFs and assert OCR output contains expected tokens.
3. **Performance benchmarks**
   - Track wall-clock per page on representative devices (mid-tier Android, iPhone).
   - Alert if regression >20%.
4. **Fallbacks**
   - If plugin fails (e.g., older Android < API 21), fallback to existing Dart pipeline with warning.

## Next Steps

1. **Accuracy tuning**: improve the native regex heuristics (e.g., handle tabular layouts, colon-separated rows, units containing digits). Consider feeding raw text into a Dart parser for more complex documents.
2. **VisionKit / Doc Scanner**: integrate live document capture pipelines to pre-process images (deskew, contrast).
3. **Multipage images**: support selecting mixed PDFs/images in one request and maintain deterministic ordering.
4. **Instrumentation**: add platform UI tests or automated scripts that run the scanner against a corpus of sample reports to catch regressions.
5. **UI feedback**: surface per-page progress and cancellation in the Upload page; display warnings when no biomarkers are extracted.

With the native bridge in place, the pipeline now respects the privacy/offline requirements while dramatically reducing conversion overhead. All business logic remains in Dart, preserving Clean Architecture boundaries and testability.
