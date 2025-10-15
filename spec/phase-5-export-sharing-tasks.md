# Phase 5: Export, Backup & Sharing - Task List

**Phase Goal:** Enable users to export data to CSV, backup to Google Drive, generate professional doctor summaries, and share reports.

**Status:** Not Started

**Start Date:** TBD

**Completion Date:** TBD

---

## Feature 1: CSV Export (TDD)

### Tasks

#### 1.1 ExportToCSV UseCase
- [ ] **TEST:** Write test for exporting all reports to CSV
- [ ] **CODE:** Create ExportToCSV usecase
- [ ] **TEST:** Write test for CSV format structure
- [ ] **CODE:** Implement CSV formatting (headers, rows)
- [ ] **TEST:** Write test for handling special characters
- [ ] **CODE:** Properly escape commas, quotes, newlines
- [ ] **TEST:** Write test for date formatting
- [ ] **CODE:** Format dates consistently (ISO 8601)
- [ ] **TEST:** Write test for empty data handling
- [ ] **CODE:** Handle case with no reports
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for ExportToCSV usecase`
- [ ] **COMMIT:** `feat: implement CSV export functionality`

**Location:** `lib/domain/usecases/export_to_csv.dart`

**Test Location:** `test/unit/domain/usecases/export_to_csv_test.dart`

**Git Commits:**
- (empty)

#### 1.2 File Writing Service
- [ ] **TEST:** Write test for saving CSV to file system
- [ ] **CODE:** Create FileWriterService
- [ ] **TEST:** Write test for file path generation
- [ ] **CODE:** Generate unique filenames with timestamps
- [ ] **TEST:** Write test for permission handling
- [ ] **CODE:** Handle file permission errors
- [ ] **TEST:** Write test for different platforms (iOS/Android/Web)
- [ ] **CODE:** Handle platform-specific file paths
- [ ] **COMMIT:** `test: add tests for FileWriterService`
- [ ] **COMMIT:** `feat: implement file writing service`

**Location:** `lib/data/datasources/external/file_writer_service.dart`

**Test Location:** `test/unit/data/datasources/external/file_writer_service_test.dart`

**Git Commits:**
- (empty)

#### 1.3 Export UI
- [ ] **TEST:** Write widget test for export button
- [ ] **CODE:** Add export button to SettingsPage or HomePage
- [ ] **TEST:** Write test for export progress indicator
- [ ] **CODE:** Show progress during export
- [ ] **TEST:** Write test for success message
- [ ] **CODE:** Show success snackbar with file location
- [ ] **TEST:** Write test for error handling
- [ ] **CODE:** Display error if export fails
- [ ] **COMMIT:** `test: add widget tests for CSV export UI`
- [ ] **COMMIT:** `feat: add CSV export button to settings`

**Location:** `lib/presentation/pages/settings/settings_page.dart` (updated)

**Test Location:** `test/widget/pages/settings/settings_page_test.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 2: Google Drive Integration (TDD)

### Tasks

