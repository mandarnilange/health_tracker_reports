# Phase 1: Foundation & OCR Upload - Task List

**Phase Goal:** Enable users to upload blood reports (PDF/images) and automatically extract biomarker data using OCR and optional LLM processing.

**Status:** Not Started

**Start Date:** TBD

**Completion Date:** TBD

---

## Feature 1: Project Setup & Infrastructure

### Tasks

#### 1.1 Flutter Project Initialization
- [ ] Run `flutter create --org com.healthtracker --platforms ios,android,web health_tracker_reports`
- [ ] Verify project runs on all platforms (iOS, Android, Web)
- [ ] Create clean architecture folder structure
- [ ] Set up `.gitignore` with Flutter defaults

**Git Commits:**
- (empty)

#### 1.2 Dependencies Configuration
- [ ] Add all dependencies to `pubspec.yaml`
- [ ] Add dev dependencies (mocktail, build_runner, generators)
- [ ] Run `flutter pub get`
- [ ] Verify no conflicts

**Git Commits:**
- (empty)

#### 1.3 Testing Infrastructure
- [ ] Create `test/` folder structure (unit/widget/integration)
- [ ] Create test helper files
- [ ] Configure coverage settings
- [ ] Verify `flutter test --coverage` works

**Git Commits:**
- (empty)

#### 1.4 Code Generation Setup
- [ ] Add `build.yaml` configuration
- [ ] Set up injectable configuration
- [ ] Set up Riverpod generators
- [ ] Set up Hive generators
- [ ] Test code generation with `dart run build_runner build`

**Git Commits:**
- (empty)

---

## Feature 2: Core Domain Entities (TDD)

### Tasks

#### 2.1 ReferenceRange Value Object
- [x] **TEST:** Write test for ReferenceRange creation
- [x] **CODE:** Implement ReferenceRange entity
- [x] **TEST:** Write test for `isOutOfRange(value)` method
- [x] **CODE:** Implement `isOutOfRange(value)` logic
- [x] **TEST:** Write test for edge cases (null values, equal to boundaries)
- [x] **CODE:** Handle edge cases
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for ReferenceRange value object`
- [x] **COMMIT:** `feat: implement ReferenceRange with boundary validation`

**Location:** `lib/domain/entities/reference_range.dart`

**Test Location:** `test/unit/domain/entities/reference_range_test.dart`

**Git Commits:**
- 5d7e4e7 test: add comprehensive tests for ReferenceRange entity
- ed227d3 feat: implement ReferenceRange value object

#### 2.2 Biomarker Entity
- [ ] **TEST:** Write test for Biomarker entity creation with all fields
- [ ] **CODE:** Implement Biomarker entity (id, name, value, unit, referenceRange, measuredAt)
- [ ] **TEST:** Write test for `isOutOfRange` getter
- [ ] **CODE:** Implement `isOutOfRange` getter
- [ ] **TEST:** Write test for `status` getter (low/normal/high)
- [ ] **CODE:** Implement `status` getter with BiomarkerStatus enum
- [ ] **TEST:** Write test for Equatable props
- [ ] **CODE:** Implement Equatable correctly
- [ ] **TEST:** Write test for copyWith method
- [ ] **CODE:** Implement copyWith method
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add comprehensive tests for Biomarker entity`
- [ ] **COMMIT:** `feat: implement Biomarker entity with status logic`

**Location:** `lib/domain/entities/biomarker.dart`

**Test Location:** `test/unit/domain/entities/biomarker_test.dart`

**Git Commits:**
- (empty)

