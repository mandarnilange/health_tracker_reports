# Health Tracker Reports – Current Implementation Plan

Last reviewed: 2025-10-18

This document reflects the **implemented** architecture, dependencies, and open follow‑ups for the Health Tracker Reports application. Earlier drafts that referenced ML Kit pipelines, embedding matchers, or large local NER models have been archived.

---

## Product Vision

A privacy-first Flutter app that lets people capture or upload their lab reports, extract biomarker values with high accuracy using cloud LLMs, log daily vital signs, view unified health timeline, track trends across both lab results and vitals, and prepare shareable summaries.

---

## Core Requirements (Delivered vs Pending)

- **Implemented**
  - Upload PDF/image reports and run a cloud LLM extraction pass.
  - Persist reports locally in Hive.
  - View, filter, and sort saved reports.
  - Track biomarker trends across reports.
  - Manage LLM provider selection and API keys in Settings.
  - Riverpod-based state management, GetIt/Injectable DI.
  - Unit + widget test coverage for critical flows.

- **Planned / Not Implemented**
  - **Phase 5**: Doctor PDF generation, CSV export (3 files). _In Progress - Google Drive backup/import deferred._
  - **Phase 4 Hardening**: Image file loading in `ImageProcessingService._readImageBytes`.
  - **Phase 4 Hardening**: Provider parity tests (OpenAI/Gemini services).
  - Local notifications, reminders, onboarding refinements.

---

## Technology Stack

```
Flutter 3.5.x / Dart 3.5.x

State & DI
- flutter_riverpod: ^2.6.1
- get_it: ^8.0.2
- injectable: ^2.5.0

Persistence
- hive: ^2.2.3
- hive_flutter: ^1.1.0

Routing
- go_router: ^16.2.4

File handling & media
- file_picker: ^8.1.6
- pdfx: ^2.7.0
- image: ^4.3.0

HTTP / Security
- dio: ^5.4.0
- flutter_secure_storage: ^9.2.2 (declared, not yet wired)

Charts & Export
- fl_chart: ^1.1.1
- pdf: ^3.11.1
- printing: ^5.14.1
- share_plus: ^12.0.0

Other utilities
- intl, equatable, dartz, uuid, path, path_provider

Testing
- flutter_test, mocktail, build_runner, hive_generator, injectable_generator
```

---

## Clean Architecture Snapshot

```
lib/
├── main.dart / app.dart
├── core/
│   ├── di/                      // get_it + injectable wiring
│   ├── error/                   // Failures & Exceptions
│   └── constants/model_config.dart (legacy ML config, unused)
├── domain/
│   ├── entities/                // Report, Biomarker, HealthLog, VitalMeasurement, AppConfig, LlmExtraction, Trend*
│   ├── repositories/            // ReportRepository, HealthLogRepository, TimelineRepository, ConfigRepository, LlmExtractionRepository
│   └── usecases/                // ExtractReportFromFileLlm, CreateHealthLog, GetUnifiedTimeline, SaveReport, etc.
├── data/
│   ├── models/                  // Hive adapters for entities
│   ├── datasources/
│   │   ├── local/               // Hive database + data sources
│   │   └── external/            // LLM provider services, image processing
│   └── repositories/            // *RepositoryImpl classes
└── presentation/
    ├── providers/               // Riverpod notifiers/providers
    ├── pages/                   // Upload, Review, Trends, Settings, etc.
    ├── widgets/                 // Biomarker card, trend indicator
    ├── router/                  // GoRouter routes
    └── theme/                   // App themes & colors
```

> **Note**: `core/constants/model_config.dart` and other ML-kit related artifacts remain for historical reasons but are not referenced by the runtime code. See Risks/TODOs.

---

## Extraction Pipeline (Implemented)

1. **Image preparation**
   - PDFs rendered page-by-page to PNG via `pdfx`.
   - Non-PDF images intended to be read by `ImageProcessingService.imageToBase64` (current stub).
   - Optional compression keeps payloads <5 MB.

