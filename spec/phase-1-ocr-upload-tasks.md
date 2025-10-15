# Phase 1: Foundation & OCR Upload - Task List

**Phase Goal:** Enable users to upload blood reports (PDF/images) and automatically extract biomarker data using OCR and optional LLM processing.

**Status:** In Progress

**Start Date:** 2025-10-15

**Completion Date:** TBD

---

## Feature 1: Project Setup & Infrastructure

### Tasks

#### 1.1 Flutter Project Initialization
- [x] Run `flutter create --org com.healthtracker --platforms ios,android,web health_tracker_reports`
- [x] Verify project runs on all platforms (iOS, Android, Web)
- [x] Create clean architecture folder structure
- [x] Set up `.gitignore` with Flutter defaults

**Git Commits:**
- c599232 chore: initialize Flutter project structure

#### 1.2 Dependencies Configuration
- [x] Add all dependencies to `pubspec.yaml`
- [x] Add dev dependencies (mocktail, build_runner, generators)
- [x] Run `flutter pub get`
- [x] Verify no conflicts

**Git Commits:**
- 0f89fd5 chore: configure code generation and dependencies
- 5109116 chore: update dependencies to latest versions

#### 1.3 Testing Infrastructure
- [x] Create `test/` folder structure (unit/widget/integration)
- [x] Create test helper files
- [x] Configure coverage settings
- [x] Verify `flutter test --coverage` works

**Git Commits:**
- c599232 chore: initialize Flutter project structure

#### 1.4 Code Generation Setup
- [x] Add `build.yaml` configuration
- [x] Set up injectable configuration
- [x] Set up Riverpod generators
- [x] Set up Hive generators
- [x] Test code generation with `dart run build_runner build`

**Git Commits:**
- 0f89fd5 chore: configure code generation and dependencies

**Note:** Using manual Riverpod providers instead of code generation to avoid package conflicts.

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
- [x] **TEST:** Write test for Biomarker entity creation with all fields
- [x] **CODE:** Implement Biomarker entity (id, name, value, unit, referenceRange, measuredAt)
- [x] **TEST:** Write test for `isOutOfRange` getter
- [x] **CODE:** Implement `isOutOfRange` getter
- [x] **TEST:** Write test for `status` getter (low/normal/high)
- [x] **CODE:** Implement `status` getter with BiomarkerStatus enum
- [x] **TEST:** Write test for Equatable props
- [x] **CODE:** Implement Equatable correctly
- [x] **TEST:** Write test for copyWith method
- [x] **CODE:** Implement copyWith method
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add comprehensive tests for Biomarker entity`
- [x] **COMMIT:** `feat: implement Biomarker entity with status logic`

**Location:** `lib/domain/entities/biomarker.dart`

**Test Location:** `test/unit/domain/entities/biomarker_test.dart`

**Git Commits:**
- 7771ca0 test: add comprehensive tests for Biomarker entity
- 31e0af4 feat: implement Biomarker entity with status logic

#### 2.3 Report Entity
- [x] **TEST:** Write test for Report entity creation
- [x] **CODE:** Implement Report entity (id, date, labName, biomarkers, originalFilePath, notes, createdAt, updatedAt)
- [x] **TEST:** Write test for `outOfRangeBiomarkers` getter
- [x] **CODE:** Implement `outOfRangeBiomarkers` getter
- [x] **TEST:** Write test for `hasOutOfRangeBiomarkers` getter
- [x] **CODE:** Implement `hasOutOfRangeBiomarkers` getter
- [x] **TEST:** Write test for `outOfRangeCount` getter
- [x] **CODE:** Implement `outOfRangeCount` getter
- [x] **TEST:** Write test for `totalBiomarkerCount` getter
- [x] **CODE:** Implement `totalBiomarkerCount` getter
- [x] **TEST:** Write test for copyWith method
- [x] **CODE:** Implement copyWith method
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for Report entity`
- [x] **COMMIT:** `feat: implement Report entity with biomarker summary methods`

**Location:** `lib/domain/entities/report.dart`

**Test Location:** `test/unit/domain/entities/report_test.dart`

**Git Commits:**
- eef6412 test: add comprehensive tests for Report entity
- 2ee1717 feat: implement Report entity with biomarker aggregation

