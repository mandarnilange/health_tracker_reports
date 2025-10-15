# Phase 4: Enhanced UX Features - Task List

**Phase Goal:** Improve user experience with notes, reminders, theming, settings, and better error handling.

**Status:** Not Started

**Start Date:** TBD

**Completion Date:** TBD

---

## Feature 1: Notes on Reports (TDD)

### Tasks

#### 1.1 Add Note UseCase
- [ ] **TEST:** Write test for adding note to report
- [ ] **CODE:** Create AddNoteToReport usecase
- [ ] **TEST:** Write test for updating existing note
- [ ] **CODE:** Implement note update logic
- [ ] **TEST:** Write test for validation (max length, etc.)
- [ ] **CODE:** Add validation
- [ ] **TEST:** Write test for failure handling
- [ ] **CODE:** Add error handling
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for AddNoteToReport usecase`
- [ ] **COMMIT:** `feat: implement note addition to reports`

**Location:** `lib/domain/usecases/add_note_to_report.dart`

**Test Location:** `test/unit/domain/usecases/add_note_to_report_test.dart`

**Git Commits:**
- (empty)

#### 1.2 Notes UI Widget
- [ ] **TEST:** Write widget test for NotesSection
- [ ] **CODE:** Create NotesSection widget
- [ ] **TEST:** Write test for displaying existing note
- [ ] **CODE:** Implement note display
- [ ] **TEST:** Write test for edit button
- [ ] **CODE:** Add edit functionality
- [ ] **TEST:** Write test for TextField for editing
- [ ] **CODE:** Implement editable TextField
- [ ] **TEST:** Write test for save button
- [ ] **CODE:** Implement save functionality
- [ ] **TEST:** Write test for cancel button
- [ ] **CODE:** Implement cancel/discard changes
- [ ] **COMMIT:** `test: add widget tests for NotesSection`
- [ ] **COMMIT:** `feat: implement notes UI in ReportDetailPage`

**Location:** `lib/presentation/pages/report_detail/widgets/notes_section.dart`

**Test Location:** `test/widget/pages/report_detail/widgets/notes_section_test.dart`

**Git Commits:**
- (empty)

#### 1.3 Integrate Notes into ReportDetailPage
- [ ] **CODE:** Add NotesSection to ReportDetailPage
- [ ] **TEST:** Write integration test for note saving
- [ ] **CODE:** Connect to provider and usecase
- [ ] **COMMIT:** `feat: integrate notes into ReportDetailPage`

**Location:** `lib/presentation/pages/report_detail/report_detail_page.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 2: Reminders (TDD)

### Tasks

#### 2.1 Reminder Entity
- [ ] **TEST:** Write test for Reminder entity creation
- [ ] **CODE:** Create Reminder entity (id, title, date, isCompleted)
- [ ] **TEST:** Write test for copyWith method
- [ ] **CODE:** Implement copyWith
- [ ] **COMMIT:** `test: add tests for Reminder entity`
- [ ] **COMMIT:** `feat: implement Reminder entity`

**Location:** `lib/domain/entities/reminder.dart`

**Test Location:** `test/unit/domain/entities/reminder_test.dart`

**Git Commits:**
- (empty)

#### 2.2 ReminderModel
- [ ] **TEST:** Write test for ReminderModel serialization
- [ ] **CODE:** Create ReminderModel with Hive support
- [ ] **TEST:** Write test for fromJson/toJson
- [ ] **CODE:** Implement JSON serialization
- [ ] **COMMIT:** `test: add tests for ReminderModel`
- [ ] **COMMIT:** `feat: implement ReminderModel`

**Location:** `lib/data/models/reminder_model.dart`

**Test Location:** `test/unit/data/models/reminder_model_test.dart`

**Git Commits:**
- (empty)

#### 2.3 Reminder Local DataSource
- [ ] **TEST:** Write test for saving reminder
- [ ] **CODE:** Create ReminderLocalDataSource
- [ ] **TEST:** Write test for getting all reminders
- [ ] **CODE:** Implement getAllReminders
- [ ] **TEST:** Write test for deleting reminder
- [ ] **CODE:** Implement deleteReminder
- [ ] **TEST:** Write test for updating reminder
- [ ] **CODE:** Implement updateReminder
- [ ] **COMMIT:** `test: add tests for ReminderLocalDataSource`
- [ ] **COMMIT:** `feat: implement ReminderLocalDataSource`

**Location:** `lib/data/datasources/local/reminder_local_datasource.dart`

**Test Location:** `test/unit/data/datasources/local/reminder_local_datasource_test.dart`

**Git Commits:**
- (empty)

