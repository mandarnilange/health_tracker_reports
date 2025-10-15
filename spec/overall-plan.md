# Health Tracker Reports - Overall Implementation Plan

## Project Vision
A privacy-first Flutter application for tracking blood test reports with automated OCR/LLM extraction, trend analysis, and professional report generation for healthcare providers.

---

## Core Requirements

### Functional Requirements
- Upload blood reports (PDF/images) with automated data extraction
- View all reports with summary (x/y parameters out of range)
- Filter biomarkers (all vs. out-of-range only)
- Visualize biomarker trends over time
- Add notes and reminders to reports
- Generate doctor-friendly PDF summaries
- Export data to CSV for backup
- Google Drive integration for CSV sync

### Non-Functional Requirements
- TDD mandatory: 90% code coverage minimum
- Clean Architecture with strict layer separation
- Local-first: All data in Hive database
- Cross-platform: iOS, Android, Web
- Material Design 3 with dark mode
- Privacy: No cloud storage except user-controlled exports

---

## Technical Architecture

### Technology Stack

```yaml
# Core
Flutter SDK: >=3.5.0
Dart: >=3.5.0

# State Management & DI
flutter_riverpod: ^2.5.1
riverpod_annotation: ^2.3.5
get_it: ^7.6.7
injectable: ^2.3.2

# Local Storage
hive: ^2.2.3
hive_flutter: ^1.1.0

# Routing
go_router: ^14.0.2

# File Handling & OCR
file_picker: ^8.0.0
pdf_render: ^1.4.3
google_mlkit_text_recognition: ^0.11.0
image: ^4.1.7

# Charts & PDF Generation
fl_chart: ^0.68.0
pdf: ^3.10.8
printing: ^5.12.0

# Utilities
intl: ^0.19.0
equatable: ^2.0.5
dartz: ^0.10.1
uuid: ^4.3.3

# Testing
mocktail: ^1.0.3
build_runner: ^2.4.8
injectable_generator: ^2.4.1
riverpod_generator: ^2.4.0
hive_generator: ^2.0.1
```

### Folder Structure