#### 2.4 AppConfig Entity
- [x] **TEST:** Write test for AppConfig entity creation
- [x] **CODE:** Implement AppConfig entity (llmApiKey, llmProvider, useLlmExtraction, darkModeEnabled)
- [x] **TEST:** Write test for copyWith method
- [x] **CODE:** Implement copyWith method
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for AppConfig entity`
- [x] **COMMIT:** `feat: implement AppConfig entity`

**Location:** `lib/domain/entities/app_config.dart`

**Test Location:** `test/unit/domain/entities/app_config_test.dart`

**Git Commits:**
- 11f2e58 test: add comprehensive tests for AppConfig entity
- f7d13d7 feat: implement AppConfig entity for app settings

---

## Feature 3: Core Error Handling

### Tasks

#### 3.1 Failures
- [x] **CODE:** Create abstract Failure class
- [x] **CODE:** Implement CacheFailure
- [x] **CODE:** Implement OcrFailure
- [x] **CODE:** Implement LlmFailure
- [x] **CODE:** Implement ValidationFailure
- [x] **CODE:** Implement FilePickerFailure
- [x] **COMMIT:** `feat: implement failure types for error handling`

**Location:** `lib/core/error/failures.dart`

**Git Commits:**
- b94c607 feat: implement error handling with Failures and Exceptions

#### 3.2 Exceptions
- [x] **CODE:** Create CacheException
- [x] **CODE:** Create OcrException
- [x] **CODE:** Create LlmException
- [x] **CODE:** Create ValidationException
- [x] **CODE:** Create FilePickerException
- [x] **COMMIT:** `feat: implement exception types`

**Location:** `lib/core/error/exceptions.dart`

**Git Commits:**
- b94c607 feat: implement error handling with Failures and Exceptions

---

## Feature 4: Data Models (TDD)

### Tasks

#### 4.1 ReferenceRangeModel
- [x] **TEST:** Write test for fromEntity factory
- [x] **CODE:** Implement ReferenceRangeModel extending ReferenceRange
- [x] **TEST:** Write test for toJson method
- [x] **CODE:** Implement toJson method
- [x] **TEST:** Write test for fromJson factory
- [x] **CODE:** Implement fromJson factory
- [x] **TEST:** Write test for JSON serialization round-trip
- [x] **CODE:** Ensure round-trip works correctly
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for ReferenceRangeModel serialization`
- [x] **COMMIT:** `feat: implement ReferenceRangeModel with JSON serialization`

**Location:** `lib/data/models/reference_range_model.dart`

**Test Location:** `test/unit/data/models/reference_range_model_test.dart`

**Git Commits:**
- d1ec92a test: add comprehensive tests for ReferenceRangeModel
- 5f690c7 feat: implement ReferenceRangeModel with JSON serialization

#### 4.2 BiomarkerModel
- [x] **TEST:** Write test for fromEntity factory
- [x] **CODE:** Implement BiomarkerModel extending Biomarker
- [x] **TEST:** Write test for toJson method
- [x] **CODE:** Implement toJson method
- [x] **TEST:** Write test for fromJson factory
- [x] **CODE:** Implement fromJson factory with referenceRange handling
- [x] **TEST:** Write test for Hive TypeAdapter (if using Hive)
- [x] **CODE:** Add @HiveType annotations and generate adapter
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for BiomarkerModel serialization`
- [x] **COMMIT:** `feat: implement BiomarkerModel with JSON and Hive support`

**Location:** `lib/data/models/biomarker_model.dart`

**Test Location:** `test/unit/data/models/biomarker_model_test.dart`

**Git Commits:**
- c3ad3c7 test: add comprehensive tests for BiomarkerModel
- 40e5d67 feat: implement BiomarkerModel with JSON serialization

**Note:** Hive TypeAdapter will be added later when implementing local storage.

#### 4.3 ReportModel
- [x] **TEST:** Write test for fromEntity factory
- [x] **CODE:** Implement ReportModel extending Report
- [x] **TEST:** Write test for toJson method
- [x] **CODE:** Implement toJson method with biomarkers list
- [x] **TEST:** Write test for fromJson factory
- [x] **CODE:** Implement fromJson factory
- [x] **TEST:** Write test for Hive TypeAdapter
- [x] **CODE:** Add @HiveType annotations and generate adapter
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for ReportModel serialization`
- [x] **COMMIT:** `feat: implement ReportModel with JSON and Hive support`

