# Health Tracker Reports - Agent Context Guide

## Project Overview
A Flutter-based blood report tracking application that allows users to upload blood test reports (PDF/images), automatically extract biomarker data using OCR/LLM, track trends over time, and generate shareable summaries for healthcare providers.

**Key Principles:**
- Test-Driven Development (TDD) - NO production code without tests first
- Clean Architecture with clear layer separation
- 90% minimum code coverage
- Privacy-first: All data stored locally (Hive)
- Support iOS, Android, and Web platforms

---

## Architecture Overview

### Clean Architecture Layers

```
lib/
├── core/                          # Shared utilities, DI, errors
│   ├── di/
│   │   ├── injection_container.dart      # get_it setup
│   │   └── injection_container.config.dart  # injectable generated
│   ├── error/
│   │   ├── failures.dart         # Failure types
│   │   └── exceptions.dart       # Exception types
│   ├── utils/
│   │   ├── constants.dart
│   │   └── validators.dart
│   └── network/
│       └── llm_client.dart       # Optional LLM API client
│
├── domain/                        # Business logic (pure Dart)
│   ├── entities/
│   │   ├── biomarker.dart        # Biomarker entity
│   │   ├── report.dart           # Report entity
│   │   └── reference_range.dart  # Reference range value object
│   ├── repositories/             # Abstract interfaces
│   │   ├── report_repository.dart
│   │   └── config_repository.dart
│   └── usecases/
│       ├── extract_report_from_file.dart
│       ├── save_report.dart
│       ├── get_all_reports.dart
│       ├── get_biomarker_trend.dart
│       ├── normalize_biomarker_name.dart
│       └── generate_doctor_pdf.dart
│
├── data/                          # Data layer (framework-dependent)
│   ├── models/
│   │   ├── biomarker_model.dart  # Extends entity, adds fromJson/toJson
│   │   └── report_model.dart
│   ├── repositories/             # Repository implementations
│   │   ├── report_repository_impl.dart
│   │   └── config_repository_impl.dart
│   └── datasources/
│       ├── local/
│       │   ├── hive_database.dart
│       │   ├── report_local_datasource.dart
│       │   └── config_local_datasource.dart
│       └── external/
│           ├── ocr_service.dart          # ML Kit wrapper
│           ├── pdf_service.dart          # PDF to image conversion
│           └── llm_extraction_service.dart  # LLM-based extraction
│
└── presentation/                  # UI layer
    ├── providers/                # Riverpod providers
    │   ├── report_providers.dart
    │   ├── config_providers.dart
    │   └── theme_provider.dart
    ├── pages/
    │   ├── home/
    │   │   ├── home_page.dart
    │   │   └── widgets/
    │   ├── upload/
    │   │   ├── upload_page.dart
    │   │   ├── review_page.dart
    │   │   └── widgets/
    │   ├── report_detail/
    │   │   ├── report_detail_page.dart
    │   │   └── widgets/
    │   ├── trends/
    │   │   ├── trends_page.dart
    │   │   └── widgets/
    │   └── settings/
    │       └── settings_page.dart
    └── widgets/
        ├── biomarker_card.dart
        ├── report_card.dart
        └── trend_chart.dart
```

---

## Technology Stack

### Core Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.6.1        # State management (manual providers, no code gen)
  get_it: ^8.0.2                  # Dependency injection
  injectable: ^2.5.0              # DI code generation
  hive: ^2.2.3                    # Local database
  hive_flutter: ^1.1.0            # Hive Flutter integration
  go_router: ^16.2.4              # Routing

  # File & OCR
  file_picker: ^8.1.6             # File selection
  pdf_render: ^1.4.3              # PDF to image
  google_mlkit_text_recognition: ^0.15.0  # OCR
  image: ^4.3.0                   # Image processing

  # Charts & PDF
  fl_chart: ^1.1.1                # Charts
  pdf: ^3.11.1                    # PDF generation
  printing: ^5.14.1               # PDF sharing

  # Utilities
  intl: ^0.20.1                   # Internationalization
  equatable: ^2.0.7               # Value equality
  dartz: ^0.10.1                  # Functional programming (Either)
  uuid: ^4.5.1                    # UUID generation

  # Google Drive
  googleapis: ^15.0.0             # Google APIs
  google_sign_in: ^7.2.0          # Google Sign-In
  extension_google_sign_in_as_googleapis_auth: ^3.0.0  # Auth extension

  # Notifications
  flutter_local_notifications: ^19.4.2  # Local notifications

  # Sharing
  share_plus: ^12.0.0             # Native sharing

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4                # Mocking
  build_runner: ^2.4.14           # Code generation
  injectable_generator: ^2.4.0    # DI generation (no Riverpod/Hive generators)
  flutter_lints: ^6.0.0           # Linting
