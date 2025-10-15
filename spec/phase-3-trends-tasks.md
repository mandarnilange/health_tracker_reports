# Phase 3: Biomarker Normalization & Trends - Task List

**Phase Goal:** Enable consistent biomarker tracking across reports and provide visual trend analysis over time.

**Status:** Not Started

**Start Date:** TBD

**Completion Date:** TBD

---

## Feature 1: Enhanced Normalization (TDD)

### Tasks

#### 1.1 Extended Normalization Dictionary
- [ ] **TEST:** Write tests for additional biomarker variations
- [ ] **CODE:** Expand normalization map in NormalizeBiomarkerName
- [ ] **TEST:** Write test for lipid panel variations
- [ ] **CODE:** Add lipid panel mappings
- [ ] **TEST:** Write test for liver function variations
- [ ] **CODE:** Add liver function mappings
- [ ] **TEST:** Write test for kidney function variations
- [ ] **CODE:** Add kidney function mappings
- [ ] **TEST:** Write test for diabetes markers
- [ ] **CODE:** Add diabetes marker mappings
- [ ] **TEST:** Write test for thyroid markers
- [ ] **CODE:** Add thyroid marker mappings
- [ ] **TEST:** Write test for vitamin mappings
- [ ] **CODE:** Add vitamin mappings
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for extended biomarker normalization`
- [ ] **COMMIT:** `feat: expand biomarker normalization dictionary`

**Location:** `lib/domain/usecases/normalize_biomarker_name.dart` (updated)

**Test Location:** `test/unit/domain/usecases/normalize_biomarker_name_test.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 2: Trend Data UseCase (TDD)

### Tasks

#### 2.1 GetBiomarkerTrend UseCase
- [ ] **TEST:** Write test for getting trend data for a biomarker
- [ ] **CODE:** Create GetBiomarkerTrend usecase
- [ ] **TEST:** Write test for filtering by date range
- [ ] **CODE:** Implement date range filtering
- [ ] **TEST:** Write test for sorting by date (chronological)
- [ ] **CODE:** Implement sorting
- [ ] **TEST:** Write test for normalizing biomarker name before query
- [ ] **CODE:** Apply normalization before searching
- [ ] **TEST:** Write test for empty result handling
- [ ] **CODE:** Handle case when biomarker not found
- [ ] **TEST:** Write test for failure propagation
- [ ] **CODE:** Add error handling
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for GetBiomarkerTrend usecase`
- [ ] **COMMIT:** `feat: implement biomarker trend retrieval`

**Location:** `lib/domain/usecases/get_biomarker_trend.dart`

**Test Location:** `test/unit/domain/usecases/get_biomarker_trend_test.dart`

**Git Commits:**
- (empty)

#### 2.2 Repository Support for Trends
- [ ] **TEST:** Write test for getBiomarkerTrend in ReportRepository
- [ ] **CODE:** Add getBiomarkerTrend method to ReportRepository interface
- [ ] **TEST:** Write test for implementation in ReportRepositoryImpl
- [ ] **CODE:** Implement getBiomarkerTrend in ReportRepositoryImpl
- [ ] **TEST:** Write test for querying across multiple reports
- [ ] **CODE:** Implement cross-report querying
- [ ] **TEST:** Write test for error handling
- [ ] **CODE:** Add error handling
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for repository trend support`
- [ ] **COMMIT:** `feat: add trend querying to ReportRepository`

**Location:** `lib/domain/repositories/report_repository.dart` (updated)
`lib/data/repositories/report_repository_impl.dart` (updated)