#### 2.3 Report Entity
- [ ] **TEST:** Write test for Report entity creation
- [ ] **CODE:** Implement Report entity (id, date, labName, biomarkers, originalFilePath, notes, createdAt, updatedAt)
- [ ] **TEST:** Write test for `outOfRangeBiomarkers` getter
- [ ] **CODE:** Implement `outOfRangeBiomarkers` getter
- [ ] **TEST:** Write test for `hasOutOfRangeBiomarkers` getter
- [ ] **CODE:** Implement `hasOutOfRangeBiomarkers` getter
- [ ] **TEST:** Write test for `outOfRangeCount` getter
- [ ] **CODE:** Implement `outOfRangeCount` getter
- [ ] **TEST:** Write test for `totalBiomarkerCount` getter
- [ ] **CODE:** Implement `totalBiomarkerCount` getter
- [ ] **TEST:** Write test for copyWith method
- [ ] **CODE:** Implement copyWith method
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for Report entity`
- [ ] **COMMIT:** `feat: implement Report entity with biomarker summary methods`

**Location:** `lib/domain/entities/report.dart`

**Test Location:** `test/unit/domain/entities/report_test.dart`

**Git Commits:**
- (empty)

#### 2.4 AppConfig Entity
- [ ] **TEST:** Write test for AppConfig entity creation
- [ ] **CODE:** Implement AppConfig entity (llmApiKey, llmProvider, useLlmExtraction, darkModeEnabled)
- [ ] **TEST:** Write test for copyWith method
- [ ] **CODE:** Implement copyWith method
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for AppConfig entity`
- [ ] **COMMIT:** `feat: implement AppConfig entity`

**Location:** `lib/domain/entities/app_config.dart`

**Test Location:** `test/unit/domain/entities/app_config_test.dart`

**Git Commits:**
- (empty)

---

## Feature 3: Core Error Handling

### Tasks

#### 3.1 Failures
- [ ] **CODE:** Create abstract Failure class
- [ ] **CODE:** Implement CacheFailure
- [ ] **CODE:** Implement OcrFailure
- [ ] **CODE:** Implement LlmFailure
- [ ] **CODE:** Implement ValidationFailure
- [ ] **CODE:** Implement FilePickerFailure
- [ ] **COMMIT:** `feat: implement failure types for error handling`

**Location:** `lib/core/error/failures.dart`

**Git Commits:**
- (empty)

#### 3.2 Exceptions
- [ ] **CODE:** Create CacheException
- [ ] **CODE:** Create OcrException
- [ ] **CODE:** Create LlmException
- [ ] **CODE:** Create ValidationException
- [ ] **CODE:** Create FilePickerException
- [ ] **COMMIT:** `feat: implement exception types`

**Location:** `lib/core/error/exceptions.dart`

**Git Commits:**
- (empty)

---

## Feature 4: Data Models (TDD)

### Tasks

#### 4.1 ReferenceRangeModel
- [ ] **TEST:** Write test for fromEntity factory
- [ ] **CODE:** Implement ReferenceRangeModel extending ReferenceRange
- [ ] **TEST:** Write test for toJson method
- [ ] **CODE:** Implement toJson method
- [ ] **TEST:** Write test for fromJson factory
- [ ] **CODE:** Implement fromJson factory
- [ ] **TEST:** Write test for JSON serialization round-trip
- [ ] **CODE:** Ensure round-trip works correctly
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for ReferenceRangeModel serialization`
- [ ] **COMMIT:** `feat: implement ReferenceRangeModel with JSON serialization`

**Location:** `lib/data/models/reference_range_model.dart`

**Test Location:** `test/unit/data/models/reference_range_model_test.dart`

**Git Commits:**
- (empty)

#### 4.2 BiomarkerModel
- [ ] **TEST:** Write test for fromEntity factory
- [ ] **CODE:** Implement BiomarkerModel extending Biomarker
- [ ] **TEST:** Write test for toJson method
- [ ] **CODE:** Implement toJson method
- [ ] **TEST:** Write test for fromJson factory
- [ ] **CODE:** Implement fromJson factory with referenceRange handling
- [ ] **TEST:** Write test for Hive TypeAdapter (if using Hive)
- [ ] **CODE:** Add @HiveType annotations and generate adapter
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for BiomarkerModel serialization`
- [ ] **COMMIT:** `feat: implement BiomarkerModel with JSON and Hive support`

**Location:** `lib/data/models/biomarker_model.dart`