2. **LLM inference**
   - `LlmExtractionRepositoryImpl` selects the configured provider (Claude, OpenAI, Gemini).
   - Each provider service (Dio-based) receives a base64 image + normalization hints.
   - Prompt instructs the model to return canonical biomarker JSON with metadata.

3. **Report synthesis**
   - `ExtractReportFromFileLlm` converts LLM results into domain `Report`/`Biomarker` entities.
   - Normalization relies on provider output plus any existing names fetched from Hive.

4. **Persistence**
   - `SaveReport` assigns IDs with `uuid` and persists via `ReportRepositoryImpl` (Hive).
   - Config updates flow through `ConfigRepositoryImpl`.

5. **Presentation**
   - Upload and Review pages use Riverpod `ExtractionNotifier` + `ReportsNotifier`.
   - Trends page consumes `GetBiomarkerTrend`, `CalculateTrend`, `CompareBiomarkerAcrossReports`.

---

## Key Modules

- **Domain**
  - Entities: `Report`, `Biomarker`, `HealthLog`, `VitalMeasurement`, `ReferenceRange`, `TrendDataPoint`, `AppConfig`, `LlmExtractionResult`.
  - Repositories: `ReportRepository`, `HealthLogRepository`, `TimelineRepository`, `ConfigRepository`, `LlmExtractionRepository`.
  - Use cases: `ExtractReportFromFileLlm`, `CreateHealthLog`, `GetUnifiedTimeline`, `GetVitalTrend`,
    `SaveReport`, `GetAllReports`, `DeleteReport`, `GetBiomarkerTrend`, `CalculateTrend`,
    `CompareBiomarkerAcrossReports`, `NormalizeBiomarkerName`, `SearchBiomarkers`, `UpdateConfig`.

- **Data**
  - Local: `HiveDatabase`, `ReportLocalDataSource`, `HealthLogLocalDataSource`, `ConfigLocalDataSource`.
  - External: `ImageProcessingService`, `Claude/OpenAi/GeminiLlmService`.
  - Repositories: `ReportRepositoryImpl`, `HealthLogRepositoryImpl`, `TimelineRepositoryImpl`,
    `ConfigRepositoryImpl`, `LlmExtractionRepositoryImpl`.

- **Presentation**
  - Providers: `reports_provider.dart`, `health_log_provider.dart`, `timeline_provider.dart`,
    `extraction_provider.dart`, `config_provider.dart`, `trend_provider.dart`, `vital_trend_provider.dart`.
  - Pages: Upload, Review, Trends, Settings (API key management), Report detail, Health log entry (bottom sheet),
    Health log detail, Reminders (stub), Export (placeholder), Onboarding (basic).
  - Widgets: `HealthTimeline`, `HealthLogCard`, `BiomarkerCard`, `VitalInputField`, `VitalTrendChart`.

---

## Testing Overview

- Unit tests cover:
  - Domain entities and trend calculations.
  - Report/config repositories with Hive boxes (mocked).
  - LLM provider service parsing (Claude).
  - Providers and notifiers.

- Widget tests cover:
  - Upload, Review, Trends, Report detail, Router, core widgets.

The pipeline currently lacks integration tests for OpenAI/Gemini parsing and real image IO.

---

## Known Gaps / TODO

| Area | Status | Notes |
|------|--------|-------|
| Image file loading | ❌ | `_readImageBytes` is unimplemented; local image uploads fail. |
| API key security | ✅ | API keys persisted via `flutter_secure_storage`; Hive now stores sanitized placeholders only. |
| Provider parity tests | ⚠️ | Only Claude service has unit tests; OpenAI/Gemini missing. |
| Normalization strategy | ⚠️ | LLM prompts accept hints, but `NormalizeBiomarkerName` is still used in trend use cases. Decide whether to keep or remove. |
| Legacy constants | ⚠️ | `core/constants/model_config.dart` references deprecated ML models. |
| Export/Doctor PDF | ⏳ | In Progress - Phase 5 (Doctor PDF + 3 CSV files). Drive backup/import deferred. |
| Notifications/Reminders | ⚠️ | Pages exist but functionality incomplete. |

---

## Risks & Mitigations

