# Biomarker Extraction Design Notes

Last reviewed: 2025-10-21  
Applies to the cloud-first extraction pipeline that is currently in production.

---

## Objectives

- Support PDF and image uploads on iOS, Android, and Web.
- Achieve high-quality biomarker extraction via remote LLMs (Claude, OpenAI, Gemini).
- Normalize biomarker names using historical context to power trends and comparisons.
- Keep all persisted data (reports, config) local in Hive.
- Provide responsive feedback and recoverable errors in the upload flow.

---

## User Flow

1. **Upload** (`presentation/pages/upload/upload_page.dart`)
   - User selects PDF or image using `file_picker`.
   - UI triggers `ExtractionNotifier.extractFromFile`.

2. **Extraction**
   - `ExtractReportFromFileLlm` converts the file into base64 images via `ImageProcessingService`.
   - Each page/image is sent to `LlmExtractionRepository`, which delegates to the selected provider.
   - Responses are parsed into `Report` + `Biomarker` entities.

3. **Review** (`presentation/pages/upload/review_page.dart`)
   - Display extracted biomarkers, metadata hints (patient name, report date, lab name).
   - Allow the user to accept/save (persist via `SaveReport`) or discard.

4. **Reports & Trends**
   - `ReportsNotifier` refreshes the Hive-backed list.
   - Trend providers consume `GetBiomarkerTrend`, `CalculateTrend`, `CompareBiomarkerAcrossReports`.

---

## Detailed Pipeline

### 1. Image Preparation

- **PDFs**: `ImageProcessingService.pdfToBase64Images` renders via `pdfx`, doubling resolution for clarity.
- **Images**: `imageToBase64` is intended to read bytes; currently unimplemented (TODO).  
  When implemented it should:
  ```dart
  Future<Uint8List> _readImageBytes(String path) async {
    final file = File(path);
    return await file.readAsBytes();
  }
  ```
  with platform-aware paths (use `path_provider` on mobile).

- **Compression**: `compressImageBase64` ensures payloads stay within provider limits (~5 MB).

### 2. LLM Invocation

- `LlmExtractionRepositoryImpl` resolves active provider + API key from `ConfigRepository`.
- Provider services share a consistent prompt structure:
  - List historical biomarker names (`reportRepository.getDistinctBiomarkerNames`) to encourage canonical naming.
  - Request JSON with `confidence`, `metadata`, and `biomarkers`.
  - Enforce ISO date format and numeric strings.
- Dio handles HTTP calls; errors mapped to Failures:
  - 401 → `NetworkFailure('Invalid API key')`
  - 429 → `RateLimitFailure`
  - Timeouts → `NetworkFailure('Request timeout')`

### 3. Report Assembly

- `ExtractReportFromFileLlm` iterates page responses:
  - Retains metadata from the first successful page.
  - Parses numeric values (`_parseDouble`) and reference ranges (`_parseReferenceRange`).
  - Creates `Biomarker` entities with UUIDs, defaulting to measured date = report date.
- Generates a `Report` with empty ID and default lab name when absent.
- Returns `ValidationFailure` if no biomarkers extracted and no provider failure recorded.

### 4. Persistence & Config

- `SaveReport` assigns IDs and persists to Hive.
- `AppConfig` holds provider choice and API keys (Hive box `config`).  
  **Security gap**: keys are not yet moved to `flutter_secure_storage`.

---

## UI Responsibilities

| Screen | Responsibilities | Status |
|--------|------------------|--------|
| Upload | File picker, progress state, error handling | ✅ |
| Review | Show biomarkers, allow saving or retry | ✅ |
| Settings | Provider selection, API key entry, privacy notice | ✅ (keys stored in Hive) |
| Trends | Visualize biomarker values over time | ✅ |
| Export / Reminders | Stubs only | ⚠️ |

Feedback patterns:
- Loading indicator during extraction.
- Snackbar on successful settings save.
- Error state surfaces underlying `Failure.message`.

---

## Normalization Strategy

- Historical biomarker names retrieved from Hive are injected into prompts.
- The prompt instructs providers to reuse existing canonical names when synonyms appear.
- `NormalizeBiomarkerName` use case is still utilised by downstream trend features; removal would require updating trend/search logic.  
  Decision: **keep for now**, but mark in backlog to reassess once LLM normalization proves sufficient.

---

## Error Scenarios & UX Responses

| Scenario | Failure | UI Behaviour |
|----------|---------|--------------|
| No API key provided | `ApiKeyMissingFailure` | Settings prompt indicating missing key |
| Provider timeout | `NetworkFailure('Request timeout')` | Upload page shows retry CTA |
| Provider returns malformed JSON | `InvalidResponseFailure` | Upload page displays extraction failure |
| No biomarkers detected | `ValidationFailure('No biomarkers detected…')` | Review page not shown; user notified |
| Multiple page errors | Last failure propagated | Continue to next page (`lastFailure` memo) |

---

## Open TODOs

- Implement image byte loading for camera/gallery workflows.
- ✅ Persist API keys with `flutter_secure_storage` (Hive now holds sanitized placeholders).
- Add retries/exponential backoff for transient HTTP failures.
- Expand automated tests:
  - Provider service parsing (OpenAI, Gemini).
  - Multi-page extraction integration test with fixtures.
  - Settings form validation widget tests.
- Clean up unused legacy constants (`core/constants/model_config.dart`) or mark as deprecated.

---

## Metrics & Monitoring (Manual for now)

- Track extraction confidence scores stored in `LlmExtractionResult.confidence`.
- Log or display the provider used per extraction for troubleshooting.
- Document API usage expectations for users (cost guidance in settings help text).

---

## Reference Implementation Files

- `lib/domain/usecases/extract_report_from_file_llm.dart`
- `lib/data/repositories/llm_extraction_repository_impl.dart`
- `lib/data/datasources/external/{claude_llm_service,openai_llm_service,gemini_llm_service}.dart`
- `lib/data/datasources/external/image_processing_service.dart`
- `lib/presentation/providers/extraction_provider.dart`
- `lib/presentation/pages/upload/{upload_page,review_page}.dart`
- `lib/presentation/pages/settings/settings_page.dart`

Use this document as the authoritative extraction design. Update it whenever code changes affect the flow above.
