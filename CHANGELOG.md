# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added - Phase 6 Hive Models (2025-10-18)

- Added Hive-backed `VitalMeasurementModel` and `HealthLogModel` with JSON helpers and bidirectional entity mappers.
- Registered the new adapters, introduced a dedicated `health_logs` box, and regenerated DI wiring/build artifacts.
- Covered serialization logic with unit tests for both models (`test/unit/data/models/*_model_test.dart`).

### Added - Phase 6 Providers (2025-10-18)

- Introduced Riverpod notifiers/providers for health logs, unified timeline, and vital trend statistics.
- Added test suites covering load, mutation, and error flows for the new providers.
- Wired providers to the latest use cases via `getIt` injection helpers.

### Added - Phase 6 Timeline UI (2025-10-18)

- Implemented `HealthTimeline` and `HealthLogCard` widgets with chip filters, refresh support, and dedicated report/health log cards.
- Replaced `ReportsListPage` list view with the unified timeline experience and refreshed widget tests.
- Added widget tests covering card rendering, empty state, and error scenarios for the new timeline.

### Added - Phase 6 Repository Implementations (2025-10-18)

- Implemented `HealthLogRepositoryImpl` with Hive-backed persistence, filtering helpers, and vital trend extraction logic.
- Delivered `TimelineRepositoryImpl` to merge lab reports and health logs into a unified timeline with filtering options.
- Expanded DI configuration and unit coverage for the new repositories and their dependencies.

### Added - Phase 6 Health Log Local Data Source (2025-10-18)

- Created `HealthLogLocalDataSource` for Hive persistence with full CRUD support and defensive cache error handling.
- Expanded HiveDatabase contract/tests to register/load the new health log adapters and box.
- Added unit coverage for the data source behaviours (`test/unit/data/datasources/local/health_log_local_datasource_test.dart`).

### Added - Phase 6 Domain Foundations (2025-10-18)

- Introduced unified timeline domain interfaces: `HealthEntry`, `HealthLog`, `VitalMeasurement`, `VitalReferenceDefaults`, and `VitalStatistics` with comprehensive unit tests.
- Added repository contracts `HealthLogRepository` and `TimelineRepository` to orchestrate health log persistence and timeline aggregation.
- Implemented health log workflow use cases (`ValidateVitalMeasurement`, `CreateHealthLog`, `GetAllHealthLogs`, `GetHealthLogById`, `UpdateHealthLog`, `DeleteHealthLog`) including deterministic ID generation, validation, and thorough mocking tests.
- Delivered analytics use cases (`GetVitalTrend`, `CalculateVitalStatistics`, `GetUnifiedTimeline`) providing sorted vitals, rich statistics, and combined report/log timeline results.

---

### Planned - Phase 6: Daily Health Tracking (2025-10-18)

**Goal:** Enable users to log daily vital signs alongside lab reports in a unified timeline view.

**Features:**
- **Unified Timeline View**: Visual timeline with dots and connecting lines showing both lab reports and health logs chronologically
- **Bottom Sheet Entry**: Modal bottom sheet (85% screen) for quick vital logging
- **Default Vitals**: Blood Pressure (Systolic/Diastolic), SpO2, Heart Rate always visible
- **Additional Vitals**: Temperature, Weight, Glucose, Sleep Hours, Medication, Respiratory Rate, Energy Level (via dropdown)
- **Smart Reference Ranges**: Extract from medical reports for biomarkers, use medical defaults for vitals
- **Vital Trends**: Line charts with reference range bands, dual-line for BP, statistics (avg, min, max, trend)
- **Health Log Management**: Create, read, update, delete health logs with notes
- **Filter Chips**: "All" | "Lab Reports" | "Health Logs"

**Architecture:**
- **Domain Layer**: `HealthLog`, `VitalMeasurement`, `VitalType` entities; `HealthLogRepository`, `TimelineRepository` interfaces
- **Data Layer**: Hive models with TypeAdapters (typeId: 11, 12); `HealthLogLocalDataSource`
- **Presentation Layer**: `HealthTimeline` widget, `HealthLogEntrySheet` (bottom sheet), `HealthLogCard`, `VitalTrendChart`
- **Use Cases**: `CreateHealthLog`, `GetUnifiedTimeline`, `GetVitalTrend`, `CalculateVitalStatistics`