#### 2.4 Reminder Repository
- [ ] **TEST:** Write test for ReminderRepository interface
- [ ] **CODE:** Create ReminderRepository interface
- [ ] **TEST:** Write test for ReminderRepositoryImpl
- [ ] **CODE:** Implement ReminderRepositoryImpl
- [ ] **COMMIT:** `test: add tests for ReminderRepository`
- [ ] **COMMIT:** `feat: implement reminder repository`

**Location:** `lib/domain/repositories/reminder_repository.dart`
`lib/data/repositories/reminder_repository_impl.dart`

**Test Location:** `test/unit/data/repositories/reminder_repository_impl_test.dart`

**Git Commits:**
- (empty)

#### 2.5 Reminder UseCases
- [ ] **TEST:** Write test for CreateReminder usecase
- [ ] **CODE:** Implement CreateReminder usecase
- [ ] **TEST:** Write test for GetAllReminders usecase
- [ ] **CODE:** Implement GetAllReminders usecase
- [ ] **TEST:** Write test for DeleteReminder usecase
- [ ] **CODE:** Implement DeleteReminder usecase
- [ ] **TEST:** Write test for MarkReminderComplete usecase
- [ ] **CODE:** Implement MarkReminderComplete usecase
- [ ] **COMMIT:** `test: add tests for reminder usecases`
- [ ] **COMMIT:** `feat: implement reminder usecases`

**Location:** `lib/domain/usecases/create_reminder.dart` (and others)

**Test Location:** `test/unit/domain/usecases/reminder_usecases_test.dart`

**Git Commits:**
- (empty)

#### 2.6 Notification Service
- [ ] **TEST:** Write test for scheduling notifications
- [ ] **CODE:** Create NotificationService using flutter_local_notifications
- [ ] **TEST:** Write test for canceling notifications
- [ ] **CODE:** Implement cancel functionality
- [ ] **TEST:** Write test for notification permissions
- [ ] **CODE:** Handle permission requests
- [ ] **COMMIT:** `test: add tests for NotificationService`
- [ ] **COMMIT:** `feat: implement local notifications for reminders`

**Location:** `lib/data/datasources/external/notification_service.dart`

**Test Location:** `test/unit/data/datasources/external/notification_service_test.dart`

**Git Commits:**
- (empty)

#### 2.7 Reminder UI
- [ ] **TEST:** Write widget test for RemindersPage
- [ ] **CODE:** Create RemindersPage
- [ ] **TEST:** Write test for reminder list
- [ ] **CODE:** Implement reminder list view
- [ ] **TEST:** Write test for add reminder button
- [ ] **CODE:** Implement add reminder dialog
- [ ] **TEST:** Write test for date picker
- [ ] **CODE:** Add date/time picker
- [ ] **TEST:** Write test for deleting reminder
- [ ] **CODE:** Add delete functionality
- [ ] **COMMIT:** `test: add widget tests for RemindersPage`
- [ ] **COMMIT:** `feat: implement reminders UI`

**Location:** `lib/presentation/pages/reminders/reminders_page.dart`

**Test Location:** `test/widget/pages/reminders/reminders_page_test.dart`

**Git Commits:**
- (empty)

---

## Feature 3: Delete Reports (TDD)

### Tasks

#### 3.1 DeleteReport UseCase
- [ ] **TEST:** Write test for deleting report
- [ ] **CODE:** Create DeleteReport usecase
- [ ] **TEST:** Write test for deleting associated files
- [ ] **CODE:** Implement file cleanup
- [ ] **TEST:** Write test for failure handling
- [ ] **CODE:** Add error handling
- [ ] **COMMIT:** `test: add tests for DeleteReport usecase`
- [ ] **COMMIT:** `feat: implement report deletion`

**Location:** `lib/domain/usecases/delete_report.dart`

**Test Location:** `test/unit/domain/usecases/delete_report_test.dart`

**Git Commits:**
- (empty)

#### 3.2 Delete UI
- [ ] **TEST:** Write widget test for delete confirmation dialog
- [ ] **CODE:** Create delete confirmation dialog
- [ ] **TEST:** Write test for delete action in ReportDetailPage
- [ ] **CODE:** Add delete menu item/button
- [ ] **TEST:** Write test for successful deletion and navigation
- [ ] **CODE:** Implement deletion with navigation back
- [ ] **COMMIT:** `test: add widget tests for delete functionality`
- [ ] **COMMIT:** `feat: add delete report UI`

**Location:** `lib/presentation/pages/report_detail/report_detail_page.dart` (updated)