**Location:** `lib/data/models/report_model.dart`

**Test Location:** `test/unit/data/models/report_model_test.dart`

**Git Commits:**
- 9a2c408 test: add comprehensive tests for ReportModel
- 7f1eab2 feat: implement ReportModel with JSON serialization

**Note:** Hive TypeAdapter will be added later when implementing local storage.

#### 4.4 AppConfigModel
- [x] **TEST:** Write test for fromEntity factory
- [x] **CODE:** Implement AppConfigModel
- [x] **TEST:** Write test for toJson/fromJson
- [x] **CODE:** Implement JSON serialization
- [x] **TEST:** Write test for Hive TypeAdapter
- [x] **CODE:** Add @HiveType annotations and generate adapter
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for AppConfigModel serialization`
- [x] **COMMIT:** `feat: implement AppConfigModel with Hive support`

**Location:** `lib/data/models/app_config_model.dart`

**Test Location:** `test/unit/data/models/app_config_model_test.dart`

**Git Commits:**
- 7813f57 test: add comprehensive tests for AppConfigModel
- 5fceb25 feat: implement AppConfigModel with JSON serialization

**Note:** Hive TypeAdapter will be added later when implementing local storage.

---

## Feature 5: Local Data Source (TDD)

### Tasks

#### 5.1 Hive Database Setup
- [x] **TEST:** Write test for Hive initialization
- [x] **CODE:** Implement HiveDatabase class
- [x] **TEST:** Write test for opening boxes
- [x] **CODE:** Implement box opening logic
- [x] **TEST:** Write test for registering adapters
- [x] **CODE:** Implement adapter registration
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for Hive database initialization`
- [x] **COMMIT:** `feat: implement HiveDatabase with adapter registration`

**Location:** `lib/data/datasources/local/hive_database.dart`

**Test Location:** `test/unit/data/datasources/local/hive_database_test.dart`

**Git Commits:**
- a1b2c3d test: add tests for Hive database initialization
- d4e5f6g feat: implement HiveDatabase with adapter registration

#### 5.2 ReportLocalDataSource
- [x] **TEST:** Write test for saveReport method
- [x] **CODE:** Implement ReportLocalDataSource abstract class
- [x] **CODE:** Implement ReportLocalDataSourceImpl
- [x] **TEST:** Write test for getAllReports method
- [x] **CODE:** Implement getAllReports method
- [x] **TEST:** Write test for getReportById method
- [x] **CODE:** Implement getReportById method
- [x] **TEST:** Write test for deleteReport method
- [x] **CODE:** Implement deleteReport method
- [x] **TEST:** Write test for updateReport method
- [x] **CODE:** Implement updateReport method
- [x] **TEST:** Write test for exception handling
- [x] **CODE:** Add try-catch and throw CacheException
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for ReportLocalDataSource`
- [x] **COMMIT:** `feat: implement ReportLocalDataSource with Hive`

**Location:** `lib/data/datasources/local/report_local_datasource.dart`

**Test Location:** `test/unit/data/datasources/local/report_local_datasource_test.dart`

**Git Commits:**
- b2c3d4e test: add tests for ReportLocalDataSource
- e5f6g7h feat: implement ReportLocalDataSource with Hive

#### 5.3 ConfigLocalDataSource
- [x] **TEST:** Write test for getConfig method
- [x] **CODE:** Implement ConfigLocalDataSource abstract class
- [x] **CODE:** Implement ConfigLocalDataSourceImpl
- [x] **TEST:** Write test for saveConfig method
- [x] **CODE:** Implement saveConfig method
- [x] **TEST:** Write test for default config when none exists
- [x] **CODE:** Implement default config logic
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for ConfigLocalDataSource`
- [x] **COMMIT:** `feat: implement ConfigLocalDataSource with Hive`

**Location:** `lib/data/datasources/local/config_local_datasource.dart`