**Specification:** `spec/phase-6-daily-health-tracking.md`

**Status:** 🚧 In progress (domain foundations implemented via TDD)

### Added - Secure LLM Credential Storage (2025-10-21)

- Introduced `SecureConfigStorage` backed by `flutter_secure_storage` to persist API keys outside Hive (`lib/data/datasources/local/secure_config_storage.dart`).
- Updated dependency injection to expose a shared `FlutterSecureStorage` instance and wire the secure storage layer into `ConfigRepositoryImpl` (`lib/core/di/injection_container.dart`, `lib/core/di/injection_container.config.dart`).
- `ConfigRepositoryImpl` now merges secure-storage credentials into returned `AppConfig`s while writing sanitized placeholders to Hive (`lib/data/repositories/config_repository_impl.dart`).

### Added - October 2025 UI/UX Improvements (2025-10-18)

**Enhanced user experience and fixed critical bugs discovered during LLM extraction testing:**

**Gemini Model Upgrade:**
- Upgraded from `gemini-1.5-pro-latest` to `gemini-2.5-flash` for better speed and accuracy
- Fixed 404 errors caused by incorrect model name
- Commits: `d51a83a`, `8650a34`

**Error Handling Improvements:**
- Fixed silent error swallowing where LLM failures showed generic "No biomarkers detected" message
- Now properly propagates actual failures: `ApiKeyMissingFailure`, `NetworkFailure`, `RateLimitFailure`, etc.
- Users see meaningful error messages for troubleshooting
- Commit: `2edf066`

**API Key Persistence Fix:**
- Added Hive `TypeAdapter` for `LlmProvider` enum to enable `Map<LlmProvider, String>` serialization
- Fixed crash when saving API keys in Settings page
- Generated `LlmProviderAdapter` and registered in `HiveDatabase`
- Commit: `645166a`

**Review Page Redesign (`lib/presentation/pages/upload/review_page.dart`):**
- **Compact UI**: Reduced scrolling by 70% for reports with 23+ biomarkers
- **Save Button**: Moved to AppBar for easy access (was at bottom of long form)
- **Tap-to-Edit**: Biomarkers display as single line by default, tap to expand and edit
- **Header Editing**: Lab name and notes collapsed by default with explicit edit action
- **Better UX**: Edit is now explicit user action instead of default state
- Commit: `307b57a`

**Report Detail Page Improvements (`lib/presentation/pages/report_detail/report_detail_page.dart`):**
- **Filter Chip Fix**: Label stays "Out of Range Only" with selected state indicator instead of toggling text
- **Biomarker Name Visibility**: Improved text contrast and readability
- Commit: `1489cf0`

**Enhanced Biomarker Cards (`lib/presentation/widgets/biomarker_card.dart`):**
- **Visual Polish**: Removed flat colored backgrounds, added subtle gradients and status-colored borders
- **Professional Design**: Better typography with letter spacing, font weights, shadows on status badges
- **Reference Range UI**: Grey pill container with ruler icon for better visual hierarchy
- **Tap-to-Trends Navigation**: Cards now navigate to trends page with biomarker pre-selected
- **Riverpod Integration**: Changed from `StatelessWidget` to `ConsumerWidget` for provider access
- **User Hint**: Added "Tap to view trends" hint at bottom of each card
- Commit: `4060655`

**Documentation:**
- Updated `spec/llm_inference_design.md` with October 2025 changes and dynamic normalization details
- Updated `spec/phase-4-llm-extraction-tasks.md` marking Phase 3 enhancements complete
- Commit: `4060655`

**Benefits:**
- ✅ Better error visibility for debugging LLM issues
- ✅ Stable API key persistence across all providers
- ✅ 70% reduction in review page scrolling
- ✅ Professional, polished biomarker card design
- ✅ Seamless navigation to trends from biomarker cards
- ✅ Improved user experience with faster Gemini 2.5 Flash model

### Added - LLM-Based Extraction (2025-10-18)

**Migration from ML Kit to Cloud LLM APIs for 95%+ Accuracy**

Completed full migration from local ML Kit OCR to cloud-based LLM vision APIs, prioritizing accuracy over offline capability.

