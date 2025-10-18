# Cloud LLM Extraction – Design Spec

Last reviewed: 2025-10-18

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
- **Claude**: Fully implemented with Claude 3.5 Sonnet model (`claude-3-5-sonnet-latest`)
- **OpenAI**: Fully implemented with GPT-4 Vision (`gpt-4-turbo`)
- **Gemini**: Fully implemented with Gemini 2.5 Flash (`gemini-2.5-flash`) - Oct 2025 upgrade from 1.5-pro-latest
- All providers tested with live API calls (integration tests TODO)

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
- **Secure Storage**: API keys persisted securely via `flutter_secure_storage`; Hive stores empty placeholders for backwards compatibility.
  - `SecureConfigStorage` handles read/write of sensitive API keys
  - ConfigRepository merges secure keys with Hive config on load
  - Prevents accidental exposure of keys in backups/logs

### Dynamic Biomarker Normalization (Oct 2025)
**Problem**: Hardcoded biomarker aliases required maintenance and couldn't adapt to user-specific naming conventions.

**Solution**: LLM-based dynamic normalization using historical data
- `ReportRepository.getDistinctBiomarkerNames()` fetches all unique biomarker names from user's reports
- `ExtractReportFromFileLlm` passes these names to LLM via `existingBiomarkerNames` parameter
- LLM prompts include normalization guidance with historical names
- LLM intelligently maps variations (e.g., "Hb" → "Hemoglobin", "WBC" → "White Blood Cell Count") based on context

**Benefits**:
- Zero maintenance - no hardcoded alias lists to update
- Learns from actual user data - adapts to lab-specific naming
- Context-aware matching - handles abbreviations, spaces, capitalization
- Ensures consistency for accurate trend analysis across reports

**Implementation**: All three provider services (Claude, OpenAI, Gemini) include normalization guidance in prompts when historical names are available.

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

## Recent Updates (Oct 2025)

### ✅ Completed
- **Dynamic Normalization**: Replaced hardcoded aliases with LLM-based normalization using historical data
- **Gemini 2.5 Flash**: Upgraded from 1.5-pro-latest to 2.5-flash for better speed and accuracy
- **Secure Storage**: Implemented API key encryption using flutter_secure_storage
- **Error Propagation**: Fixed silent error swallowing - now shows actual LLM failures (ApiKeyMissing, NetworkFailure, etc.)
- **Hive TypeAdapter**: Added LlmProvider enum adapter to fix API key serialization
- **UI Improvements**:
  - Compact review page with tap-to-edit (70% less scroll for 23 biomarkers)
  - Save button moved to AppBar
  - Enhanced biomarker cards with gradient backgrounds and tap-to-trends navigation
  - Fixed filter chip to show selected state without changing text
  - Improved text contrast and readability

### 🔧 Open Work
- Finish `ImageProcessingService._readImageBytes` for JPEG/PNG camera uploads
- Add comprehensive unit tests for OpenAI and Gemini services
- Consider adding resiliency features (retries with exponential backoff)
- Add regression test fixtures (multi-page PDF + image)
- Revisit prompt tuning based on real-world usage patterns

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