**Test Location:** `test/unit/data/repositories/report_repository_impl_test.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 3: Trends Page UI (TDD)

### Tasks

#### 3.1 TrendsPage Widget
- [ ] **TEST:** Write widget test for TrendsPage rendering
- [ ] **CODE:** Create TrendsPage widget
- [ ] **TEST:** Write test for biomarker selector
- [ ] **CODE:** Implement biomarker dropdown/selector
- [ ] **TEST:** Write test for time range selector
- [ ] **CODE:** Implement time range buttons (3M, 6M, 1Y, All)
- [ ] **TEST:** Write test for chart rendering
- [ ] **CODE:** Implement chart container
- [ ] **TEST:** Write test for loading state
- [ ] **CODE:** Implement loading indicator
- [ ] **TEST:** Write test for empty state (no data)
- [ ] **CODE:** Implement empty state message
- [ ] **TEST:** Write test for error state
- [ ] **CODE:** Implement error display
- [ ] **VERIFY:** Run widget tests, ensure coverage >= 85%
- [ ] **COMMIT:** `test: add widget tests for TrendsPage`
- [ ] **COMMIT:** `feat: implement TrendsPage structure`

**Location:** `lib/presentation/pages/trends/trends_page.dart`

**Test Location:** `test/widget/pages/trends/trends_page_test.dart`

**Git Commits:**
- (empty)

#### 3.2 BiomarkerSelector Widget
- [ ] **TEST:** Write widget test for BiomarkerSelector
- [ ] **CODE:** Create BiomarkerSelector dropdown widget
- [ ] **TEST:** Write test for displaying all available biomarkers
- [ ] **CODE:** Implement biomarker list generation
- [ ] **TEST:** Write test for selection callback
- [ ] **CODE:** Implement onChanged callback
- [ ] **TEST:** Write test for grouping by category (optional)
- [ ] **CODE:** Implement category grouping
- [ ] **COMMIT:** `test: add widget tests for BiomarkerSelector`
- [ ] **COMMIT:** `feat: implement BiomarkerSelector dropdown`

**Location:** `lib/presentation/pages/trends/widgets/biomarker_selector.dart`

**Test Location:** `test/widget/pages/trends/widgets/biomarker_selector_test.dart`

**Git Commits:**
- (empty)

#### 3.3 TimeRangeSelector Widget
- [ ] **TEST:** Write widget test for TimeRangeSelector
- [ ] **CODE:** Create TimeRangeSelector with button chips
- [ ] **TEST:** Write test for 3M button
- [ ] **CODE:** Implement 3 months button
- [ ] **TEST:** Write test for 6M button
- [ ] **CODE:** Implement 6 months button
- [ ] **TEST:** Write test for 1Y button
- [ ] **CODE:** Implement 1 year button
- [ ] **TEST:** Write test for All button
- [ ] **CODE:** Implement all time button
- [ ] **TEST:** Write test for selection state
- [ ] **CODE:** Highlight selected range
- [ ] **COMMIT:** `test: add widget tests for TimeRangeSelector`
- [ ] **COMMIT:** `feat: implement TimeRangeSelector widget`

**Location:** `lib/presentation/pages/trends/widgets/time_range_selector.dart`

**Test Location:** `test/widget/pages/trends/widgets/time_range_selector_test.dart`

**Git Commits:**
- (empty)

---

## Feature 4: Chart Implementation (TDD)

### Tasks

#### 4.1 TrendChart Widget with fl_chart
- [ ] **TEST:** Write widget test for TrendChart rendering
- [ ] **CODE:** Create TrendChart widget using fl_chart
- [ ] **TEST:** Write test for line chart data points
- [ ] **CODE:** Implement LineChart with biomarker data
- [ ] **TEST:** Write test for reference range bands
- [ ] **CODE:** Add background shaded area for reference range
- [ ] **TEST:** Write test for x-axis (dates)
- [ ] **CODE:** Implement date formatting on x-axis
- [ ] **TEST:** Write test for y-axis (values)
- [ ] **CODE:** Implement value scaling on y-axis
- [ ] **TEST:** Write test for tooltips on data points
- [ ] **CODE:** Implement interactive tooltips
- [ ] **TEST:** Write test for color coding (out of range points highlighted)
- [ ] **CODE:** Apply different colors to out-of-range points
- [ ] **VERIFY:** Run widget tests, ensure coverage >= 85%
- [ ] **COMMIT:** `test: add widget tests for TrendChart`
- [ ] **COMMIT:** `feat: implement TrendChart with fl_chart`

**Location:** `lib/presentation/pages/trends/widgets/trend_chart.dart`

**Test Location:** `test/widget/pages/trends/widgets/trend_chart_test.dart`

**Git Commits:**
- (empty)

#### 4.2 Chart Data Transformation
- [ ] **TEST:** Write test for transforming biomarker data to chart data
- [ ] **CODE:** Create helper function for data transformation
- [ ] **TEST:** Write test for handling missing data points
- [ ] **CODE:** Handle gaps in timeline
- [ ] **TEST:** Write test for date formatting
- [ ] **CODE:** Format dates for x-axis labels
- [ ] **COMMIT:** `test: add tests for chart data transformation`
- [ ] **COMMIT:** `feat: implement chart data transformation helpers`

**Location:** `lib/presentation/pages/trends/widgets/trend_chart.dart` (helpers)

**Test Location:** `test/unit/presentation/pages/trends/trend_chart_test.dart`

**Git Commits:**
- (empty)

---

## Feature 5: Trend Analysis (TDD)

### Tasks

#### 5.1 Calculate Trend UseCase
- [ ] **TEST:** Write test for calculating trend direction (up/down/stable)
- [ ] **CODE:** Create CalculateTrend usecase
- [ ] **TEST:** Write test for calculating percentage change
- [ ] **CODE:** Implement percentage change calculation
- [ ] **TEST:** Write test for trend over time period
- [ ] **CODE:** Implement time-based trend analysis
- [ ] **TEST:** Write test for insufficient data handling
- [ ] **CODE:** Handle case with < 2 data points
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for CalculateTrend usecase`
- [ ] **COMMIT:** `feat: implement trend calculation logic`

