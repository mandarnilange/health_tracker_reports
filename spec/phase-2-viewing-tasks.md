# Phase 2: Reports Viewing & Filtering - Task List

**Phase Goal:** Enable users to browse all reports, view detailed biomarker information, and filter to see only out-of-range parameters.

**Status:** Not Started

**Start Date:** TBD

**Completion Date:** TBD

---

## Feature 1: Home Page - Reports List (TDD)

### Tasks

#### 1.1 HomePage Widget
- [ ] **TEST:** Write widget test for HomePage rendering
- [ ] **CODE:** Create HomePage widget
- [ ] **TEST:** Write test for AppBar with title
- [ ] **CODE:** Implement AppBar
- [ ] **TEST:** Write test for FloatingActionButton (add report)
- [ ] **CODE:** Implement FAB with navigation to /upload
- [ ] **TEST:** Write test for empty state when no reports
- [ ] **CODE:** Implement EmptyState widget
- [ ] **TEST:** Write test for loading state
- [ ] **CODE:** Implement loading indicator
- [ ] **TEST:** Write test for error state
- [ ] **CODE:** Implement error display
- [ ] **VERIFY:** Run widget tests, ensure coverage >= 85%
- [ ] **COMMIT:** `test: add widget tests for HomePage`
- [ ] **COMMIT:** `feat: implement HomePage with state handling`

**Location:** `lib/presentation/pages/home/home_page.dart`

**Test Location:** `test/widget/pages/home/home_page_test.dart`

**Git Commits:**
- (empty)

#### 1.2 ReportCard Widget
- [ ] **TEST:** Write widget test for ReportCard rendering report data
- [ ] **CODE:** Create ReportCard widget
- [ ] **TEST:** Write test for displaying date (formatted)
- [ ] **CODE:** Implement date formatting (e.g., "Oct 15, 2025")
- [ ] **TEST:** Write test for displaying lab name
- [ ] **CODE:** Implement lab name display
- [ ] **TEST:** Write test for "x/y out of range" summary
- [ ] **CODE:** Implement out-of-range summary chip/badge
- [ ] **TEST:** Write test for tap navigation to report detail
- [ ] **CODE:** Implement onTap navigation
- [ ] **TEST:** Write test for visual indicator (color) when parameters out of range
- [ ] **CODE:** Add conditional styling based on hasOutOfRange
- [ ] **VERIFY:** Run widget tests, ensure coverage >= 85%
- [ ] **COMMIT:** `test: add widget tests for ReportCard`
- [ ] **COMMIT:** `feat: implement ReportCard with summary and navigation`

**Location:** `lib/presentation/pages/home/widgets/report_card.dart`

**Test Location:** `test/widget/pages/home/widgets/report_card_test.dart`

**Git Commits:**
- (empty)

#### 1.3 EmptyState Widget
- [ ] **TEST:** Write widget test for EmptyState rendering
- [ ] **CODE:** Create EmptyState widget
- [ ] **TEST:** Write test for icon display
- [ ] **CODE:** Add appropriate icon (e.g., medical/document icon)
- [ ] **TEST:** Write test for message text
- [ ] **CODE:** Add message: "No reports yet. Upload your first blood report!"
- [ ] **TEST:** Write test for action button
- [ ] **CODE:** Add "Upload Report" button with navigation
- [ ] **COMMIT:** `test: add widget tests for EmptyState`
- [ ] **COMMIT:** `feat: implement EmptyState widget`

**Location:** `lib/presentation/pages/home/widgets/empty_state.dart`

**Test Location:** `test/widget/pages/home/widgets/empty_state_test.dart`

**Git Commits:**
- (empty)

---

## Feature 2: Report Detail Page (TDD)

### Tasks

#### 2.1 ReportDetailPage Widget
- [ ] **TEST:** Write widget test for ReportDetailPage rendering
- [ ] **CODE:** Create ReportDetailPage widget
- [ ] **TEST:** Write test for AppBar with report date as title
- [ ] **CODE:** Implement AppBar
- [ ] **TEST:** Write test for lab name display
- [ ] **CODE:** Implement lab name section
- [ ] **TEST:** Write test for summary card (x/y out of range)
- [ ] **CODE:** Implement summary card widget
- [ ] **TEST:** Write test for biomarkers list
- [ ] **CODE:** Implement biomarkers ListView
- [ ] **TEST:** Write test for loading state
- [ ] **CODE:** Implement loading indicator
- [ ] **TEST:** Write test for error state (report not found)
- [ ] **CODE:** Implement error handling
- [ ] **VERIFY:** Run widget tests, ensure coverage >= 85%
- [ ] **COMMIT:** `test: add widget tests for ReportDetailPage`
- [ ] **COMMIT:** `feat: implement ReportDetailPage structure`

**Location:** `lib/presentation/pages/report_detail/report_detail_page.dart`

**Test Location:** `test/widget/pages/report_detail/report_detail_page_test.dart`

**Git Commits:**
- (empty)