#### 2.1 DriveService
- [ ] **TEST:** Write test for Google Drive authentication
- [ ] **CODE:** Create DriveService using googleapis
- [ ] **TEST:** Write test for uploading file to Drive
- [ ] **CODE:** Implement file upload functionality
- [ ] **TEST:** Write test for checking existing backups
- [ ] **CODE:** Implement file listing/search
- [ ] **TEST:** Write test for updating existing backup
- [ ] **CODE:** Implement file update logic
- [ ] **TEST:** Write test for error handling (network, auth)
- [ ] **CODE:** Add comprehensive error handling
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for DriveService`
- [ ] **COMMIT:** `feat: implement Google Drive service`

**Location:** `lib/data/datasources/external/drive_service.dart`

**Test Location:** `test/unit/data/datasources/external/drive_service_test.dart`

**Git Commits:**
- (empty)

#### 2.2 BackupToGoogleDrive UseCase
- [ ] **TEST:** Write test for backup workflow
- [ ] **CODE:** Create BackupToGoogleDrive usecase
- [ ] **TEST:** Write test for export + upload flow
- [ ] **CODE:** Combine ExportToCSV and DriveService
- [ ] **TEST:** Write test for backup success
- [ ] **CODE:** Return success with file ID
- [ ] **TEST:** Write test for partial failure handling
- [ ] **CODE:** Handle export success but upload failure
- [ ] **COMMIT:** `test: add tests for BackupToGoogleDrive usecase`
- [ ] **COMMIT:** `feat: implement Google Drive backup`

**Location:** `lib/domain/usecases/backup_to_google_drive.dart`

**Test Location:** `test/unit/domain/usecases/backup_to_google_drive_test.dart`

**Git Commits:**
- (empty)

#### 2.3 Google Sign-In Integration
- [ ] **TEST:** Write test for Google Sign-In flow
- [ ] **CODE:** Integrate google_sign_in package
- [ ] **TEST:** Write test for authentication state
- [ ] **CODE:** Manage auth state with provider
- [ ] **TEST:** Write test for sign-out
- [ ] **CODE:** Implement sign-out functionality
- [ ] **COMMIT:** `test: add tests for Google Sign-In`
- [ ] **COMMIT:** `feat: integrate Google Sign-In for Drive`

**Location:** `lib/data/datasources/external/google_auth_service.dart`

**Test Location:** `test/unit/data/datasources/external/google_auth_service_test.dart`

**Git Commits:**
- (empty)

#### 2.4 Backup UI
- [ ] **TEST:** Write widget test for backup button
- [ ] **CODE:** Add backup button to SettingsPage
- [ ] **TEST:** Write test for Google Sign-In prompt
- [ ] **CODE:** Show sign-in dialog if not authenticated
- [ ] **TEST:** Write test for backup progress
- [ ] **CODE:** Show progress indicator during backup
- [ ] **TEST:** Write test for success confirmation
- [ ] **CODE:** Show success message
- [ ] **TEST:** Write test for last backup timestamp
- [ ] **CODE:** Display last backup date/time
- [ ] **COMMIT:** `test: add widget tests for Google Drive backup UI`
- [ ] **COMMIT:** `feat: add Google Drive backup to settings`

**Location:** `lib/presentation/pages/settings/settings_page.dart` (updated)

**Test Location:** `test/widget/pages/settings/settings_page_test.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 3: CSV Import/Restore (TDD)

### Tasks

#### 3.1 ImportFromCSV UseCase
- [ ] **TEST:** Write test for importing CSV file
- [ ] **CODE:** Create ImportFromCSV usecase
- [ ] **TEST:** Write test for parsing CSV format
- [ ] **CODE:** Implement CSV parsing logic
- [ ] **TEST:** Write test for validation (correct headers, data types)
- [ ] **CODE:** Add validation logic
- [ ] **TEST:** Write test for duplicate handling
- [ ] **CODE:** Handle duplicate reports (skip or update)
- [ ] **TEST:** Write test for error rows handling
- [ ] **CODE:** Return list of errors for invalid rows
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for ImportFromCSV usecase`
- [ ] **COMMIT:** `feat: implement CSV import functionality`

**Location:** `lib/domain/usecases/import_from_csv.dart`

**Test Location:** `test/unit/domain/usecases/import_from_csv_test.dart`

**Git Commits:**
- (empty)

#### 3.2 RestoreFromGoogleDrive UseCase
- [ ] **TEST:** Write test for restore workflow
- [ ] **CODE:** Create RestoreFromGoogleDrive usecase
- [ ] **TEST:** Write test for download + import flow
- [ ] **CODE:** Combine DriveService download and ImportFromCSV
- [ ] **TEST:** Write test for selecting backup file
- [ ] **CODE:** List available backups for selection
- [ ] **COMMIT:** `test: add tests for RestoreFromGoogleDrive usecase`
- [ ] **COMMIT:** `feat: implement restore from Google Drive`

**Location:** `lib/domain/usecases/restore_from_google_drive.dart`

**Test Location:** `test/unit/domain/usecases/restore_from_google_drive_test.dart`

**Git Commits:**
- (empty)

#### 3.3 Import/Restore UI
- [ ] **TEST:** Write widget test for import button
- [ ] **CODE:** Add import button to SettingsPage
- [ ] **TEST:** Write test for file picker
- [ ] **CODE:** Show file picker for CSV selection
- [ ] **TEST:** Write test for import progress
- [ ] **CODE:** Show progress during import
- [ ] **TEST:** Write test for import summary (x succeeded, y failed)
- [ ] **CODE:** Display import results
- [ ] **TEST:** Write test for restore from Drive button
- [ ] **CODE:** Add restore from Drive functionality
- [ ] **COMMIT:** `test: add widget tests for import/restore UI`
- [ ] **COMMIT:** `feat: add import and restore to settings`

**Location:** `lib/presentation/pages/settings/settings_page.dart` (updated)

**Test Location:** `test/widget/pages/settings/settings_page_test.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 4: Doctor Summary PDF Generation (TDD)