**Location:** `lib/domain/usecases/calculate_trend.dart`

**Test Location:** `test/unit/domain/usecases/calculate_trend_test.dart`

**Git Commits:**
- (empty)

#### 5.2 Trend Indicator Widget
- [ ] **TEST:** Write widget test for TrendIndicator
- [ ] **CODE:** Create TrendIndicator widget
- [ ] **TEST:** Write test for up arrow (increasing trend)
- [ ] **CODE:** Implement up arrow with red color
- [ ] **TEST:** Write test for down arrow (decreasing trend)
- [ ] **CODE:** Implement down arrow with color based on biomarker context
- [ ] **TEST:** Write test for stable indicator
- [ ] **CODE:** Implement stable/neutral indicator
- [ ] **TEST:** Write test for percentage display
- [ ] **CODE:** Display percentage change
- [ ] **COMMIT:** `test: add widget tests for TrendIndicator`
- [ ] **COMMIT:** `feat: implement TrendIndicator widget`

**Location:** `lib/presentation/widgets/trend_indicator.dart`

**Test Location:** `test/widget/widgets/trend_indicator_test.dart`

**Git Commits:**
- (empty)

#### 5.3 Integrate Trend Indicator into UI
- [ ] **CODE:** Add TrendIndicator to BiomarkerListItem
- [ ] **CODE:** Add TrendIndicator to TrendsPage summary
- [ ] **TEST:** Write widget test for integration
- [ ] **CODE:** Verify indicators display correctly
- [ ] **COMMIT:** `feat: integrate trend indicators into UI`

**Location:** Multiple locations (updated)

**Git Commits:**
- (empty)

---

## Feature 6: Multi-Report Comparison (TDD)

### Tasks

#### 6.1 Comparison View UseCase
- [ ] **TEST:** Write test for comparing biomarker across selected reports
- [ ] **CODE:** Create CompareBiomarkerAcrossReports usecase
- [ ] **TEST:** Write test for side-by-side comparison data
- [ ] **CODE:** Implement comparison logic
- [ ] **TEST:** Write test for highlighting changes
- [ ] **CODE:** Calculate deltas between reports
- [ ] **VERIFY:** Run tests, ensure coverage >= 90%
- [ ] **COMMIT:** `test: add tests for comparison usecase`
- [ ] **COMMIT:** `feat: implement multi-report comparison logic`