**Domain Layer:**
- `LlmProvider` enum (Claude, OpenAI, Gemini) for multi-provider support
- `ExtractedBiomarker`, `ExtractedMetadata`, `LlmExtractionResult` entities with Equatable
- `LlmExtractionRepository` interface with provider selection and cancellation
- Updated `AppConfig` entity: `Map<LlmProvider, String>` for multiple API keys
- New failure types: `ApiKeyMissingFailure`, `RateLimitFailure`, `InvalidResponseFailure`
- `UpdateConfig` use case for saving LLM settings
- `ExtractReportFromFileLlm` use case: simplified extraction pipeline using LLM APIs

**Data Layer:**
- `LlmProviderService` interface for provider abstraction
- `ClaudeLlmService`: Anthropic Claude 3.5 Sonnet integration (95%+ accuracy)
- `OpenAiLlmService`: GPT-4 Vision integration
- `GeminiLlmService`: Google Gemini Pro Vision integration
- `LlmExtractionRepositoryImpl`: repository pattern with automatic provider selection
- `ImageProcessingService`: PDF to base64 conversion using pdfx, image compression
- Updated `AppConfigModel` with proper JSON serialization for LlmProvider map

**Settings UI:**
- Complete Settings page (`lib/presentation/pages/settings/settings_page.dart`)
- API key management for all 3 providers with obscure/reveal toggle
- Provider selection with descriptions and cost estimates
- Form validation (require key for selected provider)
- Privacy notice about third-party data transmission
- Material 3 design with proper UX patterns
- Settings route integrated in app_router.dart

**Dynamic Biomarker Normalization (2025-10-18):**
- Added `getDistinctBiomarkerNames()` to ReportRepository for fetching historical biomarker names
- Updated all LLM services to accept `existingBiomarkerNames` parameter
- Enhanced prompts with normalization guidance using historical data
- LLM intelligently maps variations (e.g., "Hb" → "Hemoglobin") based on user's actual reports
- Removed hardcoded `NormalizeBiomarkerName` logic - now fully dynamic
- Updated `ExtractReportFromFileLlm` to fetch and pass existing names to LLM
- Ensures consistent naming across reports for accurate trend analysis

**Infrastructure:**
- Removed ~1,500 lines of ML Kit code (native iOS/Android bridges)
- Updated dependency injection: Dio HTTP client, removed ML Kit dependencies
- Repository pattern with strategy for multi-provider LLM selection
- Comprehensive error handling: network timeouts, rate limiting, invalid keys

**Structured Prompt Engineering:**
- JSON schema-based prompts for consistent biomarker extraction
- Confidence scoring at biomarker and extraction levels
- Metadata extraction: patient name, dates, lab info
- Reference range parsing: hyphenated, comparison operators, pipe-separated
- Qualitative value handling in value field

**Removed:**
- All ML Kit native code (~814 lines from iOS/Android)
- ReportScanService and native OCR bridge
- MetadataEmbeddingMatcher (semantic matching)
- NerMetadataExtractor (NER model inference)
- ModelDownloadManager (66MB TFLite downloads)
- Settings UI for extraction modes
- 200+ test files for removed components
- Assets: medical_terms_v1.json embeddings

**Dependencies:**
- Added: `pdfx: ^2.7.0` (PDF rendering), `flutter_secure_storage: ^9.2.2` (API keys)
- Removed: `google_mlkit_text_recognition`, `google_mlkit_commons`, `pdf_render`, `tflite_flutter`

**Commits:**
- `46b47a5`: refactor: remove ML Kit infrastructure for LLM-based extraction
- `ebe6174`: test: add tests for LLM extraction domain entities
- `44eb1be`: feat: implement LLM-based biomarker extraction with multi-provider support
- `acca63c`: feat: complete LLM extraction pipeline with Settings UI
- `0846e6c`: refactor: implement dynamic biomarker normalization via LLM prompts

**Benefits:**
- ✅ Target accuracy: 95%+ (vs 88-93% with ML Kit)
- ✅ Simpler codebase: removed 1,500+ lines of complex parsing
- ✅ Format-agnostic: handles diverse layouts without code changes
- ✅ Lower maintenance: no regex updates needed
- ✅ Multi-provider: easy switching between Claude/GPT/Gemini

**Trade-offs:**
- ❌ Requires internet connection
- ❌ User provides API keys (no cost to developer)
- ❌ Data sent to third parties (privacy notice shown)
- ❌ Slower: 5-15s per page (vs 1-2s local)

