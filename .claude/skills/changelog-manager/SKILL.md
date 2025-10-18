---
name: changelog-manager
description: Maintains CHANGELOG.md following Keep a Changelog format. Use after commits, feature completions, bug fixes, or when preparing releases to keep changelog current and accurate.
---

# Changelog Manager

Automatically maintains CHANGELOG.md file following industry-standard conventions.

## Purpose

Keep a human-readable changelog that documents all notable changes:
- What changed?
- Why did it change?
- When did it change?
- Who should care?

## Format Standard

Follows [Keep a Changelog](https://keepachangelog.com/) v1.1.0 format.

### Basic Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features

### Changed
- Changes to existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security improvements

## [1.0.0] - 2025-10-17

### Added
- Initial release
```

## Change Categories

### Added
New features, functionality, or capabilities
```markdown
### Added
- User authentication with JWT tokens
- Dark mode support across all pages
- Export reports to PDF functionality
```

### Changed
Changes to existing functionality
```markdown
### Changed
- Updated database schema for better performance
- Improved error messages for user clarity
- Refactored authentication service for maintainability
```

### Deprecated
Features that will be removed in upcoming releases
```markdown
### Deprecated
- Legacy API v1 endpoints (use v2 instead)
- Old configuration format (migrate to new YAML format)
```

### Removed
Features that have been removed
```markdown
### Removed
- Deprecated API v1 endpoints
- Support for Internet Explorer 11
```

### Fixed
Bug fixes
```markdown
### Fixed
- Fixed crash when uploading large files
- Resolved memory leak in background service
- Corrected timezone handling in date picker
```

### Security
Security improvements and vulnerability fixes
```markdown
### Security
- Updated dependencies to patch CVE-2024-1234
- Added rate limiting to prevent brute force attacks
- Implemented CSRF token validation
```

## Workflow

### Step 1: Detect Changes

Monitor for:
- Git commits
- Feature completions
- Bug fixes
- Dependency updates
- Breaking changes

### Step 2: Parse Commit Message

Extract information from conventional commits:
```
feat: add user authentication
  → Category: Added
  → Entry: "User authentication with JWT tokens"

fix: resolve crash on file upload
  → Category: Fixed
  → Entry: "Fixed crash when uploading large files"

chore: update dependencies
  → Category: Changed (or Security if security-related)
  → Entry: "Updated dependencies to latest versions"

BREAKING CHANGE: remove legacy API
  → Category: Removed
  → Entry: "Legacy API v1 endpoints (use v2 instead)"
```

### Step 3: Suggest Changelog Entry

Present suggestion to user:
```
📝 Changelog Update Suggested

Based on commit: "feat: add user authentication"

Add to CHANGELOG.md under [Unreleased] → Added:
- User authentication with JWT tokens (commit: abc1234)

Add this entry? (yes/no/edit)
```

### Step 4: Update CHANGELOG.md

Insert entry in appropriate section:
- Find `[Unreleased]` section
- Find or create appropriate category (Added, Changed, etc.)
- Add entry with commit reference
- Maintain chronological order (newest first)

## Commit Reference Format

### Option 1: Include commit hash
```markdown
### Added
- User authentication with JWT tokens (abc1234)
- Dark mode toggle in settings (def5678)
```

### Option 2: Link to commit
```markdown
### Added
- User authentication with JWT tokens ([abc1234](https://github.com/user/repo/commit/abc1234))
```

### Option 3: No commit reference (cleaner for users)
```markdown
### Added
- User authentication with JWT tokens
- Dark mode toggle in settings
```

**Default to Option 3** unless user prefers otherwise.

## Grouping Related Changes

Group related commits into single entry:
```markdown
Instead of:
### Added
- Login page
- Registration page
- Password reset page

Better:
### Added
- Complete authentication system with login, registration, and password reset
```

## Release Workflow

### Creating a Release

When user says "prepare release" or "version X.Y.Z":

1. **Move Unreleased to Version**
```markdown
## [Unreleased]

## [1.2.0] - 2025-10-17

### Added
- User authentication system
```

2. **Add Compare Links (optional)**
```markdown
## [1.2.0] - 2025-10-17

[Compare changes](https://github.com/user/repo/compare/v1.1.0...v1.2.0)
```

3. **Create New Unreleased Section**
```markdown
## [Unreleased]

## [1.2.0] - 2025-10-17
```

## Semantic Versioning Hints

Suggest version bump based on changes:
```
Only bug fixes (Fixed) → Patch version (1.0.1)
New features (Added) → Minor version (1.1.0)
Breaking changes (Removed, major Changed) → Major version (2.0.0)
```

## Language-Agnostic Approach

Works with any project type:
- Detect version from:
  - `package.json` (JavaScript)
  - `pubspec.yaml` (Dart)
  - `pom.xml` (Java)
  - `*.csproj` (C#)
  - `Cargo.toml` (Rust)
  - `pyproject.toml` (Python)
  - `go.mod` (Go)

## When to Update

### Automatic Triggers
- After significant commits
- After feature completion
- After bug fixes
- Before releases

### Manual Triggers
- User says "update changelog"
- User says "prepare release"
- User asks "what's changed?"

## Update Strategies

### Strategy 1: After Every Commit
```
Most granular, but can be noisy.
Good for: Active development, detailed tracking
```

### Strategy 2: After Feature Completion
```
Balanced approach.
Good for: Most projects
```

### Strategy 3: Before Release
```
Less frequent, batch updates.
Good for: Stable projects, formal releases
```

**Default to Strategy 2** unless user specifies.

## Response Template

### Suggesting Update
```
📝 Changelog Update

Recent commits detected:
- feat: add user authentication (abc1234)
- fix: resolve file upload crash (def5678)

Suggested CHANGELOG.md updates:

[Unreleased]
━━━━━━━━━━━━━━━━━━━━━━━━━━
Added:
+ User authentication system

Fixed:
+ File upload crash for large files

Apply these changes? (yes/no/edit)
```

### After Update
```
✅ CHANGELOG.md updated

Added 2 entries under [Unreleased]
View: CHANGELOG.md lines 15-18
```

## Best Practices

1. **Write for users, not developers**
   - Bad: "Refactored AuthService to use DI pattern"
   - Good: "Improved authentication service reliability"

2. **Be specific but concise**
   - Bad: "Fixed bug"
   - Good: "Fixed crash when uploading files over 10MB"

3. **Group related changes**
   - Combine multiple commits into logical features

4. **Include migration notes for breaking changes**
```markdown
### Removed
- Legacy API v1 endpoints

  **Migration:** Update API calls from `/api/v1/` to `/api/v2/`.
  See [migration guide](docs/migration-v2.md) for details.
```

5. **Link to relevant docs/issues**
```markdown
### Added
- OAuth2 authentication (closes #42, see docs/oauth.md)
```

## Allowed Tools

- Read: Check existing CHANGELOG.md
- Write: Create new CHANGELOG.md
- Edit: Update existing changelog
- Bash (git log): Get commit history
- Grep: Find existing entries