### Tasks

#### 4.1 DoctorSummaryData Model
- [ ] **TEST:** Write test for DoctorSummaryData structure
- [ ] **CODE:** Create DoctorSummaryData class
- [ ] **TEST:** Write test for multi-report comparison data
- [ ] **CODE:** Structure data for table format
- [ ] **COMMIT:** `test: add tests for DoctorSummaryData`
- [ ] **COMMIT:** `feat: implement doctor summary data model`

**Location:** `lib/domain/entities/doctor_summary_data.dart`

**Test Location:** `test/unit/domain/entities/doctor_summary_data_test.dart`

**Git Commits:**
- (empty)

#### 4.2 GenerateDoctorPDF UseCase
- [ ] **TEST:** Write test for generating PDF with selected reports
- [ ] **CODE:** Create GenerateDoctorPDF usecase
- [ ] **TEST:** Write test for table structure (biomarkers × reports)
- [ ] **CODE:** Implement table layout
- [ ] **TEST:** Write test for highlighting out-of-range values
- [ ] **CODE:** Apply color/bold to out-of-range cells
- [ ] **TEST:** Write test for trend indicators (↑↓→)
- [ ] **CODE:** Add trend symbols with percentages
- [ ] **TEST:** Write test for summary section
- [ ] **CODE:** Add summary with key findings
- [ ] **TEST:** Write test for professional formatting
- [ ] **CODE:** Style PDF professionally (headers, footers, branding)
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for GenerateDoctorPDF usecase`
- [ ] **COMMIT:** `feat: implement doctor summary PDF generation`

**Location:** `lib/domain/usecases/generate_doctor_pdf.dart`

**Test Location:** `test/unit/domain/usecases/generate_doctor_pdf_test.dart`

**Git Commits:**
- (empty)

#### 4.3 PDF Generation Service
- [ ] **TEST:** Write test for PDF package integration
- [ ] **CODE:** Create PdfGeneratorService using pdf package
- [ ] **TEST:** Write test for table rendering
- [ ] **CODE:** Implement table widget
- [ ] **TEST:** Write test for custom styling
- [ ] **CODE:** Add custom fonts, colors, spacing
- [ ] **TEST:** Write test for multi-page PDFs
- [ ] **CODE:** Handle page breaks correctly
- [ ] **COMMIT:** `test: add tests for PdfGeneratorService`
- [ ] **COMMIT:** `feat: implement PDF generation service`

**Location:** `lib/data/datasources/external/pdf_generator_service.dart`

**Test Location:** `test/unit/data/datasources/external/pdf_generator_service_test.dart`

**Git Commits:**
- (empty)

#### 4.4 Report Selection UI
- [ ] **TEST:** Write widget test for ReportSelectionPage
- [ ] **CODE:** Create ReportSelectionPage
- [ ] **TEST:** Write test for multi-select checkboxes
- [ ] **CODE:** Implement report checkboxes
- [ ] **TEST:** Write test for generate button (enabled when >= 1 selected)
- [ ] **CODE:** Add generate button with validation
- [ ] **TEST:** Write test for PDF preview (optional)
- [ ] **CODE:** Add preview functionality
- [ ] **COMMIT:** `test: add widget tests for ReportSelectionPage`
- [ ] **COMMIT:** `feat: implement report selection for doctor PDF`

**Location:** `lib/presentation/pages/export/report_selection_page.dart`

**Test Location:** `test/widget/pages/export/report_selection_page_test.dart`

**Git Commits:**
- (empty)

#### 4.5 PDF Generation UI
- [ ] **TEST:** Write widget test for PDF generation flow
- [ ] **CODE:** Trigger PDF generation from selected reports
- [ ] **TEST:** Write test for progress indicator
- [ ] **CODE:** Show progress during generation
- [ ] **TEST:** Write test for success with file location
- [ ] **CODE:** Show success message
- [ ] **TEST:** Write test for error handling
- [ ] **CODE:** Display errors if generation fails
- [ ] **COMMIT:** `test: add widget tests for PDF generation UI`
- [ ] **COMMIT:** `feat: implement doctor PDF generation flow`

**Location:** `lib/presentation/pages/export/report_selection_page.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 5: Native Sharing (TDD)

### Tasks