```
health_tracker_reports/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── di/
│   │   │   ├── injection_container.dart
│   │   │   └── injection_container.config.dart
│   │   ├── error/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── utils/
│   │   │   ├── constants.dart
│   │   │   ├── validators.dart
│   │   │   └── date_helpers.dart
│   │   └── network/
│   │       └── llm_client.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── biomarker.dart
│   │   │   ├── report.dart
│   │   │   ├── reference_range.dart
│   │   │   └── app_config.dart
│   │   ├── repositories/
│   │   │   ├── report_repository.dart
│   │   │   └── config_repository.dart
│   │   └── usecases/
│   │       ├── extract_report_from_file.dart
│   │       ├── save_report.dart
│   │       ├── get_all_reports.dart
│   │       ├── get_report_by_id.dart
│   │       ├── delete_report.dart
│   │       ├── get_biomarker_trend.dart
│   │       ├── normalize_biomarker_name.dart
│   │       ├── add_note_to_report.dart
│   │       ├── generate_doctor_pdf.dart
│   │       ├── export_to_csv.dart
│   │       └── update_config.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── biomarker_model.dart
│   │   │   ├── report_model.dart
│   │   │   ├── reference_range_model.dart
│   │   │   └── app_config_model.dart
│   │   ├── repositories/
│   │   │   ├── report_repository_impl.dart
│   │   │   └── config_repository_impl.dart
│   │   └── datasources/
│   │       ├── local/
│   │       │   ├── hive_database.dart
│   │       │   ├── report_local_datasource.dart
│   │       │   └── config_local_datasource.dart
│   │       └── external/
│   │           ├── ocr_service.dart
│   │           ├── pdf_service.dart
│   │           ├── llm_extraction_service.dart
│   │           └── drive_service.dart
│   │
│   └── presentation/
│       ├── app.dart
│       ├── router.dart
│       ├── theme/
│       │   ├── app_theme.dart
│       │   └── app_colors.dart
│       ├── providers/
│       │   ├── report_providers.dart
│       │   ├── config_providers.dart
│       │   ├── theme_provider.dart
│       │   └── filter_provider.dart
│       ├── pages/
│       │   ├── home/
│       │   │   ├── home_page.dart
│       │   │   └── widgets/
│       │   │       ├── report_card.dart
│       │   │       └── empty_state.dart
│       │   ├── upload/
│       │   │   ├── upload_page.dart
│       │   │   ├── review_page.dart
│       │   │   └── widgets/
│       │   │       ├── biomarker_edit_form.dart
│       │   │       └── extraction_loading.dart
│       │   ├── report_detail/
│       │   │   ├── report_detail_page.dart
│       │   │   └── widgets/
│       │   │       ├── biomarker_list_item.dart
│       │   │       ├── out_of_range_indicator.dart
│       │   │       └── notes_section.dart
│       │   ├── trends/
│       │   │   ├── trends_page.dart
│       │   │   └── widgets/
│       │   │       ├── trend_chart.dart
│       │   │       ├── time_range_selector.dart
│       │   │       └── biomarker_selector.dart
│       │   └── settings/
│       │       ├── settings_page.dart
│       │       └── widgets/
│       │           ├── api_key_input.dart
│       │           └── theme_toggle.dart
│       └── widgets/
│           ├── custom_app_bar.dart
│           ├── loading_indicator.dart
│           └── error_display.dart
│
├── test/
│   ├── unit/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── data/
│   │       ├── models/
│   │       ├── repositories/
│   │       └── datasources/
│   ├── widget/
│   │   └── pages/
│   └── integration/
│       └── flows/
│
├── spec/
│   ├── overall-plan.md (this file)
│   ├── phase-1-ocr-upload-tasks.md
│   ├── phase-2-viewing-tasks.md
│   ├── phase-3-trends-tasks.md
│   ├── phase-4-enhanced-ux-tasks.md
│   └── phase-5-export-sharing-tasks.md
│
├── AGENTS.md
├── .claude/
│   └── claude.md
├── pubspec.yaml
└── README.md
```

---

## Implementation Phases

### Phase 1: Foundation & OCR Upload (MVP)
**Delivers:** Automated report upload with OCR extraction

**Duration:** ~25-30 commits

**Key Features:**
- Flutter project scaffolding
- Clean architecture setup with DI
- Hive database configuration
- File picker integration
- PDF to image conversion
- OCR with Google ML Kit
- Basic LLM extraction (with optional API key)
- Review/edit extracted data screen
- Save to local database

**Success Criteria:**
- User can select PDF/image
- Data is automatically extracted
- User can review/edit before saving
- Report is stored locally
- 90%+ test coverage

**Task File:** `phase-1-ocr-upload-tasks.md`

**Status:** In Progress

---

### Phase 2: Reports Viewing & Filtering
**Delivers:** Browse reports and identify problematic biomarkers

**Duration:** ~12-15 commits

**Key Features:**
- Home page with reports list
- Report card UI (date, lab, x/y out of range summary)
- Report detail page
- Biomarker list with color coding (green/yellow/red)
- Filter toggle: all vs. out-of-range only
- Search within report
- Navigation with go_router

**Success Criteria:**
- User can view all reports chronologically
- Out-of-range biomarkers are visually distinct
- Filtering works correctly
- Navigation is smooth
- 90%+ test coverage

**Task File:** `phase-2-viewing-tasks.md`

---

### Phase 3: Biomarker Normalization & Trends
**Delivers:** Consistent tracking and visual trend analysis

**Duration:** ~10-12 commits

**Key Features:**
- Biomarker normalization service (Na→Sodium, etc.)
- Trend page with biomarker selector
- Line chart with fl_chart
- Reference range bands on chart
- Time range filters (3M, 6M, 1Y, All)
- Multi-report comparison view
- Trend indicators (↑↓→ with %)