**Location:** `lib/domain/usecases/compare_biomarker_across_reports.dart`

**Test Location:** `test/unit/domain/usecases/compare_biomarker_across_reports_test.dart`

**Git Commits:**
- (empty)

#### 6.2 Comparison View UI
- [ ] **TEST:** Write widget test for ComparisonView
- [ ] **CODE:** Create ComparisonView widget/page
- [ ] **TEST:** Write test for report selector (checkboxes)
- [ ] **CODE:** Implement multi-select for reports
- [ ] **TEST:** Write test for comparison table
- [ ] **CODE:** Implement table showing biomarkers across selected reports
- [ ] **TEST:** Write test for highlighting differences
- [ ] **CODE:** Add visual highlights for changes
- [ ] **COMMIT:** `test: add widget tests for ComparisonView`
- [ ] **COMMIT:** `feat: implement multi-report comparison view`

**Location:** `lib/presentation/pages/trends/comparison_view.dart`

**Test Location:** `test/widget/pages/trends/comparison_view_test.dart`

**Git Commits:**
- (empty)

---

## Feature 7: Routing & Navigation Updates

### Tasks

#### 7.1 Add Trends Route
- [ ] **CODE:** Add /trends route to go_router
- [ ] **CODE:** Add navigation from HomePage to TrendsPage
- [ ] **TEST:** Write test for navigation
- [ ] **CODE:** Verify navigation works
- [ ] **COMMIT:** `feat: add trends route to navigation`

**Location:** `lib/presentation/router.dart` (updated)

**Test Location:** `test/unit/presentation/router_test.dart` (updated)

**Git Commits:**
- (empty)

#### 7.2 Add Comparison Route
- [ ] **CODE:** Add /trends/comparison route
- [ ] **CODE:** Add navigation from TrendsPage to ComparisonView
- [ ] **TEST:** Write test for route parameters (selected reports)
- [ ] **CODE:** Pass selected report IDs
- [ ] **COMMIT:** `feat: add comparison route`

**Location:** `lib/presentation/router.dart` (updated)

**Git Commits:**
- (empty)

---

## Feature 8: Providers for Trends (TDD)

### Tasks

#### 8.1 TrendProvider
- [ ] **TEST:** Write test for TrendProvider state management
- [ ] **CODE:** Create TrendProvider with @riverpod
- [ ] **TEST:** Write test for selected biomarker
- [ ] **CODE:** Implement biomarker selection state
- [ ] **TEST:** Write test for selected time range
- [ ] **CODE:** Implement time range selection state
- [ ] **TEST:** Write test for fetching trend data
- [ ] **CODE:** Implement trend data fetching
- [ ] **COMMIT:** `test: add tests for TrendProvider`
- [ ] **COMMIT:** `feat: implement TrendProvider for trend state`

**Location:** `lib/presentation/providers/trend_provider.dart`

**Test Location:** `test/unit/presentation/providers/trend_provider_test.dart`

**Git Commits:**
- (empty)

---

## Phase 3 Completion Checklist

- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] Overall coverage >= 90%
- [ ] No linting errors (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] All tasks above completed
- [ ] User can successfully:
  - [ ] View trends for any biomarker
  - [ ] Select time ranges (3M, 6M, 1Y, All)
  - [ ] See reference range bands on charts
  - [ ] View trend indicators (↑↓→)
  - [ ] Compare biomarkers across multiple reports
  - [ ] Navigate to/from trends page
- [ ] Documentation updated:
  - [ ] overall-plan.md changelog updated
  - [ ] This task file marked complete
- [ ] Git commits follow conventional commits format
- [ ] All commits pushed to repository

---

## Status Summary

**Total Tasks:** ~70
**Completed:** 0
**In Progress:** 0
**Blocked:** 0

**Test Coverage:** 0%

**Last Updated:** 2025-10-15

---

## Notes

- Ensure charts are performant with many data points
- Consider accessibility for chart interactions
- Test on different screen sizes
- Normalize biomarker names consistently across all features