**Test Location:** `test/unit/data/models/biomarker_model_test.dart`

**Git Commits:**
- (empty)

#### 4.3 ReportModel
- [ ] **TEST:** Write test for fromEntity factory
- [ ] **CODE:** Implement ReportModel extending Report
- [ ] **TEST:** Write test for toJson method
- [ ] **CODE:** Implement toJson method with biomarkers list
- [ ] **TEST:** Write test for fromJson factory
- [ ] **CODE:** Implement fromJson factory
- [ ] **TEST:** Write test for Hive TypeAdapter
- [ ] **CODE:** Add @HiveType annotations and generate adapter
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for ReportModel serialization`
- [ ] **COMMIT:** `feat: implement ReportModel with JSON and Hive support`

**Location:** `lib/data/models/report_model.dart`

**Test Location:** `test/unit/data/models/report_model_test.dart`

**Git Commits:**
- (empty)

#### 4.4 AppConfigModel
- [ ] **TEST:** Write test for fromEntity factory
- [ ] **CODE:** Implement AppConfigModel
- [ ] **TEST:** Write test for toJson/fromJson
- [ ] **CODE:** Implement JSON serialization
- [ ] **TEST:** Write test for Hive TypeAdapter
- [ ] **CODE:** Add @HiveType annotations and generate adapter
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for AppConfigModel serialization`
- [ ] **COMMIT:** `feat: implement AppConfigModel with Hive support`

**Location:** `lib/data/models/app_config_model.dart`

**Test Location:** `test/unit/data/models/app_config_model_test.dart`

**Git Commits:**
- (empty)

---

## Feature 5: Local Data Source (TDD)

### Tasks

#### 5.1 Hive Database Setup
- [ ] **TEST:** Write test for Hive initialization
- [ ] **CODE:** Implement HiveDatabase class
- [ ] **TEST:** Write test for opening boxes
- [ ] **CODE:** Implement box opening logic
- [ ] **TEST:** Write test for registering adapters
- [ ] **CODE:** Implement adapter registration
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for Hive database initialization`
- [ ] **COMMIT:** `feat: implement HiveDatabase with adapter registration`

**Location:** `lib/data/datasources/local/hive_database.dart`

**Test Location:** `test/unit/data/datasources/local/hive_database_test.dart`

**Git Commits:**
- (empty)

#### 5.2 ReportLocalDataSource
- [ ] **TEST:** Write test for saveReport method
- [ ] **CODE:** Implement ReportLocalDataSource abstract class
- [ ] **CODE:** Implement ReportLocalDataSourceImpl
- [ ] **TEST:** Write test for getAllReports method
- [ ] **CODE:** Implement getAllReports method
- [ ] **TEST:** Write test for getReportById method
- [ ] **CODE:** Implement getReportById method
- [ ] **TEST:** Write test for deleteReport method
- [ ] **CODE:** Implement deleteReport method
- [ ] **TEST:** Write test for updateReport method
- [ ] **CODE:** Implement updateReport method
- [ ] **TEST:** Write test for exception handling
- [ ] **CODE:** Add try-catch and throw CacheException
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for ReportLocalDataSource`
- [ ] **COMMIT:** `feat: implement ReportLocalDataSource with Hive`

**Location:** `lib/data/datasources/local/report_local_datasource.dart`

**Test Location:** `test/unit/data/datasources/local/report_local_datasource_test.dart`

**Git Commits:**
- (empty)

