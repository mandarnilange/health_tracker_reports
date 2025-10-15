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
  flutter_riverpod: ^2.5.1        # State management
  riverpod_annotation: ^2.3.5     # Code generation for providers
  get_it: ^7.6.7                  # Dependency injection
  injectable: ^2.3.2              # DI code generation
  hive: ^2.2.3                    # Local database
  hive_flutter: ^1.1.0            # Hive Flutter integration
  go_router: ^14.0.2              # Routing

  # File & OCR
  file_picker: ^8.0.0             # File selection
  pdf_render: ^1.4.3              # PDF to image
  google_mlkit_text_recognition: ^0.11.0  # OCR
  image: ^4.1.7                   # Image processing

  # Charts & PDF
  fl_chart: ^0.68.0               # Charts
  pdf: ^3.10.8                    # PDF generation
  printing: ^5.12.0               # PDF sharing

  # Utilities
  intl: ^0.19.0                   # Internationalization
  equatable: ^2.0.5               # Value equality
  dartz: ^0.10.1                  # Functional programming (Either)

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.3                # Mocking
  build_runner: ^2.4.8            # Code generation
  injectable_generator: ^2.4.1    # DI generation
  riverpod_generator: ^2.4.0      # Provider generation
  hive_generator: ^2.0.1          # Hive adapters
  flutter_lints: ^3.0.1           # Linting
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

Use code generation for type safety and performance.

```dart
// presentation/providers/report_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/di/injection_container.dart';

part 'report_providers.g.dart';

@riverpod
class ReportList extends _$ReportList {
  @override
  Future<List<Report>> build() async {
    final getReports = getIt<GetAllReports>();
    final result = await getReports();
    return result.fold(
      (failure) => throw failure,
      (reports) => reports,
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
        saveResult.fold(
          (failure) => state = AsyncValue.error(failure, StackTrace.current),
          (_) => ref.invalidateSelf(), // Refresh list
        );
      },
    );
  }
}

@riverpod
class FilteredReports extends _$FilteredReports {
  @override
  List<Report> build(bool showOnlyOutOfRange) {
    final allReports = ref.watch(reportListProvider);

    return allReports.when(
      data: (reports) {
        if (!showOnlyOutOfRange) return reports;
        return reports.where((r) => r.hasOutOfRangeBiomarkers).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }
}
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

**Last Updated:** 2025-10-15
**Version:** 1.0
**Maintainer:** AI Agent Context Guide
