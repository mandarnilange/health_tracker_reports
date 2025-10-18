---
name: tdd-workflow
description: Guides test-driven development workflow. Use when implementing new features, fixing bugs, or refactoring. Ensures tests are written before implementation code.
---

# TDD Workflow Guide

Enforces strict Test-Driven Development workflow across any language or framework.

## Core TDD Cycle

```
RED → GREEN → REFACTOR → COMMIT
```

1. **RED**: Write a failing test
2. **GREEN**: Write minimal code to pass
3. **REFACTOR**: Improve code while keeping tests green
4. **COMMIT**: Commit test + implementation together

## Workflow Steps

### Step 1: Understand the Requirement
Before writing any code, clarify:
- What functionality is needed?
- What inputs/outputs are expected?
- What edge cases exist?
- What error conditions must be handled?

### Step 2: Write the Test FIRST
```
MANDATORY: Test must be written before implementation!

Guide user to create test file:
- Match test structure to source structure
- Name: <source_file>_test.<ext>
- Use project's testing framework
- Write descriptive test names
- Cover happy path first
```

### Step 3: Run the Test (Should FAIL)
```
Run test command (detect from project):
- npm test / yarn test (JavaScript/TypeScript)
- pytest (Python)
- go test (Go)
- flutter test / dart test (Dart)
- mvn test / gradle test (Java)
- dotnet test (C#)
- cargo test (Rust)

VERIFY: Test must fail for the right reason
```

### Step 4: Write Minimal Implementation
```
Write just enough code to make test pass.
No gold plating. No extra features.
```

### Step 5: Run Tests Again (Should PASS)
```
All tests must be green before proceeding.
If not green, debug before continuing.
```

### Step 6: Refactor (Optional)
```
Now improve code quality:
- Remove duplication
- Improve naming
- Extract methods/functions
- Optimize performance

Keep tests green throughout!
```

### Step 7: Commit
```
Commit test + implementation together:
- Use conventional commit format
- Include both test and implementation files
```

## Language-Specific Testing Patterns

### Detect Project Type
Look for:
- `package.json` → JavaScript/TypeScript (Jest, Mocha, Vitest)
- `pubspec.yaml` → Dart/Flutter (flutter_test)
- `requirements.txt` / `pyproject.toml` → Python (pytest, unittest)
- `go.mod` → Go (testing package)
- `pom.xml` / `build.gradle` → Java (JUnit)
- `*.csproj` → C# (xUnit, NUnit)
- `Cargo.toml` → Rust (cargo test)

### Common Test Patterns

**Arrange-Act-Assert (AAA)**
```
test('description', () => {
  // Arrange: Set up test data
  const input = ...

  // Act: Execute function under test
  const result = functionUnderTest(input)

  // Assert: Verify expectations
  expect(result).toBe(expected)
})
```

**Given-When-Then (BDD)**
```
test('given X when Y then Z', () => {
  // Given: Initial context
  // When: Action occurs
  // Then: Expected outcome
})
```

## Test Structure Checklist

For each new feature/function:
- [ ] Happy path test
- [ ] Edge case tests (empty, null, boundary values)
- [ ] Error condition tests
- [ ] Integration tests (if applicable)

## Coverage Goals

Remind user of coverage targets:
- Unit tests: 80-90%+ coverage
- Integration tests: Key user flows
- E2E tests: Critical paths

## When to Use This Skill

Activate when:
- User says "implement X"
- User says "add feature Y"
- User says "fix bug Z"
- User creates new source files
- User asks "how do I TDD this?"

## Intervention Points

**If user writes implementation first:**
```
⚠️ TDD Violation Detected

You're writing implementation before tests!

Please:
1. Delete or stash this code
2. Write the test first
3. Run test (should fail)
4. Then implement

TDD ensures:
✓ Testable design
✓ No untested code
✓ Clear requirements
```

**If user skips test run:**
```
⚠️ Please run tests before proceeding

Run: [detected test command]

Verify test fails for the right reason.
```

## Response Templates

**Starting new feature:**
```
Let's use TDD!

Step 1: Write the test first

I'll create: test/<path>/<file>_test.<ext>

Test will verify:
- [list expected behaviors]

Ready to proceed?
```

**After test passes:**
```
✅ Test PASSING

Step 6: Refactor (optional)
- Any code improvements needed?
- Performance optimizations?
- Better naming?

Step 7: Ready to commit:
- test: <description>
- feat: <description>
```

## Allowed Tools

- Read: Check existing tests
- Write: Create test files
- Bash: Run test commands
- Edit: Modify tests/implementation