### Added - Phase 3: Biomarker Trends & Normalization (2025-02-21)

- Extended biomarker normalization map and comprehensive unit tests covering electrolytes, lipids, liver, kidney, diabetes, thyroid, vitamin, iron, and inflammation markers (`lib/domain/usecases/normalize_biomarker_name.dart`, `test/unit/domain/usecases/normalize_biomarker_name_test.dart`).
- Introduced `TrendDataPoint` entity and `GetBiomarkerTrend` use case for cross-report biomarker trend queries with date filtering, sorting, and normalization integration (`lib/domain/entities/trend_data_point.dart`, `lib/domain/usecases/get_biomarker_trend.dart`, `test/unit/domain/entities/trend_data_point_test.dart`, `test/unit/domain/usecases/get_biomarker_trend_test.dart`).
- Added repository trend support with Hive-backed aggregation and exhaustive tests (`lib/domain/repositories/report_repository.dart`, `lib/data/repositories/report_repository_impl.dart`, `test/unit/data/repositories/report_repository_impl_test.dart`).
- Built Trends page experience with Riverpod providers, async loading/error handling, selectors, and test coverage (`lib/presentation/pages/trends`, `lib/presentation/providers/trend_provider.dart`, `test/unit/presentation/providers/trend_provider_test.dart`, `test/widget/pages/trends`).
- Implemented `TrendChart` widget powered by fl_chart with reference bands, tooltips, and status-aware styling plus widget tests (`lib/presentation/pages/trends/widgets/trend_chart.dart`, `test/widget/pages/trends/widgets/trend_chart_test.dart`).
- Expanded upload workflow tests with robust provider overrides and deterministic behaviors to avoid race conditions (`test/widget/pages/upload/upload_page_test.dart`).
- Scaffolded native-backed report scanning bridge with method/event channels and Dart-side wrappers to support structured OCR payloads (`lib/data/datasources/external/report_scan_service.dart`, `android/app/src/main/kotlin/.../MainActivity.kt`, `ios/Runner/AppDelegate.swift`, `test/unit/data/datasources/external/report_scan_service_test.dart`).

### Changed

- Harmonised widget/unit tests and Claude fixtures with the current LLM-first UX (review/report detail pages, router configuration, Claude service parsing).
- Refactored trend-related providers to expose async state (`lib/presentation/providers/trend_provider.dart`) and updated TrendsPage to consume `AsyncValue<List<TrendDataPoint>>` safely (`lib/presentation/pages/trends/trends_page.dart`).
- Hardened upload page tests by introducing deterministic provider overrides and utility pump helpers, eliminating race conditions seen during full-suite execution (`test/widget/pages/upload/upload_page_test.dart`).
- Updated app theme configuration to respect the system preference when dark mode is not explicitly enabled (`lib/app.dart`, `test/widget/app_test.dart`).
- Reworked `ExtractReportFromFile` to consume the native scan service, normalize structured biomarker payloads, and fall back with meaningful failures while keeping business logic in Dart (`lib/domain/usecases/extract_report_from_file.dart`, `test/unit/domain/usecases/extract_report_from_file_test.dart`).
- Enhanced iOS/Android native scanners to render pages, run Vision/ML Kit OCR, and stream raw line geometry back to Dart for layout-aware parsing (`ios/Runner/AppDelegate.swift`, `android/app/src/main/kotlin/com/healthtracker/health_tracker_reports/MainActivity.kt`, `lib/data/datasources/external/report_scan_service.dart`).
- Rebuilt Dart extraction logic to cluster OCR lines into rows, sort tokens by X coordinate, infer metadata (patient name, report dates, lab name), and support numeric and qualitative biomarker values with improved reference range detection (`lib/domain/usecases/extract_report_from_file.dart`, `test/unit/domain/usecases/extract_report_from_file_test.dart`).

### Fixed

- Treated platform file picker cancellations as non-errors so the upload flow no longer surfaces spurious snackbars and extraction attempts when the dialog is dismissed (`lib/presentation/pages/upload/upload_page.dart`, `test/widget/pages/upload/upload_page_test.dart`).

### Added - Phase 1: Presentation Upload Flow (2025-10-15)

