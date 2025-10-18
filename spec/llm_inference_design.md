# Cloud LLM Extraction – Design Spec

Last reviewed: 2025-10-21

This spec captures the **production** extraction pipeline that relies on hosted LLM vision APIs. It supersedes earlier drafts describing ML Kit, embedding matchers, or on-device NER models.

---

## Goals

- Deliver ≥95 % extraction accuracy across PDF and image-based blood reports.
- Keep all persistence local (Hive) while allowing the user to supply their own LLM API keys.
- Provide a consistent JSON contract from all providers so downstream code stays provider-agnostic.
- Surface meaningful failure states (missing API key, rate limits, invalid responses).

---

## High-Level Flow

```
Upload Page ──► ImageProcessingService ──► LlmExtractionRepository
                                    │                 │
                                    ▼                 ▼
                               base64 images   Claude/OpenAI/Gemini
                                    │                 │
                                    └─────► ExtractReportFromFileLlm
                                                  │
                                                  ▼
                                            Report entity
                                                  │
                                                  ▼
                                           SaveReport (Hive)
```

---

## Components

### ImageProcessingService (`lib/data/datasources/external/image_processing_service.dart`)
- **pdfToBase64Images**: renders each page using `pdfx` at 2× resolution, returns PNG bytes encoded as base64.
- **imageToBase64**: intended to read image bytes; currently `UnimplementedError` (TODO).
- **compressImageBase64**: resizes and re-encodes images >5 MB using the `image` package.

### LlmExtractionRepository (`lib/domain/repositories/llm_extraction_repository.dart`)
- Abstract contract returning `Either<Failure, LlmExtractionResult>`.
- Concrete implementation (`lib/data/repositories/llm_extraction_repository_impl.dart`) injects:
  - `ClaudeLlmService`
  - `OpenAiLlmService`
  - `GeminiLlmService`
  - `ConfigRepository` (for provider + API keys)
- Responsibilities:
  - Resolve the active provider (explicit parameter or saved config).
  - Validate API key presence (`ApiKeyMissingFailure` if absent).
  - Delegate to provider services and map Dio errors to Failures.
  - Forward historical biomarker names to prompts for normalization hints.
  - Cancel in-flight requests when needed.

### Provider Services (`lib/data/datasources/external/*.dart`)
Common responsibilities:
- Accept base64 image, API key, optional `existingBiomarkerNames`.
- Construct provider-specific prompts emphasizing:
  - JSON-only response with `confidence`, `metadata`, and `biomarkers`.
  - Normalization instructions referencing historical biomarker names.
  - Field-level confidence scores.
- Parse responses into `LlmExtractionResult` (entities in `lib/domain/entities/llm_extraction.dart`).
- Handle provider-specific errors (timeouts, invalid JSON) by throwing exceptions consumed by the repository.

Implementation status:
- Claude: fully implemented and unit-tested (`test/unit/data/datasources/external/claude_llm_service_test.dart`).
- OpenAI & Gemini: implemented but lack dedicated tests (TODO).

### ExtractReportFromFileLlm (`lib/domain/usecases/extract_report_from_file_llm.dart`)
- Fetches distinct biomarker names from `ReportRepository` to guide normalization.
- Converts uploaded file to base64 images (PDF multi-page supported).
- Iterates pages:
  - Compresses images if necessary.
  - Calls `LlmExtractionRepository.extractFromImage`.
  - Aggregates biomarker results, applies numeric parsing, reference range parsing.
- Captures metadata (patient name, report date, lab name) from the first successful page.
- Produces a `Report` with placeholder `id` (assigned later by `SaveReport`).
- Returns `ValidationFailure` when no biomarkers detected; propagates LLM failures if available.

### SaveReport (`lib/domain/usecases/save_report.dart`)
- Assigns UUID when `Report.id` empty.
- Persists via `ReportRepository` → `ReportLocalDataSource` (Hive).

### Settings / Config
- `AppConfig` stores `Map<LlmProvider, String>` and the active provider.
- `ConfigRepositoryImpl` persists `AppConfigModel` in Hive (box `config`).
- Settings page (`lib/presentation/pages/settings/settings_page.dart`) allows key entry, provider selection, and shows a privacy notice.
- API keys persisted securely via `flutter_secure_storage`; Hive stores sanitized placeholders for backwards compatibility.

---

## Failures & Error Handling

| Failure | Trigger | Handling |
|---------|---------|----------|
| `ApiKeyMissingFailure` | Provider selected without key | UI prompts user to add key |
| `RateLimitFailure` | HTTP 429 | Suggest retry after `retryAfter` |
| `NetworkFailure` | Timeouts, unreachable hosts, 401 | Display error with retry CTA |
| `InvalidResponseFailure` | JSON parse mismatch | Logged for debugging; user sees extraction failure |
| `ValidationFailure` | No biomarkers detected | UI shows friendly “nothing extracted” message |

All failures use the shared `Failure` classes in `lib/core/error/failures.dart`.

---

## Prompt Contract (Simplified)

```json
{
  "confidence": 0.93,
  "metadata": {
    "patientName": "Jane Doe",
    "reportDate": "2025-01-05",
    "collectionDate": "2025-01-04",
    "labName": "Quest Diagnostics",
    "labReference": "REF-123"
  },
  "biomarkers": [
    {
      "name": "Hemoglobin",
      "value": "13.2",
      "unit": "g/dL",
      "referenceRange": "12.0-16.0",
      "confidence": 0.98
    }
  ]
}
```

Provider services strip markdown fences before parsing to guard against model hallucinations.

---

## Open Work

- Finish `ImageProcessingService._readImageBytes` using `File(path).readAsBytes` with cross-platform handling (path_provider).
- Add unit tests for `OpenAiLlmService` and `GeminiLlmService` mirroring the Claude coverage.
- Consider adding resiliency features (retries with exponential backoff).
- Evaluate whether to retire `NormalizeBiomarkerName` or keep for trend queries only.
- Revisit prompt tuning once real-world reports highlight gaps.

---

## Testing Strategy

| Layer | Current Coverage | Next Steps |
|-------|------------------|-----------|
| Provider services | Claude tests only | Add golden responses & failure cases for OpenAI/Gemini |
| Use case | Covered via provider/unit tests | Add integration test with stubbed repository simulating multi-page PDFs |
| Presentation | Upload/Review widgets tested | Add Settings form validation widget tests |

---

## Deployment Checklist

1. Ensure at least one provider API key configured in Settings before extraction.
2. Confirm `flutter test` and `flutter analyze` pass.
3. Run manual regression on representative PDF & image samples.
4. Monitor request costs (user responsibility, as keys are user-supplied).

---

For historical details about the deprecated ML Kit pipeline, consult prior versions of this file in Git history. The current spec is the canonical reference for all extraction work going forward.