#### 2.2 BiomarkerListItem Widget
- [ ] **TEST:** Write widget test for BiomarkerListItem rendering
- [ ] **CODE:** Create BiomarkerListItem widget
- [ ] **TEST:** Write test for biomarker name display
- [ ] **CODE:** Implement name display
- [ ] **TEST:** Write test for value and unit display
- [ ] **CODE:** Implement value/unit display
- [ ] **TEST:** Write test for reference range display
- [ ] **CODE:** Implement reference range (e.g., "80-120 mg/dL")
- [ ] **TEST:** Write test for color coding (green/yellow/red)
- [ ] **CODE:** Implement status-based color coding
- [ ] **TEST:** Write test for low status indicator
- [ ] **CODE:** Add low indicator (down arrow/icon)
- [ ] **TEST:** Write test for high status indicator
- [ ] **CODE:** Add high indicator (up arrow/icon)
- [ ] **TEST:** Write test for normal status
- [ ] **CODE:** Style normal status
- [ ] **VERIFY:** Run widget tests, ensure coverage >= 85%
- [ ] **COMMIT:** `test: add widget tests for BiomarkerListItem`
- [ ] **COMMIT:** `feat: implement BiomarkerListItem with color coding`

**Location:** `lib/presentation/pages/report_detail/widgets/biomarker_list_item.dart`

**Test Location:** `test/widget/pages/report_detail/widgets/biomarker_list_item_test.dart`

**Git Commits:**
- (empty)

#### 2.3 OutOfRangeIndicator Widget
- [ ] **TEST:** Write widget test for OutOfRangeIndicator
- [ ] **CODE:** Create OutOfRangeIndicator widget
- [ ] **TEST:** Write test for displaying count
- [ ] **CODE:** Implement count display
- [ ] **TEST:** Write test for conditional rendering (show only if > 0)
- [ ] **CODE:** Add conditional logic
- [ ] **TEST:** Write test for styling (warning color)
- [ ] **CODE:** Apply Material Design warning colors
- [ ] **COMMIT:** `test: add widget tests for OutOfRangeIndicator`
- [ ] **COMMIT:** `feat: implement OutOfRangeIndicator widget`

**Location:** `lib/presentation/pages/report_detail/widgets/out_of_range_indicator.dart`

**Test Location:** `test/widget/pages/report_detail/widgets/out_of_range_indicator_test.dart`

**Git Commits:**
- (empty)

---

## Feature 3: Filtering Functionality (TDD)

### Tasks

#### 3.1 FilterProvider (Riverpod)
- [ ] **TEST:** Write test for FilterProvider initial state (showAll)
- [ ] **CODE:** Create FilterProvider with @riverpod
- [ ] **TEST:** Write test for toggling filter
- [ ] **CODE:** Implement toggleFilter method
- [ ] **TEST:** Write test for state persistence
- [ ] **CODE:** Ensure state persists during navigation
- [ ] **COMMIT:** `test: add tests for FilterProvider`
- [ ] **COMMIT:** `feat: implement FilterProvider for biomarker filtering`

**Location:** `lib/presentation/providers/filter_provider.dart`

**Test Location:** `test/unit/presentation/providers/filter_provider_test.dart`

**Git Commits:**
- (empty)

#### 3.2 FilteredBiomarkersProvider
- [ ] **TEST:** Write test for filtering all biomarkers
- [ ] **CODE:** Create FilteredBiomarkersProvider
- [ ] **TEST:** Write test for filtering only out-of-range
- [ ] **CODE:** Implement filtering logic
- [ ] **TEST:** Write test for empty result when all normal
- [ ] **CODE:** Handle empty state
- [ ] **COMMIT:** `test: add tests for FilteredBiomarkersProvider`
- [ ] **COMMIT:** `feat: implement biomarker filtering logic`

**Location:** `lib/presentation/providers/filter_provider.dart`

**Test Location:** `test/unit/presentation/providers/filter_provider_test.dart`

**Git Commits:**
- (empty)

#### 3.3 Filter Toggle UI
- [ ] **TEST:** Write widget test for filter toggle button
- [ ] **CODE:** Add filter toggle to ReportDetailPage AppBar
- [ ] **TEST:** Write test for toggle state changes
- [ ] **CODE:** Implement toggle functionality
- [ ] **TEST:** Write test for list updating when filter changes
- [ ] **CODE:** Connect to FilteredBiomarkersProvider
- [ ] **TEST:** Write test for toggle icon/label changes
- [ ] **CODE:** Implement visual feedback
- [ ] **COMMIT:** `test: add widget tests for filter toggle`
- [ ] **COMMIT:** `feat: add filter toggle to ReportDetailPage`

**Location:** `lib/presentation/pages/report_detail/report_detail_page.dart` (updated)