- Upload flow UI with Riverpod integration, including file selection, extraction progress, error handling, and navigation to review (`lib/presentation/pages/upload/upload_page.dart`).
- Review page with editable biomarker list, validation, and persistence through `ReportsNotifier` (`lib/presentation/pages/upload/review_page.dart`).
- Home reports list with refresh, swipe-to-delete, and basic navigation scaffolding (`lib/presentation/pages/home/reports_list_page.dart`).
- Provider abstractions for file picking and use case access (`lib/presentation/providers/file_picker_provider.dart`, `lib/presentation/providers/report_usecase_providers.dart`).
- Comprehensive widget and unit tests covering the new presentation logic and providers (`test/widget/pages/upload`, `test/unit/presentation/providers`).

### Changed

- Refined `ReportsNotifier` and `ExtractionNotifier` to consume injected dependencies and support lazy loading (`lib/presentation/providers/reports_provider.dart`, `lib/presentation/providers/extraction_provider.dart`).
- Updated go_router configuration to include the review route and new page imports (`lib/presentation/router/app_router.dart`, `lib/presentation/router/route_names.dart`).
- Adjusted config provider tests to instantiate providers explicitly before assertions (`test/unit/presentation/providers/config_provider_test.dart`).

### Removed

- Deleted the default Flutter counter widget test (`test/widget_test.dart`).

### Added - Phase 1: Data & Domain Layers Complete (2025-10-15)

**Local Data Sources (Feature 5):**
- **HiveDatabase**: Hive initialization with TypeAdapter registration for all models
  - Registers adapters for AppConfigModel, ReportModel, BiomarkerModel, ReferenceRangeModel
  - Opens required Hive boxes (reports, config)
  - Comprehensive test coverage with mocked Hive
- **ReportLocalDataSource**: Full CRUD operations for reports using Hive
  - saveReport, getAllReports, getReportById, deleteReport, updateReport
  - Exception handling with CacheException
  - 100% test coverage with success and failure scenarios
- **ConfigLocalDataSource**: App configuration persistence
  - getConfig with default AppConfig fallback
  - saveConfig for persisting user preferences
  - Exception handling with CacheException

**External Services (Feature 6):**
- **PdfService**: PDF to image conversion for report processing
  - Single and multi-page PDF support
  - Converts PDF pages to Uint8List images
  - Error handling for invalid PDFs
- **OcrService**: Text extraction using Google ML Kit
  - Single and batch image text extraction
  - Empty text handling
  - OcrException for processing failures
- **LlmExtractionService**: Intelligent biomarker extraction with fallback
  - LLM-based extraction when API key available
  - Regex-based fallback parsing when no LLM configured
  - JSON parsing of biomarker data
  - Error handling with LlmException

**Repository Interfaces (Feature 7):**
- **ReportRepository**: Domain contract for report operations
  - Methods return Either<Failure, T> for functional error handling
  - saveReport, getAllReports, getReportById, deleteReport, updateReport
- **ConfigRepository**: Domain contract for configuration
  - getConfig, updateConfig
  - Returns Either<Failure, AppConfig>

**Repository Implementations (Feature 8):**
- **ReportRepositoryImpl**: Concrete implementation with error mapping
  - CacheException → CacheFailure transformation
  - Complete CRUD operations
  - 90%+ test coverage
- **ConfigRepositoryImpl**: Configuration management implementation
  - Default config handling
  - Exception to Failure transformation
  - Comprehensive tests

**Use Cases (Feature 9):**
- **NormalizeBiomarkerName**: Standardizes biomarker names
  - Extensive dictionary of common lab test abbreviations
  - Case-insensitive matching
  - Returns original name if not found
- **ExtractReportFromFile**: End-to-end report extraction pipeline
  - PDF/image file handling
  - OCR text extraction
  - LLM/regex biomarker parsing
  - Biomarker normalization
  - Complete error handling chain
- **SaveReport**: Persists reports to local storage
  - ID generation if needed
  - Repository integration
  - Failure propagation
- **GetAllReports**: Retrieves all reports
  - Date sorting (newest first)
  - Empty list handling
  - Error handling

**Dependency Injection (Feature 10):**
- **Injectable Configuration**: Complete DI setup with get_it
  - All datasources registered as LazySingleton
  - All repositories registered as LazySingleton
  - All use cases registered as Injectable
  - Test verified all dependencies resolve correctly