#### 5.3 ConfigLocalDataSource
- [ ] **TEST:** Write test for getConfig method
- [ ] **CODE:** Implement ConfigLocalDataSource abstract class
- [ ] **CODE:** Implement ConfigLocalDataSourceImpl
- [ ] **TEST:** Write test for saveConfig method
- [ ] **CODE:** Implement saveConfig method
- [ ] **TEST:** Write test for default config when none exists
- [ ] **CODE:** Implement default config logic
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for ConfigLocalDataSource`
- [ ] **COMMIT:** `feat: implement ConfigLocalDataSource with Hive`

**Location:** `lib/data/datasources/local/config_local_datasource.dart`

**Test Location:** `test/unit/data/datasources/local/config_local_datasource_test.dart`

**Git Commits:**
- (empty)

---

## Feature 6: External Services (TDD)

### Tasks

#### 6.1 PdfService
- [ ] **TEST:** Write test for PDF file to image conversion
- [ ] **CODE:** Implement PdfService class
- [ ] **TEST:** Write test for multi-page PDF
- [ ] **CODE:** Implement multi-page handling
- [ ] **TEST:** Write test for invalid PDF handling
- [ ] **CODE:** Add error handling
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for PdfService`
- [ ] **COMMIT:** `feat: implement PdfService for PDF to image conversion`

**Location:** `lib/data/datasources/external/pdf_service.dart`

**Test Location:** `test/unit/data/datasources/external/pdf_service_test.dart`

**Git Commits:**
- (empty)

#### 6.2 OcrService
- [ ] **TEST:** Write test for extractText from image
- [ ] **CODE:** Implement OcrService using ML Kit
- [ ] **TEST:** Write test for extractText from multiple images
- [ ] **CODE:** Implement batch processing
- [ ] **TEST:** Write test for empty/no text scenarios
- [ ] **CODE:** Handle edge cases
- [ ] **TEST:** Write test for OcrException throwing
- [ ] **CODE:** Add error handling
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for OcrService`
- [ ] **COMMIT:** `feat: implement OcrService with ML Kit integration`

**Location:** `lib/data/datasources/external/ocr_service.dart`

**Test Location:** `test/unit/data/datasources/external/ocr_service_test.dart`

**Git Commits:**
- (empty)

#### 6.3 LlmExtractionService
- [ ] **TEST:** Write test for extractBiomarkers with API key
- [ ] **CODE:** Implement LlmExtractionService interface
- [ ] **CODE:** Implement LlmExtractionServiceImpl
- [ ] **TEST:** Write test for parsing LLM JSON response
- [ ] **CODE:** Implement JSON parsing logic
- [ ] **TEST:** Write test for fallback when no API key
- [ ] **CODE:** Implement fallback to basic regex parsing
- [ ] **TEST:** Write test for LlmException on API failure
- [ ] **CODE:** Add error handling
- [ ] **TEST:** Write test for malformed JSON handling
- [ ] **CODE:** Handle parsing errors gracefully
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for LlmExtractionService`
- [ ] **COMMIT:** `feat: implement LlmExtractionService with fallback logic`

**Location:** `lib/data/datasources/external/llm_extraction_service.dart`

**Test Location:** `test/unit/data/datasources/external/llm_extraction_service_test.dart`

**Git Commits:**
- (empty)

---

## Feature 7: Repository Interfaces (Domain)

### Tasks

#### 7.1 ReportRepository Interface
- [ ] **CODE:** Define ReportRepository abstract class
- [ ] **CODE:** Add saveReport method signature returning Either<Failure, Report>
- [ ] **CODE:** Add getAllReports method signature
- [ ] **CODE:** Add getReportById method signature
- [ ] **CODE:** Add deleteReport method signature
- [ ] **CODE:** Add updateReport method signature
- [ ] **COMMIT:** `feat: define ReportRepository interface`

**Location:** `lib/domain/repositories/report_repository.dart`

**Git Commits:**
- (empty)

#### 7.2 ConfigRepository Interface
- [ ] **CODE:** Define ConfigRepository abstract class
- [ ] **CODE:** Add getConfig method signature
- [ ] **CODE:** Add updateConfig method signature
- [ ] **COMMIT:** `feat: define ConfigRepository interface`

**Location:** `lib/domain/repositories/config_repository.dart`

**Git Commits:**
- (empty)

---

## Feature 8: Repository Implementations (TDD)

### Tasks