- **API Keys in Hive**  
  Keys are currently persisted in plain Hive boxes. Mitigation: implement secure storage (platform keychain/keystore) and document migration.

- **Unimplemented Image IO**  
  Image uploads from camera/gallery will throw at runtime. Mitigation: finish `_readImageBytes` and cover with widget/integration tests.

- **LLM Error Handling Coverage**  
  Only limited provider tests exist. Mitigation: add tests for OpenAI/Gemini parsing, error branches, and cancellation.

- **Legacy Files**  
  Old ML artifacts can mislead future updates. Mitigation: clean up unused constants or tag them clearly as deprecated.

---

## Phase Checklist (High-Level)

| Phase | Focus | Status | Notes |
|-------|-------|--------|-------|
| Phase 1 – Upload & Extraction | LLM-based upload flow, Hive persistence, settings | ✅ Core flows implemented |
| Phase 2 – Viewing & Trends | Reports list, trends, search/filter | ✅ Implemented with Riverpod and charts |
| Phase 3 – Enhancements | Reminders, onboarding | ⏳ Partially done (reminders stubbed) |
| Phase 4 – LLM Extraction | Dynamic normalization, UI polish, secure storage | ✅ Complete (hardening tasks pending) |
| Phase 6 – Daily Health Tracking | Vitals logging, unified timeline, vital trends | ✅ Complete (2025-10-19) |
| **Phase 5 – Export & Sharing** | **Doctor PDF (2-4 pages), CSV export (3 files)** | ⏳ **In Progress (2026-01-15)** |

**Phase 4 Hardening (Pending)**:
- Image file loading (`_readImageBytes`)
- Provider coverage tests (OpenAI/Gemini)
- Regression fixtures (multi-page PDF + image tests)

**Phase 6 – Daily Health Tracking (Completed 2025-10-19)**:
- Domain: `HealthLog`, `VitalMeasurement` entities; `HealthLogRepository`, `TimelineRepository` interfaces; 9 use cases
- Data: Hive models (typeId 11, 12); `HealthLogLocalDataSource`; repository implementations
- Presentation: Riverpod providers; unified timeline with filter chips; health log entry bottom sheet; detail page with edit/delete; vital trend charts with dual-line BP support
- Test coverage: 90%+ for Phase 6 code
- All acceptance criteria met
- See `spec/phase-6-daily-health-tracking.md` for full implementation details

**Phase 5 – Export & Sharing (In Progress - Started 2026-01-15)**:
- **Scope (Revised):** Doctor Summary PDF (2-4 pages) + CSV Export (3 denormalized files)
- **Deferred:** Google Drive backup/restore, CSV import functionality
- Domain: `DoctorSummaryConfig`, `SummaryStatistics` entities; PDF & CSV export use cases
- Data: `PdfGeneratorService`, `CsvExportService`, `ChartRenderingService`, `FileWriterService`, `ShareService`
- Presentation: `ExportPage`, `DoctorPdfConfigPage`; `ExportProvider` for state management
- PDF Features: Executive summary, biomarker trends with charts, vitals summary, optional full data table
- CSV Features: 3 separate files (reports_biomarkers, health_logs_vitals, trends_statistics)
- See `spec/phase-5-export-sharing-tasks.md` for complete task breakdown

---

## Working Agreements

- Maintain TDD cadence: write/extend tests before altering production logic.
- Update `/spec` alongside feature changes; flag TODOs explicitly.
- Keep changelog entries truthful to the repository history (instructions per user request).
- Use conventional commits and update coverage metrics regularly (`flutter test --coverage`).

---

## Appendix – Reference Paths

- Extraction core: `lib/domain/usecases/extract_report_from_file_llm.dart`
- LLM services: `lib/data/datasources/external/*.dart`
- Persistence: `lib/data/repositories/*`, `lib/data/datasources/local/*`
- Settings page: `lib/presentation/pages/settings/settings_page.dart`
- Trend analytics: `lib/domain/usecases/get_biomarker_trend.dart`, `lib/presentation/providers/trend_provider.dart`
- Tests: `test/unit/...`, `test/widget/...`

For historical context on the ML Kit pipeline, see prior versions of this document in Git history.
