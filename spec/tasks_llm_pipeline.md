# LLM Extraction Pipeline – Task Tracker

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Remove legacy ML Kit / Vision geometry parser code paths | ✅ | Native OCR bridge removed; only cloud LLM path remains. |
| 2 | Implement LLM inference service (prompt orchestration, parsing, retries) | ✅ | Claude/OpenAI/Gemini services implemented via Dio; retries/TODO for exponential backoff remain. |
| 3 | Add metadata enrichment (patient name, lab details, dates) from LLM output | ✅ | Metadata captured from first successful page and stored in report notes/lab fields. |
| 4 | Persist LLM extraction results through existing use case + Hive storage | ✅ | `ExtractReportFromFileLlm` returns `Report`; `SaveReport` persists to Hive. |
| 5 | Update settings to reflect LLM-only extraction mode | ✅ | Settings page manages provider + API keys; keys now persisted via `flutter_secure_storage`. |
| 6 | Implement image byte loading for local images | ⏳ | `ImageProcessingService._readImageBytes` still throws `UnimplementedError`. |
| 7 | Regression tests: sample reports (PDF/image) through LLM pipeline | ⚠️ | Widgets/unit tests exist; need provider test coverage for OpenAI/Gemini and end-to-end fixtures. |