#### 8.1 ReportRepositoryImpl
- [ ] **TEST:** Write test for saveReport success case
- [ ] **CODE:** Implement ReportRepositoryImpl with @LazySingleton
- [ ] **TEST:** Write test for saveReport failure (CacheException → CacheFailure)
- [ ] **CODE:** Implement error handling in saveReport
- [ ] **TEST:** Write test for getAllReports success
- [ ] **CODE:** Implement getAllReports
- [ ] **TEST:** Write test for getAllReports failure
- [ ] **CODE:** Add error handling
- [ ] **TEST:** Write test for getReportById success
- [ ] **CODE:** Implement getReportById
- [ ] **TEST:** Write test for getReportById not found
- [ ] **CODE:** Handle not found case
- [ ] **TEST:** Write test for deleteReport
- [ ] **CODE:** Implement deleteReport
- [ ] **TEST:** Write test for updateReport
- [ ] **CODE:** Implement updateReport
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for ReportRepositoryImpl`
- [ ] **COMMIT:** `feat: implement ReportRepositoryImpl with error handling`

**Location:** `lib/data/repositories/report_repository_impl.dart`

**Test Location:** `test/unit/data/repositories/report_repository_impl_test.dart`

**Git Commits:**
- (empty)

#### 8.2 ConfigRepositoryImpl
- [ ] **TEST:** Write test for getConfig success
- [ ] **CODE:** Implement ConfigRepositoryImpl with @LazySingleton
- [ ] **TEST:** Write test for getConfig with default values
- [ ] **CODE:** Implement default config logic
- [ ] **TEST:** Write test for updateConfig success
- [ ] **CODE:** Implement updateConfig
- [ ] **TEST:** Write test for updateConfig failure
- [ ] **CODE:** Add error handling
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for ConfigRepositoryImpl`
- [ ] **COMMIT:** `feat: implement ConfigRepositoryImpl`

**Location:** `lib/data/repositories/config_repository_impl.dart`

**Test Location:** `test/unit/data/repositories/config_repository_impl_test.dart`

**Git Commits:**
- (empty)

---

## Feature 9: Use Cases (TDD)

### Tasks

#### 9.1 NormalizeBiomarkerName UseCase
- [ ] **TEST:** Write test for normalizing "Na" → "Sodium"
- [ ] **CODE:** Implement NormalizeBiomarkerName usecase with @lazySingleton
- [ ] **TEST:** Write test for multiple variations (Na, NA, na, Na+)
- [ ] **CODE:** Implement case-insensitive normalization map
- [ ] **TEST:** Write test for unknown biomarker (return as-is)
- [ ] **CODE:** Handle unknown biomarkers
- [ ] **TEST:** Write test for empty/null input
- [ ] **CODE:** Handle edge cases
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for NormalizeBiomarkerName usecase`
- [ ] **COMMIT:** `feat: implement biomarker normalization with extensive dictionary`

**Location:** `lib/domain/usecases/normalize_biomarker_name.dart`

**Test Location:** `test/unit/domain/usecases/normalize_biomarker_name_test.dart`

**Git Commits:**
- (empty)

#### 9.2 ExtractReportFromFile UseCase
- [ ] **TEST:** Write test for successful extraction from PDF
- [ ] **CODE:** Implement ExtractReportFromFile usecase with dependencies (PdfService, OcrService, LlmService, NormalizeBiomarkerName)
- [ ] **TEST:** Write test for PDF to image conversion
- [ ] **CODE:** Implement PDF conversion flow
- [ ] **TEST:** Write test for OCR text extraction
- [ ] **CODE:** Implement OCR flow
- [ ] **TEST:** Write test for LLM biomarker extraction
- [ ] **CODE:** Implement LLM extraction flow
- [ ] **TEST:** Write test for biomarker normalization
- [ ] **CODE:** Apply normalization to all biomarkers
- [ ] **TEST:** Write test for image file (skip PDF conversion)
- [ ] **CODE:** Handle image files directly
- [ ] **TEST:** Write test for OcrException → OcrFailure
- [ ] **CODE:** Add error handling for OCR failures
- [ ] **TEST:** Write test for LlmException → LlmFailure
- [ ] **CODE:** Add error handling for LLM failures
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add comprehensive tests for ExtractReportFromFile`
- [ ] **COMMIT:** `feat: implement end-to-end report extraction pipeline`