**Test Location:** `test/widget/pages/report_detail/report_detail_page_test.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 4: Search Functionality (TDD)

### Tasks

#### 4.1 Search UseCase
- [ ] **TEST:** Write test for searching biomarkers by name
- [ ] **CODE:** Create SearchBiomarkers usecase
- [ ] **TEST:** Write test for case-insensitive search
- [ ] **CODE:** Implement case-insensitive matching
- [ ] **TEST:** Write test for partial matching
- [ ] **CODE:** Implement partial string matching
- [ ] **TEST:** Write test for empty query (return all)
- [ ] **CODE:** Handle empty query
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for SearchBiomarkers usecase`
- [ ] **COMMIT:** `feat: implement biomarker search functionality`

**Location:** `lib/domain/usecases/search_biomarkers.dart`

**Test Location:** `test/unit/domain/usecases/search_biomarkers_test.dart`

**Git Commits:**
- (empty)

#### 4.2 Search Bar UI
- [ ] **TEST:** Write widget test for search bar rendering
- [ ] **CODE:** Add search TextField to ReportDetailPage
- [ ] **TEST:** Write test for search input changes
- [ ] **CODE:** Implement onChanged handler
- [ ] **TEST:** Write test for filtered results display
- [ ] **CODE:** Connect to search logic
- [ ] **TEST:** Write test for clear button
- [ ] **CODE:** Add clear button functionality
- [ ] **COMMIT:** `test: add widget tests for search bar`
- [ ] **COMMIT:** `feat: add search bar to ReportDetailPage`

**Location:** `lib/presentation/pages/report_detail/report_detail_page.dart` (updated)

**Test Location:** `test/widget/pages/report_detail/report_detail_page_test.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 5: Routing & Navigation (TDD)

### Tasks

#### 5.1 Router Updates
- [ ] **CODE:** Add /report/:id route to go_router
- [ ] **CODE:** Add navigation from ReportCard to ReportDetailPage
- [ ] **TEST:** Write test for route parameters
- [ ] **CODE:** Pass report ID via route params
- [ ] **TEST:** Write test for back navigation
- [ ] **CODE:** Ensure navigation stack works correctly
- [ ] **COMMIT:** `feat: add report detail route to go_router`

**Location:** `lib/presentation/router.dart` (updated)

**Test Location:** `test/unit/presentation/router_test.dart` (updated)

**Git Commits:**
- (empty)

#### 5.2 Deep Linking (Optional)
- [ ] **CODE:** Configure deep linking for reports
- [ ] **TEST:** Write test for deep link handling
- [ ] **CODE:** Verify deep links work on all platforms
- [ ] **COMMIT:** `feat: add deep linking support for reports`

**Location:** `lib/presentation/router.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 6: Additional UI Enhancements

### Tasks

#### 6.1 Pull-to-Refresh
- [ ] **TEST:** Write widget test for pull-to-refresh
- [ ] **CODE:** Add RefreshIndicator to HomePage
- [ ] **TEST:** Write test for refresh triggering data reload
- [ ] **CODE:** Implement refresh logic
- [ ] **COMMIT:** `test: add test for pull-to-refresh`
- [ ] **COMMIT:** `feat: add pull-to-refresh to HomePage`

**Location:** `lib/presentation/pages/home/home_page.dart` (updated)

**Test Location:** `test/widget/pages/home/home_page_test.dart` (updated)

**Git Commits:**
- (empty)

#### 6.2 Sorting Options
- [ ] **TEST:** Write test for sorting reports by date (newest first)
- [ ] **CODE:** Implement date sorting (default)
- [ ] **TEST:** Write test for sorting by date (oldest first)
- [ ] **CODE:** Add sort toggle
- [ ] **TEST:** Write test for sorting by most out-of-range
- [ ] **CODE:** Add additional sort options
- [ ] **COMMIT:** `test: add tests for report sorting`
- [ ] **COMMIT:** `feat: implement report sorting options`

**Location:** `lib/presentation/providers/report_providers.dart` (updated)

**Test Location:** `test/unit/presentation/providers/report_providers_test.dart` (updated)

**Git Commits:**
- (empty)

---

## Phase 2 Completion Checklist

- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] Overall coverage >= 90%
- [ ] No linting errors (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] All tasks above completed
- [ ] User can successfully:
  - [ ] View list of all reports
  - [ ] See out-of-range summary on each card
  - [ ] Navigate to report details
  - [ ] View all biomarkers with color coding
  - [ ] Filter to show only out-of-range biomarkers
  - [ ] Search for specific biomarkers
  - [ ] Pull to refresh reports list
- [ ] Documentation updated:
  - [ ] overall-plan.md changelog updated
  - [ ] This task file marked complete
- [ ] Git commits follow conventional commits format
- [ ] All commits pushed to repository

---

## Status Summary

**Total Tasks:** ~60
**Completed:** 0
**In Progress:** 0
**Blocked:** 0

**Test Coverage:** 0%

**Last Updated:** 2025-10-15

---

## Notes

- Maintain strict TDD discipline
- Focus on user experience and visual clarity
- Ensure color coding is accessible (consider colorblind users)
- Test on multiple screen sizes
- Update overall-plan.md changelog with each commit