**Success Criteria:**
- Biomarker names are normalized across reports
- Trends display correctly over time
- Charts are interactive and readable
- Time filters work accurately
- 90%+ test coverage

**Task File:** `phase-3-trends-tasks.md`

---

### Phase 4: Enhanced UX Features
**Delivers:** Improved usability and customization

**Duration:** ~8-10 commits

**Key Features:**
- Add/edit notes on reports
- Set reminders for next blood test
- Delete reports with confirmation
- Dark/light theme toggle
- Settings page (API keys, preferences)
- Onboarding flow for new users
- Improved error handling UI

**Success Criteria:**
- Notes persist correctly
- Reminders trigger notifications
- Dark mode works seamlessly
- Settings are saved and applied
- 90%+ test coverage

**Task File:** `phase-4-enhanced-ux-tasks.md`

---

### Phase 5: Export, Backup & Sharing
**Delivers:** Data portability and professional reporting

**Duration:** ~10-12 commits

**Key Features:**
- Export all data to CSV
- Google Drive integration for CSV backup
- Doctor summary PDF generator:
  - Multi-report comparison table
  - Highlighted out-of-range values
  - Trend indicators with comments
  - Professional formatting
- Native share functionality
- Import CSV (restore from backup)

**Success Criteria:**
- CSV export contains all data
- Google Drive sync works reliably
- Doctor PDF is professional and readable
- Share works on all platforms
- 90%+ test coverage

**Task File:** `phase-5-export-sharing-tasks.md`

---

## Development Workflow

### TDD Cycle (MANDATORY)

```
1. Write failing test (RED)
2. Run test - should FAIL
3. Write minimal code to pass (GREEN)
4. Run test - should PASS
5. Refactor if needed
6. Commit with descriptive message
7. Update task file with checkbox
8. Update changelog below
```

### Code Review Checklist

Before each commit:
- [ ] All tests pass
- [ ] Coverage >= 90%
- [ ] Code follows clean architecture
- [ ] No business logic in presentation layer
- [ ] Repository returns Either<Failure, T>
- [ ] Entities are immutable and pure
- [ ] Dependencies injected via constructor
- [ ] Comments only where necessary
- [ ] Task file updated
- [ ] Changelog updated

---

## Biomarker Normalization Dictionary