**Location:** `lib/domain/usecases/extract_report_from_file.dart`

**Test Location:** `test/unit/domain/usecases/extract_report_from_file_test.dart`

**Git Commits:**
- (empty)

#### 9.3 SaveReport UseCase
- [ ] **TEST:** Write test for successful save
- [ ] **CODE:** Implement SaveReport usecase with ReportRepository dependency
- [ ] **TEST:** Write test for duplicate ID handling
- [ ] **CODE:** Implement ID generation if empty
- [ ] **TEST:** Write test for CacheFailure propagation
- [ ] **CODE:** Add error handling
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for SaveReport usecase`
- [ ] **COMMIT:** `feat: implement SaveReport usecase`

**Location:** `lib/domain/usecases/save_report.dart`

**Test Location:** `test/unit/domain/usecases/save_report_test.dart`

**Git Commits:**
- (empty)

#### 9.4 GetAllReports UseCase
- [ ] **TEST:** Write test for getting all reports
- [ ] **CODE:** Implement GetAllReports usecase
- [ ] **TEST:** Write test for empty list
- [ ] **CODE:** Handle empty case
- [ ] **TEST:** Write test for sorted by date (newest first)
- [ ] **CODE:** Implement sorting logic
- [ ] **TEST:** Write test for failure handling
- [ ] **CODE:** Add error handling
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for GetAllReports usecase`
- [ ] **COMMIT:** `feat: implement GetAllReports with date sorting`

**Location:** `lib/domain/usecases/get_all_reports.dart`

**Test Location:** `test/unit/domain/usecases/get_all_reports_test.dart`

**Git Commits:**
- (empty)

---

## Feature 10: Dependency Injection Setup

### Tasks

#### 10.1 Injectable Configuration
- [ ] **CODE:** Create `injection_container.dart` with @InjectableInit
- [ ] **CODE:** Create configureDependencies function
- [ ] **CODE:** Register all @injectable, @lazySingleton classes
- [ ] **CODE:** Run `dart run build_runner build`
- [ ] **TEST:** Write test for DI container initialization
- [ ] **CODE:** Verify all dependencies resolve correctly
- [ ] **COMMIT:** `feat: set up dependency injection with injectable`

**Location:** `lib/core/di/injection_container.dart`

**Test Location:** `test/unit/core/di/injection_container_test.dart`

**Git Commits:**
- (empty)

---

## Feature 11: Presentation Layer - Upload Flow (TDD)

### Tasks

#### 11.1 Riverpod Providers
- [ ] **CODE:** Create reportListProvider with @riverpod annotation
- [ ] **CODE:** Create configProvider
- [ ] **CODE:** Implement addReport method in provider
- [ ] **CODE:** Run `dart run build_runner build`
- [ ] **TEST:** Write widget test for provider state changes
- [ ] **CODE:** Ensure provider updates correctly
- [ ] **COMMIT:** `feat: create Riverpod providers for reports and config`

**Location:** `lib/presentation/providers/report_providers.dart`

**Test Location:** `test/widget/providers/report_providers_test.dart`

**Git Commits:**
- (empty)

#### 11.2 UploadPage UI
- [ ] **TEST:** Write widget test for UploadPage rendering
- [ ] **CODE:** Create UploadPage widget
- [ ] **TEST:** Write test for file picker button tap
- [ ] **CODE:** Implement file picker integration
- [ ] **TEST:** Write test for loading state during extraction
- [ ] **CODE:** Implement loading indicator
- [ ] **TEST:** Write test for navigation to ReviewPage on success
- [ ] **CODE:** Implement navigation logic
- [ ] **TEST:** Write test for error display on failure
- [ ] **CODE:** Implement error handling UI
- [ ] **VERIFY:** Run widget tests, ensure coverage >= 85%
- [ ] **COMMIT:** `test: add widget tests for UploadPage`
- [ ] **COMMIT:** `feat: implement UploadPage with file picker`

