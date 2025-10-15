# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Domain entities: ReferenceRange, Biomarker, Report with comprehensive test coverage
- TDD workflow established with strict RED-GREEN-COMMIT cycle

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

### Domain Entities (TDD)

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
