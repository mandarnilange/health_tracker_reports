# Phase 4: LLM-Based Extraction – Task List

**Phase Goal:** Transition report extraction to the new LLM pipeline, deliver accuracy gains over the retired ML Kit flow, and prepare for upcoming semantic/NER enhancements.

**Status:** ✅ Complete (Core functionality)

**Start Date:** 2025-10-20

**Completion Date:** 2025-10-18

---

## Phase 1 – Baseline Migration (Day 1)

_Objective: replace legacy Vision/ML Kit parsing with pure LLM inference._

- [x] **TASK:** Remove geometry parser & native ML Kit dependencies from upload flow  
_Notes:_ LLM pipeline now the sole extraction path; native code only handles file I/O.
- [x] **TASK:** Implement `LlmExtractionService` (prompt orchestration, retries, schema validation)  
_Notes:_ Service returns biomarkers + metadata JSON for Claude/OpenAI/Gemini.
- [x] **TASK:** Integrate LLM payloads into `ExtractReportFromFile` and Hive persistence  
_Notes:_ Legacy OCR parser removed; `ExtractReportFromFileLlm` returns a `Report` consumed by `SaveReport`.
- [x] **TASK:** Regression pass on curated PDFs/images  
_Notes:_ Basic widget/unit tests pass; provider-specific tests and real image fixtures still pending.

---

## Phase 2 – Hardening (Days 2‑4)

Objective: close remaining gaps before declaring migration complete.

- [ ] **TASK:** Implement image byte loading for local JPEG/PNG files
  _Notes:_ Stubbed `_readImageBytes` currently throws; affects camera/gallery uploads.
- [x] **TASK:** Secure API key storage using `flutter_secure_storage`
  _Notes:_ ✅ Complete - Keys persisted via secure storage; Hive retains sanitized placeholders for backwards compatibility.
- [ ] **TASK:** Expand provider coverage tests
  _Notes:_ Add OpenAI/Gemini parsing tests + error branches; integrate golden fixtures.
- [ ] **TASK:** Add regression fixtures (multi-page PDF + image)
  _Notes:_ Automate extraction smoke tests to guard against prompt/format changes.

---

## Phase 3 – October 2025 Enhancements

_Objective: Polish UX, fix bugs, and optimize for production._

- [x] **TASK:** Implement dynamic biomarker normalization
  _Notes:_ ✅ Complete - LLM uses historical biomarker names for intelligent normalization
- [x] **TASK:** Upgrade Gemini to 2.5 Flash model
  _Notes:_ ✅ Complete - Changed from `gemini-1.5-pro-latest` to `gemini-2.5-flash`
- [x] **TASK:** Add Hive TypeAdapter for LlmProvider enum
  _Notes:_ ✅ Complete - Fixed API key serialization issue
- [x] **TASK:** Improve error handling and propagation
  _Notes:_ ✅ Complete - Errors now show actual failures instead of generic "no biomarkers" message
- [x] **TASK:** Redesign review page for compact UX
  _Notes:_ ✅ Complete - Tap-to-edit cards, save button in AppBar, 70% less scrolling
- [x] **TASK:** Enhance biomarker card UI
  _Notes:_ ✅ Complete - Gradient backgrounds, better contrast, tap-to-trends navigation
- [x] **TASK:** Fix filter chip behavior
  _Notes:_ ✅ Complete - Shows "Out of Range Only" with selected state instead of changing text