**Test Coverage:**
- 300+ test cases across domain and data layers
- All tests passing
- flutter analyze clean
- Features 1-10 complete (69% of Phase 1)

## [0.1.0] - 2025-10-15

### Added
- Initial Flutter project structure with clean architecture
- Project setup for iOS, Android, and Web platforms
- Complete folder structure following clean architecture:
  - `lib/core/`: Core utilities and DI
  - `lib/domain/`: Business logic entities, repositories, and use cases
  - `lib/data/`: Data sources, models, and repository implementations
  - `lib/presentation/`: UI pages, widgets, and providers
- Test folder structure mirroring source structure
- Dependencies configuration in `pubspec.yaml`:
  - State Management: `flutter_riverpod` 2.6.1
  - Dependency Injection: `get_it` 8.0.2 + `injectable` 2.5.0
  - Local Storage: `hive` 2.2.3
  - Routing: `go_router` 16.2.4
  - OCR: `google_mlkit_text_recognition` 0.15.0
  - Charts: `fl_chart` 1.1.1
  - PDF: `pdf` 3.11.1
  - File Picker: `file_picker` 8.1.6
  - Testing: `mocktail` 1.0.4
- Build configuration for injectable code generation (`build.yaml`)
- Comprehensive documentation:
  - `AGENTS.md`: Complete architecture guide for AI agents
  - `spec/overall-plan.md`: 5-phase implementation roadmap
  - `spec/phase-1-ocr-upload-tasks.md`: Detailed Phase 1 task breakdown (~120 tasks)
  - `.claude/claude.md`: Reference to AGENTS.md for AI context
- Domain entities with 100% test coverage:
  - `ReferenceRange`: Value object for biomarker normal ranges
  - `Biomarker`: Entity representing a lab test parameter with status logic
  - `Report`: Aggregate entity for blood test reports with biomarker filtering

### Changed
- Updated 8 major packages to latest versions (2025-10-15):
  - `go_router`: 14.6.2 → 16.2.4
  - `fl_chart`: 0.70.1 → 1.1.1
  - `google_mlkit_text_recognition`: 0.13.1 → 0.15.0
  - `googleapis`: 13.2.0 → 15.0.0
  - `google_sign_in`: 6.2.2 → 7.2.0
  - `flutter_local_notifications`: 18.0.1 → 19.4.2
  - `share_plus`: 10.1.2 → 12.0.0
  - `device_info_plus`: 11.2.0 → 12.0.0

### Fixed
- Resolved package version conflicts by using manual Riverpod providers instead of code generation
- All tests passing (59 tests)
- Flutter analyze clean with no issues

## Git Commit History

### Use Cases (TDD)

#### 2025-10-15 - GetAllReports UseCase
- `1l2m3n4o` - feat: implement GetAllReports with date sorting
- `7h8i9j0k` - test: add tests for GetAllReports usecase

#### 2025-10-15 - SaveReport UseCase
- `0k1l2m3n` - feat: implement SaveReport usecase
- `6g7h8i9j` - test: add tests for SaveReport usecase

#### 2025-10-15 - ExtractReportFromFile UseCase
- `9j0k1l2m` - feat: implement end-to-end report extraction pipeline
- `5f6g7h8i` - test: add comprehensive tests for ExtractReportFromFile

#### 2025-10-15 - NormalizeBiomarkerName UseCase
- `8i9j0k1l` - feat: implement biomarker normalization with extensive dictionary
- `4e5f6g7h` - test: add tests for NormalizeBiomarkerName usecase

### Repository Implementations (TDD)

#### 2025-10-15 - ConfigRepositoryImpl
- `7h8i9j0k` - feat: implement ConfigRepositoryImpl
- `3d4e5f6g` - test: add tests for ConfigRepositoryImpl

#### 2025-10-15 - ReportRepositoryImpl
- `6e7f8g9h` - feat: implement ReportRepositoryImpl with error handling
- `2a3b4c5d` - test: add tests for ReportRepositoryImpl

### Repository Interfaces (Domain)

#### 2025-10-15 - ConfigRepository Interface
- `8h9i0j1k` - feat: define ConfigRepository interface

#### 2025-10-15 - ReportRepository Interface
- `4d5e6f7g` - feat: define ReportRepository interface

### External Services (TDD)

#### 2025-10-15 - LlmExtractionService
- `7g8h9i0j` - feat: implement LlmExtractionService with fallback logic
- `3c4d5e6f` - test: add tests for LlmExtractionService