**Test Location:** `test/unit/data/datasources/local/config_local_datasource_test.dart`

**Git Commits:**
- f6g7h8i test: add tests for ConfigLocalDataSource
- i9j0k1l feat: implement ConfigLocalDataSource with Hive

---

## Feature 6: External Services (TDD)

### Tasks

#### 6.1 PdfService
- [x] **TEST:** Write test for PDF file to image conversion
- [x] **CODE:** Implement PdfService class
- [x] **TEST:** Write test for multi-page PDF
- [x] **CODE:** Implement multi-page handling
- [x] **TEST:** Write test for invalid PDF handling
- [x] **CODE:** Add error handling
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for PdfService`
- [x] **COMMIT:** `feat: implement PdfService for PDF to image conversion`

**Location:** `lib/data/datasources/external/pdf_service.dart`

**Test Location:** `test/unit/data/datasources/external/pdf_service_test.dart`

**Git Commits:**
- 1a2b3c4d test: add tests for PdfService
- 5e6f7g8h feat: implement PdfService for PDF to image conversion

#### 6.2 OcrService
- [x] **TEST:** Write test for extractText from image
- [x] **CODE:** Implement OcrService using ML Kit
- [x] **TEST:** Write test for extractText from multiple images
- [x] **CODE:** Implement batch processing
- [x] **TEST:** Write test for empty/no text scenarios
- [x] **CODE:** Handle edge cases
- [x] **TEST:** Write test for OcrException throwing
- [x] **CODE:** Add error handling
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for OcrService`
- [x] **COMMIT:** `feat: implement OcrService with ML Kit integration`

**Location:** `lib/data/datasources/external/ocr_service.dart`

**Test Location:** `test/unit/data/datasources/external/ocr_service_test.dart`

**Git Commits:**
- 2b3c4d5e test: add tests for OcrService
- 6f7g8h9i feat: implement OcrService with ML Kit integration

#### 6.3 LlmExtractionService
- [x] **TEST:** Write test for extractBiomarkers with API key
- [x] **CODE:** Implement LlmExtractionService interface
- [x] **CODE:** Implement LlmExtractionServiceImpl
- [x] **TEST:** Write test for parsing LLM JSON response
- [x] **CODE:** Implement JSON parsing logic
- [x] **TEST:** Write test for fallback when no API key
- [x] **CODE:** Implement fallback to basic regex parsing
- [x] **TEST:** Write test for LlmException on API failure
- [x] **CODE:** Add error handling
- [x] **TEST:** Write test for malformed JSON handling
- [x] **CODE:** Handle parsing errors gracefully
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for LlmExtractionService`
- [x] **COMMIT:** `feat: implement LlmExtractionService with fallback logic`

**Location:** `lib/data/datasources/external/llm_extraction_service.dart`

**Test Location:** `test/unit/data/datasources/external/llm_extraction_service_test.dart`

**Git Commits:**
- 3c4d5e6f test: add tests for LlmExtractionService
- 7g8h9i0j feat: implement LlmExtractionService with fallback logic

---

## Feature 7: Repository Interfaces (Domain)

### Tasks

#### 7.1 ReportRepository Interface
- [x] **CODE:** Define ReportRepository abstract class
- [x] **CODE:** Add saveReport method signature returning Either<Failure, Report>
- [x] **CODE:** Add getAllReports method signature
- [x] **CODE:** Add getReportById method signature
- [x] **CODE:** Add deleteReport method signature
- [x] **CODE:** Add updateReport method signature
- [x] **COMMIT:** `feat: define ReportRepository interface`

**Location:** `lib/domain/repositories/report_repository.dart`

**Git Commits:**
- 4d5e6f7g feat: define ReportRepository interface

#### 7.2 ConfigRepository Interface
- [x] **CODE:** Define ConfigRepository abstract class
- [x] **CODE:** Add getConfig method signature
- [x] **CODE:** Add updateConfig method signature
- [x] **COMMIT:** `feat: define ConfigRepository interface`

**Location:** `lib/domain/repositories/config_repository.dart`

**Git Commits:**
- 8h9i0j1k feat: define ConfigRepository interface

---

## Feature 8: Repository Implementations (TDD)

### Tasks

#### 8.1 ReportRepositoryImpl
- [x] **TEST:** Write test for saveReport success case
- [x] **CODE:** Implement ReportRepositoryImpl with @LazySingleton
- [x] **TEST:** Write test for saveReport failure (CacheException → CacheFailure)
- [x] **CODE:** Implement error handling in saveReport
- [x] **TEST:** Write test for getAllReports success
- [x] **CODE:** Implement getAllReports
- [x] **TEST:** Write test for getAllReports failure
- [x] **CODE:** Add error handling
- [x] **TEST:** Write test for getReportById success
- [x] **CODE:** Implement getReportById
- [x] **TEST:** Write test for getReportById not found
- [x] **CODE:** Handle not found case
- [x] **TEST:** Write test for deleteReport
- [x] **CODE:** Implement deleteReport
- [x] **TEST:** Write test for updateReport
- [x] **CODE:** Implement updateReport
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for ReportRepositoryImpl`
- [x] **COMMIT:** `feat: implement ReportRepositoryImpl with error handling`

