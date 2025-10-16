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
2. Convert native images directly to ML Kit compatible formats (both `google_mlkit_text_recognition` plugins already bridge to native recognizers).
3. Stream OCR text back to Dart through a platform channel.
4. Maintain existing Dart logic for normalization, parsing, persistence.

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
    - Emit (pageIndex, textChunk) events via platform channel stream
    ↓
Dart Extraction Layer
    - Concatenate text chunks
    - Parse structured biomarkers (existing logic)
    - Normalize biomarker names
    - Persist via Hive
```

### Detailed Design

#### 1. New Plugin: `native_report_scanner`

- Federated plugin with separate iOS (Swift) and Android (Kotlin) implementations.
- Method: `scanReport(uri, {type: pdf|image, pageLimit?, progressInterval?})`.
- Returns a `Stream` of `ScanEvent` objects:
  ```json
  {
    "type": "progress" | "text" | "error" | "complete",
    "page": 3,
    "totalPages": 10,
    "text": "Hemoglobin 13.5 g/dL ..."
  }
  ```
- Handles cancel (`cancelScan(scanId)`).

#### 2. iOS Implementation Notes

- Use `PDFDocument(url:)` to open the PDF.
- Render with `PDFPage` `draw(with:to:)` into `UIGraphicsImageRenderer`.
- Use `Vision` framework `VNRecognizeTextRequest` for OCR (same backend as ML Kit on iOS).
- Ensure work runs on a background `DispatchQueue`.
- For images captured/imported, optionally run `VNDetectDocumentSegmentationRequest`.

#### 3. Android Implementation Notes

- Use `ParcelFileDescriptor` + `PdfRenderer`.
- Render each page into `Bitmap` with chosen DPI (150–200 DPI is a good balance).
- Feed `InputImage.fromBitmap` to ML Kit.
- Manage `CoroutineScope` on `Dispatchers.Default`; emit events via `EventChannel`.
- For images, apply rotation correction using EXIF metadata.

#### 4. Dart Integration

- Replace `PdfService.convertToImages` with `ReportScanService` abstraction.
- `ExtractReportFromFile` orchestrates:
  1. `nativeReportScanner.scan(...)` to get text per page.
  2. Aggregate text, run existing normalization + parsing.
- Provide fake scanner implementation for unit tests (simulate multi-page output).

#### 5. UX Improvements

- Show progress bar (`page n / total`) while scanning.
- Allow cancel button to terminate the stream (`cancelScan`).
- If OCR yields empty text, present actionable error (“Unable to read document; please try again with clearer photo”).

#### 6. Persistence

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

1. Scaffold federated plugin with minimal API (progress stream, cancel).
2. Update dependency injection to provide `ReportScanService`.
3. Refactor `ExtractReportFromFile` to consume new abstraction; adjust tests.
4. Implement platform code incrementally (iOS first, then Android) with instrumentation tests.
5. Update Upload page UI to display per-page progress and cancel button.

This approach keeps the core domain logic in Dart, offers significant performance gains, and honors the clean architecture + TDD expectations of the project.