```dart
// Maintained in: lib/domain/usecases/normalize_biomarker_name.dart

const biomarkerNormalization = {
  // Electrolytes
  'NA': 'Sodium', 'Na': 'Sodium', 'Na+': 'Sodium', 'SODIUM': 'Sodium',
  'K': 'Potassium', 'K+': 'Potassium', 'POTASSIUM': 'Potassium',
  'CL': 'Chloride', 'Cl': 'Chloride', 'Cl-': 'Chloride', 'CHLORIDE': 'Chloride',
  'CA': 'Calcium', 'Ca': 'Calcium', 'Ca++': 'Calcium', 'CALCIUM': 'Calcium',
  'MG': 'Magnesium', 'Mg': 'Magnesium', 'Mg++': 'Magnesium',

  // Complete Blood Count
  'HB': 'Hemoglobin', 'Hb': 'Hemoglobin', 'HEMOGLOBIN': 'Hemoglobin',
  'WBC': 'White Blood Cells', 'TLC': 'White Blood Cells', 'WHITE BLOOD CELLS': 'White Blood Cells',
  'RBC': 'Red Blood Cells', 'RED BLOOD CELLS': 'Red Blood Cells',
  'PLT': 'Platelets', 'PLATELET': 'Platelets', 'PLATELET COUNT': 'Platelets',
  'HCT': 'Hematocrit', 'HEMATOCRIT': 'Hematocrit',
  'MCV': 'Mean Corpuscular Volume', 'MEAN CORPUSCULAR VOLUME': 'Mean Corpuscular Volume',
  'MCH': 'Mean Corpuscular Hemoglobin',
  'MCHC': 'Mean Corpuscular Hemoglobin Concentration',

  // Lipid Panel
  'CHOL': 'Total Cholesterol', 'TC': 'Total Cholesterol', 'TOTAL CHOLESTEROL': 'Total Cholesterol',
  'LDL': 'LDL Cholesterol', 'LDL-C': 'LDL Cholesterol', 'LDL CHOLESTEROL': 'LDL Cholesterol',
  'HDL': 'HDL Cholesterol', 'HDL-C': 'HDL Cholesterol', 'HDL CHOLESTEROL': 'HDL Cholesterol',
  'TG': 'Triglycerides', 'TRIGLYCERIDES': 'Triglycerides', 'TRIG': 'Triglycerides',
  'VLDL': 'VLDL Cholesterol', 'VLDL-C': 'VLDL Cholesterol',

  // Liver Function
  'SGOT': 'AST', 'AST': 'AST', 'ASPARTATE AMINOTRANSFERASE': 'AST',
  'SGPT': 'ALT', 'ALT': 'ALT', 'ALANINE AMINOTRANSFERASE': 'ALT',
  'ALP': 'Alkaline Phosphatase', 'ALK PHOS': 'Alkaline Phosphatase', 'ALKALINE PHOSPHATASE': 'Alkaline Phosphatase',
  'BILI': 'Bilirubin', 'BILIRUBIN': 'Bilirubin', 'TOTAL BILIRUBIN': 'Total Bilirubin',
  'ALBUMIN': 'Albumin', 'ALB': 'Albumin',
  'TP': 'Total Protein', 'TOTAL PROTEIN': 'Total Protein',

  // Kidney Function
  'BUN': 'Blood Urea Nitrogen', 'BLOOD UREA NITROGEN': 'Blood Urea Nitrogen',
  'CREAT': 'Creatinine', 'CR': 'Creatinine', 'CREATININE': 'Creatinine',
  'UA': 'Uric Acid', 'URIC ACID': 'Uric Acid',
  'EGFR': 'eGFR', 'eGFR': 'eGFR',

  // Diabetes
  'GLUC': 'Glucose', 'GLU': 'Glucose', 'GLUCOSE': 'Glucose', 'FBS': 'Fasting Glucose',
  'HBA1C': 'HbA1c', 'HbA1c': 'HbA1c', 'A1C': 'HbA1c', 'HEMOGLOBIN A1C': 'HbA1c',

  // Thyroid
  'TSH': 'TSH', 'THYROID STIMULATING HORMONE': 'TSH',
  'T3': 'T3', 'TRIIODOTHYRONINE': 'T3',
  'T4': 'T4', 'THYROXINE': 'T4',
  'FT3': 'Free T3', 'FREE T3': 'Free T3',
  'FT4': 'Free T4', 'FREE T4': 'Free T4',

  // Vitamins
  'VIT D': 'Vitamin D', 'VITAMIN D': 'Vitamin D', '25-OH VIT D': 'Vitamin D',
  'VIT B12': 'Vitamin B12', 'VITAMIN B12': 'Vitamin B12', 'B12': 'Vitamin B12',
  'FOLATE': 'Folate', 'FOLIC ACID': 'Folate',

  // Iron Studies
  'FE': 'Iron', 'IRON': 'Iron', 'SERUM IRON': 'Serum Iron',
  'FERRITIN': 'Ferritin', 'SERUM FERRITIN': 'Ferritin',
  'TIBC': 'TIBC', 'TOTAL IRON BINDING CAPACITY': 'TIBC',

  // Inflammation
  'CRP': 'C-Reactive Protein', 'C-REACTIVE PROTEIN': 'C-Reactive Protein',
  'ESR': 'ESR', 'ERYTHROCYTE SEDIMENTATION RATE': 'ESR',
};
```

---

## Changelog

For detailed changelog with all commits and changes, see [CHANGELOG.md](../CHANGELOG.md).

