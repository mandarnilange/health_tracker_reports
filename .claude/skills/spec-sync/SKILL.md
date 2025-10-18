---
name: spec-sync
description: Synchronizes task/spec files with project progress. Use after commits, feature completions, or when updating project documentation to keep task tracking files current.
---

# Spec File Sync

Automatically maintains task tracking and specification files across any project.

## Purpose

Keep specification/task files synchronized with actual code progress:
- Mark completed tasks
- Update status indicators
- Track blockers and in-progress work
- Maintain accurate project state

## Common Spec File Patterns

Projects often use these documentation patterns:

### Pattern 1: Phase/Sprint Files
```
/spec/phase-1-tasks.md
/spec/phase-2-tasks.md
/spec/sprint-1.md
```

### Pattern 2: Feature Files
```
/docs/features/authentication.md
/docs/features/payment-processing.md
```

### Pattern 3: Backlog/Kanban
```
/tasks/backlog.md
/tasks/in-progress.md
/tasks/done.md
```

### Pattern 4: Issue Tracking
```
/issues/open.md
/issues/closed.md
```

### Pattern 5: Project Board
```
/PROJECT.md
/TODO.md
/ROADMAP.md
```

## Detection Strategy

### On Project Start
Scan for spec files:
```bash
Look for:
- /spec/*.md
- /docs/*.md
- /tasks/*.md
- /issues/*.md
- TODO.md, ROADMAP.md, PROJECT.md

Priority: Check project root first, then subdirectories
```

### Identify Task Format
Common task formats:
```markdown
- [ ] Task description
- [x] Completed task
✓ Done task
✗ Blocked task
🔄 In progress
⏸️ Paused
```

Or numbered lists:
```markdown
1. ✅ Completed task
2. 🚧 In progress
3. ⏳ Pending
```

Or tables:
```markdown
| Task | Status | Notes |
|------|--------|-------|
| Setup | Done | ✓ |
| Auth | In Progress | 🔄 |
```

## Sync Operations

### 1. After Commit
```
Trigger: User commits code

Actions:
1. Parse commit message
2. Extract feature/task reference
3. Find related task in spec files
4. Update task status to "Done" or "✅"
5. Add commit hash reference
6. Update timestamp
```

### 2. Feature Completion
```
Trigger: User completes a feature

Actions:
1. Mark all related tasks as complete
2. Update overall progress percentage
3. Move tasks from "In Progress" to "Completed"
4. Add completion notes
```

### 3. Starting New Task
```
Trigger: User begins new work

Actions:
1. Mark task as "In Progress" or "🔄"
2. Add start timestamp
3. Move from backlog to active
```

### 4. Blocking Issues
```
Trigger: User reports blocker

Actions:
1. Mark task as "Blocked" or "✗"
2. Add blocker notes
3. Link to related issues
```

## Language-Agnostic Approach

### Detect Commit Content
Analyze commit message and files changed:
```
Commit: "feat: implement user authentication"
Files: src/auth/login.js, test/auth/login.test.js

Search spec files for:
- "authentication"
- "login"
- "auth"

Update matching tasks
```

### Parse Conventional Commits
```
feat: New feature → Mark feature task complete
fix: Bug fix → Mark bug task complete
test: Tests added → Update test coverage task
docs: Documentation → Mark doc task complete
refactor: Refactoring → Note in relevant task
```

## Workflow

### Step 1: Locate Spec Files
```
On first use or when user says "update tasks":
1. Scan project for task files
2. Ask user which files to track
3. Remember preferences
```

### Step 2: Monitor Changes
```
After each commit:
1. Read commit message
2. Identify completed work
3. Find related tasks
4. Suggest updates
```

### Step 3: Update Task Files
```
Present changes to user:

"I found related tasks to update:

File: spec/phase-1-tasks.md
Line 15: - [ ] Implement user authentication

Change to:
Line 15: - [x] Implement user authentication (commit: abc1234)

Update this file? (yes/no)"
```

### Step 4: Track Progress
```
Calculate completion percentage:
Total tasks: 25
Completed: 18
In Progress: 3
Pending: 4

Progress: 72% complete
```

## Status Markers

Support multiple notation styles:

**Checkboxes:**
- `- [ ]` → Pending
- `- [x]` → Complete
- `- [-]` → In Progress
- `- [~]` → Blocked

**Emojis:**
- `⏳` → Pending
- `✅` → Complete
- `🔄` → In Progress
- `❌` → Blocked
- `⏸️` → Paused

**Text:**
- `TODO:` → Pending
- `DONE:` → Complete
- `WIP:` → In Progress
- `BLOCKED:` → Blocked

## Update Format

### Task Completion
```markdown
Before:
- [ ] Implement user authentication

After:
- [x] Implement user authentication
  - Completed: 2025-10-17
  - Commit: abc1234
  - Files: src/auth/login.js, src/auth/register.js
```

### Progress Note
```markdown
## Phase 1: Authentication

Progress: 8/10 tasks complete (80%)

- [x] Setup auth routes
- [x] Implement login
- [x] Implement register
- [x] Add JWT tokens
- [x] Implement logout
- [x] Password hashing
- [x] Email verification
- [x] Password reset
- [ ] OAuth integration
- [ ] 2FA support
```

## When to Use This Skill

Activate when:
- User commits code
- User says "mark task complete"
- User says "update progress"
- User asks "what's left to do?"
- User completes a feature
- User starts new work

## Response Template

```
📋 Spec Sync Check

Found updates to apply:

File: spec/phase-1-tasks.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Line 15: Mark "Implement auth" as complete
Line 23: Update progress to 65%

File: TODO.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Line 8: Move "Add tests" to Done section

Apply these updates? (yes/no/review)
```

## Allowed Tools

- Read: Scan spec files
- Grep: Search for task references
- Glob: Find all spec files
- Edit: Update task statuses
- Git log: Check recent commits
