# Claude Code Instructions for Health Tracker Reports

For complete architecture, patterns, conventions, and implementation guidance, please refer to:

**[AGENTS.md](../AGENTS.md)**

This file contains:
- Complete project architecture and clean architecture layers
- Technology stack and dependencies
- TDD workflow and testing standards
- Entity, repository, and usecase patterns
- Riverpod provider examples
- Dependency injection with get_it
- Biomarker normalization rules
- Error handling patterns
- UI/UX guidelines
- Code generation setup
- Common pitfalls to avoid
- Quick reference commands

## Additional Instructions

### Code Style
- Follow strict TDD: Write tests before implementation
- Maintain 90% minimum code coverage
- Use conventional commits format
- Update /spec task files after each commit
- Update CHANGELOG.md after significant commits

### Git Workflow
- Commit after each test-implementation pair
- NO production code without tests first
- Format: `test: description` then `feat: description`

### Architecture Rules
- Domain layer NEVER imports from data or presentation
- All repository methods return `Either<Failure, T>`
- Entities are immutable and pure Dart
- Use dependency injection for all dependencies
- Providers use code generation (@riverpod)

### Testing Rules
- Unit tests: 90%+ coverage
- Widget tests: 85%+ coverage
- Use mocktail for mocking
- Test file structure mirrors source structure

Refer to AGENTS.md for detailed examples and patterns.