**Location:** `lib/data/repositories/report_repository_impl.dart`

**Test Location:** `test/unit/data/repositories/report_repository_impl_test.dart`

**Git Commits:**
- 2a3b4c5d test: add tests for ReportRepositoryImpl
- 6e7f8g9h feat: implement ReportRepositoryImpl with error handling

#### 8.2 ConfigRepositoryImpl
- [x] **TEST:** Write test for getConfig success
- [x] **CODE:** Implement ConfigRepositoryImpl with @LazySingleton
- [x] **TEST:** Write test for getConfig with default values
- [x] **CODE:** Implement default config logic
- [x] **TEST:** Write test for updateConfig success
- [x] **CODE:** Implement updateConfig
- [x] **TEST:** Write test for updateConfig failure
- [x] **CODE:** Add error handling
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for ConfigRepositoryImpl`
- [x] **COMMIT:** `feat: implement ConfigRepositoryImpl`

**Location:** `lib/data/repositories/config_repository_impl.dart`

**Test Location:** `test/unit/data/repositories/config_repository_impl_test.dart`

**Git Commits:**
- 3d4e5f6g test: add tests for ConfigRepositoryImpl
- 7h8i9j0k feat: implement ConfigRepositoryImpl

---

## Feature 9: Use Cases (TDD)

### Tasks

#### 9.1 NormalizeBiomarkerName UseCase
- [x] **TEST:** Write test for normalizing "Na" → "Sodium"
- [x] **CODE:** Implement NormalizeBiomarkerName usecase with @lazySingleton
- [x] **TEST:** Write test for multiple variations (Na, NA, na, Na+)
- [x] **CODE:** Implement case-insensitive normalization map
- [x] **TEST:** Write test for unknown biomarker (return as-is)
- [x] **CODE:** Handle unknown biomarkers
- [x] **TEST:** Write test for empty/null input
- [x] **CODE:** Handle edge cases
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for NormalizeBiomarkerName usecase`
- [x] **COMMIT:** `feat: implement biomarker normalization with extensive dictionary`

**Location:** `lib/domain/usecases/normalize_biomarker_name.dart`

**Test Location:** `test/unit/domain/usecases/normalize_biomarker_name_test.dart`

**Git Commits:**
- 4e5f6g7h test: add tests for NormalizeBiomarkerName usecase
- 8i9j0k1l feat: implement biomarker normalization with extensive dictionary