**Test Location:** `test/widget/pages/report_detail/report_detail_page_test.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 4: Dark Mode & Theming (TDD)

### Tasks

#### 4.1 Theme Provider
- [ ] **TEST:** Write test for ThemeProvider state
- [ ] **CODE:** Create ThemeProvider with @riverpod
- [ ] **TEST:** Write test for theme toggle
- [ ] **CODE:** Implement toggleTheme method
- [ ] **TEST:** Write test for persisting theme preference
- [ ] **CODE:** Save theme to config repository
- [ ] **COMMIT:** `test: add tests for ThemeProvider`
- [ ] **COMMIT:** `feat: implement theme state management`

**Location:** `lib/presentation/providers/theme_provider.dart`

**Test Location:** `test/unit/presentation/providers/theme_provider_test.dart`

**Git Commits:**
- (empty)

#### 4.2 Dark Theme Design
- [ ] **CODE:** Create dark theme in app_theme.dart
- [ ] **CODE:** Define dark color scheme
- [ ] **CODE:** Ensure contrast ratios meet accessibility standards
- [ ] **CODE:** Test dark theme on all screens
- [ ] **COMMIT:** `feat: implement dark theme with accessibility`

**Location:** `lib/presentation/theme/app_theme.dart` (updated)

**Git Commits:**
- (empty)

#### 4.3 Theme Toggle UI
- [ ] **TEST:** Write widget test for theme toggle switch
- [ ] **CODE:** Add theme toggle to SettingsPage
- [ ] **TEST:** Write test for theme change reflecting in app
- [ ] **CODE:** Connect to ThemeProvider
- [ ] **COMMIT:** `test: add widget tests for theme toggle`
- [ ] **COMMIT:** `feat: add theme toggle to settings`

**Location:** `lib/presentation/pages/settings/settings_page.dart`

**Test Location:** `test/widget/pages/settings/settings_page_test.dart`

**Git Commits:**
- (empty)

---

## Feature 5: Settings Page (TDD)

### Tasks

#### 5.1 SettingsPage Structure
- [ ] **TEST:** Write widget test for SettingsPage
- [ ] **CODE:** Create SettingsPage widget
- [ ] **TEST:** Write test for AppBar
- [ ] **CODE:** Implement AppBar
- [ ] **TEST:** Write test for settings sections
- [ ] **CODE:** Create settings sections (General, API Keys, About)
- [ ] **COMMIT:** `test: add widget tests for SettingsPage`
- [ ] **COMMIT:** `feat: implement SettingsPage structure`

**Location:** `lib/presentation/pages/settings/settings_page.dart`

**Test Location:** `test/widget/pages/settings/settings_page_test.dart`

**Git Commits:**
- (empty)

#### 5.2 API Key Input Widget
- [ ] **TEST:** Write widget test for ApiKeyInput
- [ ] **CODE:** Create ApiKeyInput widget
- [ ] **TEST:** Write test for obscured text field
- [ ] **CODE:** Implement obscured TextField
- [ ] **TEST:** Write test for show/hide toggle
- [ ] **CODE:** Add visibility toggle button
- [ ] **TEST:** Write test for save functionality
- [ ] **CODE:** Implement save to config
- [ ] **TEST:** Write test for validation
- [ ] **CODE:** Add validation logic
- [ ] **COMMIT:** `test: add widget tests for ApiKeyInput`
- [ ] **COMMIT:** `feat: implement API key configuration UI`

**Location:** `lib/presentation/pages/settings/widgets/api_key_input.dart`

**Test Location:** `test/widget/pages/settings/widgets/api_key_input_test.dart`

**Git Commits:**
- (empty)

#### 5.3 LLM Provider Selection
- [ ] **TEST:** Write widget test for LLM provider selector
- [ ] **CODE:** Create LLM provider dropdown (OpenAI, Gemini, None)
- [ ] **TEST:** Write test for provider selection
- [ ] **CODE:** Implement selection logic
- [ ] **TEST:** Write test for saving selection
- [ ] **CODE:** Save to config
- [ ] **COMMIT:** `test: add tests for LLM provider selection`
- [ ] **COMMIT:** `feat: add LLM provider selection to settings`

**Location:** `lib/presentation/pages/settings/settings_page.dart` (updated)

**Git Commits:**
- (empty)

#### 5.4 About Section
- [ ] **CODE:** Add About section with app version
- [ ] **CODE:** Add licenses page link
- [ ] **CODE:** Add privacy policy (local-first messaging)
- [ ] **COMMIT:** `feat: add About section to settings`

**Location:** `lib/presentation/pages/settings/settings_page.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 6: Onboarding Flow (TDD)

### Tasks

#### 6.1 Onboarding Screens
- [ ] **TEST:** Write widget test for OnboardingPage
- [ ] **CODE:** Create OnboardingPage with PageView
- [ ] **TEST:** Write test for welcome screen
- [ ] **CODE:** Create welcome screen
- [ ] **TEST:** Write test for features screen
- [ ] **CODE:** Create features overview screen
- [ ] **TEST:** Write test for permissions screen
- [ ] **CODE:** Create permissions request screen
- [ ] **TEST:** Write test for get started button
- [ ] **CODE:** Implement navigation to home
- [ ] **COMMIT:** `test: add widget tests for onboarding`
- [ ] **COMMIT:** `feat: implement onboarding flow`