**Location:** `lib/presentation/pages/upload/upload_page.dart`

**Test Location:** `test/widget/pages/upload/upload_page_test.dart`

**Git Commits:**
- (empty)

#### 11.3 ReviewPage UI
- [ ] **TEST:** Write widget test for ReviewPage displaying extracted data
- [ ] **CODE:** Create ReviewPage widget
- [ ] **TEST:** Write test for editable biomarker fields
- [ ] **CODE:** Implement editable form fields
- [ ] **TEST:** Write test for save button
- [ ] **CODE:** Implement save functionality
- [ ] **TEST:** Write test for form validation
- [ ] **CODE:** Add validation logic
- [ ] **TEST:** Write test for navigation back to home on save
- [ ] **CODE:** Implement navigation
- [ ] **VERIFY:** Run widget tests, ensure coverage >= 85%
- [ ] **COMMIT:** `test: add widget tests for ReviewPage`
- [ ] **COMMIT:** `feat: implement ReviewPage with editable forms`

**Location:** `lib/presentation/pages/upload/review_page.dart`

**Test Location:** `test/widget/pages/upload/review_page_test.dart`

**Git Commits:**
- (empty)

---

## Feature 12: App Initialization & Routing

### Tasks

#### 12.1 Main App Setup
- [ ] **CODE:** Create main.dart with Hive initialization
- [ ] **CODE:** Call configureDependencies()
- [ ] **CODE:** Set up ProviderScope
- [ ] **CODE:** Initialize MaterialApp with theme
- [ ] **TEST:** Write integration test for app startup
- [ ] **CODE:** Verify app loads correctly
- [ ] **COMMIT:** `feat: implement main.dart with initialization`

**Location:** `lib/main.dart`

**Test Location:** `test/integration/app_startup_test.dart`

**Git Commits:**
- (empty)

#### 12.2 Routing with go_router
- [ ] **CODE:** Create router.dart with go_router configuration
- [ ] **CODE:** Define routes: /, /upload, /review
- [ ] **CODE:** Add route guards if needed
- [ ] **TEST:** Write test for route navigation
- [ ] **CODE:** Verify routes work correctly
- [ ] **COMMIT:** `feat: set up go_router with initial routes`

**Location:** `lib/presentation/router.dart`

**Test Location:** `test/unit/presentation/router_test.dart`

**Git Commits:**
- (empty)

#### 12.3 Theme Configuration
- [ ] **CODE:** Create app_theme.dart with Material 3 light theme
- [ ] **CODE:** Create dark theme
- [ ] **CODE:** Define color scheme (medical/health theme)
- [ ] **CODE:** Configure typography
- [ ] **COMMIT:** `feat: implement Material 3 theme with dark mode`

**Location:** `lib/presentation/theme/app_theme.dart`

**Git Commits:**
- (empty)

---

## Phase 1 Completion Checklist

- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] Overall coverage >= 90%
- [ ] No linting errors (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] All tasks above completed
- [ ] User can successfully:
  - [ ] Select a PDF file
  - [ ] See extracted biomarkers
  - [ ] Edit extracted data
  - [ ] Save report to local database
  - [ ] View saved reports (basic list)
- [ ] Documentation updated:
  - [ ] overall-plan.md changelog updated
  - [ ] This task file marked complete
- [ ] Git commits follow conventional commits format
- [ ] All commits pushed to repository

---

## Status Summary

**Total Tasks:** ~120
**Completed:** 0
**In Progress:** 0
**Blocked:** 0

**Test Coverage:** 0%

**Last Updated:** 2025-10-15

---

## Notes

- Follow strict TDD: Write test → Fail → Implement → Pass → Refactor → Commit
- Never skip tests to speed up development
- Each checkbox represents a discrete unit of work
- Commit frequently (after each test-code pair)
- Update this file after each commit
- Refer to AGENTS.md for architecture patterns and examples