The changelog follows [Keep a Changelog](https://keepachangelog.com/) format and includes:
- All commits with descriptions and hashes
- Package version updates
- Feature additions and changes
- Bug fixes and refactoring
- Breaking changes

**Note:** Update CHANGELOG.md after each significant commit or group of related commits.

---

## Testing Standards

### Unit Test Template

```dart
void main() {
  late ClassName classUnderTest;
  late MockDependency mockDependency;

  setUp(() {
    mockDependency = MockDependency();
    classUnderTest = ClassName(dependency: mockDependency);
  });

  group('ClassName', () {
    test('should do something when condition is met', () async {
      // Arrange
      when(() => mockDependency.method()).thenAnswer((_) async => result);

      // Act
      final result = await classUnderTest.method();

      // Assert
      expect(result, expected);
      verify(() => mockDependency.method()).called(1);
    });
  });
}
```

### Coverage Requirements

- **Overall:** 90% minimum
- **Domain layer:** 95% minimum (pure business logic)
- **Data layer:** 90% minimum
- **Presentation layer:** 85% minimum (UI can be harder to test)

Run coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Git Commit Conventions

Follow Conventional Commits:

```
test: add unit tests for Biomarker entity
feat: implement Biomarker entity with validation
test: add tests for ExtractReportFromFile usecase
feat: implement OCR extraction usecase
refactor: extract normalization logic into separate class
fix: resolve null reference in report parsing
docs: update phase-1-ocr-upload-tasks.md progress
chore: update dependencies to latest versions
```

**Commit frequency:** After each test-implementation pair (TDD cycle completion)

---

## Definition of Done

A feature is considered complete when:
- [ ] All tests written and passing
- [ ] Code coverage >= 90%
- [ ] Clean architecture principles followed
- [ ] No linting errors
- [ ] Documentation updated (AGENTS.md, task files)
- [ ] Changelog updated
- [ ] Code committed with conventional commit message
- [ ] Peer review passed (if applicable)
- [ ] Integration tests pass
- [ ] UI tested on iOS, Android, Web

---

## Risk Management

### Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| OCR accuracy low | Medium | High | Use LLM fallback, allow manual editing |
| Biomarker normalization incomplete | High | Medium | Maintain extensible dictionary, allow custom names |
| PDF parsing failures | Medium | Medium | Support image upload as alternative |
| Platform-specific issues (Web) | Medium | Medium | Test early on all platforms |
| Test coverage drops below 90% | Low | High | Enforce in CI/CD, frequent checks |

### Process Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Not following TDD | Low | High | Strict adherence, no exceptions |
| Architecture violations | Low | High | Regular code reviews, clear guidelines |
| Documentation drift | Medium | Medium | Update docs with each commit |

---

## Performance Targets

- **App startup:** < 2 seconds
- **OCR extraction:** < 5 seconds for 2-page PDF
- **Database queries:** < 100ms for list views
- **Chart rendering:** < 500ms
- **PDF generation:** < 3 seconds for 10-report comparison

---

## Accessibility Standards

- WCAG 2.1 Level AA compliance
- Screen reader support (Semantics widgets)
- Minimum touch target: 48x48 dp
- Color contrast: 4.5:1 for text, 3:1 for UI
- Keyboard navigation (Web)

---

## Future Enhancements (Post-MVP)

- Multi-user support (family profiles)
- Cloud backup with end-to-end encryption
- AI-powered health insights
- Integration with fitness trackers
- Medication tracking
- Appointment scheduling
- Multilingual support
- Apple Health / Google Fit integration
- Doctor portal (share access)

---

## References

- [AGENTS.md](../AGENTS.md) - Complete architecture context
- [Flutter Documentation](https://docs.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Conventional Commits](https://www.conventionalcommits.org)

---

**Document Version:** 1.0
**Last Updated:** 2025-10-15
**Status:** In Progress
**Current Phase:** Phase 1 - Foundation & OCR Upload (Ready to Start TDD)