**Location:** `lib/presentation/pages/onboarding/onboarding_page.dart`

**Test Location:** `test/widget/pages/onboarding/onboarding_page_test.dart`

**Git Commits:**
- (empty)

#### 6.2 Onboarding State Management
- [ ] **TEST:** Write test for hasCompletedOnboarding in config
- [ ] **CODE:** Add hasCompletedOnboarding to AppConfig
- [ ] **TEST:** Write test for setting onboarding complete
- [ ] **CODE:** Implement setter in config repository
- [ ] **TEST:** Write test for routing based on onboarding status
- [ ] **CODE:** Update router to show onboarding first
- [ ] **COMMIT:** `test: add tests for onboarding state`
- [ ] **COMMIT:** `feat: implement onboarding state persistence`

**Location:** `lib/domain/entities/app_config.dart` (updated)
`lib/presentation/router.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 7: Improved Error Handling UI

### Tasks

#### 7.1 ErrorDisplay Widget
- [ ] **TEST:** Write widget test for ErrorDisplay
- [ ] **CODE:** Create ErrorDisplay widget
- [ ] **TEST:** Write test for different error types
- [ ] **CODE:** Customize message based on failure type
- [ ] **TEST:** Write test for retry button
- [ ] **CODE:** Implement retry callback
- [ ] **COMMIT:** `test: add widget tests for ErrorDisplay`
- [ ] **COMMIT:** `feat: implement ErrorDisplay widget`

**Location:** `lib/presentation/widgets/error_display.dart`

**Test Location:** `test/widget/widgets/error_display_test.dart`

**Git Commits:**
- (empty)

#### 7.2 Integrate ErrorDisplay Across Pages
- [ ] **CODE:** Replace generic error messages with ErrorDisplay
- [ ] **CODE:** Add retry functionality where appropriate
- [ ] **TEST:** Write integration tests for error scenarios
- [ ] **CODE:** Verify error handling works end-to-end
- [ ] **COMMIT:** `feat: integrate ErrorDisplay across all pages`

**Location:** Multiple pages (updated)

**Git Commits:**
- (empty)

---

## Feature 8: Loading Indicators

### Tasks

#### 8.1 Custom LoadingIndicator Widget
- [ ] **TEST:** Write widget test for LoadingIndicator
- [ ] **CODE:** Create branded LoadingIndicator widget
- [ ] **CODE:** Add custom animation (optional)
- [ ] **COMMIT:** `feat: implement custom LoadingIndicator`

**Location:** `lib/presentation/widgets/loading_indicator.dart`

**Git Commits:**
- (empty)

#### 8.2 Integrate LoadingIndicator
- [ ] **CODE:** Replace CircularProgressIndicator with custom widget
- [ ] **CODE:** Ensure consistent loading UX across app
- [ ] **COMMIT:** `feat: standardize loading indicators across app`

**Location:** Multiple pages (updated)

**Git Commits:**
- (empty)

---

## Feature 9: Routing Updates

### Tasks

#### 9.1 Add Settings Route
- [ ] **CODE:** Add /settings route to go_router
- [ ] **CODE:** Add navigation from HomePage to SettingsPage
- [ ] **COMMIT:** `feat: add settings route`

**Location:** `lib/presentation/router.dart` (updated)

**Git Commits:**
- (empty)

#### 9.2 Add Reminders Route
- [ ] **CODE:** Add /reminders route
- [ ] **CODE:** Add navigation from HomePage/SettingsPage
- [ ] **COMMIT:** `feat: add reminders route`

**Location:** `lib/presentation/router.dart` (updated)

**Git Commits:**
- (empty)

---

## Phase 4 Completion Checklist

- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] Overall coverage >= 90%
- [ ] No linting errors (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] All tasks above completed
- [ ] User can successfully:
  - [ ] Add/edit notes on reports
  - [ ] Create reminders for next blood test
  - [ ] Receive notifications for reminders
  - [ ] Delete reports with confirmation
  - [ ] Toggle dark/light theme
  - [ ] Configure API keys in settings
  - [ ] Complete onboarding on first launch
  - [ ] See helpful error messages with retry options
- [ ] Documentation updated:
  - [ ] overall-plan.md changelog updated
  - [ ] This task file marked complete
- [ ] Git commits follow conventional commits format
- [ ] All commits pushed to repository

---

## Status Summary

**Total Tasks:** ~80
**Completed:** 0
**In Progress:** 0
**Blocked:** 0

**Test Coverage:** 0%

**Last Updated:** 2025-10-15

---

## Notes

- Ensure notifications work on all platforms (iOS requires additional setup)
- Test dark mode thoroughly for visual consistency
- Validate API keys before saving
- Consider accessibility in all UX enhancements