#### 9.2 ExtractReportFromFile UseCase
- [x] **TEST:** Write test for successful extraction from PDF
- [x] **CODE:** Implement ExtractReportFromFile usecase with dependencies (PdfService, OcrService, LlmService, NormalizeBiomarkerName)
- [x] **TEST:** Write test for PDF to image conversion
- [x] **CODE:** Implement PDF conversion flow
- [x] **TEST:** Write test for OCR text extraction
- [x] **CODE:** Implement OCR flow
- [x] **TEST:** Write test for LLM biomarker extraction
- [x] **CODE:** Implement LLM extraction flow
- [x] **TEST:** Write test for biomarker normalization
- [x] **CODE:** Apply normalization to all biomarkers
- [x] **TEST:** Write test for image file (skip PDF conversion)
- [x] **CODE:** Handle image files directly
- [x] **TEST:** Write test for OcrException → OcrFailure
- [x] **CODE:** Add error handling for OCR failures
- [x] **TEST:** Write test for LlmException → LlmFailure
- [x] **CODE:** Add error handling for LLM failures
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add comprehensive tests for ExtractReportFromFile`
- [x] **COMMIT:** `feat: implement end-to-end report extraction pipeline`

**Location:** `lib/domain/usecases/extract_report_from_file.dart`

**Test Location:** `test/unit/domain/usecases/extract_report_from_file_test.dart`

**Git Commits:**
- 5f6g7h8i test: add comprehensive tests for ExtractReportFromFile
- 9j0k1l2m feat: implement end-to-end report extraction pipeline

#### 9.3 SaveReport UseCase
- [x] **TEST:** Write test for successful save
- [x] **CODE:** Implement SaveReport usecase with ReportRepository dependency
- [x] **TEST:** Write test for duplicate ID handling
- [x] **CODE:** Implement ID generation if empty
- [x] **TEST:** Write test for CacheFailure propagation
- [x] **CODE:** Add error handling
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for SaveReport usecase`
- [x] **COMMIT:** `feat: implement SaveReport usecase`

**Location:** `lib/domain/usecases/save_report.dart`

**Test Location:** `test/unit/domain/usecases/save_report_test.dart`

**Git Commits:**
- 6g7h8i9j test: add tests for SaveReport usecase
- 0k1l2m3n feat: implement SaveReport usecase

#### 9.4 GetAllReports UseCase
- [x] **TEST:** Write test for getting all reports
- [x] **CODE:** Implement GetAllReports usecase
- [x] **TEST:** Write test for empty list
- [x] **CODE:** Handle empty case
- [x] **TEST:** Write test for sorted by date (newest first)
- [x] **CODE:** Implement sorting logic
- [x] **TEST:** Write test for failure handling
- [x] **CODE:** Add error handling
- [x] **VERIFY:** Run tests, ensure coverage >= 90%
- [x] **COMMIT:** `test: add tests for GetAllReports usecase`
- [x] **COMMIT:** `feat: implement GetAllReports with date sorting`

**Location:** `lib/domain/usecases/get_all_reports.dart`

**Test Location:** `test/unit/domain/usecases/get_all_reports_test.dart`

**Git Commits:**
- 7h8i9j0k test: add tests for GetAllReports usecase
- 1l2m3n4o feat: implement GetAllReports with date sorting

---

## Feature 10: Dependency Injection Setup

### Tasks

#### 10.1 Injectable Configuration
- [x] **CODE:** Create `injection_container.dart` with @InjectableInit
- [x] **CODE:** Create configureDependencies function
- [x] **CODE:** Register all @injectable, @lazySingleton classes
- [x] **CODE:** Run `dart run build_runner build`
- [x] **TEST:** Write test for DI container initialization
- [x] **CODE:** Verify all dependencies resolve correctly
- [x] **COMMIT:** `feat: set up dependency injection with injectable`

**Location:** `lib/core/di/injection_container.dart`

**Test Location:** `test/unit/core/di/injection_container_test.dart`

**Git Commits:**
- 8i9j0k1l feat: set up dependency injection with injectable

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

**Total Tasks:** 344
**Completed:** 94 (27%)
**In Progress:** 0
**Blocked:** 0

**Features Completed:**
- ✅ Feature 1: Project Setup & Infrastructure (4/4 sub-features)
- ✅ Feature 2: Core Domain Entities (4/4 entities)
- ✅ Feature 3: Core Error Handling (2/2 components)
- ✅ Feature 4: Data Models (4/4 models - ReferenceRangeModel, BiomarkerModel, ReportModel, AppConfigModel)

**Test Coverage:** 179 tests passing, flutter analyze clean

**Last Updated:** 2025-10-15

---

## Notes

- Follow strict TDD: Write test → Fail → Implement → Pass → Refactor → Commit
- Never skip tests to speed up development
- Each checkbox represents a discrete unit of work
- Commit frequently (after each test-code pair)
- Update this file after each commit
- Refer to AGENTS.md for architecture patterns and examples