#### 5.1 Share Service
- [ ] **TEST:** Write test for sharing files
- [ ] **CODE:** Create ShareService using share_plus
- [ ] **TEST:** Write test for sharing PDF
- [ ] **CODE:** Implement PDF sharing
- [ ] **TEST:** Write test for sharing CSV
- [ ] **CODE:** Implement CSV sharing
- [ ] **TEST:** Write test for platform-specific behavior
- [ ] **CODE:** Handle iOS/Android/Web differences
- [ ] **COMMIT:** `test: add tests for ShareService`
- [ ] **COMMIT:** `feat: implement native sharing service`

**Location:** `lib/data/datasources/external/share_service.dart`

**Test Location:** `test/unit/data/datasources/external/share_service_test.dart`

**Git Commits:**
- (empty)

#### 5.2 Share Button UI
- [ ] **TEST:** Write widget test for share button
- [ ] **CODE:** Add share button to ReportDetailPage
- [ ] **TEST:** Write test for share options (original PDF vs. doctor PDF)
- [ ] **CODE:** Show share options dialog
- [ ] **TEST:** Write test for share success
- [ ] **CODE:** Trigger native share sheet
- [ ] **COMMIT:** `test: add widget tests for share button`
- [ ] **COMMIT:** `feat: add share functionality to reports`

**Location:** `lib/presentation/pages/report_detail/report_detail_page.dart` (updated)

**Test Location:** `test/widget/pages/report_detail/report_detail_page_test.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 6: Routing & Navigation Updates

### Tasks

#### 6.1 Add Report Selection Route
- [ ] **CODE:** Add /export/select route to go_router
- [ ] **CODE:** Add navigation from HomePage/SettingsPage
- [ ] **COMMIT:** `feat: add report selection route`

**Location:** `lib/presentation/router.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 7: Export/Import Providers

### Tasks

#### 7.1 ExportProvider
- [ ] **TEST:** Write test for ExportProvider state
- [ ] **CODE:** Create ExportProvider with @riverpod
- [ ] **TEST:** Write test for export progress
- [ ] **CODE:** Track export progress
- [ ] **TEST:** Write test for export completion
- [ ] **CODE:** Handle completion state
- [ ] **COMMIT:** `test: add tests for ExportProvider`
- [ ] **COMMIT:** `feat: implement export state management`

**Location:** `lib/presentation/providers/export_provider.dart`

**Test Location:** `test/unit/presentation/providers/export_provider_test.dart`

**Git Commits:**
- (empty)

#### 7.2 BackupProvider
- [ ] **TEST:** Write test for BackupProvider state
- [ ] **CODE:** Create BackupProvider with @riverpod
- [ ] **TEST:** Write test for authentication state
- [ ] **CODE:** Track Google auth state
- [ ] **TEST:** Write test for backup progress
- [ ] **CODE:** Track backup/restore progress
- [ ] **TEST:** Write test for last backup timestamp
- [ ] **CODE:** Store and display last backup time
- [ ] **COMMIT:** `test: add tests for BackupProvider`
- [ ] **COMMIT:** `feat: implement backup state management`

**Location:** `lib/presentation/providers/backup_provider.dart`

**Test Location:** `test/unit/presentation/providers/backup_provider_test.dart`

**Git Commits:**
- (empty)

---

## Phase 5 Completion Checklist

- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] Overall coverage >= 90%
- [ ] No linting errors (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] All tasks above completed
- [ ] User can successfully:
  - [ ] Export all data to CSV
  - [ ] Import data from CSV
  - [ ] Backup to Google Drive
  - [ ] Restore from Google Drive
  - [ ] Select multiple reports
  - [ ] Generate professional doctor summary PDF
  - [ ] Share PDFs via native share sheet
  - [ ] Share CSV files
- [ ] Documentation updated:
  - [ ] overall-plan.md changelog updated
  - [ ] This task file marked complete
  - [ ] README.md with user guide (optional)
- [ ] Git commits follow conventional commits format
- [ ] All commits pushed to repository

---

## Status Summary

**Total Tasks:** ~75
**Completed:** 0
**In Progress:** 0
**Blocked:** 0

**Test Coverage:** 0%

**Last Updated:** 2025-10-15

---

## Notes

- Ensure Google Drive integration respects user privacy (no data sent without explicit action)
- Test PDF generation on different screen sizes and orientations
- Verify CSV format is compatible with Excel, Google Sheets
- Handle large datasets efficiently in CSV export
- Consider adding encryption for exported files (future enhancement)