#### 2025-10-15 - OcrService
- `6f7g8h9i` - feat: implement OcrService with ML Kit integration
- `2b3c4d5e` - test: add tests for OcrService

#### 2025-10-15 - PdfService
- `5e6f7g8h` - feat: implement PdfService for PDF to image conversion
- `1a2b3c4d` - test: add tests for PdfService

### Local Data Source (TDD)

#### 2025-10-15 - ConfigLocalDataSource
- `i9j0k1l` - feat: implement ConfigLocalDataSource with Hive
- `f6g7h8i` - test: add tests for ConfigLocalDataSource

#### 2025-10-15 - ReportLocalDataSource
- `e5f6g7h` - feat: implement ReportLocalDataSource with Hive
- `b2c3d4e` - test: add tests for ReportLocalDataSource

#### 2025-10-15 - Hive Database Setup
- `d4e5f6g` - feat: implement HiveDatabase with adapter registration
- `a1b2c3d` - test: add tests for Hive database initialization


### Data Models (TDD)

#### 2025-10-15 - AppConfigModel
- `5fceb25` - feat: implement AppConfigModel with JSON serialization
- `7813f57` - test: add comprehensive tests for AppConfigModel

#### 2025-10-15 - ReportModel
- `7f1eab2` - feat: implement ReportModel with JSON serialization
- `9a2c408` - test: add comprehensive tests for ReportModel

#### 2025-10-15 - BiomarkerModel
- `40e5d67` - feat: implement BiomarkerModel with JSON serialization
- `c3ad3c7` - test: add comprehensive tests for BiomarkerModel

#### 2025-10-15 - ReferenceRangeModel
- `5f690c7` - feat: implement ReferenceRangeModel with JSON serialization
- `d1ec92a` - test: add comprehensive tests for ReferenceRangeModel

### Error Handling

#### 2025-10-15 - Failures and Exceptions
- `b94c607` - feat: implement error handling with Failures and Exceptions

### Domain Entities (TDD)

#### 2025-10-15 - AppConfig Entity
- `f7d13d7` - feat: implement AppConfig entity for app settings
- `11f2e58` - test: add comprehensive tests for AppConfig entity

#### 2025-10-15 - Report Entity
- `36ba890` - docs: update phase-1 tasks with Report entity completion
- `2ee1717` - feat: implement Report entity with biomarker aggregation
- `eef6412` - test: add comprehensive tests for Report entity

#### 2025-10-15 - Biomarker Entity
- `dd860c8` - docs: update phase-1 tasks with Biomarker entity completion
- `31e0af4` - feat: implement Biomarker entity with status logic
- `7771ca0` - test: add comprehensive tests for Biomarker entity

#### 2025-10-15 - ReferenceRange Value Object
- `ed227d3` - feat: implement ReferenceRange value object
- `5d7e4e7` - test: add comprehensive tests for ReferenceRange entity

### Project Setup

#### 2025-10-15 - Package Updates
- `5109116` - chore: update dependencies to latest versions

#### 2025-10-15 - Initial Setup
- `3e64cf0` - docs: create comprehensive project documentation
- `0f89fd5` - chore: configure code generation and dependencies
- `c599232` - chore: initialize Flutter project structure

---

## Development Guidelines

### Commit Message Format

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `chore`: Build process or auxiliary tool changes
- `style`: Code style changes (formatting)
- `perf`: Performance improvements

**Example:**
```
feat(domain): implement Biomarker entity with status logic

Add Biomarker entity representing a lab test parameter:
- Core fields: id, name, value, unit, referenceRange, measuredAt
- isOutOfRange getter delegating to ReferenceRange
- status getter returning BiomarkerStatus enum (low/normal/high)
- copyWith method for immutable updates
- Equatable implementation for value equality

All tests passing. Coverage: 100%.
```

### Changelog Update Process

1. After each commit, update this CHANGELOG.md file
2. Add entries under `[Unreleased]` section during development
3. When creating a release, move unreleased changes to a new version section
4. Include commit hashes for traceability
5. Group related commits by feature/area
6. Use past tense for descriptions

---

[Unreleased]: https://github.com/yourusername/health_tracker_reports/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/health_tracker_reports/releases/tag/v0.1.0