```

---

## Design Patterns & Conventions

### 1. Test-Driven Development (TDD) Workflow

**MANDATORY RULE: Write tests BEFORE implementation**

```dart
// Step 1: Write the test (RED)
test('should return Report when extraction is successful', () async {
  // Arrange
  when(() => mockOcrService.extractText(any()))
      .thenAnswer((_) async => 'extracted text');

  // Act
  final result = await usecase(filePath);

  // Assert
  expect(result, isA<Right<Failure, Report>>());
});

// Step 2: Run test (should FAIL)
// Step 3: Write minimal code to pass (GREEN)
// Step 4: Refactor
// Step 5: Commit
```

### 2. Entity Design (Domain Layer)

Entities are pure Dart classes with business logic, no framework dependencies.

```dart
// domain/entities/biomarker.dart
import 'package:equatable/equatable.dart';

class Biomarker extends Equatable {
  final String id;
  final String name;
  final double value;
  final String unit;
  final ReferenceRange referenceRange;
  final DateTime measuredAt;

  const Biomarker({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.referenceRange,
    required this.measuredAt,
  });

  bool get isOutOfRange => referenceRange.isOutOfRange(value);

  BiomarkerStatus get status {
    if (value < referenceRange.min) return BiomarkerStatus.low;
    if (value > referenceRange.max) return BiomarkerStatus.high;
    return BiomarkerStatus.normal;
  }

  @override
  List<Object?> get props => [id, name, value, unit, referenceRange, measuredAt];
}

enum BiomarkerStatus { low, normal, high }
```

**Health Log Entity (Phase 6):**

```dart
// domain/entities/health_log.dart
import 'package:equatable/equatable.dart';

class HealthLog extends Equatable implements HealthEntry {
  final String id;
  final DateTime timestamp;
  final List<VitalMeasurement> vitals;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HealthLog({
    required this.id,
    required this.timestamp,
    required this.vitals,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  HealthEntryType get entryType => HealthEntryType.healthLog;

  @override
  String get displayTitle => 'Health Log';

  @override
  bool get hasWarnings {
    return vitals.any((v) => v.status != VitalStatus.normal);
  }

  HealthLog copyWith({
    String? id,
    DateTime? timestamp,
    List<VitalMeasurement>? vitals,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      vitals: vitals ?? this.vitals,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, timestamp, vitals, notes, createdAt, updatedAt];
}

// Unified timeline interface
abstract class HealthEntry {
  String get id;
  DateTime get timestamp;
  HealthEntryType get entryType;
  String get displayTitle;
  bool get hasWarnings;
}

enum HealthEntryType {
  labReport,
  healthLog,
}
```

**Vital Measurement Entity:**

```dart
// domain/entities/vital_measurement.dart
class VitalMeasurement extends Equatable {
  final String id;
  final VitalType type;
  final double value;
  final String unit;
  final VitalStatus status;
  final ReferenceRange? referenceRange;

  const VitalMeasurement({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.status,
    this.referenceRange,
  });

  bool get isOutOfRange => status != VitalStatus.normal;

  @override
  List<Object?> get props => [id, type, value, unit, status, referenceRange];
}

enum VitalType {
  bloodPressureSystolic,
  bloodPressureDiastolic,
  oxygenSaturation,      // SpO2
  heartRate,
  bodyTemperature,
  weight,
  bloodGlucose,
  sleepHours,
  medicationAdherence,
  respiratoryRate,
  energyLevel,           // 1-10 scale
}

enum VitalStatus {
  normal,    // Within reference range
  warning,   // Slightly outside range
  critical,  // Significantly outside range
}
```

### 3. Repository Pattern (Domain + Data)

**Domain Layer (Interface):**
```dart
// domain/repositories/report_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/report.dart';
import '../../core/error/failures.dart';

abstract class ReportRepository {
  Future<Either<Failure, Report>> saveReport(Report report);
  Future<Either<Failure, List<Report>>> getAllReports();
  Future<Either<Failure, Report>> getReportById(String id);
  Future<Either<Failure, void>> deleteReport(String id);
  Future<Either<Failure, List<Biomarker>>> getBiomarkerTrend(
    String biomarkerName,
    {DateTime? startDate, DateTime? endDate}
  );
}
```

**Data Layer (Implementation):**
```dart
// data/repositories/report_repository_impl.dart
import 'package:injectable/injectable.dart';
import '../../domain/repositories/report_repository.dart';

@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource localDataSource;

  const ReportRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Report>> saveReport(Report report) async {
    try {
      final reportModel = ReportModel.fromEntity(report);
      await localDataSource.saveReport(reportModel);
      return Right(report);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  // ... other methods
}
```

### 4. UseCase Pattern

Each usecase should have a single responsibility and return `Either<Failure, T>`.

```dart
// domain/usecases/extract_report_from_file.dart
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

@lazySingleton
class ExtractReportFromFile {
  final OcrService ocrService;
  final LlmExtractionService llmService;
  final NormalizeBiomarkerName normalizeBiomarker;

  const ExtractReportFromFile({
    required this.ocrService,
    required this.llmService,
    required this.normalizeBiomarker,
  });

  Future<Either<Failure, Report>> call(String filePath) async {
    try {
      // 1. Extract text via OCR
      final extractedText = await ocrService.extractText(filePath);

      // 2. Parse structured data via LLM (if configured)
      final structuredData = await llmService.extractBiomarkers(extractedText);

      // 3. Normalize biomarker names
      final normalizedBiomarkers = structuredData.biomarkers.map((b) {
        final normalizedName = normalizeBiomarker(b.name);
        return b.copyWith(name: normalizedName);
      }).toList();

      // 4. Build Report entity
      final report = Report(
        id: generateId(),
        date: structuredData.reportDate,
        labName: structuredData.labName,
        biomarkers: normalizedBiomarkers,
        originalFilePath: filePath,
      );

      return Right(report);
    } on OcrException catch (e) {
      return Left(OcrFailure(message: e.message));
    } on LlmException catch (e) {
      return Left(LlmFailure(message: e.message));
    }
  }
}
```

### 5. Riverpod Providers

Use manual providers for simplicity (no code generation needed).

```dart
// presentation/providers/report_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/report.dart';
import '../../domain/usecases/get_all_reports.dart';
import '../../domain/usecases/extract_report_from_file.dart';
import '../../domain/usecases/save_report.dart';

// Provider for fetching all reports
final reportListProvider = FutureProvider<List<Report>>((ref) async {
  final getReports = getIt<GetAllReports>();
  final result = await getReports();
  return result.fold(
    (failure) => throw failure,
    (reports) => reports,
  );
});

// Provider for filtered reports
final filteredReportsProvider = Provider.family<List<Report>, bool>((ref, showOnlyOutOfRange) {
  final reportsAsync = ref.watch(reportListProvider);

  return reportsAsync.when(
    data: (reports) {
      if (!showOnlyOutOfRange) return reports;
      return reports.where((r) => r.hasOutOfRangeBiomarkers).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// StateNotifier for managing report operations
class ReportNotifier extends StateNotifier<AsyncValue<List<Report>>> {
  ReportNotifier() : super(const AsyncValue.loading()) {
    _loadReports();
  }

  Future<void> _loadReports() async {
    final getReports = getIt<GetAllReports>();
    final result = await getReports();
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (reports) => AsyncValue.data(reports),
    );
  }

  Future<void> addReport(String filePath) async {
    state = const AsyncValue.loading();
    final extractReport = getIt<ExtractReportFromFile>();
    final saveReport = getIt<SaveReport>();

    final extractResult = await extractReport(filePath);
    await extractResult.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (report) async {
        final saveResult = await saveReport(report);
        await saveResult.fold(
          (failure) => state = AsyncValue.error(failure, StackTrace.current),
          (_) => _loadReports(), // Refresh list
        );
      },
    );
  }
}

final reportNotifierProvider = StateNotifierProvider<ReportNotifier, AsyncValue<List<Report>>>(
  (ref) => ReportNotifier(),
);
```

### 6. Dependency Injection with get_it + injectable

**Setup:**
```dart
// core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

**Usage in annotations:**
```dart
@lazySingleton  // Single instance, lazy initialization
@singleton      // Single instance, eager initialization
@injectable     // New instance per injection
@LazySingleton(as: ReportRepository)  // Interface binding
```

---

## Biomarker Normalization Rules

Common variations that should map to the same biomarker:

```dart
final biomarkerNormalizationMap = {
  // Electrolytes
  'Na': 'Sodium',
  'Na+': 'Sodium',
  'SODIUM': 'Sodium',
  'K': 'Potassium',
  'K+': 'Potassium',
  'POTASSIUM': 'Potassium',
  'Cl': 'Chloride',
  'Cl-': 'Chloride',

  // Blood count
  'Hb': 'Hemoglobin',
  'HB': 'Hemoglobin',
  'HEMOGLOBIN': 'Hemoglobin',
  'WBC': 'White Blood Cells',
  'TLC': 'White Blood Cells',
  'RBC': 'Red Blood Cells',

  // Lipids
  'CHOL': 'Total Cholesterol',
  'TC': 'Total Cholesterol',
  'LDL-C': 'LDL Cholesterol',
  'HDL-C': 'HDL Cholesterol',
  'TG': 'Triglycerides',

  // Liver
  'SGOT': 'AST',
  'SGPT': 'ALT',
  'ALK PHOS': 'Alkaline Phosphatase',
  'ALP': 'Alkaline Phosphatase',

  // Kidney
  'BUN': 'Blood Urea Nitrogen',
  'CREAT': 'Creatinine',
  'Cr': 'Creatinine',

  // Add more as needed...
};
```

---

## Testing Strategy

### Unit Tests (90% Coverage)

**File naming:** `test/unit/<layer>/<file>_test.dart`

```dart
// test/unit/domain/usecases/extract_report_from_file_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOcrService extends Mock implements OcrService {}
class MockLlmService extends Mock implements LlmExtractionService {}

void main() {
  late ExtractReportFromFile usecase;
  late MockOcrService mockOcrService;
  late MockLlmService mockLlmService;

  setUp(() {
    mockOcrService = MockOcrService();
    mockLlmService = MockLlmService();
    usecase = ExtractReportFromFile(
      ocrService: mockOcrService,
      llmService: mockLlmService,
    );
  });

  group('ExtractReportFromFile', () {
    const filePath = '/path/to/report.pdf';
    const extractedText = 'Sample report text...';

    test('should extract text from file using OCR', () async {
      // Arrange
      when(() => mockOcrService.extractText(any()))
          .thenAnswer((_) async => extractedText);
      when(() => mockLlmService.extractBiomarkers(any()))
          .thenAnswer((_) async => tStructuredData);

      // Act
      await usecase(filePath);

      // Assert
      verify(() => mockOcrService.extractText(filePath)).called(1);
    });

    test('should return Report on successful extraction', () async {
      // Arrange
      when(() => mockOcrService.extractText(any()))
          .thenAnswer((_) async => extractedText);
      when(() => mockLlmService.extractBiomarkers(any()))
          .thenAnswer((_) async => tStructuredData);

      // Act
      final result = await usecase(filePath);

      // Assert
      expect(result, isA<Right<Failure, Report>>());
    });

    test('should return OcrFailure when OCR fails', () async {
      // Arrange
      when(() => mockOcrService.extractText(any()))
          .thenThrow(OcrException('Failed to extract'));

      // Act
      final result = await usecase(filePath);

      // Assert
      expect(result, isA<Left<Failure, Report>>());
      result.fold(
        (failure) => expect(failure, isA<OcrFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
```

### Widget Tests

```dart
// test/widget/pages/home_page_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('HomePage displays list of reports', (tester) async {
    // Arrange
    final container = ProviderContainer(
      overrides: [
        reportListProvider.overrideWith((ref) => AsyncValue.data(tReports)),
      ],
    );

    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomePage()),
      ),
    );

    // Assert
    expect(find.text('Blood Report Tracker'), findsOneWidget);
    expect(find.byType(ReportCard), findsNWidgets(tReports.length));
  });
}
```

---

## Git Commit Conventions

Follow conventional commits format:

```
feat: add biomarker trend chart
test: add unit tests for ExtractReportFromFile
fix: resolve normalization issue for sodium variants
refactor: extract chart logic into separate widget
docs: update AGENTS.md with testing examples
chore: update dependencies
```

**Commit frequency:** After each passing test + implementation pair.

---

## Changelog Maintenance

All project changes must be documented in `CHANGELOG.md` in the project root directory.

### When to Update CHANGELOG.md

Update the changelog:
- After each commit or group of related commits
- When completing a feature
- When fixing bugs
- When making breaking changes
- When updating dependencies

### Changelog Format

Follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format:

```markdown
## [Unreleased]

### Added
- New features go here
- Domain entities: ReferenceRange, Biomarker, Report with comprehensive test coverage

### Changed
- Changes to existing functionality
- Updated package X from version Y to Z

### Fixed
- Bug fixes
- Resolved issue with biomarker normalization

### Removed
- Removed features/code

## [0.1.0] - 2025-10-15

### Added
- Initial Flutter project structure
- Clean architecture setup
...

## Git Commit History

### Domain Entities (TDD)

#### 2025-10-15 - Report Entity
- `36ba890` - docs: update phase-1 tasks with Report entity completion
- `2ee1717` - feat: implement Report entity with biomarker aggregation
- `eef6412` - test: add comprehensive tests for Report entity
```

### Changelog Update Workflow

1. **After committing code:**
   ```bash
   # 1. Make your changes
   # 2. Commit with conventional commit message
   git commit -m "feat: implement Report entity with biomarker aggregation"

   # 3. Update CHANGELOG.md immediately
   # Add entry under [Unreleased] section
   # Include commit hash, type, and description
   ```

2. **Grouping related commits:**
   - Group related commits by feature/area
   - Use date-based subsections for organization
   - Include all commit hashes for traceability

3. **Before creating a release:**
   - Move all `[Unreleased]` entries to a new version section
   - Add release date
   - Update version number following semantic versioning

### Example Entry

```markdown
## [Unreleased]

### Added
- Domain entities with 100% test coverage:
  - Report entity with biomarker filtering capabilities (commit 2ee1717)
  - Biomarker entity with status logic (commit 31e0af4)
  - ReferenceRange value object (commit ed227d3)

### Changed
- Updated all task files with completion status (commit 36ba890)
```

### Important Notes

- **Always update CHANGELOG.md** - It's part of the definition of done
- **Be descriptive** - Future you (and others) will thank you
- **Include commit hashes** - Makes it easy to find exact changes
- **Group by type** - Added, Changed, Fixed, Removed
- **Write for humans** - Explain what and why, not just the code change

---

## File Upload & OCR Flow

```
User selects file
    ↓
PdfService.convertToImages()  (if PDF)
    ↓
OcrService.extractText()  (ML Kit)
    ↓
LlmExtractionService.extractBiomarkers()  (optional, if API key configured)
    ↓
NormalizeBiomarkerName.normalize()  (for each biomarker)
    ↓
Display ReviewPage with editable fields
    ↓
User confirms/edits
    ↓
SaveReport.call()
    ↓
HiveDatabase stores ReportModel
```

---

## Error Handling

All repository methods return `Either<Failure, T>`:

```dart
// core/error/failures.dart
abstract class Failure extends Equatable {
  final String message;
  const Failure([this.message = 'An error occurred']);

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure']);
}

class OcrFailure extends Failure {
  const OcrFailure({required String message}) : super(message);
}

class LlmFailure extends Failure {
  const LlmFailure({required String message}) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message);
}
```

```dart
// core/error/exceptions.dart
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache exception']);
}

class OcrException implements Exception {
  final String message;
  const OcrException(this.message);
}

class LlmException implements Exception {
  final String message;
  const LlmException(this.message);
}
```

---

## UI/UX Guidelines

### Material Design 3
- Use Material 3 components (Material Design 3)
- Support light and dark themes
- Color scheme based on health/medical context (calming blues/greens)

### Color Coding for Biomarkers
```dart
Color getBiomarkerColor(BiomarkerStatus status) {
  switch (status) {
    case BiomarkerStatus.low:
      return Colors.orange.shade700;
    case BiomarkerStatus.high:
      return Colors.red.shade700;
    case BiomarkerStatus.normal:
      return Colors.green.shade700;
  }
}
```

### Accessibility
- Semantic labels for screen readers
- Minimum touch target size: 48x48
- Color contrast ratios: 4.5:1 (text), 3:1 (UI components)

---

## LLM Integration for Data Extraction

### Prompt Template

```
You are a medical data extraction assistant. Extract structured biomarker data from the following blood test report text.

Report Text:
{extracted_ocr_text}

Output Format (JSON):
{
  "reportDate": "YYYY-MM-DD",
  "labName": "Lab Name",
  "biomarkers": [
    {
      "name": "Biomarker Name",
      "value": 123.45,
      "unit": "mg/dL",
      "referenceMin": 80.0,
      "referenceMax": 120.0
    }
  ]
}

Rules:
1. Normalize biomarker names (e.g., "Hb" → "Hemoglobin")
2. Extract numeric values only
3. Include reference ranges when available
4. Return valid JSON only
```

### Configuration Storage (Hive)

```dart
@HiveType(typeId: 1)
class AppConfig {
  @HiveField(0)
  final String? openAiApiKey;

  @HiveField(1)
  final String? geminiApiKey;

  @HiveField(2)
  final bool useLlmExtraction;

  @HiveField(3)
  final bool darkModeEnabled;
}
```

---

## Phase-by-Phase Implementation Guide

### Phase 1: Foundation & OCR Upload

**Test-first tasks:**
1. Write tests for Biomarker entity
2. Implement Biomarker entity
3. Write tests for Report entity
4. Implement Report entity
5. Write tests for OcrService
6. Implement OcrService (ML Kit)
7. Write tests for ExtractReportFromFile usecase
8. Implement ExtractReportFromFile usecase
9. Write tests for SaveReport usecase
10. Implement SaveReport usecase
11. Write tests for HiveDatabase
12. Implement HiveDatabase
13. Write widget tests for UploadPage
14. Implement UploadPage UI
15. Write widget tests for ReviewPage
16. Implement ReviewPage UI

**Git commits:** After each test-implementation pair (30+ commits expected)

---

## Phase 6 Examples: Daily Health Tracking

### Health Log Entity Usage

```dart
// domain/entities/health_log.dart
import 'package:equatable/equatable.dart';
import 'vital_measurement.dart';
import 'health_entry.dart';

class HealthLog extends Equatable implements HealthEntry {
  final String id;
  final DateTime timestamp;
  final List<VitalMeasurement> vitals;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HealthLog({
    required this.id,
    required this.timestamp,
    required this.vitals,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  HealthEntryType get entryType => HealthEntryType.healthLog;

  @override
  String get displayTitle => 'Health Log';

  @override
  bool get hasWarnings {
    return vitals.any((v) => v.status != VitalStatus.normal);
  }

  HealthLog copyWith({
    String? id,
    DateTime? timestamp,
    List<VitalMeasurement>? vitals,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      vitals: vitals ?? this.vitals,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, timestamp, vitals, notes, createdAt, updatedAt];
}
```

### VitalMeasurement Creation with Reference Ranges

```dart
// Example: Creating vital measurements with automatic status calculation
import 'package:uuid/uuid.dart';
import '../../domain/entities/vital_measurement.dart';
import '../../domain/entities/vital_reference_defaults.dart';

VitalMeasurement createVitalMeasurement({
  required VitalType type,
  required double value,
}) {
  final unit = VitalReferenceDefaults.getUnit(type);
  final referenceRange = VitalReferenceDefaults.getDefault(type);
  final status = VitalReferenceDefaults.calculateStatus(type, value);

  return VitalMeasurement(
    id: const Uuid().v4(),
    type: type,
    value: value,
    unit: unit,
    status: status,
    referenceRange: referenceRange,
  );
}

// Usage example
void main() {
  // Normal BP reading
  final systolic = createVitalMeasurement(
    type: VitalType.bloodPressureSystolic,
    value: 115.0,  // Within 90-120 range
  );
  print(systolic.status);  // VitalStatus.normal

  // High heart rate
  final heartRate = createVitalMeasurement(
    type: VitalType.heartRate,
    value: 105.0,  // Above 100 bpm
  );
  print(heartRate.status);  // VitalStatus.warning or critical
}
```

### Timeline Aggregation Repository Pattern

```dart
// data/repositories/timeline_repository_impl.dart
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../domain/repositories/timeline_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/repositories/health_log_repository.dart';
import '../../domain/entities/health_entry.dart';

@LazySingleton(as: TimelineRepository)
class TimelineRepositoryImpl implements TimelineRepository {
  final ReportRepository reportRepository;
  final HealthLogRepository healthLogRepository;

  const TimelineRepositoryImpl({
    required this.reportRepository,
    required this.healthLogRepository,
  });

  @override
  Future<Either<Failure, List<HealthEntry>>> getUnifiedTimeline({
    DateTime? startDate,
    DateTime? endDate,
    HealthEntryType? filterType,
  }) async {
    try {
      final entries = <HealthEntry>[];

      // Fetch reports if not filtered to health logs only
      if (filterType != HealthEntryType.healthLog) {
        final reportsResult = await reportRepository.getAllReports();
        reportsResult.fold(
          (failure) => throw CacheException(),
          (reports) => entries.addAll(reports),
        );
      }

      // Fetch health logs if not filtered to reports only
      if (filterType != HealthEntryType.labReport) {
        final logsResult = await healthLogRepository.getAllHealthLogs();
        logsResult.fold(
          (failure) => throw CacheException(),
          (logs) => entries.addAll(logs),
        );
      }

      // Filter by date range
      var filtered = entries;
      if (startDate != null) {
        filtered = filtered.where((e) => e.timestamp.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        filtered = filtered.where((e) => e.timestamp.isBefore(endDate)).toList();
      }

      // Sort by timestamp descending (newest first)
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return Right(filtered);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
```

### Riverpod Provider Patterns for Health Logs

```dart
// presentation/providers/health_log_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/health_log.dart';
import '../../domain/usecases/get_all_health_logs.dart';
import '../../domain/usecases/create_health_log.dart';
import '../../domain/usecases/update_health_log.dart';
import '../../domain/usecases/delete_health_log.dart';

part 'health_log_provider.g.dart';

@riverpod
class HealthLogs extends _$HealthLogs {
  @override
  Future<List<HealthLog>> build() async {
    return _loadHealthLogs();
  }

  Future<List<HealthLog>> _loadHealthLogs() async {
    final getAllLogs = getIt<GetAllHealthLogs>();
    final result = await getAllLogs();

    return result.fold(
      (failure) => throw failure,
      (logs) => logs,
    );
  }

  Future<void> addHealthLog(HealthLog log) async {
    // Set state to loading
    state = const AsyncValue.loading();

    final createLog = getIt<CreateHealthLog>();
    final result = await createLog(log);

    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) async {
        // Refresh the list
        state = await AsyncValue.guard(() => _loadHealthLogs());
      },
    );
  }

  Future<void> updateHealthLog(HealthLog log) async {
    state = const AsyncValue.loading();

    final updateLog = getIt<UpdateHealthLog>();
    final result = await updateLog(log);

    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) async {
        state = await AsyncValue.guard(() => _loadHealthLogs());
      },
    );
  }

  Future<void> deleteHealthLog(String id) async {
    state = const AsyncValue.loading();

    final deleteLog = getIt<DeleteHealthLog>();
    final result = await deleteLog(id);

    await result.fold(
      (failure) async {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) async {
        state = await AsyncValue.guard(() => _loadHealthLogs());
      },
    );
  }
}

// Usage in a widget
class HealthLogsListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthLogsAsync = ref.watch(healthLogsProvider);

    return healthLogsAsync.when(
      data: (logs) => ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return HealthLogCard(log: log);
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Health Log Detail Page Widget Example

```dart
// presentation/pages/health_log/health_log_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/health_log.dart';
import '../../domain/entities/vital_measurement.dart';
import '../../providers/health_log_provider.dart';
import 'package:intl/intl.dart';

class HealthLogDetailPage extends ConsumerWidget {
  const HealthLogDetailPage({
    super.key,
    required this.log,
  });

  final HealthLog log;

  static final DateFormat _timestampFormatter =
      DateFormat('MMM d, yyyy • h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Log Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => _onEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: () => _onDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimestampCard(context),
            const SizedBox(height: 16),
            ..._buildVitalCards(context),
            if (log.notes != null && log.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildNotesCard(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVitalCard(BuildContext context, VitalMeasurement vital) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(vital.status);
    final statusEmoji = _getStatusEmoji(vital.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, name, and status
            Row(
              children: [
                Text(
                  vital.type.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vital.type.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  statusEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Value and unit
            Text(
              '${_formatValue(vital.value)} ${vital.unit}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Reference range if available
            if (vital.referenceRange != null) ...[
              const SizedBox(height: 8),
              Text(
                'Reference: ${_formatValue(vital.referenceRange!.min)}-${_formatValue(vital.referenceRange!.max)} ${vital.unit}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(VitalStatus status) {
    switch (status) {
      case VitalStatus.normal:
        return Colors.green.shade700;
      case VitalStatus.warning:
        return Colors.orange.shade700;
      case VitalStatus.critical:
        return Colors.red.shade700;
    }
  }

  String _getStatusEmoji(VitalStatus status) {
    switch (status) {
      case VitalStatus.normal:
        return '🟢';
      case VitalStatus.warning:
        return '🟡';
      case VitalStatus.critical:
        return '🔴';
    }
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Health Log'),
        content: const Text(
          'Are you sure you want to delete this health log? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(healthLogsProvider.notifier).deleteHealthLog(log.id);

    if (!context.mounted) return;

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Health log deleted.')),
    );
  }
}
```

### Vital Trend Chart Widget with Dual-Line Support

```dart
// presentation/widgets/vital_trend_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/vital_measurement.dart';

/// A chart widget that displays vital sign trends with dual-line support for BP
class VitalTrendChart extends StatelessWidget {
  final List<VitalMeasurement> measurements;
  final VitalType vitalType;
  final List<DateTime> dates;
  final bool showStatistics;

  const VitalTrendChart({
    super.key,
    required this.measurements,
    required this.vitalType,
    required this.dates,
    this.showStatistics = false,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return _buildEmptyState();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Vital trend chart for ${vitalType.displayName}',
      child: Column(
        children: [
          if (_isBloodPressure) _buildLegend(colorScheme),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                _buildLineChartData(colorScheme),
              ),
            ),
          ),
          if (showStatistics) _buildStatistics(colorScheme),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(ColorScheme colorScheme) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _calculateInterval(),
      ),
      titlesData: _buildTitlesData(colorScheme),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      lineBarsData: _buildLineBarsData(colorScheme),
      extraLinesData: _buildExtraLinesData(colorScheme),
      lineTouchData: _buildTouchData(colorScheme),
      minX: 0,
      maxX: (dates.length - 1).toDouble(),
      minY: _calculateMinY(),
      maxY: _calculateMaxY(),
    );
  }

  List<LineChartBarData> _buildLineBarsData(ColorScheme colorScheme) {
    if (_isBloodPressure) {
      // Dual-line chart for blood pressure
      return [
        _buildSystolicLine(colorScheme),
        _buildDiastolicLine(colorScheme),
      ];
    }

    return [_buildSingleLine(colorScheme)];
  }

  LineChartBarData _buildSystolicLine(ColorScheme colorScheme) {
    final systolicMeasurements = measurements
        .where((m) => m.type == VitalType.bloodPressureSystolic)
        .toList();

    final spots = <FlSpot>[];
    for (int i = 0; i < systolicMeasurements.length; i++) {
      spots.add(FlSpot(i.toDouble(), systolicMeasurements[i].value));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Colors.red[600],
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final status = systolicMeasurements[index].status;
          final color = _getStatusColor(status);

          return FlDotCirclePainter(
            radius: 6,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
    );
  }

  LineChartBarData _buildDiastolicLine(ColorScheme colorScheme) {
    final diastolicMeasurements = measurements
        .where((m) => m.type == VitalType.bloodPressureDiastolic)
        .toList();

    final spots = <FlSpot>[];
    for (int i = 0; i < diastolicMeasurements.length; i++) {
      spots.add(FlSpot(i.toDouble(), diastolicMeasurements[i].value));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Colors.blue[600],
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final status = diastolicMeasurements[index].status;
          final color = _getStatusColor(status);

          return FlDotCirclePainter(
            radius: 6,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
    );
  }

  bool get _isBloodPressure =>
      vitalType == VitalType.bloodPressureSystolic ||
      vitalType == VitalType.bloodPressureDiastolic;
}
```

---

## Common Pitfalls to Avoid

1. **Writing code before tests** - Always TDD
2. **Mixing layers** - Domain should never import from data/presentation
3. **God objects** - Keep classes single-responsibility
4. **Forgetting to normalize** - Always normalize biomarker names
5. **Hardcoding strings** - Use constants
6. **Missing error handling** - Always use Either<Failure, T>
7. **Not updating docs** - Update /spec files with each phase completion

---

## Quick Reference Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# Code generation (Riverpod, injectable, Hive)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for development
dart run build_runner watch --delete-conflicting-outputs

# Analyze code
flutter analyze

# Format code
dart format .

# Run on specific platform
flutter run -d chrome     # Web
flutter run -d macos      # macOS
flutter run               # Connected device
```

---

## Resources

- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Documentation](https://riverpod.dev)
- [get_it Documentation](https://pub.dev/packages/get_it)
- [Hive Documentation](https://docs.hivedb.dev)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Material Design 3](https://m3.material.io)

---

**Last Updated:** 2025-10-19
**Version:** 1.1 (Added Phase 6 examples)
**Maintainer:** AI Agent Context Guide
